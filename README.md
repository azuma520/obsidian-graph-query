# obsidian-graph-query

[繁體中文](README.zh-TW.md)

Turn your Obsidian vault into a queryable knowledge graph — find hub notes, shortest paths, clusters, bridges, orphans, and relationship summaries, all through natural language in Claude Code.

---

## What You Need

Before installing, make sure you have these three things:

1. **[Obsidian](https://obsidian.md/)** — with the [CLI](https://help.obsidian.md/cli) enabled (Settings > General > Command-line interface)
2. **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's CLI for Claude

That's it.

---

## Installation (3 steps)

### Step 1: Clone this repo

Open your terminal and run:

```bash
git clone https://github.com/YOUR_USERNAME/obsidian-graph-query.git
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

When it's done, **restart Claude Code**. The skill is now available in every project.

> **Prefer manual install?** Run `bash install.sh` and edit `vault-config.md` yourself. See `examples/` for reference configs.

---

## What Can It Do?

Just ask Claude in natural language. Here are some examples:

| You say | What happens |
|---------|-------------|
| "What are the most connected notes in my vault?" | Finds your top hub notes by link count |
| "How are [[Note A]] and [[Note B]] connected?" | Finds the shortest path between two notes |
| "What cluster does [[My Note]] belong to?" | Shows all reachable notes from a starting point |
| "Which notes are structural bridges in my vault?" | Finds critical notes whose removal would disconnect the graph |
| "Find orphan notes in my Projects folder" | Lists isolated notes with no links in or out |
| "What relationships does [[My Note]] have?" | Extracts frontmatter relationship fields + link stats |
| "Analyze the relationships around [[Topic X]]" | Multi-step analysis combining graph structure + frontmatter + LLM reasoning |

### Example: hub notes

> **You:** What are the most connected notes?
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

## License

MIT
