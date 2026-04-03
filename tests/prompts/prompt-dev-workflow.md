Lance le skill /sdd-dev-workflow sur le premier lot du projet.

Pour identifier le premier lot, lis les fichiers dans plan/ et choisis celui
qui n'a aucune dépendance (ou le lot numéro 1).

Suis le processus complet du skill sdd-dev-workflow sans poser de questions.
Considère toutes les décisions techniques comme validées par le pilote.

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
