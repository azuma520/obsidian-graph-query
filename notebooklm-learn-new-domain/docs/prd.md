---
entity_type: 參考
date: 2026-03-09
tags:
  - prd
  - learning-method
  - skill-development
status: 草稿
---

# PRD：AI 輔助學習工作流

## Executive Summary

基於知識四層級（原理→模型→操作→經驗）的由上而下學習方法，以 NotebookLM 為主要工具，幫助零基礎用戶快速進入陌生領域。核心理念：AI 負責提取和呈現，用戶負責判斷和思考。

## Business Objectives

1. 提供一套基於知識四層級的結構化學習方法，幫助用戶快速進入陌生領域
2. 以 NotebookLM 為主要工具，降低使用門檻（免費、不需 coding agent）
3. 為有 notebooklm-py + coding agent 的用戶提供自動化編排

## Success Metrics

- 用戶能照著提問模板在 NotebookLM 中完成原理→模型→操作三層學習
- SKILL.md 能讓 agent 自動串接工作流
- 一般學習者拿到使用手冊就能開始，無需額外學習成本

## User Personas

### 主要受眾：一般學習者

- 只有 NotebookLM（免費）
- 對目標領域零基礎
- 不懂 CLI、coding agent 等技術概念
- 需求：拿到提問模板，複製貼上就能用

### 次要受眾：工具型用戶

- 有 notebooklm-py + coding agent（Claude Code、OpenClaw、Cline 等）
- 想要自動化重複操作
- 需求：SKILL.md 讓 agent 一句話觸發整個流程

## Design Principles

- **思考引導器，不是筆記生成器** — AI 提取和呈現，用戶判斷和思考
- **零基礎預設** — 所有文件預設用戶對目標領域無任何背景知識
- **低摩擦** — 盡可能降低學習和使用的摩擦力
- **由上而下** — 本工作流專注由上而下的學習路徑（原理→模型→操作）
- **獨立可用，串接更好** — 每個層級可單獨使用，照順序走銜接更自然

---

## Functional Requirements

### FR-001：原理層提問模板

**Priority：** Must Have

**Description：**
提供一組針對原理層的提問句，讓用戶在 NotebookLM 中提取領域的核心術語、定義、基本邏輯和現象。

**Acceptance Criteria：**
- [ ] 包含具體的提問句範例，可直接複製使用
- [ ] 涵蓋：術語、定義、基本邏輯、現象/效應
- [ ] 不預設用戶有任何領域背景知識

---

### FR-002：模型層提問模板

**Priority：** Must Have

**Description：**
提供一組針對模型層的提問句，讓用戶提取領域的核心框架、結構化關係，並觸發思維導圖生成。

**Acceptance Criteria：**
- [ ] 包含 Q1（核心框架）的具體提問句
- [ ] 包含 Q2（核心分歧）的具體提問句
- [ ] 包含觸發 `generate mind-map` 的指引
- [ ] 提問建立在原理層已完成的基礎上

---

### FR-003：操作層提問模板

**Priority：** Must Have

**Description：**
提供一組針對操作層的提問句和自測流程，讓用戶透過測驗和追問循環驗證理解。

**Acceptance Criteria：**
- [ ] 包含觸發 `generate quiz` 的指引
- [ ] 包含答錯後的追問句範例（為什麼錯、漏了什麼）
- [ ] 包含逼用戶表態的提問（你站哪邊、為什麼）
- [ ] 包含播客生成作為被動驗證的指引

---

### FR-004：使用手冊

**Priority：** Must Have

**Description：**
一份說明文件，解釋工作流的順序、為什麼這個順序有效、每一步該做什麼。以 NotebookLM 為主要工具撰寫。

**Acceptance Criteria：**
- [ ] 說明知識四層級的邏輯（為什麼原理→模型→操作）
- [ ] 每一步有清楚的「做什麼」和「為什麼」
- [ ] 以 NotebookLM 為主要工具撰寫
- [ ] 其他 AI 工具使用者可參考方法論邏輯自行調整
- [ ] 一般學習者能看懂，不需技術背景

---

### FR-005：SKILL.md 自動化編排

**Priority：** Should Have

**Description：**
一份 SKILL.md 文件，讓 coding agent 能自動按知識四層級串接 notebooklm-py 指令。

**Acceptance Criteria：**
- [ ] agent 能根據用戶輸入的學習主題自動執行工作流
- [ ] 調用 notebooklm-py 的 ask、generate mind-map、generate quiz
- [ ] 步驟可跳、可挑，不強制序列
- [ ] 引用 anything-to-notebooklm skill 處理材料匯入

**Dependencies：** FR-001, FR-002, FR-003, FR-004

---

### FR-006：多來源比對指引

**Priority：** Could Have

**Description：**
指引用戶如何上傳多種不同觀點的材料，利用 NotebookLM 的指定來源提問功能交叉比對，提升框架提取品質。

**Acceptance Criteria：**
- [ ] 說明為什麼多來源比對有效（麥肯錫三步法的邏輯）
- [ ] 包含 `notebooklm ask -s <source_id>` 的使用指引
- [ ] 包含 `source add-research` 研究模式的指引

---

## Non-Functional Requirements

### NFR-001：可讀性與低摩擦

