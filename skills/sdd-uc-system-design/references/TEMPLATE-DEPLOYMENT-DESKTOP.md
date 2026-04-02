# Sections spécifiques Client lourd — Déploiement

<!-- Sous-template à fusionner dans DEPLOYMENT.md pour les clients lourds
et applications desktop. Insérer ces sections après le tronc commun
(§ 11 Disaster recovery), avant le Changelog. Numéroter à la suite. -->

## N. Spécificités Client lourd

### N.1 Distribution

<!-- Canaux de distribution : site web, store, entreprise (MSI/GPO).
Installeurs, formats de package par plateforme. -->

| Plateforme | Format | Canal | Signature |
|-----------|--------|-------|-----------|
| [ex: Windows] | [ex: MSI / MSIX] | [ex: Site web + entreprise (GPO)] | [ex: Certificat EV] |
| [ex: macOS] | [ex: DMG / PKG] | [ex: Site web + Mac App Store] | [ex: Apple Developer ID + notarization] |
| [ex: Linux] | [ex: AppImage / .deb / .rpm] | [ex: Site web + dépôt APT/RPM] | [ex: GPG] |

### N.2 Mise à jour automatique

<!-- Mécanisme de vérification et d'application des mises à jour.
Fréquence de vérification, téléchargement en arrière-plan,
mises à jour obligatoires vs optionnelles. -->

| Paramètre | Valeur | Notes |
|-----------|--------|-------|
| Fréquence de vérification | [ex: Au démarrage + toutes les 6h] | |
| Téléchargement | [ex: En arrière-plan, notification à l'utilisateur] | |
| Application | [ex: Au prochain redémarrage, ou immédiate si critique] | |
| Mises à jour obligatoires | [ex: Oui pour les patches de sécurité] | |
| Canal de mise à jour | [ex: Stable / Beta, configurable par l'utilisateur] | |
| Mécanisme de delta | [ex: Oui / Non — diff binaire ou téléchargement complet] | |

### N.3 Compatibilité

<!-- Matrice de compatibilité OS / versions.
Gestion de la rétrocompatibilité des données locales. -->

| OS | Versions supportées | Architecture | Fin de support prévue |
|-----|---------------------|-------------|----------------------|
| [ex: Windows] | [ex: 10 22H2+, 11] | [ex: x64, ARM64] | [ex: Aligné sur Microsoft] |
| [ex: macOS] | [ex: 13 Ventura+] | [ex: x64, ARM64 (Apple Silicon)] | [ex: Aligné sur Apple (N-2)] |

**Rétrocompatibilité des données locales :**
<!-- Comment le logiciel gère les fichiers/données créés par des versions
antérieures. Migrations automatiques, format versionné, etc. -->

[Description de la stratégie]

### N.4 Mode hors-ligne

<!-- Si applicable : fonctionnalités disponibles hors-ligne,
synchronisation au retour en ligne, gestion des conflits. -->

| Fonctionnalité | Disponible hors-ligne | Synchronisation | Gestion des conflits |
|---------------|----------------------|-----------------|---------------------|
| [ex: Consultation des données] | [ex: Oui (cache local)] | [ex: Au retour en ligne, automatique] | [ex: N/A (lecture seule)] |
| [ex: Création/modification] | [ex: Oui (queue locale)] | [ex: Au retour en ligne, FIFO] | [ex: Last-write-wins / prompt utilisateur] |

### N.5 Données locales et stockage

<!-- Où et comment le client lourd stocke ses données localement.
Chiffrement, nettoyage à la désinstallation, migration entre versions. -->

| Donnée | Emplacement | Chiffrement | Nettoyage désinstallation |
|--------|------------|-------------|--------------------------|
| [ex: Configuration utilisateur] | [ex: `%APPDATA%/NomApp/`] | [ex: Non (pas sensible)] | [ex: Optionnel (proposé à l'utilisateur)] |
| [ex: Cache de données] | [ex: `%LOCALAPPDATA%/NomApp/cache/`] | [ex: Non] | [ex: Oui (automatique)] |
| [ex: Tokens d'authentification] | [ex: Credential Manager OS] | [ex: Oui (natif OS)] | [ex: Oui (automatique)] |
