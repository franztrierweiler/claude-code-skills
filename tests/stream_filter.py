#!/usr/bin/env python3
"""Filtre stream-json de Claude Code : extrait le texte, les outils et la progression."""

import sys
import json

# Couleurs
ORANGE = "\033[38;5;208m"
REVERSE_ORANGE = "\033[7;38;5;208m"
RESET = "\033[0m"

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        obj = json.loads(line)
        msg_type = obj.get("type")

        if msg_type == "assistant":
            for c in obj.get("message", {}).get("content", []):
                ct = c.get("type")
                if ct == "text":
                    print(f"{ORANGE}{c['text']}{RESET}", end="", flush=True)
                elif ct == "tool_use":
                    name = c.get("name", "?")
                    inp = c.get("input", {})
                    detail = ""
                    if name in ("Read", "Write"):
                        detail = inp.get("file_path", "")
                    elif name == "Bash":
                        detail = inp.get("command", "")
                    elif name == "Edit":
                        detail = inp.get("file_path", "")
                    elif name in ("Glob", "Grep"):
                        detail = inp.get("pattern", "")
                    elif name == "Agent":
                        detail = inp.get("description", "")
                    if len(detail) > 80:
                        detail = detail[:77] + "..."
                    print(f"  {REVERSE_ORANGE} {name} {RESET} {ORANGE}{detail}{RESET}", flush=True)

        elif msg_type == "system":
            subtype = obj.get("subtype", "")
            if subtype == "task_progress":
                desc = obj.get("description", "")
                if desc:
                    print(f"{ORANGE}    {desc}{RESET}", flush=True)
            elif subtype == "task_notification":
                status = obj.get("status", "")
                summary = obj.get("summary", "")
                if status == "completed":
                    print(f"{ORANGE}    done: {summary}{RESET}", flush=True)

        elif msg_type == "result":
            # Le texte final est déjà affiché via les messages "assistant".
            # Ne pas le réafficher ici pour éviter le doublon.
            pass

    except (json.JSONDecodeError, KeyError):
        pass
