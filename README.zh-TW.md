# obsidian-graph-query

讓你的 AI agent 直接對 Obsidian vault 的知識圖譜下查詢。

你的 vault 有圖譜。但你只能盯著它看。

Obsidian 的 graph view 很美，但它回答不了任何問題 —「哪些筆記是知識樞紐？」「這兩個概念之間隔幾層？」「哪些筆記斷掉會讓整張網散掉？」「我有多少篇心血結晶其實是孤島？」

這個 skill 讓你的 AI agent 直接查詢 vault 的連結結構。不是看圖，是跑圖演算法 — BFS、最短路徑、Tarjan 橋接偵測、度數分析 — 然後用自然語言把結果講給你聽。

---

## 解決什麼問題

**筆記越多越迷路。** 500 篇的時候還靠記憶，2000 篇之後你根本不知道自己的知識庫長什麼樣。哪些是核心節點？哪些區塊之間其實沒連上？Graph view 能讓你看到大點小點，但你拿不到具體數字，也沒辦法問它「前 20 名是誰」。

**孤島筆記是沉默的浪費。** 花了時間寫的筆記，沒有連入也沒有連出，就這樣沉在 vault 底部。你甚至不知道它們存在。

**結構弱點是隱形風險。** 某篇筆記是唯一橋接兩個知識區塊的節點 — 如果你移動或刪掉它，整張知識網就斷了。但 Obsidian 不會警告你。

**Graph view 能探索，但不能查詢。** 你能縮放、能拖曳、能看到局部結構。但你沒辦法量化它、沒辦法對它問問題。

**Graph view 不可查詢，Dataview 能查單篇連結但跑不了跨節點的圖遍歷。** 最短路徑、連通分量、橋接偵測 — 這些需要在整張鄰接表上跑演算法，目前 Obsidian 生態裡沒有現成工具能透過自然語言做到這件事。這個 skill 補上了這塊：讓你的 AI agent 直接在 vault 的連結結構上跑 BFS、Tarjan、度數分析，你只需要用自然語言與你的 agent 描述你想知道什麼。

---

## 你需要準備

