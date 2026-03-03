# Graph Query Templates

每個模板都是完整 JS IIFE，用 `{{PARAM}}` 佔位符。Agent 代入參數後寫到 `/tmp/obsidian_graph_query.js` 執行。

所有模板共用排除邏輯：`EXCLUDED_PREFIXES` 過濾系統資料夾。

> **`{{EXCLUDED_FOLDERS}}` 和 `{{RELATIONSHIP_FIELDS}}`** 從 `vault-config.md` 讀取，Agent 執行前代入。

---

## 1. neighbors — N 層鄰居（BFS）

**參數**：`{{NOTE_PATH}}`（完整路徑）、`{{MAX_HOPS}}`（預設 2）

```javascript
(() => {
  const NOTE = '{{NOTE_PATH}}';
  const MAX_HOPS = {{MAX_HOPS}};
  const EXCLUDED = {{EXCLUDED_FOLDERS}};
  const isExcluded = p => EXCLUDED.some(e => p.startsWith(e));

  const rl = app.metadataCache.resolvedLinks;
  const adj = {};
  for (const [src, targets] of Object.entries(rl)) {
    if (isExcluded(src)) continue;
    for (const tgt of Object.keys(targets)) {
      if (isExcluded(tgt)) continue;
      if (!adj[src]) adj[src] = new Set();
      if (!adj[tgt]) adj[tgt] = new Set();
      adj[src].add(tgt);
      adj[tgt].add(src);
    }
  }

  const visited = new Map();
  visited.set(NOTE, 0);
  const queue = [NOTE];
  let qi = 0;

  while (qi < queue.length) {
    const node = queue[qi++];
    const hop = visited.get(node);
    if (hop >= MAX_HOPS) continue;
    for (const nb of (adj[node] || [])) {
      if (!visited.has(nb)) {
        visited.set(nb, hop + 1);
        queue.push(nb);
      }
    }
  }

  const MAX_DETAIL = 50;
  const byHop = {};
  for (const [node, hop] of visited.entries()) {
    if (node === NOTE) continue;
    const h = String(hop);
    if (!byHop[h]) byHop[h] = [];
    byHop[h].push(node);
  }

  const total = visited.size - 1;
  let truncated = false;

  if (total > MAX_DETAIL) {
    truncated = true;
    let cumulative = 0;
    for (let h = 1; h <= MAX_HOPS; h++) {
      const key = String(h);
      if (!byHop[key]) continue;
      cumulative += byHop[key].length;
      if (cumulative > MAX_DETAIL) {
        byHop[key] = { count: byHop[key].length, notes: '(truncated)' };
      }
    }
  }

  return JSON.stringify({
    source: NOTE,
    maxHops: MAX_HOPS,
    neighbors: byHop,
    total: total,
    truncated: truncated
  });
})()
```

**輸出範例**：
```json
{
  "source": "notes/某筆記.md",
  "maxHops": 2,
  "neighbors": {
    "1": ["notes/A.md", "notes/B.md"],
    "2": ["notes/C.md"]
  },
  "total": 3
}
```

---

## 2. path — 最短路徑（BFS）

**參數**：`{{FROM_PATH}}`、`{{TO_PATH}}`（完整路徑）

