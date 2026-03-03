# Vault Configuration — Biomedical Knowledge Base 範例

此為生醫產品知識庫 vault 的設定範例。適用於以產品、材料、適應症為核心的結構化知識管理。

---

## 環境設定

| 項目 | 值 |
|------|-----|
| CLI 路徑 | `/usr/local/bin/obsidian` |
| Vault 名稱 | `BioMed KB` |
| Vault 路徑 | `/Users/researcher/Documents/BioMed KB` |
| 平台 | macOS |

---

## 排除資料夾

```json
[".obsidian/", ".trash/", "assets/", "templates/", "_archive/", "Excalidraw/"]
```

---

## 關係欄位

```json
["company", "materials", "indications", "related_genes", "competitors", "references"]
```

| 欄位 | 語意 | 範例 |
|------|------|------|
| `company` | 製造商 / 母公司 | `company: [[Medtronic]]` |
| `materials` | 材料 / 成分 | `materials: [[Titanium alloy]]` |
| `indications` | 適應症 / 用途 | `indications: [[Spinal fusion]]` |
| `related_genes` | 相關基因 | `related_genes: [[BRCA1]]` |
| `competitors` | 競品 | `competitors: [[Product X]]` |
| `references` | 參考文獻 | `references: [[PMID:12345678]]` |

---

## 資料夾結構

| 資料夾 | 用途 |
|--------|------|
| Products/ | 產品資料卡（每產品一筆記） |
| Companies/ | 公司檔案 |
| Materials/ | 材料/成分資料 |
| Indications/ | 適應症/疾病 |
| Literature/ | 文獻摘要 |
| Regulatory/ | 法規資訊（FDA 510k、PMA） |
| Clinical/ | 臨床試驗資料 |
| Daily/ | 每日筆記 |
| assets/ | 圖片/PDF 附件 |
| templates/ | 筆記模板 |

---

## Frontmatter Schema

| 欄位 | 類型 | 說明 |
|------|------|------|
| type | text | Product / Company / Material / Indication / Literature |
| status | text | Active / Discontinued / Pipeline |
| fda_class | text | I / II / III |
| approval_date | date | FDA 核准日期 |
| company | text | `[[公司]]` wikilink |
| materials | list | 材料列表 |
| indications | list | 適應症列表 |
| related_genes | list | 相關基因 |
| competitors | list | 競品列表 |
| references | list | 文獻引用 |
| tags | list | 分類標籤 |
