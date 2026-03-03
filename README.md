# obsidian-graph-query

[繁體中文](README.zh-TW.md)

Let your AI agent query your Obsidian vault's knowledge graph directly.

Your vault has a graph. But you can only stare at it.

Obsidian's graph view is beautiful, but it can't answer questions — "Which notes are knowledge hubs?" "How many hops between these two concepts?" "Which notes would break the network if removed?" "How many notes did I write that are actually isolated?"

Graph view can't be queried. Dataview can query single-note links, but can't do cross-node graph traversal. Shortest path, connected components, bridge detection — these require algorithms running on the full adjacency table, and currently no existing tool in the Obsidian ecosystem can do this via natural language. This skill fills that gap: it lets your AI agent run BFS, Tarjan, and degree analysis directly on your vault's link structure. You just describe what you want to know to your agent.

---

## What You Need

1. **[Obsidian](https://obsidian.md/)** — with the [CLI](https://help.obsidian.md/cli) enabled (Settings > General > Command-line interface)
2. **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's CLI for Claude

That's it.

---

## Installation (3 steps)

### Step 1: Clone this repo

Open your terminal and run:

```bash
git clone https://github.com/azuma520/obsidian-graph-query.git
```

### Step 2: Open Claude Code in the cloned folder

```bash
cd obsidian-graph-query
claude
```

### Step 3: Tell Claude to set it up

Type any of these:

```
help me set up
```
```
幫我安裝
```
```
setup
```

Claude will walk you through everything:

- **Finds** your Claude Code skills folder automatically
- **Asks** your vault name and verifies the CLI connection
- **Scans** your vault folders and lets you pick which ones to exclude
- **Detects** your frontmatter relationship fields (or lets you set them manually)
- **Generates** the config, copies files to the right place, and runs a test query

Obsidian must be running during setup so the CLI can connect.

When it's done, **restart Claude Code**. The skill is now available in every project.

> **Prefer manual install?** Run `bash install.sh` and edit `vault-config.md` yourself. See `examples/` for reference configs.

---

## What Can It Do?

Just ask Claude in natural language. Here are some examples:

| You say | What happens |
|---------|-------------|
| "Which notes have the most links in my vault?" | Finds your top hub notes by link count |
| "How are [[Note A]] and [[Note B]] connected?" | Finds the shortest path between two notes |
| "What cluster does [[My Note]] belong to?" | Shows all reachable notes from a starting point |
| "Which notes are structural bridges in my vault?" | Finds critical notes whose removal would disconnect the graph |
| "Find orphan notes in my Projects folder" | Lists isolated notes with no links in or out |
| "What relationships does [[My Note]] have?" | Extracts frontmatter relationship fields + link stats |
| "Analyze the relationships around [[Topic X]]" | Multi-step analysis combining graph structure + frontmatter + LLM reasoning |

### Example: hub notes

> **You:** Which notes have the most links?
>
> **Claude:**
>
> | Note | In | Out | Total |
> |------|----|-----|-------|
> | MOC Index | 45 | 30 | 75 |
> | Core Concept | 40 | 20 | 60 |
> | ... | | | |

### Example: shortest path

> **You:** How are "Machine Learning" and "Neuroscience" connected?
>
> **Claude:** Machine Learning → Neural Networks → Neuroscience (2 hops)

---

## Changing Settings Later

Your config lives at:

```
<Claude Code skills folder>/obsidian-graph-query/references/vault-config.md
```

Open it in any text editor to change:

- **Excluded folders** — folders to skip in queries (e.g. attachments, templates)
- **Relationship fields** — frontmatter fields that link notes together (e.g. `Up`, `Source`, `Related`)

Or just tell Claude: **"update my graph query config"** and it will guide you.

---

## How It Works

1. Claude reads your `vault-config.md` for settings
2. Picks the right JS query template (there are 7 built-in)
3. Fills in your excluded folders and relationship fields
4. Runs the JS via Obsidian CLI's `eval` command
5. Parses the JSON result and presents it in Markdown

Queries use `app.metadataCache.resolvedLinks` — Obsidian's internal link index — so results are always live and up to date.

---

## Technical Architecture

### Data Source

All queries share a single data source: `app.metadataCache.resolvedLinks`. This is the full adjacency table maintained internally by Obsidian — every note's outgoing and incoming links, already resolved. No file crawling or wikilink parsing needed.

### Execution Pipeline

```
User natural language → Agent selects template → Substitutes parameters → Writes temp JS → Obsidian CLI eval → JSON output → Agent parses and presents
```

The JS runs inside Obsidian's Electron main process (via the CLI `eval` command), so it can access the `app` object directly. No extra API needed.

### 7 Query Templates

Each template is a standalone JS IIFE in `skill/references/query-templates.md`.

| Template | Algorithm | Complexity | Description |
|----------|-----------|------------|-------------|
| **neighbors** | BFS | O(V+E) | Expand N hops from a starting note, return neighbors grouped by hop |
| **path** | BFS shortest path | O(V+E) | Unweighted shortest path, returns full path and hop count |
| **cluster** | DFS connected component | O(V+E) | Find the entire connected subgraph. Auto-switches to folder-count mode above 500 nodes |
| **bridges** | Iterative Tarjan | O(V+E) | Find bridge edges and articulation points. Uses iterative version to avoid stack overflow on 2000+ node vaults |
| **hubs** | Degree calculation | O(V+E) | Count in-degree, out-degree, total degree for each note. Supports folder filtering |
| **orphans-rich** | Full scan | O(V+E) | Find notes with zero in-links AND zero out-links, with frontmatter and modification dates. Max 100 results |
| **frontmatter-relations** | Field extraction | O(E) | Extract frontmatter relationship fields from a note with link stats. First step in the relationship-summary workflow |

### Parameterization

Templates use two placeholder types:

- **`{{EXCLUDED_FOLDERS}}`** — JSON array from `vault-config.md`, present in all 7 templates
- **`{{RELATIONSHIP_FIELDS}}`** — JSON array from `vault-config.md`, used only by frontmatter-relations

The agent reads these values from `vault-config.md`, performs string substitution, and writes the resulting JS to a temp file for execution. This lets the same templates work across different vault structures.

### Safety Limits

- cluster: auto-switches to folder-count mode above 500 nodes
- orphans-rich: max 100 results
- bridges: max 50 bridge edges + 30 articulation points
- hubs: user-specified Top N (default 20)

These limits prevent large vault queries (2000+ notes) from flooding the AI's context window.

### Contributing

To add a new query template:

1. Add a new section to `skill/references/query-templates.md`
2. Write a JS IIFE using `{{EXCLUDED_FOLDERS}}` for filtering, returning `JSON.stringify(...)`
3. Add the new template to the query index table in `skill/SKILL.md`
4. Test: substitute your excluded folders into `{{EXCLUDED_FOLDERS}}` and verify output

Template constraints:
- Must be synchronous JS (Obsidian CLI eval doesn't support async)
- Output must be a `return JSON.stringify(...)` string
- Avoid recursion (large vaults will stack overflow) — use iterative algorithms

---

## License

MIT
