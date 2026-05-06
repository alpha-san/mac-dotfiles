#!/usr/bin/env python3
"""
PreToolUse hook: Block Claude from reading files that may contain secrets.
Fires before Read/Write/Edit tools. Returns a block decision if the target
file matches known sensitive patterns.
"""

import json
import sys
import os
import re

# ── Patterns to block ────────────────────────────────────────────────────────

BLOCKED_FILENAMES = {
    ".env",
    ".env.local",
    ".env.production",
    ".env.staging",
    ".env.development",
    ".env.test",
    "secrets.yml",
    "secrets.yaml",
    "database.yml",       # Rails — may contain DB creds
    "credentials.yml.enc", # Rails encrypted creds (safe to read, but block anyway)
    "master.key",         # Rails master key — NEVER share
    "config/master.key",
    ".netrc",
    ".npmrc",             # May contain auth tokens
    ".pypirc",
    "id_rsa",
    "id_ed25519",
    "id_ecdsa",
}

BLOCKED_EXTENSIONS = {
    ".pem",
    ".key",
    ".p12",
    ".pfx",
    ".cer",
    ".crt",
}

BLOCKED_PATH_PATTERNS = [
    r"/\.ssh/",
    r"/\.aws/credentials",
    r"/\.aws/config",
    r"/\.config/gcloud/",
    r"keystore",
    r"private_key",
    r"secret_key",
]

# ── Main logic ────────────────────────────────────────────────────────────────

def is_sensitive(file_path: str) -> tuple[bool, str]:
    """Returns (blocked: bool, reason: str)."""
    basename = os.path.basename(file_path)
    _, ext = os.path.splitext(basename)

    if basename in BLOCKED_FILENAMES:
        return True, f"sensitive filename: {basename}"

    if ext.lower() in BLOCKED_EXTENSIONS:
        return True, f"sensitive file extension: {ext}"

    for pattern in BLOCKED_PATH_PATTERNS:
        if re.search(pattern, file_path, re.IGNORECASE):
            return True, f"sensitive path pattern matched: {pattern}"

    return False, ""


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # Can't parse input — fail open (allow) to avoid breaking normal usage
        sys.exit(0)

    tool_input = data.get("tool_input", {})

    # Read tool uses "file_path"; Write/Edit use "path"
    file_path = tool_input.get("file_path") or tool_input.get("path", "")

    if not file_path:
        sys.exit(0)

    blocked, reason = is_sensitive(file_path)

    if blocked:
        decision = {
            "decision": "block",
            "reason": (
                f"🔒 Security hook blocked access to '{file_path}' ({reason}). "
                "This file may contain secrets or credentials. "
                "If you genuinely need to view this file, do it yourself in the terminal."
            )
        }
        print(json.dumps(decision))
        sys.exit(0)

    # Allow
    sys.exit(0)


if __name__ == "__main__":
    main()
