---
name: obsidian-graph-query
description: >-
  Run graph queries on Obsidian vault link structure: neighbors (N hops),
  shortest path, connected clusters, hub notes, bridge/articulation points,
  enriched orphans, relationship summaries, vault-wide statistics.
  Supports configurable frontmatter relationship fields. Use for:
  knowledge graph, note relationships, graph query, link analysis,
  note connections, hub notes, cluster analysis, bridge notes,
  relationship summary, vault stats, find path between notes,
  analyze connections, show orphans, 筆記關係, 連結分析, 孤立筆記,
  知識圖譜, 樞紐筆記, vault 統計.
---

# Obsidian Graph Query

在 Obsidian vault 的連結結構上執行圖查詢。底層資料來自 `app.metadataCache.resolvedLinks`（完整鄰接表），透過 JS eval 執行圖演算法。

---

## 前置條件

執行任何查詢前：

1. 讀取 `references/vault-config.md` 取得：
   - `<CLI>`：Obsidian CLI 可執行檔路徑
   - `<VAULT>`：vault 名稱（用於 `vault=` 參數）
   - `EXCLUDED_FOLDERS`：排除資料夾列表（JSON 陣列）
   - `RELATIONSHIP_FIELDS`：關係欄位列表（JSON 陣列）
2. 確認 Obsidian 正在執行中
3. 若 `vault-config.md` 不存在，提示用戶從 `vault-config.md.template` 複製並填寫

---

## 查詢選擇指引

根據使用者的問題類型選擇查詢：

```
使用者問題
├─ 「這篇筆記周圍有什麼？」          → neighbors
├─ 「A 和 B 怎麼連在一起？」         → path
├─ 「這篇筆記能觸及多少筆記？」       → cluster
├─ 「哪些筆記最重要？」              → hubs
├─ 「哪些筆記是孤立的？」            → orphans-rich
├─ 「知識圖譜的結構弱點在哪？」       → bridges
├─ 「這篇筆記和鄰居是什麼關係？」     → relationship-summary
└─ 「vault 整體狀況如何？」          → vault-stats
```

---

## 查詢索引

| # | 查詢名稱 | 用途 | 參數 | 模板位置 |
|---|----------|------|------|----------|
| 1 | **neighbors** | 找 N 層鄰居 | `NOTE_PATH`, `MAX_HOPS`=2 | query-templates.md §1 |
| 2 | **path** | 兩筆記間最短路徑 | `FROM_PATH`, `TO_PATH` | query-templates.md §2 |
| 3 | **cluster** | 連通子圖（所有可達筆記） | `NOTE_PATH` | query-templates.md §3 |
| 4 | **bridges** | 橋接邊 + 關鍵節點 | 無 | query-templates.md §4 |
| 5 | **hubs** | Top N 連結度 | `TOP_N`=20, `FOLDER_FILTER`='' | query-templates.md §5 |
| 6 | **orphans-rich** | 孤立筆記 + frontmatter | `FOLDER_FILTER`='' | query-templates.md §6 |
| 7 | **frontmatter-relations** | 關係欄位擷取 | `NOTE_PATH` | query-templates.md §7 |
| 8 | **vault-stats** | Vault 全域統計 | 無 | query-templates.md §8 |

relationship-summary 不是單一模板，而是多步驟 Agent 工作流（見下方）。

---

## 執行模式

### 步驟

1. **讀取設定**：從 `references/vault-config.md` 讀取 CLI 路徑、vault 名稱、排除資料夾、關係欄位
2. **讀取模板**：從 `references/query-templates.md` 讀取對應 JS 模板
3. **代入參數**：
   - 將 `{{EXCLUDED_FOLDERS}}` 替換為 vault-config.md 中的排除資料夾 JSON 陣列
   - 將 `{{RELATIONSHIP_FIELDS}}` 替換為 vault-config.md 中的關係欄位 JSON 陣列
   - 將其他 `{{PARAM}}` 佔位符替換為用戶提供的值
4. **寫入暫存檔**：用 Write 工具寫到 `/tmp/obsidian_graph_query.js`
5. **執行**：用 Bash 工具執行：
   ```bash
   <CLI> vault="<VAULT>" eval code='eval(require("fs").readFileSync("C:/tmp/obsidian_graph_query.js","utf8"))'
   ```
   > Windows 路徑：Write 工具用 `/tmp/...`，eval 中用 `C:/tmp/...`
   > macOS/Linux：兩者都用 `/tmp/...`
6. **解析**：輸出為 JSON 字串，解析後轉為 Markdown 呈現

---

## 筆記名稱解析

用戶通常只給部分名稱（如「那篇關於 BFS 的筆記」）。解析流程：

