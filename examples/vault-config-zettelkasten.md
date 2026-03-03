# Vault Configuration — Zettelkasten 範例

此為卡片盒筆記法 vault 的設定範例。

---

## 環境設定

| 項目 | 值 |
|------|-----|
| CLI 路徑 | `/c/Users/user/AppData/Local/Programs/Obsidian/Obsidian.com` |
| Vault 名稱 | `My Zettelkasten` |
| Vault 路徑 | `C:\Users\user\Documents\My Zettelkasten` |
| 平台 | Windows 11（bash shell） |

---

## 排除資料夾

```json
["Excalidraw/", "attachments/", "templates/", ".obsidian/", ".trash/", "plugins/", "archive/"]
```

---

## 關係欄位

```json
["Up", "來源", "參考", "應用於", "衍生自"]
```

| 欄位 | 語意 | 範例 |
|------|------|------|
| `Up` | 上層主題 / MOC | `Up: [[主題索引]]` |
| `來源` | 知識出處 | `來源: [[某本書的讀書筆記]]` |
| `參考` | 平行/相關概念 | `參考: [[相關概念]]` |
| `應用於` | 理論應用 | `應用於: [[專案筆記]]` |
| `衍生自` | 概念演進 | `衍生自: [[原始想法]]` |

---

## 資料夾結構

| 資料夾 | 用途 |
|--------|------|
| 0_System/ | 系統設定 |
| 1_Index/ | MOC / 索引筆記 |
| 2_Literature/ | 文獻筆記 |
| 3_Permanent/ | 永久筆記（核心知識） |
| 4_Daily/ | 每日筆記 |
| 5_Projects/ | 專案筆記 |
| 6_Inbox/ | 收件匣 / 待整理 |
| attachments/ | 圖片附件 |
| templates/ | 筆記模板 |

---

## Frontmatter Schema

| 欄位 | 類型 | 有效值 |
|------|------|--------|
| 筆記類型 | list | 永久筆記 / 文獻筆記 / 索引筆記 / 每日筆記 |
| 完成度 | list | 學習中 / 已完成 |
| 整理進度 | list | 未整理 / 已整理 |
| tags | list | 自由標籤 |
| Up | text | `[[上層筆記]]` wikilink |