```javascript
(() => {
  const FROM = '{{FROM_PATH}}';
  const TO = '{{TO_PATH}}';
  const EXCLUDED = {{EXCLUDED_FOLDERS}};
  const isExcluded = p => EXCLUDED.some(e => p.startsWith(e));

  const rl = app.metadataCache.resolvedLinks;
  const adj = {};
  for (const [src, targets] of Object.entries(rl)) {
    if (isExcluded(src)) continue;
    for (const tgt of Object.keys(targets)) {
      if (isExcluded(tgt)) continue;
      if (!adj[src]) adj[src] = new Set();
      if (!adj[tgt]) adj[tgt] = new Set();
      adj[src].add(tgt);
      adj[tgt].add(src);
    }
  }

  const fromExists = adj[FROM] !== undefined;
  const toExists = adj[TO] !== undefined;
  if (!fromExists || !toExists) {
    return JSON.stringify({
      from: FROM, to: TO, found: false, path: [], hops: -1,
      error: !fromExists ? 'source_not_in_graph' : 'target_not_in_graph'
    });
  }

  const parent = new Map();
  parent.set(FROM, null);
  const queue = [FROM];
  let qi = 0;
  let found = false;

  while (qi < queue.length) {
    const node = queue[qi++];
    if (node === TO) { found = true; break; }
    for (const nb of (adj[node] || [])) {
      if (!parent.has(nb)) {
        parent.set(nb, node);
        queue.push(nb);
      }
    }
  }

  if (!found) {
    return JSON.stringify({ from: FROM, to: TO, found: false, path: [], hops: -1, error: 'no_path' });
  }

  const path = [];
  let cur = TO;
  while (cur !== null) {
    path.unshift(cur);
    cur = parent.get(cur);
  }

  return JSON.stringify({
    from: FROM,
    to: TO,
    found: true,
    path: path,
    hops: path.length - 1
  });
})()
```

---

## 3. cluster — 連通子圖（DFS）

**參數**：`{{NOTE_PATH}}`（完整路徑）

超過 500 節點時自動切換為資料夾計數模式（安全閥）。

```javascript
(() => {
  const NOTE = '{{NOTE_PATH}}';
  const MAX_DISPLAY = 500;
  const EXCLUDED = {{EXCLUDED_FOLDERS}};
  const isExcluded = p => EXCLUDED.some(e => p.startsWith(e));

  const rl = app.metadataCache.resolvedLinks;
  const adj = {};
  for (const [src, targets] of Object.entries(rl)) {
    if (isExcluded(src)) continue;
    for (const tgt of Object.keys(targets)) {
      if (isExcluded(tgt)) continue;
      if (!adj[src]) adj[src] = new Set();
      if (!adj[tgt]) adj[tgt] = new Set();
      adj[src].add(tgt);
      adj[tgt].add(src);
    }
  }

  const component = new Set();
  const stack = [NOTE];

  while (stack.length > 0) {
    const node = stack.pop();
    if (component.has(node)) continue;
    component.add(node);
    for (const nb of (adj[node] || [])) {
      if (!component.has(nb)) stack.push(nb);
    }
  }

  const byFolder = {};
  for (const p of component) {
    const folder = p.includes('/') ? p.substring(0, p.lastIndexOf('/')) : '(root)';
    if (!byFolder[folder]) byFolder[folder] = [];
    byFolder[folder].push(p);
  }

  const total = component.size;

  if (total > MAX_DISPLAY) {
    const folderCounts = {};
    for (const [f, files] of Object.entries(byFolder)) {
      folderCounts[f] = files.length;
    }
    return JSON.stringify({
      source: NOTE,
      total: total,
      truncated: true,
      folderCounts: folderCounts
    });
  }

  return JSON.stringify({
    source: NOTE,
    total: total,
    truncated: false,
    byFolder: byFolder
  });
})()
```

---

## 4. bridges — 橋接邊與關鍵節點（Iterative Tarjan）

**參數**：無（全 vault 分析）

使用 iterative 版本的 Tarjan 演算法，避免 2,000+ 節點時 V8 遞迴 stack overflow。
同時輸出 bridge edges（橋接邊）和 articulation points（關鍵節點）。

