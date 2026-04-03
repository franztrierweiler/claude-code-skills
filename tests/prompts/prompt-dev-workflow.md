Identifie le premier lot dans plan/ (celui sans dépendances, ou le numéro 1).

Lance /sdd-dev-workflow <nom-du-lot> sur ce lot.

Considère toutes les décisions techniques comme validées par le pilote.
Ne pose pas de questions.

Contraintes spécifiques pour ce test :
- Utilise Python/FastAPI comme stack backend (imposé par ARCHITECTURE.md)
- Crée un Makefile à la racine du projet avec au minimum les cibles :
  `install` (installation des dépendances), `test` (exécution des tests),
  `lint` (vérification du code)
- Crée un fichier requirements.txt ou pyproject.toml pour les dépendances
- Écris les tests unitaires dans tests/ (pytest)
- Écris le code dans src/
- Mets à jour le fichier plan/<lot>.md avec les statuts AC en fin de workflow

À la fin, exécute `make test` pour vérifier que tous les tests passent.