1. **[Obsidian](https://obsidian.md/)** — 並開啟 CLI 功能（設定 > 一般 > 命令列介面）
2. **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic 的 Claude 命令列工具

就這樣。

---

## 安裝（3 步）

### 第 1 步：下載

```bash
git clone https://github.com/YOUR_USERNAME/obsidian-graph-query.git
```

### 第 2 步：打開 Claude Code

```bash
cd obsidian-graph-query
claude
```

### 第 3 步：說「幫我安裝」

```
幫我安裝
```

Claude 會自動完成所有設定 — 偵測你的環境、問你 vault 資訊、掃描資料夾結構、產生設定檔、跑測試確認能用。（安裝過程中需要 Obsidian 保持開啟，CLI 才能連線。）

完成後重啟 Claude Code，之後在任何專案裡都能用。

> **想手動裝？** `bash install.sh`，再自己編輯 `vault-config.md`。

---

## 能問什麼

| 你說 | 背後做什麼 |
|------|-----------|
| 「我的 vault 裡哪些筆記連結最多？」 | 跑度數分析，找出連結最多的樞紐節點 |
| 「[[筆記A]] 和 [[筆記B]] 怎麼連的？」 | BFS 最短路徑，告訴你中間經過哪些筆記 |
| 「[[這篇]] 周圍有什麼？」 | N 層鄰居展開，看到局部知識網路 |
| 「哪些筆記拿掉會斷開知識網？」 | Tarjan 演算法找橋接邊和關鍵節點 |
| 「找出沒人連的孤島筆記」 | 全 vault 掃描，列出零連結筆記 + frontmatter 資訊 |
| 「分析 [[主題X]] 的關係結構」 | 多步驟分析：圖結構 + frontmatter 關係欄位 + LLM 推理 |

### 實際對話長這樣

> **你：** 我的知識庫裡哪些筆記是核心？
>
> **Claude：**
>
> | 筆記 | 連入 | 連出 | 合計 |
> |------|------|------|------|
> | MOC 索引 | 45 | 30 | 75 |
> | 核心概念 | 40 | 20 | 60 |
> | 學習方法論 | 35 | 15 | 50 |

> **你：** 「機器學習」和「神經科學」之間怎麼連的？
>
> **Claude：** 機器學習 → 神經網路 → 神經科學（2 步）

> **你：** 哪些筆記是孤島？
>
> **Claude：** 在「永久筆記」資料夾找到 23 篇孤立筆記，最近修改的 5 篇是...

---

## 之後想改設定

跟 Claude 說「幫我更新 graph query 設定」，或直接編輯：

```
<Claude Code skills 資料夾>/obsidian-graph-query/references/vault-config.md
```

可調整排除資料夾（附件、模板等不參與查詢）和關係欄位（`Up`、`來源`、`參考` 等 frontmatter 欄位）。

---

## 運作原理

1. 讀取你的 vault 設定
2. 從 7 個內建 JS 模板中選擇對應的圖演算法
3. 代入你的排除資料夾和關係欄位
4. 透過 Obsidian CLI `eval` 直接在 Obsidian 內部執行
5. 解析結果，用 Markdown 呈現

資料來源是 `app.metadataCache.resolvedLinks` — Obsidian 即時維護的完整連結索引，不是靜態快照。

---

## 技術架構

### 資料來源

所有查詢共用同一個資料來源：`app.metadataCache.resolvedLinks`。這是 Obsidian 內部維護的完整鄰接表 — 每篇筆記指向哪些筆記、被哪些筆記指向，全部已解析。不需要自己爬檔案或解析 wikilink，Obsidian 已經做好了。

### 執行流程

```
用戶自然語言描述 → Agent 選擇模板 → 代入參數 → 寫入暫存 JS → Obsidian CLI eval 執行 → JSON 輸出 → Agent 解析呈現
```

關鍵設計：JS 跑在 Obsidian 的 Electron 主程序裡（透過 CLI 的 `eval` 指令），所以能直接存取 `app` 物件，不需要額外 API。

### 7 個查詢模板

每個模板都是獨立的 JS IIFE（Immediately Invoked Function Expression），位於 `skill/references/query-templates.md`。

| 模板 | 演算法 | 複雜度 | 說明 |
|------|--------|--------|------|
| **neighbors** | BFS | O(V+E) | 從起點展開 N 層，回傳每層的鄰居列表 |
| **path** | BFS 最短路徑 | O(V+E) | 無權重最短路徑，回傳完整路徑和步數 |
| **cluster** | DFS 連通分量 | O(V+E) | 找出起點所在的整個連通子圖。超過 500 節點自動切換為資料夾計數模式（避免輸出爆量） |
| **bridges** | Iterative Tarjan | O(V+E) | 找橋接邊（移除後圖會斷開的邊）和關鍵節點（移除後圖會斷開的點）。使用迭代版避免 2000+ 節點時的遞迴 stack overflow |
| **hubs** | 度數計算 | O(V+E) | 統計每篇筆記的連入度、連出度、合計度數，排序取 Top N。支援資料夾篩選 |
| **orphans-rich** | 全掃描 | O(V+E) | 找出連入和連出皆為 0 的筆記，附帶 frontmatter 和修改日期。最多回傳 100 筆 |
| **frontmatter-relations** | 欄位擷取 | O(E) | 讀取指定筆記的 frontmatter 關係欄位，統計連入連出。用於 relationship-summary 工作流的第一步 |

### 參數化設計

模板中有兩類佔位符：

- **`{{EXCLUDED_FOLDERS}}`** — JSON 陣列，從 `vault-config.md` 讀取，7 個模板都有
- **`{{RELATIONSHIP_FIELDS}}`** — JSON 陣列，從 `vault-config.md` 讀取，僅 frontmatter-relations 使用

Agent 執行前從 `vault-config.md` 讀取這兩個值，字串替換後寫入暫存 JS 執行。這讓同一套模板能適用於不同 vault 結構。

### 安全閥

- cluster 超過 500 節點 → 自動切換資料夾計數模式
- orphans-rich 最多回傳 100 筆
- bridges 最多顯示 50 條橋接邊 + 30 個關鍵節點
- hubs 由用戶指定 Top N（預設 20）

這些限制是為了避免大型 vault（2000+ 筆記）的查詢結果灌爆 AI 的 context window。

### 想貢獻？

新增查詢模板的步驟：

1. 在 `skill/references/query-templates.md` 新增一個 section
2. 寫一個 JS IIFE，用 `{{EXCLUDED_FOLDERS}}` 做排除，輸出 JSON 字串
3. 在 `skill/SKILL.md` 的查詢索引表加上新模板
4. 測試：把你的排除列表代入 `{{EXCLUDED_FOLDERS}}`，確認輸出正確

模板的限制：
- 必須是同步執行的 JS（Obsidian CLI eval 不支援 async）
- 輸出必須是 `return JSON.stringify(...)` 的字串
- 避免遞迴（大 vault 會 stack overflow），用迭代版本

---

## 授權

MIT
