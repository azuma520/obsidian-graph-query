---
name: notebooklm-learn-new-domain
description: >-
  基於知識四層級（原理→模型→操作）的結構化學習工作流。
  用 notebooklm-py 自動串接提問、思維導圖、測驗和播客生成，
  幫助用戶快速進入陌生領域。Use for:
  learn new domain, structured learning, knowledge levels,
  NotebookLM workflow, 學習新領域, 知識四層級, 結構化學習.
---

# NotebookLM — 學習新領域

用知識四層級（原理→模型→操作）引導用戶學習陌生領域。底層工具為 notebooklm-py。

---

## 前置條件

1. **notebooklm-py** 已安裝且可用（`notebooklm --version` ≥ 0.3.3）
2. NotebookLM 筆記本已建立，且用戶已上傳學習材料
3. 讀取 `references/prompt-templates.md` 取得提問句
4. 讀取 `references/user-guide.md` 了解方法論邏輯

> 如果用戶還沒上傳材料，先引導他建立筆記本並上傳。若有 anything-to-notebooklm skill 可用，優先使用。

---

## Decision Tree

```
使用者意圖
├─ 「幫我學 XX 領域」              → 完整流程（原理→模型→操作）
├─ 「幫我理解基本概念」             → 原理層
├─ 「幫我找出框架」                → 模型層
├─ 「幫我測驗」                    → 操作層
├─ 「從 XX 層開始」                → 指定層級開始，往後走
├─ 「跳過 XX 層」                  → 跳過指定層，執行其餘
└─ 「這是什麼方法？」              → 回覆 user-guide.md 的說明
```

---

## Workflow

### Step 0：確認筆記本 + 資料策劃檢查

確認用戶有 NotebookLM 筆記本且已上傳材料。如果沒有：

```bash
# 若有 anything-to-notebooklm skill，用它上傳
notebooklm source add <file_or_url>
```

**資料策劃檢查：** 上傳前（或上傳後），檢查資料組合是否覆蓋三角形：

| 角色 | 檢查 | 缺了怎麼辦 |
|------|------|-----------|
| 全貌型 | Wikipedia、入門指南、教科書導論 | 建議用 `notebooklm source add-research "領域關鍵字"` 補充 |
| 權威型 | 官方文檔、經典論文、技術規格 | 通常使用者自己會帶，缺的話提醒補 |
| 觀點型 | 評論、比較文、爭議報導、專家部落格 | 用 WebSearch 搜「[領域] controversy」或「[領域] vs」找一篇 |

如果缺「觀點型」，主動建議補一篇 Wikipedia 或比較文章。資料品質直接決定 Q6 和 Q7 的產出品質。

### Step 1：原理層

依序執行 prompt-templates.md 的 Q1～Q4：

```bash
notebooklm ask "Q1 提問句"
notebooklm ask "Q2 提問句"
notebooklm ask "Q3 提問句"
notebooklm ask "Q4 提問句"
```

每個回答呈現給用戶後，簡要摘要重點。確認用戶消化後再繼續。

### Step 2：模型層

#### Q5

```bash
notebooklm ask "Q5 提問句"
```

#### Q6：根據訊號選擇 A 或 B

Q6 有兩個版本（見 prompt-templates.md）。根據以下訊號判斷：

| 訊號 | 指向 |
|------|------|
| 使用者明確說「比較」「選型」「該用哪個」 | Q6-B |
| 使用者明確說「爭議」「分歧」「辯論」 | Q6-A |
| 資料來源全部是官方文檔 / tutorial | Q6-B |
| 資料來源包含 Wikipedia 或評論/觀點文章 | Q6-A |
| Q5 回答出現「最佳實踐」「建議做法」「業界標準」 | Q6-B |
| Q5 回答出現「學派」「流派」「陣營」「爭議」 | Q6-A |
| 學習主題是技術/工具/框架/流程 | Q6-B |
| 學習主題是學術/概念/倫理/政策 | Q6-A |
| 不確定 | 兩個都問 |

```bash
notebooklm ask "Q6-A 或 Q6-B 提問句"
```

告知用戶選了哪個版本及原因。

#### Q7：跟著 Q6 版本連動

| Q6 版本 | Q7 版本 |
|---------|---------|
| Q6-A（分歧） | Q7-A |
| Q6-B（比較） | Q7-B |
| 兩個都問了 | Q7-A |

```bash
notebooklm ask "Q7-A 或 Q7-B 提問句"
notebooklm generate mind-map
```

思維導圖生成後，引導用戶觀察框架之間的結構。

### Step 3：操作層

生成測驗，等待用戶作答，針對錯誤追問：

```bash
notebooklm generate quiz
# 用戶作答後...
notebooklm ask "Q8 追問句（帶入用戶的答案和正確答案）"
notebooklm ask "Q9 表態句（帶入用戶選擇的議題）"
notebooklm generate audio
```

Q8 和 Q9 需要根據用戶的實際回答動態填入，不是固定句子。Q9 跟著 Q6 版本：
- Q6-A → 挑一個分歧讓用戶表態（正方/反方）
- Q6-B → 挑一個選型問題讓用戶做選擇（方案 A/B）

參考 prompt-templates.md 的模板格式。

### Step 4：收尾

所有層級完成後：
- 摘要用戶在這次學習中覆蓋了什麼
- 指出哪些地方可能需要深入（根據測驗表現）
- 提醒下一步是「應用」（經驗層），這需要用戶自己去做

---

## 多來源比對（進階）

當用戶上傳了多份不同觀點的材料，可以用指定來源提問提升品質：

```bash
# 指定單一來源提問
notebooklm ask -s <source_id> "Q6 提問句"

# 比對不同來源的回答
notebooklm ask -s <source_A> "這個領域最重要的框架是什麼？"
notebooklm ask -s <source_B> "這個領域最重要的框架是什麼？"
```

也可以用研究模式自動搜集相關材料：

```bash
notebooklm source add-research "領域關鍵字"
```

詳見 prompt-templates.md 附錄。

---

## NEVER List

- **不代替用戶思考** — 呈現資訊、提出問題，但判斷和回答由用戶做
- **不自動產出筆記** — 工作流專注在學習引導，不是筆記生成
- **不強制順序** — 用戶要求跳過或只做某層，就照做
- **不做經驗層** — 工作流到「知識準備好」為止，實際應用是用戶的事
- **不重複寫提問句** — 所有提問句引用 prompt-templates.md，不在這裡重寫
- **不一次倒完** — 每一層完成後確認用戶消化了再繼續，不要連續丟四層回答
