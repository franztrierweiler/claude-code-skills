#!/usr/bin/env python3
"""Vérifie que le cartouche d'un SPEC.md contient les champs requis.

Usage : python3 check_cartouche.py <chemin/vers/SPEC.md>

Code retour :
  0 — cartouche conforme
  1 — champ(s) manquant(s) ou invalide(s)
  2 — erreur d'utilisation ou fichier introuvable
"""

import re
import sys

# Champs attendus dans le cartouche (communs racine + extension)
REQUIRED_FIELDS = [
    "Document",
    "UUID",
    "Version",
    "Date",
    "Auteur",
    "Statut",
    "Type",
    "Généré par",
]

# Champs supplémentaires pour les extensions
EXTENSION_FIELDS = [
    "Spec racine",
    "UUID racine",
    "Préfixe",
]

# UUID v4 : 8-4-4-4-12 caractères hexadécimaux
UUID_RE = re.compile(
    r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
    re.IGNORECASE,
)

# Le champ "Document" doit suivre la convention de nommage
# Racine :    SPEC-racine-<NomProjet>.md
# Extension : SPEC-extension-<NomProjet>-<NomFonction>.md
DOCUMENT_RE = re.compile(
    r"SPEC-(racine|extension)-[A-Za-z0-9]+(-[A-Za-z0-9]+)?\.md"
)

# Le champ "Généré par" doit mentionner le skill et une version
GENERE_PAR_RE = re.compile(r"sdd-uc-spec-write\s+v\d+\.\d+\.\d+")

# Le champ "Type" doit être l'une des valeurs autorisées
TYPE_RE = re.compile(r"Document racine|Document d'extension", re.IGNORECASE)

# Le champ "Spec racine" doit pointer vers un fichier racine valide
SPEC_RACINE_RE = re.compile(r"SPEC-racine-[A-Za-z0-9]+\.md")

# Le champ "Préfixe" doit être 3-4 lettres majuscules
PREFIXE_RE = re.compile(r"[A-Z]{3,4}")


def extract_cartouche(text):
    """Extrait les lignes du cartouche (blockquote table commençant par '>')."""
    lines = []
    in_cartouche = False
    for line in text.splitlines():
        stripped = line.strip()
        # Détecte le début du cartouche : ligne blockquote avec un tableau
        if stripped.startswith(">") and "|" in stripped:
            in_cartouche = True
            lines.append(stripped)
        elif in_cartouche:
            if stripped.startswith(">") and "|" in stripped:
                lines.append(stripped)
            else:
                break  # Fin du cartouche
    return "\n".join(lines)


def is_extension(cartouche):
    """Détecte si le cartouche est celui d'un document d'extension."""
    return bool(re.search(r"Document d'extension", cartouche, re.IGNORECASE))


def check_cartouche(text):
    """Vérifie la présence et validité des champs du cartouche.

    Retourne (champs_ok, champs_ko) sous forme de listes de tuples (champ, détail).
    """
    cartouche = extract_cartouche(text)
    ok = []
    ko = []

    if not cartouche:
        return ok, [("Cartouche", "aucun cartouche (blockquote table) détecté")]

    extension = is_extension(cartouche)
    fields_to_check = REQUIRED_FIELDS + (EXTENSION_FIELDS if extension else [])

    for field in fields_to_check:
        pattern = re.compile(re.escape(field), re.IGNORECASE)
        if not pattern.search(cartouche):
            ko.append((field, "absent"))
            continue

        # Validations spécifiques
        if field == "Document":
            if DOCUMENT_RE.search(cartouche):
                ok.append((field, "format de nommage valide"))
            else:
                ko.append((field, "champ présent mais format invalide (attendu : SPEC-<type>-<NomProjet>.md)"))
        elif field == "UUID":
            if UUID_RE.search(cartouche):
                ok.append((field, "format UUID valide"))
            else:
                ko.append((field, "champ présent mais UUID invalide (attendu : format v4)"))
        elif field == "Type":
            if TYPE_RE.search(cartouche):
                ok.append((field, "valeur autorisée"))
            else:
                ko.append((field, "champ présent mais valeur invalide (attendu : Document racine | Document d'extension)"))
        elif field == "Généré par":
            if GENERE_PAR_RE.search(cartouche):
                ok.append((field, "skill et version détectés"))
            else:
                ko.append((field, "champ présent mais format invalide (attendu : sdd-uc-spec-write vX.Y.Z)"))
        elif field == "Spec racine":
            if SPEC_RACINE_RE.search(cartouche):
                ok.append((field, "référence valide"))
            else:
                ko.append((field, "champ présent mais format invalide (attendu : SPEC-racine-<NomProjet>.md)"))
        elif field == "UUID racine":
            if UUID_RE.search(cartouche):
                ok.append((field, "format UUID valide"))
            else:
                ko.append((field, "champ présent mais UUID invalide (attendu : format v4)"))
        elif field == "Préfixe":
            if PREFIXE_RE.search(cartouche):
                ok.append((field, "format valide (3-4 lettres)"))
            else:
                ko.append((field, "champ présent mais format invalide (attendu : 3-4 lettres majuscules)"))
        else:
            ok.append((field, "présent"))

    return ok, ko


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

    ok, ko = check_cartouche(text)

    for field, detail in ok:
        print(f"    \u2713 {field} — {detail}")
    for field, detail in ko:
        print(f"    \u2717 {field} — {detail}")

    sys.exit(1 if ko else 0)


if __name__ == "__main__":
    main()
