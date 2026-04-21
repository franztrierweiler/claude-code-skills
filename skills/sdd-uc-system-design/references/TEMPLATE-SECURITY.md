# [Nom du projet] — Sécurité

> | | |
> |---|---|
> | **Document** | SECURITY.md |
> | **Version** | 1.0 |
> | **Date** | [YYYY-MM-DD] |
> | **Auteur** | [Nom] |
> | **Spec de référence** | [nom du fichier SPEC] v[X.Y] |
> | **Architecture de référence** | ARCHITECTURE.md v[X.Y] |
> | **Généré par** | sdd-uc-system-design v3.3.0 |

## 1. Vue d'ensemble sécurité

<!-- Résumé en 3-5 phrases : périmètre de sécurité, niveau de sensibilité
des données traitées, principaux vecteurs de menace identifiés,
référentiels applicables. -->

[Description]

**Classification des données :** [Public | Interne | Confidentiel | Secret]
**Exposition réseau :** [Internet | Réseau interne | Isolé]
**Référentiels appliqués :** [ex: ANSSI (Guide d'hygiène), OWASP ASVS v4, CIS Benchmarks]
**Référentiels sectoriels :** [ex: PGSSI-S (santé), PCI-DSS (paiement), DORA (finance), NIS2 (services essentiels) — ou "Aucun" si non applicable]

## 2. Modèle de menaces

<!-- Identifier les acteurs malveillants, les vecteurs d'attaque et les
frontières de confiance du système AVANT de lister les exigences. Sans
modèle de menaces, les exigences ne sont pas priorisées.
Source : OWASP ASVS Ch.1, STRIDE. -->

### 2.1 Surface d'attaque

<!-- Lister tous les points d'entrée du système (issus des acteurs et
des interfaces du SPEC.md). Pour chaque point, évaluer l'exposition. -->

| Point d'entrée | Type | Exposition | Données accessibles | Niveau de risque |
|----------------|------|-----------|---------------------|-----------------|
| [ex: API REST publique] | [ex: HTTPS] | [ex: Internet] | [ex: Données utilisateur] | [Critique / Élevé / Modéré / Faible] |
| [ex: Interface admin] | [ex: HTTPS] | [ex: VPN interne] | [ex: Configuration, données complètes] | [Critique / Élevé / Modéré / Faible] |
| [ex: Upload fichiers] | [ex: Multipart HTTP] | [ex: Internet] | [ex: Stockage serveur] | [Critique / Élevé / Modéré / Faible] |

### 2.2 Acteurs malveillants

| Acteur | Motivation | Capacités | Cibles principales |
|--------|-----------|-----------|-------------------|
| [ex: Attaquant externe non authentifié] | [ex: Vol de données, déni de service] | [ex: Outils automatisés, scanners] | [ex: API publique, formulaires] |
| [ex: Utilisateur malveillant authentifié] | [ex: Élévation de privilèges, accès non autorisé] | [ex: Compte valide, connaissance de l'application] | [ex: Endpoints API, données d'autres utilisateurs] |
| [ex: Insider (développeur, opérateur)] | [ex: Exfiltration de données] | [ex: Accès au code, à l'infra, aux secrets] | [ex: Base de données, logs, backups] |

### 2.3 Frontières de confiance

<!-- Schéma ou tableau identifiant les zones de confiance du système.
Chaque franchissement de frontière nécessite une validation. -->

| Frontière | De | Vers | Contrôles requis |
|-----------|-----|------|-----------------|
| [ex: Internet → API] | [ex: Zone non fiable] | [ex: Zone applicative] | [ex: TLS, authentification, rate limiting, WAF] |
| [ex: API → Base de données] | [ex: Zone applicative] | [ex: Zone données] | [ex: Requêtes paramétrées, accès par rôle dédié] |
| [ex: Admin → Infrastructure] | [ex: Réseau interne] | [ex: Zone infra] | [ex: VPN, MFA, audit des accès] |

## 3. Exigences de sécurité organisationnelles

<!-- Exigences issues des politiques internes de l'organisation de
développement. Couvrir : gestion des accès développeurs, revue de code,
gestion des secrets, politique de branches, formation sécurité. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-ORG-01 | [ex: Gestion des secrets] | [ex: Aucun secret dans le code source] | [ex: Vault + variables d'environnement] | [ex: Scan pre-commit, audit git history] | ⏳ |
| SEC-ORG-02 | [ex: Revue de code obligatoire] | [ex: Toute PR requiert une approbation] | [ex: Branch protection rules GitHub] | [ex: Paramètres du dépôt, historique PR] | ⏳ |
| SEC-ORG-03 | [ex: Principe du moindre privilège] | [ex: Accès limités au strict nécessaire] | [ex: RBAC, comptes de service dédiés] | [ex: Matrice des droits, audit IAM] | ⏳ |

## 4. Exigences de sécurité — Bonnes pratiques

<!-- Exigences issues de référentiels reconnus : ANSSI Guide d'hygiène
informatique, OWASP ASVS v4, OWASP Top 10, CIS Benchmarks, NIST, etc.
Sélectionner les exigences pertinentes pour le type de solution.
Citer la source (référentiel, numéro de recommandation). -->

### 4.1 Authentification et contrôle d'accès

<!-- Réf. OWASP ASVS V2 (Authentication), ANSSI R19/R28. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-BP-01 | [ex: Authentification forte] | [ex: MFA pour les accès administratifs (ANSSI R28)] | [ex: TOTP via authenticator] | [ex: Configuration IAM, tests d'accès] | ⏳ |
| SEC-BP-02 | [ex: Politique de mots de passe] | [ex: Longueur min. 12 car., complexité (ANSSI R19)] | [ex: Validation côté API] | [ex: Tests unitaires, configuration] | ⏳ |
| SEC-BP-03 | [ex: Protection contre le brute force] | [ex: Verrouillage temporaire après N échecs (OWASP ASVS V2.2)] | [ex: Rate limiting par IP + par compte] | [ex: Tests de charge, logs d'échecs] | ⏳ |

### 4.2 Gestion des sessions

<!-- Réf. OWASP ASVS V3 (Session Management). Distinct de l'authentification :
couvre le cycle de vie des sessions après login. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-BP-05 | [ex: Expiration des sessions] | [ex: Timeout inactivité 30 min, durée max 24h (OWASP ASVS V3.3)] | [ex: Configuration JWT/cookie, nettoyage côté serveur] | [ex: Tests d'expiration, configuration] | ⏳ |
| SEC-BP-06 | [ex: Fixation de session] | [ex: Régénération du token après authentification (OWASP ASVS V3.2)] | [ex: Nouveau session ID au login] | [ex: Test de non-réutilisation des anciens tokens] | ⏳ |
| SEC-BP-07 | [ex: Sessions concurrentes] | [ex: Politique définie : session unique ou multiples autorisées] | [ex: Invalidation des anciennes sessions au login (si session unique)] | [ex: Test de connexion simultanée] | ⏳ |

### 4.3 Protection des données et cryptographie

<!-- Réf. OWASP ASVS V6 (Cryptography) et V9 (Communications), ANSSI R1.
Documenter les algorithmes approuvés et la gestion des clés. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-BP-10 | [ex: Chiffrement en transit] | [ex: TLS 1.2+ pour toutes les communications (ANSSI R1)] | [ex: Certificats Let's Encrypt, HSTS] | [ex: Scan SSL Labs, config serveur] | ⏳ |
| SEC-BP-11 | [ex: Chiffrement au repos] | [ex: AES-256 pour les données sensibles] | [ex: Chiffrement natif PostgreSQL/Azure] | [ex: Configuration stockage, audit] | ⏳ |
| SEC-BP-12 | [ex: Algorithmes approuvés] | [ex: Seuls les algorithmes recommandés ANSSI/NIST (OWASP ASVS V6.2)] | [ex: AES-256-GCM, RSA-2048+, SHA-256+, pas de MD5/SHA1/DES] | [ex: Revue de code, scan SAST] | ⏳ |
| SEC-BP-13 | [ex: Gestion des clés] | [ex: Clés stockées hors code, rotation planifiée (OWASP ASVS V6.4)] | [ex: Vault / KMS, rotation 90 jours] | [ex: Politique de rotation, audit KMS] | ⏳ |
| SEC-BP-14 | [ex: Rotation des certificats] | [ex: Certificats TLS renouvelés avant expiration] | [ex: Certbot auto-renew, monitoring expiration] | [ex: Alerte 30j avant expiration] | ⏳ |

### 4.4 Protection applicative

<!-- Réf. OWASP ASVS V5 (Validation), OWASP Top 10. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-BP-20 | [ex: Injection SQL] | [ex: Prévention des injections (OWASP A03)] | [ex: ORM, requêtes paramétrées] | [ex: Revue de code, SAST] | ⏳ |
| SEC-BP-21 | [ex: Validation des entrées] | [ex: Validation et sanitisation côté serveur (OWASP ASVS V5.1)] | [ex: Pydantic, schémas de validation] | [ex: Tests unitaires, fuzzing] | ⏳ |
| SEC-BP-22 | [ex: XSS] | [ex: Échappement des sorties HTML (OWASP A07)] | [ex: Templating auto-escaped, CSP headers] | [ex: Tests de rendu, scan DAST] | ⏳ |
| SEC-BP-23 | [ex: CSRF] | [ex: Protection contre la falsification de requêtes (OWASP ASVS V4.2)] | [ex: Tokens CSRF, SameSite cookies] | [ex: Tests d'intégration] | ⏳ |

### 4.5 Gestion des erreurs et fuites d'information

<!-- Réf. OWASP ASVS V7 (Error Handling and Logging). Empêcher le système
de révéler des informations exploitables par un attaquant. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-BP-25 | [ex: Pas de stack trace en production] | [ex: Les erreurs serveur retournent un message générique (OWASP ASVS V7.4)] | [ex: Handler d'erreurs global, mode debug désactivé] | [ex: Test de réponse 500, config prod] | ⏳ |
| SEC-BP-26 | [ex: Pas de chemins internes exposés] | [ex: Aucun chemin serveur, version de framework ou header technique en réponse] | [ex: Suppression headers X-Powered-By, Server] | [ex: Scan des headers HTTP] | ⏳ |
| SEC-BP-27 | [ex: Messages d'erreur non informatifs] | [ex: Les messages d'auth ne distinguent pas "utilisateur inconnu" et "mot de passe incorrect"] | [ex: Message unique "Identifiants invalides"] | [ex: Test des messages de login/signup] | ⏳ |

### 4.6 Sécurité des API et communications

<!-- Réf. OWASP ASVS V13 (API and Web Service), V9 (Communications).
Applicable que l'API soit publique ou interne. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-BP-30 | [ex: Rate limiting] | [ex: Limitation du débit par IP et par utilisateur (OWASP ASVS V13.1)] | [ex: Middleware rate limiter, quotas par tier] | [ex: Tests de charge, monitoring 429] | ⏳ |
| SEC-BP-31 | [ex: Taille des requêtes] | [ex: Limite de taille des corps de requête (OWASP ASVS V13.1)] | [ex: max_content_length configuré] | [ex: Test avec payload surdimensionné] | ⏳ |
| SEC-BP-32 | [ex: CORS] | [ex: Origines autorisées explicitement listées (OWASP ASVS V13.3)] | [ex: Whitelist des domaines autorisés, pas de wildcard] | [ex: Test cross-origin, config serveur] | ⏳ |
| SEC-BP-33 | [ex: Authentification API] | [ex: Chaque endpoint protégé requiert un token valide] | [ex: Bearer JWT, vérification middleware] | [ex: Tests d'accès sans token] | ⏳ |
| SEC-BP-34 | [ex: Rotation des clés API] | [ex: Les clés API ont une durée de vie limitée et sont rotées] | [ex: Expiration 90j, endpoint de renouvellement] | [ex: Politique de rotation, audit] | ⏳ |

### 4.7 Upload et stockage de fichiers

<!-- Réf. OWASP ASVS V12 (File and Resources).
Supprimer cette section si l'application ne gère aucun upload de fichier. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-BP-40 | [ex: Validation des types de fichier] | [ex: Whitelist des types MIME autorisés, vérification du contenu réel (pas seulement l'extension)] | [ex: Vérification magic bytes + extension] | [ex: Tests avec fichiers déguisés] | ⏳ |
| SEC-BP-41 | [ex: Limite de taille] | [ex: Taille max par fichier et par requête] | [ex: 10 Mo max, configurable] | [ex: Test avec fichier surdimensionné] | ⏳ |
| SEC-BP-42 | [ex: Isolation du stockage] | [ex: Fichiers stockés hors de la racine web, noms aléatoires] | [ex: Object storage dédié, UUID comme noms] | [ex: Tentative d'accès direct, config stockage] | ⏳ |
| SEC-BP-43 | [ex: Scan antimalware] | [ex: Analyse des fichiers uploadés avant traitement (OWASP ASVS V12.2)] | [ex: ClamAV ou service cloud] | [ex: Test avec fichier EICAR] | ⏳ |

### 4.8 Journalisation et détection

<!-- Réf. OWASP ASVS V7 (Error Handling and Logging), ANSSI R33. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-BP-50 | [ex: Journalisation des accès] | [ex: Traçabilité des actions sensibles (ANSSI R33)] | [ex: Middleware d'audit, table audit_logs] | [ex: Requêtes de vérification, dashboards] | ⏳ |
| SEC-BP-51 | [ex: Pas de données sensibles dans les logs] | [ex: Ni mots de passe, ni tokens, ni données personnelles dans les logs (OWASP ASVS V7.1)] | [ex: Filtrage des champs sensibles, masquage] | [ex: Revue des formats de log, grep] | ⏳ |
| SEC-BP-52 | [ex: Détection d'anomalies] | [ex: Alertes sur les comportements suspects (brute force, scanning, accès anormaux)] | [ex: Règles d'alerte, dashboards sécurité] | [ex: Test de déclenchement des alertes] | ⏳ |

### 4.9 Segmentation réseau

<!-- Réf. ANSSI Guide d'hygiène section V, CIS Benchmarks.
Applicable à tout système, même en SaaS (isolation des services). -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-BP-55 | [ex: Isolation des composants] | [ex: Les composants communiquent via des réseaux dédiés, pas de réseau plat (ANSSI R23)] | [ex: VPC / subnets, security groups] | [ex: Schéma réseau, config IaC] | ⏳ |
| SEC-BP-56 | [ex: Filtrage des flux sortants] | [ex: Seuls les flux sortants nécessaires sont autorisés (egress filtering)] | [ex: Network policies, outbound rules] | [ex: Test de connexion non autorisée] | ⏳ |
| SEC-BP-57 | [ex: Protection périmétrique] | [ex: WAF ou reverse proxy devant les services exposés] | [ex: Azure Front Door / Cloudflare / nginx WAF] | [ex: Configuration WAF, test de règles] | ⏳ |

### 4.10 Continuité et résilience

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-BP-60 | [ex: Plan de sauvegarde] | [ex: Sauvegardes testées et restaurables] | [ex: Voir DEPLOYMENT.md § 8] | [ex: Rapports de test de restauration] | ⏳ |
| SEC-BP-61 | [ex: Séparation des sauvegardes] | [ex: Sauvegardes stockées dans un compte/région distinct des données primaires] | [ex: Compte de stockage dédié, réplication cross-region] | [ex: Configuration stockage, test de restauration isolée] | ⏳ |

## 5. Exigences de sécurité — Référentiels sectoriels

<!-- Section à renseigner si le SPEC.md identifie un cadre réglementaire ou
sectoriel qui impose des exigences de sécurité spécifiques. Ces référentiels
sont normalement identifiés dans les contraintes du SPEC.md (section Contexte
ou ENF). Le détail de conformité est dans COMPLIANCE_MATRIX.md — ici on
ne documente que les exigences de SÉCURITÉ induites par ces référentiels.

Exemples de référentiels sectoriels :
- Santé : PGSSI-S, HDS, HIPAA
- Finance : PCI-DSS, DORA, SOX
- Services essentiels : NIS2
- Défense : IGI 1300, II 901
- Général : ISO 27001, SOC2

Supprimer cette section si aucun référentiel sectoriel ne s'applique. -->

### 5.1 [Référentiel — ex: PGSSI-S]

Source : [ex: PGSSI-S — Politique Générale de Sécurité des Systèmes
d'Information de Santé, publiée par l'ANS]

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-SECT-01 | [ex: Authentification des professionnels de santé] | [ex: Utilisation de moyens d'identification conformes PGSSI-S (carte CPS, e-CPS)] | [ex: Intégration Pro Santé Connect] | [ex: Tests d'authentification, certificat de conformité] | ⏳ |
| SEC-SECT-02 | [ex: Traçabilité des accès aux données de santé] | [ex: Journalisation nominative de chaque accès aux données patient] | [ex: Table audit_logs avec identité PS, horodatage, action, données accédées] | [ex: Rapport d'audit, requêtes de vérification] | ⏳ |

### 5.2 [Référentiel N]

<!-- Ajouter une sous-section par référentiel sectoriel supplémentaire.
Supprimer les sous-sections non applicables. -->

## 6. Principes de développement sécurisé

<!-- Règles de codage sécurisé que TOUS les développeurs (humains ou agents IA)
doivent respecter. Ces principes sont indépendants de la stack technique :
ils s'appliquent quel que soit le langage ou le framework. Adapter les
exemples d'implémentation au langage du projet. Réf. OWASP Secure Coding
Practices, CERT Secure Coding Standards. -->

| ID | Principe | Description | Exemples d'implémentation | Vérification |
|----|----------|-------------|--------------------------|-------------|
| SEC-DEV-01 | Effacement des données sensibles en mémoire | Les buffers contenant des secrets (mots de passe, clés, tokens) sont effacés dès qu'ils ne sont plus nécessaires | [ex: `SecureString` (.NET), `Arrays.fill(0)` (Java), `memset_s` (C), `bytearray` + écrasement (Python)] | [ex: Revue de code, règle SAST] |
| SEC-DEV-02 | Pas de secrets en dur dans le code | Aucun mot de passe, clé API, token ou certificat dans le code source ou les fichiers de configuration versionnés | [ex: Variables d'environnement, Vault, fichiers `.env` dans `.gitignore`] | [ex: Scan pre-commit (detect-secrets, gitleaks)] |
| SEC-DEV-03 | Principe du moindre privilège dans le code | Chaque composant ne demande que les permissions strictement nécessaires à son fonctionnement | [ex: Rôles DB read-only pour les requêtes de lecture, scopes OAuth minimaux] | [ex: Revue de code, audit des permissions] |
| SEC-DEV-04 | Fail securely | En cas d'erreur, le système doit tomber dans un état sûr (accès refusé par défaut, pas de contournement des contrôles) | [ex: Deny by default, catch global qui refuse l'accès en cas d'exception dans l'authz] | [ex: Tests d'erreur d'autorisation] |
| SEC-DEV-05 | Pas de désérialisation non fiable | Ne jamais désérialiser des données provenant de sources non fiables avec des formats exécutables | [ex: Pas de `pickle`, `eval`, `unserialize` sur des entrées utilisateur ; JSON ou Protobuf uniquement] | [ex: Règle linter, SAST] |
| SEC-DEV-06 | Gestion sûre des fichiers temporaires | Les fichiers temporaires sont créés avec des permissions restreintes et supprimés après usage | [ex: `tempfile.mkstemp` (Python), `Files.createTempFile` (Java), cleanup dans `finally`] | [ex: Revue de code] |
| SEC-DEV-07 | Pas de comparaison en temps variable pour les secrets | Les comparaisons de tokens, signatures ou hashes utilisent des fonctions à temps constant | [ex: `hmac.compare_digest` (Python), `MessageDigest.isEqual` (Java), `crypto.timingSafeEqual` (Node)] | [ex: Revue de code, règle SAST] |
| SEC-DEV-08 | Encodage des sorties contextualisé | Chaque donnée insérée dans un contexte de sortie (HTML, SQL, URL, JSON, shell) est encodée selon ce contexte | [ex: Auto-escaping template, requêtes paramétrées, `shlex.quote`] | [ex: Revue de code, SAST, DAST] |

<!-- Ajouter des principes spécifiques au projet si nécessaire.
Supprimer les lignes non pertinentes (ex: SEC-DEV-06 si aucun fichier temporaire). -->

## 7. SDLC sécurisé et supply chain

<!-- Sécurité du cycle de développement et de la chaîne d'approvisionnement
logicielle. Réf. OWASP ASVS V14 (Configuration), ANSSI Guide d'hygiène I-II.
Ces exigences s'appliquent au processus de développement, pas au runtime. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-SDLC-01 | [ex: Analyse statique (SAST)] | [ex: Scan automatique du code à chaque PR] | [ex: Semgrep / CodeQL en CI] | [ex: Pipeline CI, rapports de scan] | ⏳ |
| SEC-SDLC-02 | [ex: Analyse dynamique (DAST)] | [ex: Scan de l'application déployée en staging] | [ex: OWASP ZAP en pipeline] | [ex: Rapports DAST, zéro critique] | ⏳ |
| SEC-SDLC-03 | [ex: Audit des dépendances] | [ex: Détection des vulnérabilités connues dans les dépendances] | [ex: Dependabot / pip-audit / npm audit en CI] | [ex: Alertes GitHub, rapport d'audit] | ⏳ |
| SEC-SDLC-04 | [ex: SBOM] | [ex: Inventaire des composants logiciels (Software Bill of Materials)] | [ex: Génération SBOM en CI (CycloneDX / SPDX)] | [ex: Fichier SBOM versionné, audit] | ⏳ |
| SEC-SDLC-05 | [ex: Hardening des images] | [ex: Images de base minimales, sans outils de debug en production] | [ex: Images distroless / Alpine, multi-stage build] | [ex: Dockerfile, scan Trivy/Grype] | ⏳ |
| SEC-SDLC-06 | [ex: Signature des artefacts] | [ex: Artefacts de build signés pour garantir l'intégrité] | [ex: Cosign / GPG sur images et packages] | [ex: Vérification de signature en déploiement] | ⏳ |

## 8. Exigences de sécurité — Stack technique

<!-- Exigences spécifiques aux technologies choisies dans ARCHITECTURE.md § 3.
Pour chaque composant de la stack, identifier les risques et les
contre-mesures propres à cette technologie. -->

### 8.1 [Technologie 1 — ex: Python / FastAPI]

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-TECH-01 | [ex: Dépendances sécurisées] | [ex: Audit régulier des dépendances Python] | [ex: pip-audit en CI, Dependabot] | [ex: Rapport pip-audit, alertes GitHub] | ⏳ |
| SEC-TECH-02 | [ex: Sérialisation sûre] | [ex: Pas de pickle/eval sur des données non fiables] | [ex: JSON uniquement, Pydantic] | [ex: Règle ruff, revue de code] | ⏳ |

### 8.2 [Technologie 2 — ex: PostgreSQL]

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-TECH-10 | [ex: Accès restreint] | [ex: Connexion via SSL, utilisateurs dédiés] | [ex: pg_hba.conf, rôles PostgreSQL] | [ex: Configuration serveur, audit] | ⏳ |

### 8.3 [Technologie N]

<!-- Ajouter une sous-section par technologie significative de la stack.
Supprimer les sous-sections vides. -->

## 9. Réponse à incident

<!-- Plan de réponse en cas d'incident de sécurité. Réf. ANSSI Guide d'hygiène
section IX. Ce plan doit être connu de l'équipe AVANT qu'un incident survienne. -->

### 9.1 Rôles et responsabilités

| Rôle | Responsable | Contact | Responsabilités |
|------|------------|---------|-----------------|
| [ex: Responsable incident] | [ex: Nom / Poste] | [ex: email, téléphone] | [ex: Coordination de la réponse, décision d'escalade] |
| [ex: Référent technique] | [ex: Nom / Poste] | [ex: email, téléphone] | [ex: Investigation, confinement, correction] |
| [ex: Communication] | [ex: Nom / Poste] | [ex: email, téléphone] | [ex: Notification des parties prenantes et utilisateurs] |

### 9.2 Procédure de réponse

| Phase | Actions | Délai cible |
|-------|---------|-------------|
| **1. Détection** | [ex: Alerte monitoring, signalement utilisateur, scan de vulnérabilité] | [ex: < 1h] |
| **2. Confinement** | [ex: Isolation du composant affecté, révocation des accès compromis, blocage IP] | [ex: < 4h] |
| **3. Éradication** | [ex: Correction de la vulnérabilité, rotation des secrets exposés, nettoyage] | [ex: < 24h] |
| **4. Restauration** | [ex: Redéploiement, vérification d'intégrité, remise en service progressive] | [ex: < 48h] |
| **5. Post-mortem** | [ex: Analyse des causes, rapport d'incident, mise à jour des procédures et exigences] | [ex: < 1 semaine] |

### 9.3 Notification

<!-- Qui notifier, dans quel délai, par quel canal. Inclure les obligations
légales (RGPD : 72h pour la CNIL, clients si données personnelles impactées). -->

| Destinataire | Condition de notification | Délai | Canal |
|-------------|--------------------------|-------|-------|
| [ex: CNIL] | [ex: Violation de données personnelles (RGPD art. 33)] | [ex: 72h] | [ex: Téléservice CNIL] |
| [ex: Utilisateurs affectés] | [ex: Risque élevé pour les droits (RGPD art. 34)] | [ex: Sans délai après notification CNIL] | [ex: Email] |
| [ex: Direction] | [ex: Tout incident de sécurité] | [ex: < 4h] | [ex: Email + téléphone] |

## 10. Conformité et privacy

<!-- Renvoi vers COMPLIANCE_MATRIX.md si applicable. Cette section résume
les obligations de sécurité liées à la protection des données personnelles
et aux réglementations. Elle ne duplique pas le détail de la matrice de
conformité mais assure que le SECURITY.md est autosuffisant sur les points
de sécurité liés à la privacy. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-PRIV-01 | [ex: Minimisation des données] | [ex: Ne collecter que les données strictement nécessaires (RGPD art. 5.1.c)] | [ex: Revue des champs collectés par UC] | [ex: Audit des schémas de données] | ⏳ |
| SEC-PRIV-02 | [ex: Droit à l'effacement] | [ex: Suppression complète des données personnelles sur demande (RGPD art. 17)] | [ex: Endpoint de suppression, cascade en base, purge des backups] | [ex: Test de suppression, vérification base + logs + backups] | ⏳ |
| SEC-PRIV-03 | [ex: Durée de conservation] | [ex: Données personnelles supprimées ou anonymisées après la durée définie] | [ex: Job de purge automatique, politique de rétention par entité] | [ex: Voir ARCHITECTURE.md § 4.6 (rétention)] | ⏳ |
| SEC-PRIV-04 | [ex: Pseudonymisation] | [ex: Données directement identifiantes séparées des données fonctionnelles (si applicable)] | [ex: Table de correspondance chiffrée, accès restreint] | [ex: Schéma de base, audit d'accès] | ⏳ |

**Détail complet :** Voir COMPLIANCE_MATRIX.md (si applicable).

## 11. Spécificités de sécurité

<!-- Section réservée aux exigences de sécurité propres au contexte
spécifique du projet, qui ne rentrent dans aucune des catégories
précédentes. Exemples : contraintes client, exigences contractuelles,
environnement d'exécution particulier, hardware dédié.

Si le projet est de type Driver ou Client lourd, inclure ici les
exigences spécifiques :
- Driver : signature du binaire, protection mémoire kernel, surface
  d'attaque réduite, isolation des privilèges.
- Client lourd : stockage local sécurisé, communication sécurisée
  avec le serveur, protection contre le reverse engineering,
  mise à jour sécurisée.

Supprimer cette section si elle est vide. -->

| ID | Exigence | Description | Implémentation | Preuve de conformité | Statut |
|----|----------|-------------|----------------|----------------------|--------|
| SEC-SPE-01 | [Titre] | [Description] | [Implémentation] | [Preuve] | ⏳ |

## 12. Légende des statuts

| Statut | Signification |
|--------|---------------|
| ✅ | Implémenté et vérifié |
| 🔄 | En cours d'implémentation |
| ⏳ | Planifié (non démarré) |
| ❌ | Non applicable |

---

## Changelog

<!-- Ne pas inclure en v1.0. Décommenter à partir de la v1.1.

| Version | Date | Auteur | Modifications |
|---------|------|--------|---------------|
| 1.1 | YYYY-MM-DD | [Auteur] | [Description des modifications] |
| 1.0 | YYYY-MM-DD | [Auteur] | Version initiale |
-->
