# obsidian-graph-query

Obsidian vault 圖查詢 skill for Claude Code。7 個 JS 模板（neighbors、path、cluster、bridges、hubs、orphans-rich、frontmatter-relations），透過 Obsidian CLI eval 執行。

---

## 首次使用：自動設定

當用戶第一次開啟此專案（或說「幫我安裝」「setup」「安裝」），執行以下流程：

### 1. 偵測 Claude Code skills 目錄

依平台偵測：

| 平台 | 路徑 |
|------|------|
| Windows | `$APPDATA/Claude/local-agent-mode-sessions/skills-plugin/` |
| macOS | `~/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin/` |
| Linux | `${XDG_CONFIG_HOME:-~/.config}/Claude/local-agent-mode-sessions/skills-plugin/` |

在該路徑下用 `find` 找到 `skills/` 子目錄（穿過 UUID 子目錄）。

### 2. 詢問用戶 vault 資訊

互動式問以下問題：

1. **Obsidian CLI 路徑**
   - Windows 預設：`/c/Users/<username>/AppData/Local/Programs/Obsidian/Obsidian.com`
   - macOS 預設：`/Applications/Obsidian.app/Contents/MacOS/Obsidian`
   - 提示用戶確認或修改

2. **Vault 名稱**（用於 `vault="..."` 參數）

3. **Vault 路徑**（磁碟上的完整路徑）

4. **排除資料夾**
   - 先用 CLI 列出 vault 的頂層資料夾（`<CLI> vault="<name>" list-folders` 或用 `ls` 讀 vault 路徑）
   - 預設排除 `.obsidian/` 和 `.trash/`
   - 讓用戶勾選還要排除哪些（附件、模板、插件資料夾等）

5. **關係欄位**
   - 用 CLI 或直接讀幾個筆記的 frontmatter，抽樣偵測常用欄位
   - 列出偵測到的欄位讓用戶確認
   - 若偵測不到，提供常見範例讓用戶選

### 3. 生成 vault-config.md

根據用戶回答，生成 `skill/references/vault-config.md`（覆蓋 template）。

### 4. 複製到 skills 目錄

```bash
cp -r skill/ <skills_dir>/obsidian-graph-query/
```

### 5. 驗證

跑一個簡單查詢測試（如 hubs top 5），確認：
- CLI 路徑正確
- Vault 名稱正確
- 排除資料夾生效
- 輸出正常

### 6. 完成提示

告訴用戶：
- 重啟 Claude Code 讓 skill 生效
- 之後在任何目錄都能用，觸發詞：「hub notes」「shortest path」「orphans」「graph query」等
- 想修改設定就編輯 `<skills_dir>/obsidian-graph-query/references/vault-config.md`

---

## 日常使用

設定完成後，此 CLAUDE.md 不再需要。用戶會在其他目錄使用 skill，skill 的 SKILL.md 會指導 Agent 如何執行查詢。

---

## 檔案結構

```
skill/
├── SKILL.md                      ← 主 skill 檔（查詢索引 + 執行流程）
└── references/
    ├── vault-config.md.template  ← 設定模板
    ├── vault-config.md           ← 用戶設定（安裝時生成）
    ├── query-templates.md        ← 7 個 JS 模板（參數化）
    └── relationship-types.md     ← 關係 schema
```