**Priority：** Must Have

**Description：**
預設用戶對目標領域是零基礎。所有文件必須讓任何人拿到就能用，最大限度降低學習摩擦力。

**Acceptance Criteria：**
- [ ] 無需了解 CLI、coding agent 等概念即可使用核心功能
- [ ] 用詞白話，專有名詞附帶解釋
- [ ] 提問模板可直接複製貼上使用，不需用戶自己改寫
- [ ] 流程說明以「做什麼」為主，不堆理論

---

### NFR-002：語言

**Priority：** Must Have

**Description：**
文件語言遵循 repo 現有慣例。

**Acceptance Criteria：**
- [ ] 使用手冊、提問模板：繁體中文
- [ ] README：雙語（English + 繁體中文）
- [ ] SKILL.md：繁體中文

---

### NFR-003：模組化與銜接性

**Priority：** Must Have

**Description：**
三個層級彼此獨立可用，同時提供清楚的層級間銜接指引，讓照順序走的用戶能自然過渡。

**Acceptance Criteria：**
- [ ] 每個層級的模板可獨立運作
- [ ] 每個層級的開頭說明「如果你已完成上一層，可以怎麼銜接」
- [ ] SKILL.md 的步驟可跳、可挑
- [ ] 提問模板中包含引用前一層產出的銜接句範例

---

### NFR-004：一致性

**Priority：** Should Have

**Description：**
文件風格與 repo 現有 skill（obsidian-graph-query、anything-to-notebooklm）保持一致。

**Acceptance Criteria：**
- [ ] SKILL.md 結構遵循現有 skill 格式（Decision Tree、Workflow、NEVER List）
- [ ] 提問模板格式與現有 references 文件風格一致

---

## Epics

### EPIC-001：提問模板

**Description：** 三個知識層級的具體提問句，核心交付物

**Functional Requirements：** FR-001, FR-002, FR-003

**Story Count Estimate：** 3-5

**Priority：** Must Have

**Business Value：** 產品的核心 — 所有用戶（含主要受眾）都靠這個使用方法論

---

### EPIC-002：使用手冊

**Description：** 說明工作流的邏輯、順序、使用方式

**Functional Requirements：** FR-004

**Story Count Estimate：** 2-3

**Priority：** Must Have

**Business Value：** 讓用戶理解為什麼這樣做有效，不只是照抄提問句

---

### EPIC-003：自動化編排

**Description：** SKILL.md 讓 coding agent 串接 notebooklm-py 自動執行工作流

**Functional Requirements：** FR-005, FR-006

**Story Count Estimate：** 2-4

**Priority：** Should Have

**Business Value：** 次要受眾的進階體驗，降低重複操作成本

---

## Traceability Matrix

| Epic | Epic Name | FRs | NFRs | Story Estimate |
|------|-----------|-----|------|----------------|
| EPIC-001 | 提問模板 | FR-001, FR-002, FR-003 | NFR-001, NFR-002, NFR-003 | 3-5 |
| EPIC-002 | 使用手冊 | FR-004 | NFR-001, NFR-002 | 2-3 |
| EPIC-003 | 自動化編排 | FR-005, FR-006 | NFR-003, NFR-004 | 2-4 |

## Prioritization Summary

**Functional Requirements：** 6 total（3 Must / 1 Should / 1 Could）
**Non-Functional Requirements：** 4 total（3 Must / 1 Should）
**Epics：** 3 total（2 Must / 1 Should）
**Estimated Stories：** 7-12

---

## Dependencies

### Internal
- 研究文件：`圖查訊/research-learning-method.md`（完成）
- 現有 skill：anything-to-notebooklm（SKILL.md 引用）

### External
- NotebookLM（Google 免費服務）
- notebooklm-py CLI v0.3.3+（次要受眾）

## Assumptions

1. NotebookLM 的 ask、generate mind-map、generate quiz 功能持續可用
2. 用戶能自行取得學習材料（書、論文、影片等）並上傳到 NotebookLM
3. 知識四層級（原理→模型→操作→經驗）作為學習順序的理論基礎是有效的

## Out of Scope

1. **經驗層** — 實際應用是用戶的事
2. **額外工具整合** — 不引入新工具（除非確有必要）
3. **自動筆記產出** — 不幫做筆記，與工作流解耦
4. **強制執行順序** — 不綁死步驟順序
5. **由下而上學習法** — 本次只做由上而下
6. **方法論教材** — 未來延伸，現階段不做
7. **Obsidian 整合**（graph-query / qmd）— 未來延伸

## Open Questions

1. 產品正式名稱？（暫定「AI 輔助學習工作流」）
2. 提問模板要放在 repo 的哪個位置？（新 skill 資料夾 or 現有 skill 的 references）
3. 使用手冊的形式？（獨立文件 or README 的一部分）

---

## Recommended Next Steps

1. **Tech Spec**（/bmad:tech-spec）— 定義文件結構、提問模板格式、SKILL.md 架構
2. **開發 EPIC-001**（提問模板）— 核心交付物，優先完成
3. **開發 EPIC-002**（使用手冊）— 搭配提問模板一起交付

---

*Generated based on research document: `圖查訊/research-learning-method.md`*
*PRD session date: 2026-03-09*
