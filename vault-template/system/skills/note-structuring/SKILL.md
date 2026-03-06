---
name: note-structuring
description: 自動從對話建立筆記、填 frontmatter、建立連結。觸發詞：「記一下」「幫我寫筆記」「這讓我想到」
---

# 自動結構化 Skill

從對話中自動辨識筆記類型、填寫 frontmatter、建立知識連結。

## 基本原則

| 規則 | 要求 |
|------|------|
| **主動但不強迫** | 討論中有明確知識內容才建議建筆記，閒聊不要硬建 |
| **類型判斷** | 根據內容辨識筆記類型，不確定就問用戶 |
| **連結為先** | 建筆記時主動搜尋可能的連結對象 |

## 筆記建立流程

```
觸發 → 辨識筆記類型 → 搜尋相似筆記 → 建議 tags/領域 → 用戶確認 → 填 frontmatter → 建連結 → 完成
```

### Tag 與領域建議

建立筆記時，在填寫 frontmatter 前：

1. 用 CLI search 找出與新筆記主題相關的 3-5 篇現有筆記
2. 讀取這些筆記的 tags 和「專業」欄位
3. 統計最常出現的 tags 和領域值
4. 向用戶建議：
   - 「根據相關筆記，建議 tags：[X, Y, Z]，領域：W。你覺得合適嗎？」
5. 用戶確認或修正後，寫入 frontmatter

原則：
- 建議基於現有 vault 的 tag 用法，保持一致性
- 用戶可以拒絕或新增 tag，Agent 不強制
- 如果找不到相關筆記（全新領域），告知用戶自行決定

## 路由

| 用戶說 | 工作流 |
|--------|--------|
| 「記一下」「幫我寫筆記」「建立筆記」 | workflows/create-note.md |
| 「這讓我想到 XX」「跟 XX 有關」「連結到 XX」 | workflows/link-notes.md |

## 資料存取

**搜尋筆記：**
```bash
<CLI> vault="<VAULT>" search "<搜尋詞>"
```

**建立筆記：**
```bash
<CLI> vault="<VAULT>" create "<路徑>" --content "<內容>"
```

**設定屬性：**
```bash
<CLI> vault="<VAULT>" property:set "<路徑>" "<key>" "<value>"
```