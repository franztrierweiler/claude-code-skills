# Sections spécifiques Logiciel embarqué — Déploiement

<!-- Sous-template à fusionner dans DEPLOYMENT.md pour les logiciels embarqués.
Couvre un large spectre de cibles :

| Catégorie | Exemples | OS / Runtime |
|-----------|----------|-------------|
| Téléphone mobile | Smartphones Android, iPhone | Android, iOS |
| TPE (Terminal de Paiement) | PAX A920, Ingenico AXIUM, Verifone | Android (majoritaire) |
| Terminal professionnel | PDA logistique (Zebra, Honeywell), borne | Android |
| Système embarqué générique | Arduino, Raspberry Pi | Bare metal, Linux embarqué |
| Carte de développement (dev board) | STM32 (STMicroelectronics), NXP (ex-Freescale), ESP32 | RTOS (FreeRTOS), bare metal |

Sélectionner les sections pertinentes selon la cible. Supprimer les sections
non applicables. Insérer après le tronc commun (§ 11 Disaster recovery),
avant le Changelog. Numéroter à la suite. -->

## N. Spécificités Logiciel embarqué

### N.1 Cible matérielle

<!-- Identifier la catégorie de cible, les modèles, et les contraintes
qu'ils imposent. -->

**Catégorie :** [Téléphone mobile | TPE | Terminal professionnel | Système embarqué générique | Dev board]

| Modèle / Plateforme | Fabricant | OS / Runtime | Version min | Processeur | RAM | Stockage | Connectivité | Périphériques spécifiques |
|---------------------|----------|-------------|-------------|-----------|-----|----------|-------------|-------------------------|
| [ex: PAX A920] | [ex: PAX Technology] | [ex: Android 7.1+] | [ex: API 25] | [ex: ARM Cortex-A53] | [ex: 1 Go] | [ex: 8 Go] | [ex: 4G, Wi-Fi, Bluetooth] | [ex: Imprimante thermique, NFC, lecteur carte à puce, caméra] |
| [ex: STM32F429] | [ex: STMicroelectronics] | [ex: FreeRTOS 10.x] | — | [ex: ARM Cortex-M4, 180 MHz] | [ex: 256 Ko SRAM] | [ex: 2 Mo Flash] | [ex: UART, SPI, I2C, Ethernet (PHY externe)] | [ex: GPIO, ADC, DAC, timers] |
| [ex: iPhone] | [ex: Apple] | [ex: iOS 16+] | — | [ex: A15+] | [ex: 4 Go+] | [ex: 128 Go+] | [ex: 5G, Wi-Fi 6, Bluetooth 5.3] | [ex: NFC (limité), caméra, GPS, accéléromètre] |

### N.2 Couche d'abstraction matérielle (HAL)

<!-- Section pertinente quand l'application doit être indépendante du modèle
de matériel. C'est le cas typique des TPE Android où chaque fabricant
(PAX, Ingenico, Verifone, Castles) expose ses périphériques via un SDK
propriétaire. Une HAL permet de supporter plusieurs modèles avec le même
code applicatif.

Supprimer cette section si l'application ne cible qu'un seul modèle ou
si l'OS fournit déjà l'abstraction (iOS, Android standard sans
périphériques spécifiques). -->

**Objectif :** Rendre l'application indépendante du modèle de terminal en
isolant les interactions matérielles derrière une interface commune.

**Architecture de la HAL :**

```
┌─────────────────────────────────┐
│        Application métier       │
├─────────────────────────────────┤
│         Interface HAL           │  ← Contrat stable (Java/Kotlin ou C)
├──────────┬──────────┬───────────┤
│ Impl PAX │ Impl ING │ Impl VFN  │  ← Une implémentation par fabricant
├──────────┼──────────┼───────────┤
│ SDK PAX  │ SDK ING  │ SDK VFN   │  ← SDK propriétaire fabricant
└──────────┴──────────┴───────────┘
```

| Périphérique | Interface HAL | Implémentation PAX | Implémentation Ingenico | Implémentation autre |
|-------------|--------------|-------------------|------------------------|---------------------|
| [ex: Imprimante] | [ex: `IPrinter.print(receipt)`] | [ex: `PaxPrinterImpl` via SDK Neptune] | [ex: `IngPrinterImpl` via SDK APOS] | [ex: À développer] |
| [ex: Lecteur carte] | [ex: `ICardReader.read(timeout)`] | [ex: `PaxCardImpl`] | [ex: `IngCardImpl`] | [ex: À développer] |
| [ex: NFC] | [ex: `INfc.detect()`] | [ex: `PaxNfcImpl`] | [ex: `IngNfcImpl`] | [ex: À développer] |

**Langage de la HAL :** [ex: Java/Kotlin (Android) | C (bare metal / RTOS) | C++ (Linux embarqué)]