```javascript
(() => {
  const EXCLUDED = {{EXCLUDED_FOLDERS}};
  const isExcluded = p => EXCLUDED.some(e => p.startsWith(e));

  const rl = app.metadataCache.resolvedLinks;

  // Build undirected adjacency with dedup
  const adjSet = {};
  for (const [src, targets] of Object.entries(rl)) {
    if (isExcluded(src)) continue;
    if (!adjSet[src]) adjSet[src] = new Set();
    for (const tgt of Object.keys(targets)) {
      if (isExcluded(tgt)) continue;
      if (!adjSet[tgt]) adjSet[tgt] = new Set();
      adjSet[src].add(tgt);
      adjSet[tgt].add(src);
    }
  }

  const nodes = Object.keys(adjSet);
  const adjArr = {};
  for (const n of nodes) {
    adjArr[n] = [...adjSet[n]];
  }

  // Iterative Tarjan: bridge + articulation point finding
  const disc = {};
  const low = {};
  let timer = 0;
  const bridges = [];
  const artPoints = new Set();

  for (const start of nodes) {
    if (disc[start] !== undefined) continue;

    // Stack frame: [node, parent, neighborIndex, dfsChildCount]
    disc[start] = low[start] = timer++;
    const stack = [[start, null, 0, 0]];

    while (stack.length > 0) {
      const frame = stack[stack.length - 1];
      const node = frame[0];
      const parent = frame[1];
      const neighbors = adjArr[node] || [];

      if (frame[2] < neighbors.length) {
        const nb = neighbors[frame[2]];
        frame[2]++;

        if (disc[nb] === undefined) {
          disc[nb] = low[nb] = timer++;
          frame[3]++;
          stack.push([nb, node, 0, 0]);
        } else if (nb !== parent) {
          low[node] = Math.min(low[node], disc[nb]);
        }
      } else {
        stack.pop();
        if (parent !== null) {
          low[parent] = Math.min(low[parent], low[node]);

          // Bridge: removing edge disconnects graph
          if (low[node] > disc[parent]) {
            bridges.push([parent, node]);
          }

          // Articulation point (non-root): child cannot reach above parent
          if (low[node] >= disc[parent]) {
            artPoints.add(parent);
          }
        } else {
          // Root: articulation point if >1 DFS children
          if (frame[3] > 1) {
            artPoints.add(node);
          }
        }
      }
    }
  }

  // Sort articulation points by degree (most connected first)
  const apSorted = [...artPoints].map(n => ({
    note: n,
    degree: (adjArr[n] || []).length
  })).sort((a, b) => b.degree - a.degree);

  // Summary: bridges by folder
  const bridgesByFolder = {};
  for (const [a, b] of bridges) {
    const fa = a.includes('/') ? a.substring(0, a.indexOf('/')) : '(root)';
    const fb = b.includes('/') ? b.substring(0, b.indexOf('/')) : '(root)';
    bridgesByFolder[fa] = (bridgesByFolder[fa] || 0) + 1;
    if (fa !== fb) bridgesByFolder[fb] = (bridgesByFolder[fb] || 0) + 1;
  }

  return JSON.stringify({
    bridgeEdges: bridges.slice(0, 50),
    totalBridges: bridges.length,
    bridgesByFolder: bridgesByFolder,
    articulationPoints: apSorted.slice(0, 30),
    totalArticulationPoints: artPoints.size,
    totalNodes: nodes.length
  });
})()
```

**輸出說明**：
- `bridgeEdges`：移除後會斷開圖的邊（最多顯示 50 條）
- `articulationPoints`：移除後會斷開圖的節點，按連結度排序（最多 30 個）
- 高 degree 的 articulation point = 知識圖譜的關鍵樞紐

---

## 5. hubs — Top N 連結度（度數計算）

**參數**：`{{TOP_N}}`（預設 20）、`{{FOLDER_FILTER}}`（可選，空字串表示不篩選）

```javascript
(() => {
  const TOP_N = {{TOP_N}};
  const FOLDER_FILTER = '{{FOLDER_FILTER}}';
  const EXCLUDED = {{EXCLUDED_FOLDERS}};
  const isExcluded = p => EXCLUDED.some(e => p.startsWith(e));

  const rl = app.metadataCache.resolvedLinks;

  const outDeg = {};
  const inDeg = {};

  for (const [src, targets] of Object.entries(rl)) {
    if (isExcluded(src)) continue;
    const tgts = Object.keys(targets).filter(t => !isExcluded(t));
    outDeg[src] = (outDeg[src] || 0) + tgts.length;
    for (const tgt of tgts) {
      inDeg[tgt] = (inDeg[tgt] || 0) + 1;
    }
  }

  const allNodes = new Set([...Object.keys(outDeg), ...Object.keys(inDeg)]);
  let nodes = [...allNodes].map(n => ({
    note: n,
    inDegree: inDeg[n] || 0,
    outDegree: outDeg[n] || 0,
    total: (inDeg[n] || 0) + (outDeg[n] || 0)
  }));

  if (FOLDER_FILTER) {
    nodes = nodes.filter(n => n.note.startsWith(FOLDER_FILTER));
  }

  nodes.sort((a, b) => b.total - a.total);

  return JSON.stringify({
    folderFilter: FOLDER_FILTER || null,
    topN: TOP_N,
    totalNodes: nodes.length,
    hubs: nodes.slice(0, TOP_N)
  });
})()
```

