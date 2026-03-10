[繁體中文](README.zh-TW.md)

# NotebookLM — Learn New Domain

A learning workflow that helps you build a structured understanding of any unfamiliar domain.

Upload your learning materials to [Google NotebookLM](https://notebooklm.google.com/), follow a set of prompts in order, and build a knowledge map of the domain from scratch. All answers are grounded in **your** materials, not generic AI knowledge.

## How It Works

The workflow breaks learning into 3 layers, each building on the previous:

| Layer | What you do | What you get |
|-------|------------|--------------|
| **Principles** (Q1-Q4) | Extract terms, logic, phenomena, first principles | A vocabulary table + causal network + 3 core principles |
| **Models** (Q5-Q7) | Find expert frameworks, debates or alternatives, knowledge map | 3-5 frameworks + a mind map of how they relate |
| **Operations** (Q8-Q9) | Quiz yourself, challenge your understanding, form opinions | Verified understanding + your own informed stance |

> [!TIP]
> Q4 (First Principles) consistently produces 3 memorable principles that let you reconstruct the entire domain. In 4 tests across different fields, this was the single most impactful output.

## Two Ways to Use

### Manual (for everyone)

No tools needed. Open the [Prompt Templates](skills/references/prompt-templates.md), copy each prompt into NotebookLM, and read the answers in order.

For the full methodology explanation, see the [User Guide](skills/references/user-guide.md).

### Automated (for Claude Code users)

Install as a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills):

```bash
npx skills add <path-or-url>/notebooklm-learn-new-domain/skills
```

Requires [notebooklm-py](https://github.com/nicobailon/notebooklm-py) (>= 0.3.3). The agent runs the full workflow automatically — source curation, prompt selection (including Q6 A/B branching), artifact generation, and pacing.

## Prompt Overview

| # | Prompt | Layer | Purpose |
|---|--------|-------|---------|
| Q1 | Core Terminology | Principles | Build a terminology map |
| Q2 | Causal Logic | Principles | Trace cause-effect relationships |
| Q3 | Key Phenomena | Principles | Identify key phenomena |
| Q4 | First Principles | Principles | Distill foundational principles |
| Q5 | Mental Models | Models | Extract thinking frameworks |
| Q6 | Debates (A) or Alternatives (B) | Models | Identify debates / compare approaches |
| Q7 | Knowledge Map (A/B) | Models | Build a knowledge structure |
| Q8 | Follow-up | Operations | Probe mistakes in depth |
| Q9 | Take a Stance (A/B) | Operations | Form your own judgment |

Q6 has two versions: **Q6-A** (core debates) for academic/policy/ethics domains, and **Q6-B** (alternative comparisons) for technical/tool/framework domains. Q7 and Q9 follow the same A/B selection.

## Source Curation

Learning quality depends more on **what you upload** than on the prompts. Aim for this triangle:

| Role | What to look for |
|------|-----------------|
| **Overview** | Wikipedia, introductory guides, textbook chapters |
| **Authoritative** | Official docs, classic papers, technical specs |
| **Perspectives** | Reviews, opinion pieces, comparison articles |

Having all three gives the best results.

## Tested Domains

Validated across social science, pure technical, and mixed (tech + ethics + business) domains.

## Scope

> [!NOTE]
> This workflow builds a **knowledge map** — you'll walk away knowing the core concepts, key frameworks, and the tradeoffs between different approaches. Try applying what you learned to a real problem next — knowledge becomes yours when you put it into practice.