**Sélection de l'implémentation :** [ex: Au build (variantes Gradle / defines préprocesseur)
| Au runtime (détection du fabricant via `Build.MANUFACTURER` ou registre hardware)]

**Gestion de la variance du parc :**

| Fabricant | Modèles supportés | Version SDK | Particularités |
|----------|-------------------|-------------|---------------|
| [ex: PAX] | [ex: A920, A910, A80] | [ex: Neptune SDK 3.x] | [ex: Imprimante intégrée sur A920, externe sur A80] |
| [ex: Ingenico] | [ex: AXIUM DX8000, DX4000] | [ex: APOS SDK 8.x] | [ex: Pas de caméra sur DX4000] |

### N.3 Distribution et provisioning

<!-- Comment le logiciel arrive sur les cibles. Le mécanisme dépend
fortement de la catégorie. -->

<!-- === Mobile (Android / iOS) === -->
<!-- App Store (Google Play, Apple App Store), MDM entreprise (Intune,
Jamf), TestFlight (iOS beta). -->

<!-- === TPE Android === -->
<!-- TMS fabricant (TOMS pour PAX, RMS pour Ingenico, VHQ pour Verifone),
MDM tiers (SOTI, VMware), store fabricant (PAX Store).
Le TMS est souvent imposé par l'acquéreur ou le processeur de paiement. -->

<!-- === Système embarqué / Dev board === -->
<!-- Flashage firmware (JTAG/SWD, USB DFU, série), OTA si connecté,
programmateur en production. -->

| Mécanisme | Outil | Cible | Notes |
|-----------|-------|-------|-------|
| [ex: TMS fabricant] | [ex: TOMS (PAX)] | [ex: Parc TPE] | [ex: Déploiement silencieux, gestion firmware + applicatif] |
| [ex: App Store] | [ex: Google Play / Apple App Store] | [ex: Téléphones grand public] | [ex: Processus de review ~24-48h, signature requise] |
| [ex: MDM entreprise] | [ex: SOTI / VMware / Intune] | [ex: Parc géré] | [ex: Déploiement silencieux, configuration à distance] |
| [ex: Store fabricant] | [ex: PAX Store / Zebra AppGallery] | [ex: Terminaux professionnels] | [ex: Validation fabricant requise] |
| [ex: Flashage firmware] | [ex: STM32CubeProgrammer / OpenOCD] | [ex: Dev boards, production] | [ex: Via JTAG/SWD ou USB DFU] |
| [ex: OTA firmware] | [ex: AWS IoT OTA / serveur custom] | [ex: Systèmes embarqués connectés] | [ex: Signature du firmware obligatoire, delta update] |
| [ex: Sideloading] | [ex: ADB / script] | [ex: Dev / staging uniquement] | [ex: Non autorisé en production] |

**Provisioning initial :**

