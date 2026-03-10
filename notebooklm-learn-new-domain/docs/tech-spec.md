---
entity_type: 參考
date: 2026-03-09
tags:
  - tech-spec
  - learning-method
  - skill-development
status: 草稿
---

# Tech Spec：notebooklm-learn-new-domain

## Problem & Solution

**Problem：** 面對陌生領域，學習者不知道從哪裡開始。現有的 48 小時法直接跳到框架層，跳過了基礎術語和原理，也缺乏結構化的驗證環節。

**Solution：** 基於知識四層級（原理→模型→操作）的提問模板 + 使用手冊，以 NotebookLM 為主要工具，引導用戶由上而下結構化地進入新領域。

---

## Technical Approach

### Stack

- **核心工具：** NotebookLM（免費，所有用戶）
- **自動化 CLI：** notebooklm-py v0.3.3+（次要受眾）
- **文件格式：** Markdown

### 交付物結構

```
notebooklm-learn-new-domain/
├── docs/
│   ├── research.md           # 研究文件
│   ├── prd.md                # 產品需求文件
│   └── tech-spec.md          # 本文件
└── skills/
    ├── SKILL.md              # agent 執行協議
    └── references/
        ├── prompt-templates.md   # 三層級提問模板
        └── user-guide.md         # 使用手冊
```

### Architecture

知識四層級的線性流程，每一層對應一組 NotebookLM 操作：

```
原理層 ──ask──→ 模型層 ──ask + mind-map──→ 操作層 ──quiz + 追問──→ 完成
```

### 各層級操作對應

| 知識層級 | 用戶做什麼 | NotebookLM 操作 | 手動用戶 | 自動化（SKILL.md） |
|---------|-----------|----------------|---------|-------------------|
| 材料匯入 | 上傳學習材料 | `source add` | 手動上傳 | agent 調用 anything-to-notebooklm |
| 原理 | 閱讀、理解基礎概念 | `ask`（術語、定義、邏輯、現象） | 複製貼上提問句 | agent 自動 ask |
| 模型 | 閱讀、判斷框架 | `ask`（Q1 框架、Q2 分歧）+ `generate mind-map` | 複製貼上 + 手動生成 | agent 自動 ask + generate |
| 操作 | 作答、思考、追問 | `generate quiz` + `ask`（追問循環） | 手動生成 + 複製貼上 | agent 自動 generate + ask |

---

## Requirements

### Functional（from PRD）

| ID | Title | Priority |
|----|-------|----------|
| FR-001 | 原理層提問模板 | Must |
| FR-002 | 模型層提問模板 | Must |
| FR-003 | 操作層提問模板 | Must |
| FR-004 | 使用手冊 | Must |
| FR-005 | SKILL.md 自動化編排 | Should |
| FR-006 | 多來源比對指引 | Could |

### Non-Functional（from PRD）

| ID | Title | Priority |
|----|-------|----------|
| NFR-001 | 可讀性與低摩擦（零基礎預設） | Must |
| NFR-002 | 語言（繁體中文） | Must |
| NFR-003 | 模組化與銜接性 | Must |
| NFR-004 | 一致性（與現有 skill 風格統一） | Should |

---

## Implementation Plan

### Stories

| # | Story | 交付什麼 | 依賴 | Priority |
|---|-------|---------|------|----------|
| 1 | 原理層提問模板 | prompt-templates.md 的原理層區塊 | — | Must |
| 2 | 模型層提問模板 | prompt-templates.md 的模型層區塊 | Story 1（銜接句） | Must |
| 3 | 操作層提問模板 | prompt-templates.md 的操作層區塊 | Story 2（銜接句） | Must |
| 4 | 使用手冊 | user-guide.md | Story 1-3 | Must |
| 5 | SKILL.md 自動化編排 | SKILL.md | Story 1-4 | Should |
| 6 | 多來源比對指引 | prompt-templates.md 附錄 | Story 2 | Could |

### Development Order

```
Story 1（原理層）→ Story 2（模型層）→ Story 3（操作層）
                                                │
                                                ▼
                                         Story 4（使用手冊）
                                                │
                                                ▼
                                         Story 5（SKILL.md）
                                                │
                                                ▼
                                         Story 6（多來源比對）
```

### 各 Story 設計規格

#### Story 1：原理層提問模板

**目的：** 讓零基礎用戶提取領域的基礎知識

**提問方向：**
- 核心術語：這個領域最重要的 N 個專有名詞是什麼？各自的定義？
- 基本邏輯：這些概念之間的因果關係是什麼？
- 現象/效應：這個領域中最重要的現象或效應有哪些？
- 基礎原理：支撐這個領域的底層邏輯是什麼？

