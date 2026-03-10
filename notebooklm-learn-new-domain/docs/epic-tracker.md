---
date: 2026-03-09
status: 完成
---

# Epic Tracker：notebooklm-learn-new-domain

## Overview

| Metric | Value |
|--------|-------|
| Total Epics | 3 |
| Total Stories | 6 |
| Must Have | 4 stories |
| Should Have | 1 story |
| Could Have | 1 story |

---

## EPIC-001：提問模板（Must Have）

核心交付物。三個知識層級的具體提問句。

**交付檔案：** `skills/references/prompt-templates.md`

| Story | Title | Priority | Status | Dependencies | Notes |
|-------|-------|----------|--------|-------------|-------|
| S-001 | 原理層提問模板 | Must | done | — | |
| S-002 | 模型層提問模板 | Must | done | S-001（銜接句） | |
| S-003 | 操作層提問模板 | Must | done | S-002（銜接句） | |

---

## EPIC-002：使用手冊（Must Have）

說明工作流的邏輯、順序、使用方式。

**交付檔案：** `skills/references/user-guide.md`

| Story | Title | Priority | Status | Dependencies | Notes |
|-------|-------|----------|--------|-------------|-------|
| S-004 | 使用手冊 | Must | done | S-001, S-002, S-003 | |

---

## EPIC-003：自動化編排（Should Have）

SKILL.md 讓 coding agent 串接 notebooklm-py 自動執行工作流。

**交付檔案：** `skills/SKILL.md`

| Story | Title | Priority | Status | Dependencies | Notes |
|-------|-------|----------|--------|-------------|-------|
| S-005 | SKILL.md 自動化編排 | Should | done | S-001~S-004 | |
| S-006 | 多來源比對指引 | Could | done | S-002 | |

---

## Status Legend

- `pending` — 未開始
- `in_progress` — 開發中
- `review` — 待審查
- `done` — 完成

---

## Change Log

| Date | Change |
|------|--------|
| 2026-03-09 | 建立 Epic Tracker，6 個 Story 全部 pending |
| 2026-03-09 | EPIC-001 完成：S-001~S-003 提問模板（prompt-templates.md） |
| 2026-03-09 | EPIC-002 完成：S-004 使用手冊（user-guide.md） |
| 2026-03-09 | EPIC-003 完成：S-005 SKILL.md + S-006 多來源比對指引 |