1. [ex: Enrôlement (QR code, NFC, ou flashage initial)]
2. [ex: Configuration réseau (Wi-Fi / APN / Ethernet)]
3. [ex: Installation de l'application ou du firmware]
4. [ex: Activation / rattachement au site ou à l'environnement]
5. [ex: Vérification du health check (voir tronc commun § 8)]

### N.4 Mise à jour à distance

<!-- Stratégie de mise à jour selon la catégorie. Contraintes communes :
bande passante limitée, appareil en usage, continuité de service. -->

| Paramètre | Valeur | Notes |
|-----------|--------|-------|
| Mécanisme | [ex: TMS push / OTA firmware / App Store update] | |
| Fenêtre de déploiement | [ex: Nuit (22h-6h) ou période creuse] | |
| Téléchargement | [ex: En arrière-plan, Wi-Fi uniquement si > 10 Mo] | |
| Application de la MAJ | [ex: Au prochain redémarrage, ou forcé si patch critique] | |
| Rollback | [ex: Version N-1 conservée, rollback auto si crash au boot] | |
| Déploiement progressif | [ex: 10% → 50% → 100%, monitoring entre chaque vague] | |
| Taille max du livrable | [ex: 50 Mo (APK) / 256 Ko (firmware)] | [ex: Contrainte stockage cible] |
| Intégrité | [ex: Signature du binaire vérifiée avant installation] | [ex: Obligatoire en production] |

### N.5 Compatibilité et fragmentation

<!-- Gestion de la diversité du parc. -->

| Contrainte | Stratégie | Implémentation |
|-----------|-----------|---------------|
| [ex: Versions OS] | [ex: Android API 25 min / iOS 16 min / FreeRTOS 10.x] | [ex: `minSdkVersion`, compilation conditionnelle] |
| [ex: Tailles d'écran] | [ex: Support 4" à 8", layouts adaptatifs] | [ex: ConstraintLayout, qualifiers — ou N/A si pas d'écran] |
| [ex: Variance matérielle] | [ex: Abstraction via HAL (voir § N.2)] | [ex: Feature detection, graceful degradation] |
| [ex: Mémoire / stockage] | [ex: 1 Go RAM min (Android) / 256 Ko SRAM (MCU)] | [ex: Monitoring mémoire, pool statiques (MCU)] |
| [ex: Périphériques optionnels] | [ex: Scanner, imprimante, NFC absents sur certains modèles] | [ex: Détection au runtime, fonctionnalité désactivée si absent] |

### N.6 Mode hors-ligne et synchronisation

<!-- Les cibles embarquées sont souvent en connectivité intermittente
(entrepôt, livraison, zone blanche, tunnel).
Supprimer si l'appareil est toujours connecté. -->

| Fonctionnalité | Disponible hors-ligne | Stockage local | Synchronisation |
|---------------|----------------------|---------------|-----------------|
| [ex: Scan et saisie] | [ex: Oui] | [ex: SQLite / Room / fichier local] | [ex: Push au retour en ligne, FIFO, retry exponentiel] |
| [ex: Consultation catalogue] | [ex: Oui (cache)] | [ex: Dernier snapshot] | [ex: Refresh si connecté + données > 24h] |
| [ex: Paiement] | [ex: Non (connexion requise)] | — | — |

**Gestion des conflits :** [ex: Last-write-wins avec horodatage, ou
résolution manuelle pour les cas critiques]

**Stockage local max :** [ex: 200 Mo (Android) / non applicable (MCU sans
stockage persistant)]

### N.7 Gestion du cycle de vie matériel

<!-- Le matériel a un cycle de vie : batterie, usure, perte, vol,
remplacement, obsolescence. -->

| Événement | Procédure | Données impactées |
|-----------|-----------|-------------------|
| [ex: Remplacement] | [ex: Désenrôlement ancien, enrôlement nouveau, restauration config] | [ex: Données locales non sync perdues — alerte si queue > 0] |
| [ex: Perte / vol] | [ex: Wipe à distance via MDM, révocation des tokens] | [ex: Données chiffrées, inaccessibles après wipe] |
| [ex: Batterie faible] | [ex: Sync forcée à 15%, mode dégradé à 5%] | [ex: Sauvegarde queue en priorité] |
| [ex: MAJ OS fabricant] | [ex: Test de compatibilité avant déploiement, blocage si incompatible] | [ex: Aucune si compatible] |
| [ex: Fin de vie matériel] | [ex: Migration vers nouveau modèle, adaptation HAL] | [ex: Recertification si TPE] |

### N.8 Sécurité spécifique embarqué

<!-- Renvoi vers SECURITY.md pour les exigences générales. Ici, documenter
uniquement les contraintes propres à la cible embarquée. -->

| Exigence | Description | Implémentation |
|----------|-------------|---------------|
| [ex: Chiffrement stockage local] | [ex: Données applicatives chiffrées au repos] | [ex: EncryptedSharedPreferences (Android), SQLCipher, Flash chiffré (MCU)] |
| [ex: Certificate pinning] | [ex: Le terminal n'accepte que les certificats du serveur connu] | [ex: OkHttp CertificatePinner, TLS client cert (MCU)] |
| [ex: Verrouillage kiosque] | [ex: Pas d'accès au launcher / shell] | [ex: Mode kiosque MDM, COSU (Android)] |
| [ex: Secure boot] | [ex: Le firmware n'exécute que du code signé] | [ex: Chain of trust, bootloader verrouillé (MCU/TPE)] |
| [ex: Authentification opérateur] | [ex: Badge NFC ou code PIN] | [ex: Écran de login, timeout inactivité] |
| [ex: Anti-tampering] | [ex: Détection d'ouverture physique du boîtier (TPE)] | [ex: Effacement des clés si tamper détecté — imposé PCI-PTS] |

### N.9 Contraintes réglementaires spécifiques

<!-- Certaines cibles embarquées sont soumises à des certifications
spécifiques au-delà de la conformité logicielle.
Supprimer si non applicable. -->

| Certification | Applicabilité | Description | Impact sur le déploiement |
|--------------|--------------|-------------|--------------------------|
| [ex: PCI-PTS] | [ex: TPE] | [ex: Sécurité physique et logique du terminal de paiement] | [ex: Firmware signé, anti-tampering, audit de sécurité] |
| [ex: EMVCo] | [ex: TPE] | [ex: Conformité des transactions carte (contact / sans contact)] | [ex: Tests L1/L2/L3, certification par réseau (Visa, MC)] |
| [ex: CE / FCC] | [ex: Tout hardware] | [ex: Conformité électromagnétique et radio] | [ex: À charge du fabricant, mais impactant si modification hardware] |
| [ex: App Store Review] | [ex: iOS] | [ex: Conformité aux guidelines Apple] | [ex: Délai review ~24-48h, rejets possibles] |
