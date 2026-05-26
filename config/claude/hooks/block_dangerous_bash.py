#!/usr/bin/env python3
"""
PreToolUse hook: Block dangerous or irreversible bash commands before they run.
Fires before every Bash tool call. Checks command against a blocklist and
prompts Claude to explain if a risky-but-allowed pattern is detected.
"""

import json
import sys
import re

# ── Hard blocks — always deny, no exceptions ──────────────────────────────────

HARD_BLOCKED_PATTERNS = [
    # Destructive filesystem ops
    (r"\brm\s+-rf\s+/", "rm -rf on root or near-root path"),
    (r"\brm\s+--no-preserve-root", "rm --no-preserve-root"),
    (r"\bmkfs\b", "mkfs (disk format)"),
    (r"\bdd\b.*of=/dev/", "dd writing to device"),

    # Piping remote scripts directly to shell
    (r"curl\s+.*\|\s*(bash|sh|zsh|python)", "curl piped to shell"),
    (r"wget\s+.*\|\s*(bash|sh|zsh|python)", "wget piped to shell"),
    (r"curl\s+.*\|\s*sudo", "curl piped to sudo"),

    # Privilege escalation
    (r"\bsudo\s+su\b", "sudo su"),
    (r"\bsudo\s+bash\b", "sudo bash"),
    (r"\bsudo\s+chmod\s+777\b", "sudo chmod 777"),

    # Exfiltration via network
    # NOTE: ssh stdin redirect is handled separately in check_command() to allow
    # *.render.com targets (used by the render-console skill).
    (r"\bnc\b.*-e\s+/bin", "netcat reverse shell"),

    # Rails-specific: never drop production DB
    (r"db:drop.*RAILS_ENV=production", "Rails db:drop in production"),
    (r"RAILS_ENV=production.*db:drop", "Rails db:drop in production"),
]

# ── Warn patterns — allow but log a visible warning ──────────────────────────

WARN_PATTERNS = [
    (r"\bsudo\b", "sudo usage"),
    (r"\bchmod\s+777\b", "chmod 777 (world-writable)"),
    (r"\bchmod\s+\+x\b", "making file executable"),
    (r">\s*/etc/", "writing to /etc/"),
    (r"\bkill\s+-9\b", "SIGKILL"),
    (r"RAILS_ENV=production", "production Rails environment"),
    (r"\bgit\s+push\s+.*--force\b", "force git push"),
    (r"\bgit\s+reset\s+--hard\b", "git reset --hard"),
    (r"\bdrop\s+table\b", "DROP TABLE in SQL", re.IGNORECASE),
    (r"\btruncate\s+table\b", "TRUNCATE TABLE in SQL", re.IGNORECASE),
]

# ─────────────────────────────────────────────────────────────────────────────

def check_command(command: str) -> tuple[str, str]:
    """
    Returns ('block', reason) | ('warn', reason) | ('allow', '')
    """
    # ssh stdin redirect — block except for *.render.com (render-console skill)
    if re.search(r"\bssh\b.*@.*\s*<\s*", command):
        if not re.search(r"\bssh\b[^|;&\n]*@[^|;&\n]*\.render\.com\b", command):
            return "block", "ssh with stdin redirect to non-Render host (possible exfil)"

    for entry in HARD_BLOCKED_PATTERNS:
        pattern, label = entry[0], entry[1]
        flags = entry[2] if len(entry) > 2 else 0
        if re.search(pattern, command, flags):
            return "block", label

    for entry in WARN_PATTERNS:
        pattern, label = entry[0], entry[1]
        flags = entry[2] if len(entry) > 2 else 0
        if re.search(pattern, command, flags):
            return "warn", label

    return "allow", ""


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    tool_name = data.get("tool_name", "")
    if tool_name != "Bash":
        sys.exit(0)

    command = data.get("tool_input", {}).get("command", "")
    if not command:
        sys.exit(0)

    verdict, reason = check_command(command)

    if verdict == "block":
        decision = {
            "decision": "block",
            "reason": (
                f"🚫 Security hook blocked command ({reason}):\n"
                f"  {command}\n\n"
                "This command pattern is on the hard blocklist. "
                "If you need to run this, execute it yourself in the terminal."
            )
        }
        print(json.dumps(decision))
        sys.exit(0)

    if verdict == "warn":
        # Print to stderr so it's visible in Claude Code's output without blocking
        print(
            f"⚠️  Hook warning: command contains '{reason}' — proceeding, but double-check this.",
            file=sys.stderr
        )
        sys.exit(0)

    # Allow
    sys.exit(0)


if __name__ == "__main__":
    main()
