# obsidian-graph-query

把你的 Obsidian vault 變成可查詢的知識圖譜 — 用自然語言找出樞紐筆記、最短路徑、叢集、橋接點、孤立筆記、關係摘要，全部在 Claude Code 裡完成。

---

## 你需要準備

1. **[Obsidian](https://obsidian.md/)** — 並開啟 CLI 功能（設定 > 一般 > 命令列介面）
2. **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic 的 Claude 命令列工具

就這樣。

---

## 安裝（3 步）

### 第 1 步：下載這個 repo

打開終端機，貼上：

```bash
git clone https://github.com/YOUR_USERNAME/obsidian-graph-query.git
```

### 第 2 步：在下載的資料夾裡打開 Claude Code

```bash
cd obsidian-graph-query
claude
```

### 第 3 步：跟 Claude 說「幫我安裝」

輸入以下任一句話：

```
幫我安裝
```
```
help me set up
```
```
setup
```

Claude 會自動引導你完成所有設定：

- **自動找到** Claude Code 的 skills 資料夾
- **詢問**你的 vault 名稱，並確認 CLI 連線正常
- **掃描**你的 vault 資料夾，讓你選擇要排除哪些
- **偵測**你的 frontmatter 關係欄位（或讓你手動設定）
- **產生設定檔**、複製檔案到正確位置、跑一次測試確認能用

完成後，**重啟 Claude Code**。之後在任何專案裡都能使用這個 skill。

> **想手動安裝？** 跑 `bash install.sh`，再自己編輯 `vault-config.md`。可參考 `examples/` 裡的範例設定。

---

## 能做什麼？

用自然語言問 Claude 就好：

| 你說 | Claude 做什麼 |
|------|--------------|
| 「我的 vault 裡最多連結的筆記是哪些？」 | 找出連結數最高的樞紐筆記 |
| 「[[筆記A]] 和 [[筆記B]] 之間怎麼連的？」 | 找出兩篇筆記間的最短路徑 |
| 「[[這篇筆記]] 屬於哪個叢集？」 | 列出從這篇筆記出發能到達的所有筆記 |
| 「我的 vault 裡哪些筆記是結構上的橋接點？」 | 找出移除後會讓圖斷開的關鍵筆記 |
| 「找出 Projects 資料夾裡的孤立筆記」 | 列出沒有任何連入或連出的筆記 |
| 「[[這篇筆記]] 有什麼關係？」 | 擷取 frontmatter 關係欄位 + 連結統計 |
| 「分析 [[主題X]] 周圍的關係」 | 多步驟分析：圖結構 + frontmatter + LLM 推理 |

### 範例：樞紐筆記

> **你：** 最多連結的筆記是哪些？
>
> **Claude：**
>
> | 筆記 | 連入 | 連出 | 合計 |
> |------|------|------|------|
> | MOC 索引 | 45 | 30 | 75 |
> | 核心概念 | 40 | 20 | 60 |
> | ... | | | |

### 範例：最短路徑

> **你：** 「機器學習」和「神經科學」怎麼連的？
>
> **Claude：** 機器學習 → 神經網路 → 神經科學（2 步）

---

## 之後想改設定

設定檔位置：

```
<Claude Code skills 資料夾>/obsidian-graph-query/references/vault-config.md
```

用任何文字編輯器打開，可以改：

- **排除資料夾** — 查詢時跳過的資料夾（如附件、模板）
- **關係欄位** — 用來標註筆記間關係的 frontmatter 欄位（如 `Up`、`來源`、`參考`）

或是直接跟 Claude 說：**「幫我更新 graph query 設定」**。

---

## 運作原理

1. Claude 讀取你的 `vault-config.md` 取得設定
2. 選擇對應的 JS 查詢模板（內建 7 個）
3. 填入你的排除資料夾和關係欄位
4. 透過 Obsidian CLI 的 `eval` 指令執行 JS
5. 解析 JSON 結果，轉成 Markdown 呈現

查詢使用 `app.metadataCache.resolvedLinks` — Obsidian 內部維護的完整連結索引 — 結果永遠是即時最新的。

---

## 授權

MIT