**格式要求：**
- 提問句可直接複製貼上到 NotebookLM
- 白話用語，不預設任何背景知識
- 每個提問句附帶一行說明（這個問題在幫你做什麼）

**NotebookLM 操作：** `notebooklm ask "提問句"`

---

#### Story 2：模型層提問模板

**目的：** 在原理層基礎上提取框架和分歧

**提問方向：**
- Q1 核心框架：專家最常用的思考框架/模型是什麼？
- Q2 核心分歧：專家在哪些核心議題上有根本分歧？
- 結構化：這些框架之間的關係是什麼？

**格式要求：**
- 同 Story 1
- 開頭包含銜接句：「如果你已完成原理層，可以這樣接著問...」

**NotebookLM 操作：** `notebooklm ask "提問句"` + `notebooklm generate mind-map`

---

#### Story 3：操作層提問模板

**目的：** 驗證理解，從「知道」推向「懂」

**提問方向：**
- 生成測驗：區分「真的懂」和「只是背」的問題
- 追問循環：答錯後追問為什麼錯、漏了什麼
- 表態提問：你站哪邊？為什麼？
- 被動驗證：播客生成，聽出自己的疑惑點

**格式要求：**
- 同 Story 1
- 開頭包含銜接句

**NotebookLM 操作：** `notebooklm generate quiz` + `notebooklm ask "追問句"` + `notebooklm generate audio`

---

#### Story 4：使用手冊

**目的：** 解釋方法論邏輯，讓用戶理解為什麼這樣做

**內容結構（草案）：**
1. 這是什麼 — 一句話說明
2. 為什麼有效 — 知識四層級的邏輯（白話版）
3. 快速開始 — 三步驟上手
4. 完整流程 — 原理→模型→操作的詳細說明
5. 常見問題

**設計原則：**
- 以「做什麼」為主，不堆理論
- 以 NotebookLM 為主要工具撰寫
- 零技術背景可讀

---

#### Story 5：SKILL.md 自動化編排

**目的：** 讓 coding agent 自動串接工作流

**結構（遵循現有 skill 格式）：**
1. Decision Tree — 判斷用戶要做什麼
2. Workflow — 按知識四層級編排 notebooklm-py 指令
3. NEVER List — 不該做的事
4. 整合銜接 — 引用 anything-to-notebooklm skill

**設計原則：**
- 步驟可跳、可挑
- 調用 notebooklm-py 的 ask、generate mind-map、generate quiz
- 引用 prompt-templates.md 的提問句，不重複寫

---

#### Story 6：多來源比對指引

**目的：** 提升框架提取品質

**內容：**
- 為什麼多來源有效（麥肯錫邏輯）
- 如何用 `notebooklm ask -s <source_id>` 指定來源比對
- 如何用 `source add-research` 自動搜集材料

---

## Acceptance Criteria

- [ ] 一般用戶拿到 prompt-templates.md，能直接在 NotebookLM 中複製貼上使用
- [ ] 三個層級可獨立使用，也可順序銜接
- [ ] user-guide.md 不需技術背景即可看懂
- [ ] SKILL.md 能讓 agent 自動執行工作流
- [ ] 所有文件為繁體中文

---

## Dependencies

### Internal
- 研究文件：`docs/research.md`（完成）
- PRD：`docs/prd.md`（完成）
- 現有 skill：anything-to-notebooklm（SKILL.md 引用）

### External
- NotebookLM（Google 免費服務）
- notebooklm-py CLI v0.3.3+（僅 SKILL.md）

---

## Risks

| Risk | Mitigation |
|------|-----------|
| NotebookLM 功能變動（ask/generate 指令改變） | 提問模板不綁指令語法，SKILL.md 集中管理指令 |
| 提問模板在不同領域效果差異大 | 模板設計為通用框架，user-guide 說明如何依領域調整 |
| 用戶不理解「為什麼要按這個順序」 | user-guide 用白話解釋四層級邏輯 |

---

## Out of Scope

1. 經驗層（實際應用）
2. 額外工具整合
3. 自動筆記產出
4. 強制執行順序
5. 由下而上學習法
6. 方法論教材
7. Obsidian 整合（graph-query / qmd）

---

## Timeline

不設限，能快就快。開發順序按 Story 1→6 線性推進。

---

*Based on PRD: `docs/prd.md`*
*Tech Spec date: 2026-03-09*
