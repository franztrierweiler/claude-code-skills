# Sections spécifiques Driver — Déploiement

<!-- Sous-template à fusionner dans DEPLOYMENT.md pour les drivers et firmware.
Insérer ces sections après le tronc commun (§ 11 Disaster recovery),
avant le Changelog. Numéroter à la suite. -->

## N. Spécificités Driver

### N.1 Certification

<!-- Processus de certification par les vendeurs OS.
WHQL (Windows), kext signing (macOS), etc. -->

| OS | Certification | Processus | Délai estimé | Coût |
|-----|--------------|-----------|-------------|------|
| [ex: Windows] | [ex: WHQL] | [ex: Soumission Microsoft Hardware Lab Kit (HLK)] | [ex: 2-4 semaines] | [ex: Inclus dans le programme partenaire] |
| [ex: macOS] | [ex: System Extension / DriverKit] | [ex: Notarization Apple + entitlement spécifique] | [ex: 1-2 semaines] | [ex: Apple Developer Program] |
| [ex: Linux] | [ex: Signature module kernel] | [ex: Signature avec clé MOK ou inclusion upstream] | [ex: Variable] | [ex: Gratuit] |

### N.2 Installation silencieuse

<!-- Procédure d'installation sans interaction utilisateur.
Paramètres de ligne de commande, codes de retour. Essentiel pour le
déploiement en entreprise (GPO, SCCM, Intune). -->

**Commande d'installation :**

```bash
# [ex: setup.exe /S /D=C:\Drivers\NomDriver]
```

**Codes de retour :**

| Code | Signification |
|------|--------------|
| [ex: 0] | [ex: Installation réussie] |
| [ex: 1] | [ex: Redémarrage nécessaire] |
| [ex: 2] | [ex: Échec — driver incompatible] |
| [ex: 3] | [ex: Échec — privilèges insuffisants] |

### N.3 Gestion des versions du matériel

<!-- Comment gérer plusieurs révisions hardware avec un seul driver.
Détection du matériel, fonctionnalités conditionnelles. -->

| Révision matériel | PID/VID ou identifiant | Fonctionnalités | Depuis version driver |
|-------------------|----------------------|-----------------|----------------------|
| [ex: Rev A] | [ex: VID_1234&PID_0001] | [ex: Fonctionnalités de base] | [ex: v1.0] |
| [ex: Rev B] | [ex: VID_1234&PID_0002] | [ex: Base + mode haute performance] | [ex: v1.2] |

**Mécanisme de détection :**
[ex: Lecture du registre hardware, descripteur USB, table ACPI]

### N.4 Cohabitation

<!-- Comportement en présence d'autres drivers concurrents ou de
versions antérieures. Désinstallation propre. -->

| Scénario | Comportement | Procédure |
|----------|-------------|-----------|
| [ex: Version antérieure présente] | [ex: Mise à jour automatique, remplacement du driver] | [ex: L'installeur détecte et remplace] |
| [ex: Driver concurrent installé] | [ex: Conflit détecté, installation bloquée avec message] | [ex: Désinstallation manuelle requise avant installation] |
| [ex: Désinstallation] | [ex: Nettoyage complet : fichiers, registre, certificats] | [ex: `setup.exe /uninstall` ou Gestionnaire de périphériques] |

### N.5 Tests matériels

<!-- Matrice de test par combinaison OS × révision matériel.
Infrastructure de test nécessaire. -->

| Matériel | OS | Type de test | Automatisé | Infrastructure |
|----------|----|-------------|-----------|---------------|
| [ex: Rev A] | [ex: Windows 10/11] | [ex: Installation, fonctionnel, stress] | [ex: Partiellement (HLK)] | [ex: Machine physique dédiée] |
| [ex: Rev B] | [ex: Windows 10/11 + Linux 6.x] | [ex: Installation, fonctionnel, perf] | [ex: Oui (CI + machine physique)] | [ex: Lab de test] |