1. 用 Obsidian CLI 的 `search` 指令搜尋：
   ```bash
   <CLI> vault="<VAULT>" search query="BFS" limit=5
   ```
2. 從結果中取得完整路徑（如 `notes/演算法/BFS.md`）
3. 將完整路徑代入模板的 `{{NOTE_PATH}}`

**重要**：模板中的路徑必須是從 vault root 開始的完整相對路徑，含副檔名（`.md`）。

---

## 篩選選項

### 資料夾篩選

`hubs` 和 `orphans-rich` 支援 `FOLDER_FILTER` 參數：

- 空字串 `''`：不篩選（全 vault）
- 資料夾前綴：如 `'notes/'`（含尾部斜線）

### Frontmatter 篩選

若需依 frontmatter 屬性篩選，在查詢結果上做後處理：

1. 先跑 hubs/orphans-rich 取得結果
2. 對結果中的筆記用 `properties` 指令逐一查 frontmatter
3. 過濾不符條件的筆記

---

## 關係分析工作流（relationship-summary）

這是一個多步驟 Agent 流程，不是單一模板。

### 適用場景

- 「這篇筆記和哪些筆記有什麼關係？」
- 「A 和 B 之間是什麼關係？」
- 「分析某主題下的筆記結構」

### 流程

```
1. 判斷範圍
   ├─ 單篇筆記 → neighbors(maxHops=1) + frontmatter-relations
   ├─ 兩篇筆記 → path + 兩端 frontmatter-relations
   └─ 主題/資料夾 → hubs(folderFilter) + 抽樣分析

2. 執行圖查詢，取得結構性資料

3. 讀取 frontmatter 關係欄位
   └─ 用 frontmatter-relations 模板查設定中的關係欄位

4. 檢查 inline dataview fields（可選）
   ├─ 用 Obsidian CLI read 指令讀取筆記內容
   └─ 正則解析：\[(\w+)::\s*\[\[([^\]]+)\]\]\]

5. 無標註連結 → LLM 推理（可選）
   ├─ 讀取兩端筆記前 500 字
   ├─ 比對共同 frontmatter 屬性
   └─ 依 relationship-types.md 的 prompt 模板推理

6. 產出關係摘要
   ├─ 標明來源：✅ frontmatter / ✅ inline / 🤖 LLM 推理
   └─ 表格或圖形呈現
```

### 關係類型參考

詳見 `references/relationship-types.md`：
- 關係欄位定義範例
- Inline dataview 解析方式
- LLM 推理 prompt 模板
- 解析優先順序

---

## NEVER

- NEVER 直接在 `eval code=` 參數中寫完整 JS 程式碼——一定要寫到暫存檔再用 `fs.readFileSync` 載入，否則引號跳脫會炸
- NEVER 在 `{{NOTE_PATH}}` 中使用筆記名稱而非完整路徑——必須是從 vault root 開始的相對路徑，含 `.md` 副檔名
- NEVER 在未確認 Obsidian 正在執行的情況下跑查詢——會靜默失敗
- NEVER 對 `{{MAX_HOPS}}` 代入大於 5 的值——BFS 會遍歷整個圖，輸出過大
- NEVER 假設 `resolvedLinks` 中的 key 存在就代表有連結——可能是 0 個連結的空 entry
- NEVER 在字串佔位符（`{{NOTE_PATH}}` 等）中代入含單引號 `'` 的值而不做逃逸——會破壞 JS 語法

---

## 輸出慣例

### Markdown 呈現

| 查詢 | 呈現方式 |
|------|----------|
| neighbors | 按層分組的列表，每層標示 hop 數 |
| path | 箭頭串連的路徑：`A → B → C`（標示 hops 數） |
| cluster | 按資料夾分組的表格（truncated 時顯示計數） |
| bridges | 兩個表格：橋接邊 + 關鍵節點（含 degree） |
| hubs | 排序表格：筆記名、in-degree、out-degree、total |
| orphans-rich | 表格：筆記名、修改日期、frontmatter 摘要 |
| frontmatter-relations | 關係表格 + 連結統計 |
| vault-stats | JSON 結構化數據（由 vault-report 工作流消費，不直接呈現） |

### 大量結果截斷

- neighbors: 超過 50 個鄰居時只顯示 top 50（依 degree 排序）
- cluster: 超過 500 節點時自動切換資料夾計數模式
- orphans-rich: 最多 100 筆
- bridges: 最多 50 條橋接邊 + 30 個關鍵節點
- hubs: 由 TOP_N 控制（預設 20）
- vault-stats: componentSizes 最多 20 個、outOnlyNotes 最多 50 筆

### 筆記名稱顯示

輸出時去除路徑前綴和 `.md` 副檔名，只顯示筆記名稱。但若有同名筆記在不同資料夾，則保留資料夾名稱以區分。
