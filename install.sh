#!/bin/bash
# obsidian-graph-query installer
# Copies skills into Claude Code's skills directory

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

SKILLS=(
  "obsidian-graph-query"
  "vault-report"
)

echo "=== Obsidian Graph Query Installer ==="
echo ""

# --- Detect Claude Code skills directory ---

detect_skills_dir() {
  local base=""

  # Windows (Git Bash / MSYS2)
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    base="$APPDATA/Claude/local-agent-mode-sessions/skills-plugin"
  # macOS
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    base="$HOME/Library/Application Support/Claude/local-agent-mode-sessions/skills-plugin"
  # Linux
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    base="${XDG_CONFIG_HOME:-$HOME/.config}/Claude/local-agent-mode-sessions/skills-plugin"
  fi

  if [[ -z "$base" || ! -d "$base" ]]; then
    echo ""
    return
  fi

  # Find the skills directory (traverse the UUID subdirectories)
  local skills_dir
  skills_dir=$(find "$base" -type d -name "skills" -maxdepth 4 2>/dev/null | head -1)
  echo "$skills_dir"
}

SKILLS_DIR=$(detect_skills_dir)

if [[ -z "$SKILLS_DIR" ]]; then
  echo "Could not auto-detect Claude Code skills directory."
  echo ""
  read -rp "Enter the full path to your Claude Code skills directory: " SKILLS_DIR
fi

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "Error: Directory does not exist: $SKILLS_DIR"
  exit 1
fi

echo "Skills directory: $SKILLS_DIR"
echo ""

# --- Install each skill ---

for SKILL_NAME in "${SKILLS[@]}"; do
  echo "--- Installing: $SKILL_NAME ---"

  SOURCE_DIR="$SCRIPT_DIR/skills/$SKILL_NAME"
  TARGET_DIR="$SKILLS_DIR/$SKILL_NAME"

  if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "  Source not found: $SOURCE_DIR (skipping)"
    echo ""
    continue
  fi

  if [[ -d "$TARGET_DIR" ]]; then
    echo "  Existing installation found."
    read -rp "  Overwrite $SKILL_NAME? (y/N) " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "  Skipped."
      echo ""
      continue
    fi
    rm -rf "$TARGET_DIR"
  fi

  cp -r "$SOURCE_DIR" "$TARGET_DIR"
  echo "  Copied to: $TARGET_DIR"

  # Create vault-config.md from template (obsidian-graph-query only)
  if [[ "$SKILL_NAME" == "obsidian-graph-query" ]]; then
    CONFIG_FILE="$TARGET_DIR/references/vault-config.md"
    TEMPLATE_FILE="$TARGET_DIR/references/vault-config.md.template"
    if [[ ! -f "$CONFIG_FILE" ]]; then
      cp "$TEMPLATE_FILE" "$CONFIG_FILE"
      echo "  Created vault-config.md from template."
    fi
  fi

  echo ""
done

echo "=== Installation complete ==="
echo ""
echo "Installed skills:"
for SKILL_NAME in "${SKILLS[@]}"; do
  if [[ -d "$SKILLS_DIR/$SKILL_NAME" ]]; then
    echo "  - $SKILL_NAME"
  fi
done
echo ""
echo "Next steps:"
echo "  1. Edit vault-config.md with your vault settings:"
echo "     $SKILLS_DIR/obsidian-graph-query/references/vault-config.md"
echo ""
echo "  2. Fill in: CLI path, Vault name, Excluded folders, Relationship fields"
echo ""
echo "  3. Restart Claude Code to load the skills."
echo ""
echo "  4. Try it:"
echo "     - \"show me the top hub notes in my vault\""
echo "     - \"generate a vault knowledge graph report\""
