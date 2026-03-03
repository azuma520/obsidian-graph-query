# obsidian-graph-query

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that runs graph queries on your Obsidian vault's link structure. Find hub notes, shortest paths, clusters, bridges, orphans, and relationship summaries — all through natural language.

## Prerequisites

- [Obsidian](https://obsidian.md/) (open and running)
- [Obsidian CLI](https://help.obsidian.md/cli) (for `eval` command)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/obsidian-graph-query.git
cd obsidian-graph-query
bash install.sh
```

The installer will:
1. Detect your Claude Code skills directory
2. Copy the skill files
3. Create `vault-config.md` from the template

Then edit `vault-config.md` with your vault settings and restart Claude Code.

## Configuration

Edit `vault-config.md` (created by the installer) to set:

### CLI Path & Vault Name

```markdown
| CLI 路徑 | `/c/Users/you/AppData/Local/Programs/Obsidian/Obsidian.com` |
| Vault 名稱 | `My Vault` |
```

### Excluded Folders

Folders to skip in all graph queries (JSON array):

```json
[".obsidian/", ".trash/", "attachments/", "templates/"]
```

### Relationship Fields

Frontmatter fields that represent note-to-note relationships (JSON array):

```json
["Up", "Source", "References", "Related"]
```

See `examples/` for complete configuration examples:
- `vault-config-zettelkasten.md` — Zettelkasten / card-based vault
- `vault-config-biomedical.md` — Biomedical knowledge base

## Queries

| Query | Description | Example prompt |
|-------|-------------|----------------|
| **neighbors** | Find notes within N hops | "Show me notes within 2 hops of [[BFS]]" |
| **path** | Shortest path between two notes | "How are [[Note A]] and [[Note B]] connected?" |
| **cluster** | All reachable notes (connected component) | "What cluster does [[My Note]] belong to?" |
| **bridges** | Critical edges and articulation points | "Which notes are structural bridges in my vault?" |
| **hubs** | Top N most-connected notes | "What are the top 20 hub notes?" |
| **orphans-rich** | Isolated notes with frontmatter | "Find orphan notes in my Projects folder" |
| **frontmatter-relations** | Relationship field extraction | "What relationships does [[My Note]] have?" |
| **relationship-summary** | Multi-step relationship analysis | "Analyze the relationships around [[Topic X]]" |

## Example Conversations

### Find hub notes

> **You:** What are the most connected notes in my vault?
>
> **Claude:** *(runs hubs query, returns top 20 sorted by total degree)*
>
> | Note | In | Out | Total |
> |------|----|-----|-------|
> | MOC Index | 45 | 30 | 75 |
> | Core Concept | 40 | 20 | 60 |
> | ... | | | |

### Find shortest path

> **You:** How are "Machine Learning" and "Neuroscience" connected?
>
> **Claude:** *(searches for notes, runs path query)*
>
> Machine Learning → Neural Networks → Neuroscience (2 hops)

### Analyze relationships

> **You:** What are the relationships around my note on "Spinal Fusion"?
>
> **Claude:** *(runs frontmatter-relations + neighbors, reads relationship fields)*
>
> | Relation | Type | Source |
> |----------|------|--------|
> | → Medtronic | company | ✅ frontmatter |
> | → Titanium alloy | materials | ✅ frontmatter |
> | ← TLIF Procedure | references | ✅ frontmatter |

## How It Works

1. Claude reads your `vault-config.md` for settings
2. Selects the appropriate JS query template
3. Substitutes your excluded folders and relationship fields into the template
4. Writes the JS to a temp file and executes via Obsidian CLI's `eval` command
5. Parses the JSON output and presents results in Markdown

All queries use `app.metadataCache.resolvedLinks` — the complete link adjacency table maintained by Obsidian — so results are always up to date.

## Project Structure

```
obsidian-graph-query/
├── README.md
├── install.sh
├── skill/
│   ├── SKILL.md                      ← Main skill file
│   └── references/
│       ├── vault-config.md.template  ← Configuration template
│       ├── query-templates.md        ← 7 JS query templates
│       └── relationship-types.md     ← Relationship schema
└── examples/
    ├── vault-config-zettelkasten.md  ← Zettelkasten vault example
    └── vault-config-biomedical.md    ← Biomedical KB example
```

## License

MIT
