#!/bin/bash
# obsidian-graph-query installer
# Copies the skill into Claude Code's skills directory

set -e

SKILL_NAME="obsidian-graph-query"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills/obsidian-graph-query"

echo "=== $SKILL_NAME Installer ==="
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

# --- Check for existing installation ---

TARGET_DIR="$SKILLS_DIR/$SKILL_NAME"

if [[ -d "$TARGET_DIR" ]]; then
  echo "Existing installation found at: $TARGET_DIR"
  read -rp "Overwrite? (y/N) " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
  fi
  rm -rf "$TARGET_DIR"
fi

# --- Copy skill files ---

echo "Copying skill files..."
cp -r "$SOURCE_DIR" "$TARGET_DIR"

# --- Create vault-config.md from template if not exists ---

CONFIG_FILE="$TARGET_DIR/references/vault-config.md"
TEMPLATE_FILE="$TARGET_DIR/references/vault-config.md.template"

if [[ ! -f "$CONFIG_FILE" ]]; then
  cp "$TEMPLATE_FILE" "$CONFIG_FILE"
  echo "Created vault-config.md from template."
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "Installed to: $TARGET_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit vault-config.md with your vault settings:"
echo "     $CONFIG_FILE"
echo ""
echo "  2. Fill in:"
echo "     - CLI path (Obsidian CLI executable)"
echo "     - Vault name"
echo "     - Excluded folders (JSON array)"
echo "     - Relationship fields (JSON array)"
echo ""
echo "  3. Restart Claude Code to load the skill."
echo ""
echo "  4. Try it: ask Claude \"show me the top hub notes in my vault\""
