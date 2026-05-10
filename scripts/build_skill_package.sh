#!/usr/bin/env bash
# Package skill/SKILL.md as installable bundles + a flat system-prompt file.
#
# Outputs (under dist/):
#   dongsam-summary.zip     — ZIP archive containing dongsam-summary/SKILL.md.
#                             Claude Desktop: upload via Settings > Skills.
#                             Claude Code:    unzip into ~/.claude/skills/.
#   dongsam-summary.skill   — same archive, .skill extension.
#   prompt.md               — flat system-prompt copy of SKILL.md body
#                             (no frontmatter); paste into ChatGPT Custom GPT
#                             instructions, Gemini Gem system prompt, Codex
#                             AGENTS.md, Cursor rules, etc.
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"
SRC="$ROOT/skill/SKILL.md"
DIST="$ROOT/dist"
NAME="dongsam-summary"

if [[ ! -f "$SRC" ]]; then
  echo "error: $SRC not found" >&2
  exit 1
fi

mkdir -p "$DIST"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/$NAME"
cp "$SRC" "$WORK/$NAME/SKILL.md"

(cd "$WORK" && zip -qr "$DIST/$NAME.zip" "$NAME")
cp "$DIST/$NAME.zip" "$DIST/$NAME.skill"

# Flat system-prompt: drop the YAML frontmatter, keep the body.
awk 'BEGIN{f=0} /^---[[:space:]]*$/{f++; next} f>=2{print}' "$SRC" \
  > "$DIST/prompt.md"

echo "wrote $DIST/$NAME.zip ($(wc -c < "$DIST/$NAME.zip") bytes)"
echo "wrote $DIST/$NAME.skill (= same archive)"
echo "wrote $DIST/prompt.md ($(wc -c < "$DIST/prompt.md") bytes, frontmatter stripped)"
echo ""
echo "Claude Code (project-local): unzip $NAME.zip into .claude/skills/"
echo "Claude Code (global):        unzip $NAME.zip into ~/.claude/skills/"
echo "Claude Desktop / claude.ai:  upload $NAME.skill via Settings > Skills"
echo "ChatGPT / Gemini / Codex:    paste prompt.md as the system prompt"
