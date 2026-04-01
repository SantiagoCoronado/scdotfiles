#!/usr/bin/env python3
"""Claude Code hook logger. Reads hook JSON from stdin and appends structured log lines.

Logs are written per-session: ~/.claude/logs/<date>_<session-id>.log
A latest.log symlink always points to the current session's log.

Usage in settings.json hooks:
  PreToolUse:  "command": "uv run ~/.claude/scripts/log-hook.py pre"
  PostToolUse: "command": "uv run ~/.claude/scripts/log-hook.py post"
  Stop:        "command": "uv run ~/.claude/scripts/log-hook.py stop"
"""

import json
import sys
import os
from datetime import datetime
from pathlib import Path

LOG_DIR = Path.home() / ".claude" / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)


def get_input():
    try:
        return json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        return {}


def get_log_file(data):
    session_id = data.get("session_id", os.environ.get("CLAUDE_SESSION_ID", "unknown"))
    short_id = session_id[:8] if session_id != "unknown" else "unknown"
    date = datetime.now().strftime("%Y-%m-%d")
    log_file = LOG_DIR / f"{date}_{short_id}.log"

    # Update latest.log symlink
    latest = LOG_DIR / "latest.log"
    try:
        latest.unlink(missing_ok=True)
        latest.symlink_to(log_file.name)
    except OSError:
        pass

    return log_file


def extract_summary(event, data):
    tool = data.get("tool_name", "---")

    if event == "stop":
        return "STOP", "---", "session ended"

    tool_input = data.get("tool_input", {})
    if isinstance(tool_input, str):
        try:
            tool_input = json.loads(tool_input)
        except (json.JSONDecodeError, TypeError):
            tool_input = {}

    if event == "pre":
        if tool == "Bash":
            detail = tool_input.get("command", "")[:120]
        elif tool in ("Read", "Write"):
            detail = tool_input.get("file_path", "")
        elif tool in ("Edit", "MultiEdit"):
            detail = tool_input.get("file_path", "")
        elif tool == "Glob":
            detail = tool_input.get("pattern", "")
        elif tool == "Grep":
            detail = tool_input.get("pattern", "")[:80]
        elif tool == "Agent":
            detail = tool_input.get("description", "")[:80]
        else:
            detail = str(tool_input)[:80]
        return "PRE ", tool, detail

    if event == "post":
        # Try multiple paths for exit code
        tool_output = data.get("tool_output", {})
        if isinstance(tool_output, str):
            try:
                tool_output = json.loads(tool_output)
            except (json.JSONDecodeError, TypeError):
                tool_output = {}

        if tool == "Bash":
            exit_code = (
                data.get("exit_code")
                or (tool_output.get("exit_code") if isinstance(tool_output, dict) else None)
                or data.get("tool_result", {}).get("exit_code") if isinstance(data.get("tool_result"), dict) else None
            )
            detail = f"exit:{exit_code}" if exit_code is not None else "ok"
        elif tool in ("Edit", "MultiEdit", "Write"):
            output_str = str(data.get("tool_output", "")).lower()
            detail = "ok" if "success" in output_str else "done"
        else:
            detail = "ok"
        return "POST", tool, detail

    return event.upper(), tool, ""


def main():
    event = sys.argv[1] if len(sys.argv) > 1 else "unknown"
    data = get_input()
    log_file = get_log_file(data)
    tag, tool, detail = extract_summary(event, data)
    timestamp = datetime.now().strftime("%H:%M:%S")

    line = f"[{timestamp}] {tag:<4} {tool:<15} {detail}\n"

    with open(log_file, "a") as f:
        f.write(line)


if __name__ == "__main__":
    main()
