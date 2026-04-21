#!/usr/bin/env python3
"""Vérifie que chaque UC d'un SPEC.md contient les champs structurels requis.

Usage : python3 check_uc_fields.py <chemin/vers/SPEC.md>

Code retour :
  0 — tous les UC sont conformes
  1 — au moins un champ manquant détecté
"""

import re
import sys

REQUIRED_FIELDS = [
    "Résumé",
    "Acteurs",
    "État initial",
    "État final",
    "Étapes",
    "Exceptions",
    "Règles de gestion",
    "Critères d'acceptation",
]

UC_HEADER_RE = re.compile(r"^#{3,5}\s+\*{0,2}(UC-(?:[A-Z]{3,4}-)?\d+)\*{0,2}\s*:", re.MULTILINE)


def extract_uc_blocks(text):
    """Découpe le texte en blocs (id_uc, contenu) entre deux en-têtes UC."""
    matches = list(UC_HEADER_RE.finditer(text))
    blocks = []
    for i, m in enumerate(matches):
        start = m.start()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        blocks.append((m.group(1), text[start:end]))
    return blocks


def check_block(uc_id, block):
    """Retourne la liste des champs manquants dans un bloc UC."""
    missing = []
    for field in REQUIRED_FIELDS:
        pattern = re.compile(re.escape(field), re.IGNORECASE)
        if not pattern.search(block):
            missing.append(field)
    return missing


def main():
    if len(sys.argv) != 2:
        print(f"Usage : {sys.argv[0]} <SPEC.md>", file=sys.stderr)
        sys.exit(2)

    path = sys.argv[1]
    try:
        with open(path, encoding="utf-8") as f:
            text = f.read()
    except FileNotFoundError:
        print(f"Fichier introuvable : {path}", file=sys.stderr)
        sys.exit(2)

    blocks = extract_uc_blocks(text)
    if not blocks:
        print("  Aucun UC détecté dans le fichier.")
        sys.exit(1)

    fail = False
    for uc_id, block in blocks:
        missing = check_block(uc_id, block)
        if missing:
            print(f"    ✗ {uc_id} — champs manquants : {', '.join(missing)}")
            fail = True
        else:
            print(f"    ✓ {uc_id}")

    sys.exit(1 if fail else 0)


if __name__ == "__main__":
    main()
