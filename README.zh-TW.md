# obsidian-graph-query

讓你的 AI agent 直接對 Obsidian vault 的知識圖譜下查詢。

你的 vault 有圖譜。但你只能盯著它看。

Obsidian 的 graph view 很美，但它回答不了任何問題 —「哪些筆記是知識樞紐？」「這兩個概念之間隔幾層？」「哪些筆記斷掉會讓整張網散掉？」「我有多少篇心血結晶其實是孤島？」

這個 skill 讓你的 AI agent 直接查詢 vault 的連結結構。不是看圖，是跑圖演算法 — BFS、最短路徑、Tarjan 橋接偵測、度數分析 — 然後用自然語言把結果講給你聽。

---

## 解決什麼問題

**筆記越多越迷路。** 500 篇的時候還靠記憶，2000 篇之後你根本不知道自己的知識庫長什麼樣。哪些是核心節點？哪些區塊之間其實沒連上？你的 graph view 不會告訴你。

**孤島筆記是沉默的浪費。** 花了時間寫的筆記，沒有連入也沒有連出，就這樣沉在 vault 底部。你甚至不知道它們存在。

**結構弱點是隱形風險。** 某篇筆記是唯一橋接兩個知識區塊的節點 — 如果你移動或刪掉它，整張知識網就斷了。但 Obsidian 不會警告你。

**Graph view 好看，但沒用。** 你能縮放、能拖曳、能上色。但你沒辦法問它問題。

**Graph view 只能看，Dataview 只能查 metadata，兩個都跑不了圖演算法。** 這個 skill 讓你的 AI agent 直接在 vault 的連結結構上跑 BFS、最短路徑、Tarjan 橋接偵測、度數分析 — 這是 Obsidian 生態裡本來做不到的事。你只需要用自然語言與你的 agent 描述你想知道什麼。

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

Claude 會自動完成所有設定 — 偵測你的環境、問你 vault 資訊、掃描資料夾結構、產生設定檔、跑測試確認能用。

完成後重啟 Claude Code，之後在任何專案裡都能用。

> **想手動裝？** `bash install.sh`，再自己編輯 `vault-config.md`。

---

## 能問什麼

| 你說 | 背後做什麼 |
|------|-----------|
| 「我的 vault 裡哪些筆記最重要？」 | 跑度數分析，找出連結最多的樞紐節點 |
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

## 授權

MIT
