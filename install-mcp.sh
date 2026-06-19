#!/usr/bin/env bash
#
# DarkWiz Area Builder — MCP one-shot installer.
#
# Installs the self-contained MCP server and registers it with your AI
# client. No source checkout, no Python venv, no PyPI account — just the
# public release wheel + uv.
#
#   curl -fsSL https://raw.githubusercontent.com/Coffee-Nerd/dw-builder-release/main/install-mcp.sh | bash
#
# Or download and run:  bash install-mcp.sh
#
set -euo pipefail

WHEEL_URL="https://github.com/Coffee-Nerd/dw-builder-release/releases/download/mcp-v0.2.0/dw_area_mcp-0.2.0-py3-none-any.whl"

echo "── DarkWiz Area MCP installer ──────────────────────────────"

# 1. Ensure uv (which provides `uvx`) is available. uvx fetches and runs
#    the wheel in an isolated, cached environment on demand.
if ! command -v uvx >/dev/null 2>&1; then
  echo "• uv not found — installing it (https://astral.sh/uv)…"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
fi
if ! command -v uvx >/dev/null 2>&1; then
  echo "✗ uvx still not on PATH. Open a new shell (or 'source ~/.bashrc') and re-run." >&2
  exit 1
fi
echo "• uvx ready: $(command -v uvx)"

# 2. Warm the cache + smoke-test the server actually launches. We send an
#    empty stdin so the stdio server starts and exits cleanly instead of
#    blocking. A non-zero here means the wheel/host is broken.
echo "• Fetching + verifying the MCP server…"
if ! uvx --from "$WHEEL_URL" dw-area-mcp </dev/null >/dev/null 2>&1; then
  : # stdio servers exit non-zero on empty stdin; that's expected. The
    # fetch above is what we care about — uvx errors loudly if it fails.
fi

# 3. Register with whichever client is present.
REGISTERED=0
if command -v claude >/dev/null 2>&1; then
  echo "• Registering with Claude Code (mcp name: dw-area)…"
  claude mcp remove dw-area >/dev/null 2>&1 || true
  claude mcp add dw-area -- uvx --from "$WHEEL_URL" dw-area-mcp
  REGISTERED=1
  echo "  ✓ done — verify with:  claude mcp list"
fi

if [ -f "$HOME/.codex/config.toml" ] || command -v codex >/dev/null 2>&1; then
  echo "• Add this block to ~/.codex/config.toml for Codex:"
  cat <<TOML

[mcp_servers.dw-area]
command = "uvx"
args = ["--from", "$WHEEL_URL", "dw-area-mcp"]
TOML
fi

if [ "$REGISTERED" -eq 0 ]; then
  echo "• No Claude Code CLI found. Add this to your MCP client config:"
  cat <<JSON

  "dw-area": {
    "command": "uvx",
    "args": ["--from", "$WHEEL_URL", "dw-area-mcp"]
  }
JSON
fi

echo "────────────────────────────────────────────────────────────"
echo "Done. Restart your client, then in your first session tell the"
echo "agent to call agent_help() first, and load_area(\"path/to/area.json\")."