---

## 6. orphans-rich — 孤立筆記 + Frontmatter

**參數**：`{{FOLDER_FILTER}}`（可選，空字串表示不篩選）

找出沒有任何連入/連出的筆記，並附帶 frontmatter 資訊供分析。最多回傳 100 筆。

> **注意**：本查詢的「孤立」定義為**無任何連入且無任何連出**，比 obsidian-cli `orphans`（僅查無 backlinks）更嚴格。

```javascript
(() => {
  const FOLDER_FILTER = '{{FOLDER_FILTER}}';
  const EXCLUDED = {{EXCLUDED_FOLDERS}};
  const isExcluded = p => EXCLUDED.some(e => p.startsWith(e));

  const rl = app.metadataCache.resolvedLinks;

  const hasOutgoing = new Set();
  const hasIncoming = new Set();

  for (const [src, targets] of Object.entries(rl)) {
    if (isExcluded(src)) continue;
    const tgts = Object.keys(targets).filter(t => !isExcluded(t));
    if (tgts.length > 0) hasOutgoing.add(src);
    for (const tgt of tgts) {
      hasIncoming.add(tgt);
    }
  }

  const allFiles = app.vault.getMarkdownFiles();

  const orphans = [];
  for (const file of allFiles) {
    if (isExcluded(file.path)) continue;
    if (FOLDER_FILTER && !file.path.startsWith(FOLDER_FILTER)) continue;
    if (!hasOutgoing.has(file.path) && !hasIncoming.has(file.path)) {
      const cache = app.metadataCache.getFileCache(file);
      const fm = (cache && cache.frontmatter) ? { ...cache.frontmatter } : {};
      delete fm.position;
      orphans.push({
        path: file.path,
        size: file.stat.size,
        created: file.stat.ctime,
        modified: file.stat.mtime,
        frontmatter: fm
      });
    }
  }

  orphans.sort((a, b) => b.modified - a.modified);

  return JSON.stringify({
    folderFilter: FOLDER_FILTER || null,
    total: orphans.length,
    orphans: orphans.slice(0, 100)
  });
})()
```

---

## 7. frontmatter-relations — 關係欄位擷取（relationship-summary 輔助）

**參數**：`{{NOTE_PATH}}`（完整路徑）

擷取指定筆記的 frontmatter 關係欄位及連結統計。用於 relationship-summary 工作流的第一步。

```javascript
(() => {
  const NOTE = '{{NOTE_PATH}}';
  const REL_FIELDS = {{RELATIONSHIP_FIELDS}};

  const file = app.vault.getAbstractFileByPath(NOTE);
  if (!file) return JSON.stringify({ error: 'File not found: ' + NOTE });

  const cache = app.metadataCache.getFileCache(file);
  const fm = (cache && cache.frontmatter) ? cache.frontmatter : {};

  const relations = {};
  for (const field of REL_FIELDS) {
    if (fm[field] !== undefined && fm[field] !== null) {
      let val = fm[field];
      if (!Array.isArray(val)) val = [val];
      relations[field] = val.map(v => {
        const match = String(v).match(/\[\[([^\]|]+)/);
        return match ? match[1] : String(v);
      });
    }
  }

  const rl = app.metadataCache.resolvedLinks;
  const outgoing = Object.keys(rl[NOTE] || {});

  const incoming = [];
  for (const [src, targets] of Object.entries(rl)) {
    if (targets[NOTE]) incoming.push(src);
  }

  return JSON.stringify({
    note: NOTE,
    frontmatterRelations: relations,
    outgoingLinks: outgoing,
    incomingLinks: incoming,
    totalOutgoing: outgoing.length,
    totalIncoming: incoming.length
  });
})()
```
