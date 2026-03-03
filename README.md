<div align="center">

# obsidian-graph-query

[繁體中文](README.zh-TW.md)

*Let your AI agent query your Obsidian vault's knowledge graph directly*

[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-orange?style=flat-square)](https://docs.anthropic.com/en/docs/claude-code)
[![Obsidian](https://img.shields.io/badge/Obsidian-CLI-7c3aed?style=flat-square)](https://help.obsidian.md/cli)

[Why](#why) · [Installation](#installation) · [Queries](#what-can-you-ask) · [Architecture](#technical-architecture) · [Contributing](#contributing)

</div>

---

Your vault has a graph. But you can only stare at it.

Obsidian's graph view is beautiful, but it can't answer questions — "Which notes have the most links?" "How many hops between these two concepts?" "Which notes would break the network if removed?" "How many notes are completely isolated?"

This skill lets your AI agent run graph algorithms directly on your vault's link structure — BFS, shortest path, Tarjan bridge detection, degree analysis — and explain the results to you in natural language.

## Why

**More notes, more lost.** At 500 notes you still rely on memory. At 2000+ you have no idea what your knowledge base looks like. Which are the core nodes? Which clusters aren't connected? Graph view shows you big dots and small dots, but you can't get numbers, and you can't ask it "who's in the top 20."

**Orphan notes are silent waste.** Notes you spent time writing, with no links in or out, sitting at the bottom of your vault. You don't even know they exist.

**Structural weaknesses are invisible risks.** A single note might be the only bridge between two knowledge clusters — move or delete it, and the whole network splits. Obsidian won't warn you.

**Graph view can explore, but it can't query.** You can zoom, drag, see local structure. But you can't quantify it, can't ask it questions.

**Graph view can't be queried. Dataview can query single-note links but can't do cross-node graph traversal.** Shortest path, connected components, bridge detection — these require algorithms running on the full adjacency table. Currently no existing tool in the Obsidian ecosystem can do this via natural language. This skill fills that gap: you just describe what you want to know to your agent.

## What You Need

1. **[Obsidian](https://obsidian.md/)** — with the [CLI](https://help.obsidian.md/cli) enabled (Settings > General > Command-line interface)
2. **Any supported AI agent** — Claude Code, OpenClaw, Cursor, Cline, GitHub Copilot, Windsurf, and 25+ more

That's it.

## Installation

### Quick Install (1 command)

```bash
npx skills add azuma520/obsidian-graph-query
```

Then open Claude Code and say **"help me set up"** — Claude will walk you through vault configuration.

### Manual Install (3 steps)

<details>
<summary>Click to expand</summary>

#### Step 1: Clone

```bash
git clone https://github.com/azuma520/obsidian-graph-query.git
```

#### Step 2: Open Claude Code

```bash
cd obsidian-graph-query
claude
```

#### Step 3: Say "help me set up"

```
help me set up
```

Claude will walk you through everything — detect your environment, ask for vault info, scan folder structure, generate config, and run a test query.

</details>

> [!IMPORTANT]
> Obsidian must be running during setup so the CLI can connect.

When it's done, restart Claude Code. The skill is now available in every project.

> [!TIP]
> Prefer `bash install.sh`? That works too — just edit `vault-config.md` yourself afterward.

## What Can You Ask

| You say | What happens |
|---------|-------------|
| "Which notes have the most links?" | Degree analysis, finds top hub nodes by link count |
| "How are [[Note A]] and [[Note B]] connected?" | BFS shortest path, shows the notes in between |
| "What's around [[this note]]?" | N-hop neighbor expansion, local knowledge network |
| "Which notes would break the network if removed?" | Tarjan algorithm finds bridge edges and articulation points |
| "Find isolated notes with no links" | Full vault scan, lists zero-link notes + frontmatter info |
| "Analyze the relationship structure of [[Topic X]]" | Multi-step analysis: graph structure + frontmatter fields + LLM reasoning |

### What it looks like

> **You:** Which notes have the most links?
>
> **Claude:**
>
> | Note | In | Out | Total |
> |------|----|-----|-------|
> | MOC Index | 45 | 30 | 75 |
> | Core Concept | 40 | 20 | 60 |
> | Learning Methods | 35 | 15 | 50 |

> **You:** How are "Machine Learning" and "Neuroscience" connected?
>
> **Claude:** Machine Learning → Neural Networks → Neuroscience (2 hops)

> **You:** Any orphan notes?
>
> **Claude:** Found 23 isolated notes in the "Permanent Notes" folder. The 5 most recently modified are...

## Changing Settings Later

Tell Claude "update my graph query config", or edit directly:

```
<Claude Code skills folder>/obsidian-graph-query/references/vault-config.md
```

You can adjust excluded folders (attachments, templates, etc.) and relationship fields (`Up`, `Source`, `References`, etc.).

## How It Works

```
User natural language → Agent selects template → Substitutes parameters → Writes temp JS → Obsidian CLI eval → JSON output → Agent parses and presents
```

The JS runs inside Obsidian's Electron main process (via the CLI `eval` command), accessing the `app` object directly. Data source is `app.metadataCache.resolvedLinks` — Obsidian's live link index, not a static snapshot.

## Technical Architecture

### 7 Query Templates

Each template is a standalone JS IIFE in `skills/obsidian-graph-query/references/query-templates.md`.

| Template | Algorithm | Complexity | Description |
|----------|-----------|------------|-------------|
| **neighbors** | BFS | O(V+E) | Expand N hops from a starting note, return neighbors grouped by hop |
| **path** | BFS shortest path | O(V+E) | Unweighted shortest path with full path and hop count |
| **cluster** | DFS connected component | O(V+E) | Find the entire connected subgraph. Auto-switches to folder-count mode above 500 nodes |
| **bridges** | Iterative Tarjan | O(V+E) | Find bridge edges and articulation points. Uses iterative version to avoid stack overflow on 2000+ node vaults |
| **hubs** | Degree calculation | O(V+E) | Count in-degree, out-degree, total degree. Supports folder filtering |
| **orphans-rich** | Full scan | O(V+E) | Find notes with zero in-links AND zero out-links, with frontmatter and dates. Max 100 results |
| **frontmatter-relations** | Field extraction | O(E) | Extract frontmatter relationship fields + link stats from a note |

### Parameterization

Templates use two placeholder types, substituted from `vault-config.md` before execution:

- **`{{EXCLUDED_FOLDERS}}`** — JSON array of folders to skip, present in all 7 templates
- **`{{RELATIONSHIP_FIELDS}}`** — JSON array of frontmatter field names, used by frontmatter-relations only

### Safety Limits

| Limit | Reason |
|-------|--------|
| cluster > 500 nodes → folder-count mode | Prevent output explosion |
| orphans-rich max 100 results | Prevent output explosion |
| bridges max 50 edges + 30 nodes | Prevent output explosion |
| hubs user-specified Top N (default 20) | User-controlled |

These limits prevent large vault queries (2000+ notes) from flooding the AI's context window.

## Contributing

To add a new query template:

1. Add a new section to `skills/obsidian-graph-query/references/query-templates.md`
2. Write a JS IIFE using `{{EXCLUDED_FOLDERS}}` for filtering, returning `JSON.stringify(...)`
3. Add the new template to the query index table in `skills/obsidian-graph-query/SKILL.md`
4. Test: substitute your excluded folders and verify output

> [!NOTE]
> Template constraints: must be synchronous JS (CLI eval doesn't support async), avoid recursion (large vaults will stack overflow), output must be a JSON string.
