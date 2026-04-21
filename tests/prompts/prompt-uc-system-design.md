Le fichier docs/SPEC-racine-*.md contient la spécification complète du projet MaintiX, structurée par cas d'utilisation (format sdd-uc-spec-write). Identifie-le dans docs/.

Produis les documents de conception technique en suivant le processus complet du skill sdd-uc-system-design, sans poser de questions. Considère chaque information de la spécification comme validée par le pilote du projet.

Pour les questions qui nécessiteraient normalement une réponse du pilote, utilise les hypothèses suivantes :

**Cadrage macro (A.1) :**
- Type de solution : SaaS
- Cloud : Azure, région France Central
- Équipe : 2 développeurs full-stack, 1 ops
- Pas d'existant technique (projet from scratch)

**Modèle de données (A.3) :**
- Volumes réalistes : ~200 techniciens, ~50 interventions/jour, ~10 sites
- Rétention des données : 10 ans (réglementaire)

**Choix technologiques (A.5) :**
- Backend : Python / FastAPI (imposé)
- Frontend : React (imposé)
- Base de données : au choix, justifier
- Infrastructure : Azure (imposé)

**Propriétés non-fonctionnelles (A.6) :**
- Disponibilité cible : 99.5%
- Temps de réponse API : < 300ms au P95
- Mode offline sur terminal mobile requis

**Sécurité (Phase C) :**
- Système exposé sur Internet
- Pas de données de santé
- Référentiels : OWASP ASVS, ANSSI Guide d'hygiène
- Pas de DPO nommé (à recruter)

**Conformité (Phase D) :**
- RGPD applicable (données personnelles des techniciens)
- Pas d'autre cadre réglementaire

Produis les 4 fichiers dans docs/ :
- docs/ARCHITECTURE.md
- docs/DEPLOYMENT.md
- docs/SECURITY.md
- docs/COMPLIANCE_MATRIX.md
