# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 專案性質

這個 repo 包含兩個產品：

1. **obsidian-graph-query skill**（產品 A）— Claude Code skill，用 Obsidian CLI eval 在 vault 連結結構上跑圖演算法。沒有 build system、沒有 dependencies、沒有 tests。「程式碼」是嵌在 Markdown 裡的 JS IIFE 模板。
2. **筆記系統升級**（產品 B）— 用戶的 Obsidian vault 知識管理系統設計。skill 是工具，筆記系統是用工具服務的對象。設計文檔在 `圖查訊/` 資料夾。

## 用戶的筆記系統

- **Vault**：`C:\Users\user\OneDrive\文件\あずま的資料庫`（約 1,253 篇，永久筆記 536 篇）
- **方法論**：Zettelkasten + PAI（雷蒙）混合體
  - 學習線（Zettelkasten）：文獻筆記 → 永久筆記
  - 執行線（PAI）：專案筆記 → 行動筆記 → 復盤 → 知識萃取
  - 每日筆記：兩條線的交匯點
- **核心問題**：跨線連結沒有結構化欄位（學習線 ↔ 執行線之間缺少可查詢的關係）
- **待整合**：現有 vault 結構 + Agent 互動架構（來自 Telegram Bot 專案）+ graph-query 分析能力

## 工作要求

- **漸進式披露**：資訊按層級、按需求展開，不一次全倒
- **分層負責**：每個文件有明確角色，不越界（開發文件 vs 使用者文件 嚴格分離）
- **即時更新**：文件應反映當前狀態，發現不一致就修
- **先策劃再動手**：動手前先規劃，想清楚用什麼工具、什麼順序
- **善用工具**：如有更好的工具（MCP server、CLI tool 等）能提升效率，主動建議安裝
- **按需調用文檔**：依任務需要讀取相關文件取得背景上下文，不要預設全讀
- **研究/調查用 subagent**：探索、搜尋、研究類工作，開 Task agent 去做
- **複雜任務開 team**：多步驟平行任務，開 agents team 處理
- **設計決策放文檔**：設計構想、決策討論放在 `圖查訊/` 的文件裡，memory 只放背景概念摘要和實作筆記

## 文件角色

| 檔案 | 角色 | 讀者 |
|------|------|------|
| `CLAUDE.md` | 開發憲法：專案性質、工作要求、代碼風格 | 開發者的 Claude Code |
| `SKILL.md` | 查詢執行協議 | 使用者的 agent（日常使用） |
| `references/setup-guide.md` | 安裝引導流程 | 使用者的 agent（首次設定） |
| `圖查訊/` | 筆記系統設計文檔 + 開發筆記 | 開發者的 Claude Code |
| `.claude/memory/` | 背景概念摘要 + 實作筆記 | 開發者的 Claude Code |

## 代碼風格

- JS 模板必須是同步 IIFE（CLI eval 不支援 async）
- 大 vault（2000+ 節點）必須用迭代演算法，禁止遞迴（stack overflow）
- 輸出一律 `JSON.stringify(...)`，加安全閥防 context window 爆量
- 所有模板用 `{{EXCLUDED_FOLDERS}}` 做排除，`{{RELATIONSHIP_FIELDS}}` 僅關係類模板使用
- 資料來源：`app.metadataCache.resolvedLinks`
- frontmatter key 維持英文（JS 穩定度），值可中文化（使用者設定的變數）

## Repo Structure

- `skills/obsidian-graph-query/` — skill 原始碼（source of truth）
  - `SKILL.md` — agent 執行協議
  - `references/query-templates.md` — 8 個 JS 模板
  - `references/relationship-types.md` — 關係 schema + LLM 推理 prompt
  - `references/setup-guide.md` — 使用者安裝引導
  - `references/vault-config.md.template` — 設定模板
  - `references/vault-config.md` — 用戶設定（gitignored）
- `skills/vault-report/SKILL.md` — 報告 skill（依賴 obsidian-graph-query）
- `.agents/` — `npx skills add` 產生的本地副本（gitignored）
- `examples/` — 不同 vault 風格的設定範例
- `圖查訊/` — 筆記系統設計文檔 + 開發筆記（不發布）
  - `note-system-upgrade.md` — 系統升級主討論文檔
  - `types.md` — 筆記類型定義（概念/經驗/工具/洞察/參考）
  - `concept-*.md` / `insight-*.md` / `exp-*.md` — 各主題討論筆記

## 語言慣例

- Skill 文件（SKILL.md、references）：繁體中文
- README：雙語（English + 繁體中文）
- Commit messages：English
- 日常對話：繁體中文

## 新增查詢模板

1. 在 `references/query-templates.md` 加 JS IIFE section
2. 用 `{{EXCLUDED_FOLDERS}}` 排除，輸出 `JSON.stringify(...)`
3. 在 `SKILL.md` 查詢索引表加入新模板
4. 加安全閥（cap output arrays）
5. 更新 README 表格（如果使用者可見）

## 測試

無自動化測試。手動驗證：
1. 把排除資料夾代入 `{{EXCLUDED_FOLDERS}}`
2. 寫到 `/tmp/obsidian_graph_query.js`
3. 執行：`<CLI> vault="<name>" eval code='eval(require("fs").readFileSync("C:/tmp/obsidian_graph_query.js","utf8"))'`
4. 確認 JSON 合法且在安全閥範圍內

> Windows 注意：Write 工具用 `/tmp/...`，eval 路徑用 `C:/tmp/...`

## User Setup

當用戶說「幫我安裝」「setup」「安裝」，讀取 `skills/obsidian-graph-query/references/setup-guide.md` 並依流程執行。
