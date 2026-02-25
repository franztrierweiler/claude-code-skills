# Stellair LGC — Spécification SDD (Cas d'utilisation)

Version : 1.0
Date : 2026-02-25
Auteur : Équipe produit Olaqin
Statut : Brouillon

<!-- CHANGELOG — Ne pas inclure en v1.0. Décommenter à partir de la v1.1.
## Changelog

| Version | Date | Auteur | Modifications |
|---|---|---|---|
| 1.1 | YYYY-MM-DD | Équipe produit Olaqin | [Description des modifications] |
| 1.0 | 2026-02-25 | Équipe produit Olaqin | Version initiale. |
-->

## Contexte et objectifs

**Ce que le projet fait :** Stellair LGC est un logiciel de gestion de cabinet (LGC) en mode SaaS destiné aux médecins libéraux, couvrant le dossier médical patient, la prescription, la communication inter-professionnelle, l'agenda et l'aide à la décision médicale.

**Pourquoi il existe :** Les médecins libéraux ont besoin d'une solution moderne, accessible depuis n'importe quel poste connecté, intégrant les exigences du Ségur du numérique en santé (INS, DMP, MSSanté, ordonnance numérique, PSC) et s'interfaçant avec la solution de facturation/télétransmission Stellair Intégral déjà éditée par Olaqin.

**Pour qui :** Médecins libéraux exerçant seul ou à plusieurs en cabinet — avec une cible progressive : V0 (psychiatres), V1 (généralistes et spécialistes de ville), V2 (MSP et centres de santé).

**Contraintes structurantes :**

- **SaaS obligatoire** — Application hébergée dans le cloud, accessible via navigateur web, sans installation locale.
- **Architecture 3-tiers** — Séparation stricte frontend / backend / base de données.
- **HDS** — Hébergement des données de santé confié à un hébergeur certifié HDS (Claranet ou Cloud). Olaqin assure l'activité 5 (administration et exploitation du système d'information de santé).
- **RGPD** — Conformité au règlement général sur la protection des données.
- **SEGUR** — Référencement Ségur du numérique en santé (INS, DMP, MSSanté, ordonnance numérique, e-prescription).
- **PSC** — Authentification des professionnels de santé via Pro Santé Connect, au travers d'un composant proxy e-santé.

**Acteurs identifiés :**

| Acteur | Rôle |
|---|---|
| Médecin titulaire | Praticien libéral exerçant en cabinet, utilisateur principal du système. Accès complet à toutes les fonctions cliniques, prescriptions et administration de son activité. |
| Médecin remplaçant | Praticien assurant le remplacement d'un titulaire. Accès aux fonctions cliniques et de prescription dans le cadre du remplacement. |
| Interne / Docteur junior | Praticien en formation exerçant sous la responsabilité d'un titulaire. Prescription encadrée. |
| Professionnel de santé non médecin | Professionnel de santé habilité à prescrire dans son domaine de compétence (sage-femme, infirmier, etc.). Prescription limitée. |
| Assistant médical | Personnel assurant des tâches d'assistance au praticien. Accès en consultation aux dossiers et prescriptions, pas de droit de prescription. |
| Employé administratif | Personnel en charge de l'accueil, de la gestion administrative et de la planification. Accès limité aux données administratives. |
| Patient | Personne prise en charge. Interaction limitée : prise de rendez-vous en ligne. |
| Cron / services système | Tâches automatisées : rappels, synchronisations, purges, alertes. |
| Administrateur Olaqin | Personnel Olaqin en charge du support éditeur, de l'administration technique, des audits de sécurité et du reporting d'usage. |

## Diagramme de contexte

Le diagramme ci-dessous présente le périmètre de Stellair LGC et les systèmes avec lesquels il interagit.

```mermaid
graph TB
    subgraph Cabinet médical
        MT([Médecin titulaire])
        MR([Médecin remplaçant])
        IDJ([Interne / Docteur junior])
        PSNM([PS non médecin])
        AM([Assistant médical])
        EA([Employé administratif])
    end

    PAT([Patient])
    CRON([Cron / services système])

    subgraph Stellair LGC
        LGC[Stellair LGC<br/>Logiciel de Gestion<br/>de Cabinet]
    end

    subgraph Systèmes externes santé
        INSI[INSi<br/>Identité Nationale<br/>de Santé]
        AS[Annuaire Santé<br/>RPPS / ADELI / FINESS]
        MSS[MSSanté<br/>Messagerie Sécurisée<br/>de Santé]
        DMP[DMP / Mon Espace Santé<br/>Dossier Médical Partagé]
        PSC[Pro Santé Connect<br/>Authentification PS]
        SYN[Synapse Medicine<br/>LAP / Aide à la<br/>prescription]
        ONUME[Ordonnance<br/>numérique]
    end

    subgraph Olaqin
        SI[Stellair Intégral<br/>Facturation &<br/>Télétransmission]
        PROXY[Proxy e-santé<br/>Composant PSC]
    end

    subgraph Nomenclatures & Référentiels
        NOM[CIM-10 · LOINC · CIP13<br/>SNOMED CT · ATC]
    end

    MT --> LGC
    MR --> LGC
    IDJ --> LGC
    PSNM --> LGC
    AM --> LGC
    EA --> LGC
    PAT -->|Prise de RDV| LGC
    CRON --> LGC

    LGC <-->|Vérification identité| INSI
    LGC <-->|Recherche PS / structures| AS
    LGC <-->|Envoi / réception messages| MSS
    LGC <-->|Alimentation / consultation| DMP
    LGC <-->|Authentification| PROXY
    PROXY <-->|Délégation auth.| PSC
    LGC <-->|Aide à la prescription| SYN
    LGC <-->|Émission / consultation| ONUME
    LGC <-->|Interface facturation| SI
    LGC <-->|Codification / référentiels| NOM
```

## Architecture

Architecture imposée de haut niveau :

- **SaaS / Web** — Application accessible via navigateur, aucune installation locale.
- **3-tiers** — Frontend (interface utilisateur web), Backend (API et logique métier), Base de données (données patients et configuration).
- **Proxy e-santé** — Composant intermédiaire gérant l'authentification PSC et l'accès aux téléservices de santé (INSi, DMP, MSSanté, ordonnance numérique).
- **Interface Stellair Intégral** — Communication inter-applications avec le logiciel de facturation/télétransmission d'Olaqin.
- **Hébergement HDS** — Données de santé hébergées chez un hébergeur certifié HDS. Olaqin assure l'activité 5.

## Niveaux de support

### Systèmes externes — Niveau de support

| Système externe | Niveau | Commentaire |
|---|---|---|
| **INSi** (Identité Nationale de Santé) | À qualifier | Appel réel à planifier. Simulation implémentée. |
| **Annuaire Santé** (RPPS, ADELI, FINESS) | À qualifier | Simulation implémentée. Intégration API réelle à planifier. |
| **MSSanté** (Messagerie Sécurisée de Santé) | À qualifier | Structure prête. Envoi/réception réelle à implémenter. |
| **DMP / Mon Espace Santé** | À qualifier | Alimentation réelle à planifier. |
| **Pro Santé Connect** (PSC) | À qualifier | Via proxy e-santé. À implémenter. |
| **Synapse Medicine** (LAP) | À qualifier | Intégration à planifier. |
| **Ordonnance numérique** | À qualifier | À planifier. |
| **Stellair Intégral** (Facturation) | À qualifier | Interface inter-applications à définir. |
| **Nomenclatures** (CIM-10, LOINC, CIP13, SNOMED CT, ATC) | À qualifier | Champs prêts, API non intégrées. |

Les niveaux de support détaillés (Supporté / Ignoré / Erreur) seront qualifiés au fil de la rédaction des cas d'utilisation, pour chaque fonctionnalité de chaque système externe.

## Hors périmètre

- Facturation et télétransmission des actes — assurées par Stellair Intégral (logiciel séparé d'Olaqin). Seule l'interface de communication inter-applications est dans le périmètre.
- Application mobile native — Stellair LGC est une application web uniquement, accessible via navigateur.
- MSP et centres de santé — Cible V2, pas dans le périmètre V0/V1.
- Infrastructure et hébergement — Gestion serveurs, sauvegardes, monitoring infrastructure. L'hébergement HDS est confié à un tiers certifié.

## Arborescence des cas d'utilisation

| Package (niveau 2) | Package (niveau 1) | UC | Intitulé |
|---|---|---|---|
| **Authentification & Sécurité** | Authentification | UC-001 | S'authentifier par email / mot de passe |
| | | UC-002 | S'authentifier via Pro Santé Connect |
| | | UC-003 | Gérer sa session (JWT, refresh, déconnexion) |
| | Sécurité SEGUR | *(Reclassé en ENF)* | *(Exigences de sécurité SEGUR traitées en ENF)* |
| | | UC-005 | Réaliser un audit forensic |
| | Reporting | UC-006 | Consulter le reporting d'usage en temps réel |
| **Administration structure** | Gestion de la structure | UC-007 | Configurer la structure médicale |
| | Gestion des utilisateurs | UC-008 | Créer et gérer un compte utilisateur |
| | | UC-009 | Afficher et accepter les CGU |
| | | UC-010 | Renseigner les informations complémentaires du praticien |
| | Préférences | UC-011 | Configurer les préférences utilisateur |
| **Dossier patient** | Identité & fiche administrative | UC-012 | Rechercher un patient (header) |
| | | UC-013 | Rechercher un patient (recherche avancée) |
| | | UC-014 | Créer la fiche administrative d'un patient manuellement |
| | | UC-015 | Créer la fiche administrative via lecture carte Vitale |
| | | UC-016 | Appeler le téléservice INSi |
| | | UC-017 | Renouveler un appel INSi |
| | | UC-018 | Restituer et qualifier l'INS d'un patient |
| | | UC-019 | Consulter la fiche administrative d'un patient |
| | | UC-020 | Modifier la fiche administrative d'un patient |
| | | UC-021 | Gérer la file active des patients |
| | Pathologies | UC-022 | Ajouter une pathologie (codification CIM-10) |
| | | UC-023 | Consulter les informations d'une pathologie |
| | | UC-024 | Modifier une pathologie existante |
| | | UC-025 | Indiquer une absence de pathologie |
| | | UC-026 | Ajouter une note sur une pathologie |
| | | UC-027 | Visualiser traitements et consultations liés à une pathologie |
| | Traitements | UC-028 | Ajouter un traitement (codification CIP13/ATC) |
| | | UC-029 | Consulter les informations d'un traitement |
| | | UC-030 | Modifier un traitement existant |
| | | UC-031 | Indiquer une absence de traitement |
| | Allergies | UC-032 | Ajouter une allergie ou une intolérance |
| | | UC-033 | Consulter une allergie ou une intolérance |
| | | UC-034 | Modifier une allergie ou une intolérance |
| | | UC-035 | Déclarer des effets indésirables |
| | Habitus & modes de vie | UC-036 | Ajouter un habitus |
| | | UC-037 | Modifier un habitus |
| | | UC-038 | Consulter la liste des habitus d'un patient |
| | Vaccinations | UC-039 | Ajouter une vaccination avec gestion des rappels |
| | | UC-040 | Consulter l'historique vaccinal d'un patient |
| | Biométries | UC-041 | Saisir des biométries |
| | Antécédents familiaux | UC-042 | Ajouter un antécédent familial |
| | Épisodes de soins | UC-043 | Consulter les épisodes de soins d'un patient |
| | Consultation | UC-044 | Créer une consultation |
| | | UC-045 | Conduire une consultation avec assistant IA |
| | | UC-046 | Gérer les modèles de consultation |
| | | UC-047 | Calculer un score clinique |
| | | UC-048 | Utiliser un dispositif connecté en consultation |
| | | UC-049 | Clôturer et facturer une consultation |
| | Prescription PPS | UC-050 | Créer une prescription de produits de santé |
| | | UC-051 | Rechercher et prescrire un médicament |
| | | UC-052 | Construire la posologie d'un médicament |
| | | UC-053 | Gérer les paramètres réglementaires d'une prescription |
| | | UC-054 | Déclarer un médicament comme traitement de fond |
| | | UC-055 | Enregistrer un traitement prescrit à l'extérieur |
| | | UC-056 | Prescrire un accessoire ou dispositif médical |
| | | UC-057 | Prescrire une préparation magistrale |
| | | UC-058 | Renouveler le traitement de fond du patient |
| | | UC-059 | Prescrire depuis un modèle |
| | | UC-060 | Prescrire à partir d'une ancienne ordonnance |
| | | UC-061 | Gérer les alertes de prescription |
| | | UC-062 | Valider une prescription de produits de santé |
| | | UC-063 | Générer le PDF de l'ordonnance |
| | | UC-064 | Modifier une prescription existante |
| | | UC-065 | Consulter l'historique des ordonnances PPS |
| | | UC-066 | Transmettre une PPS par MSSanté |
| | Prescription biologie | UC-067 | Créer une prescription de biologie |
| | | UC-068 | Prescrire une biologie depuis un modèle |
| | | UC-069 | Prescrire une biologie à partir d'une ancienne ordonnance |
| | Autres prescriptions | UC-070 | Prescrire une ordonnance de soins infirmiers |
| | | UC-071 | Prescrire une ordonnance d'imagerie |
| | | UC-072 | Prescrire une ordonnance de kinésithérapie |
| | | UC-073 | Prescrire une ordonnance d'orthoptie |
| | | UC-074 | Prescrire une ordonnance d'orthophonie |
| | | UC-075 | Prescrire une ordonnance de pédicure-podologie |
| | | UC-076 | Prescrire une ordonnance "Autre" |
| | Ordonnance numérique | UC-077 | Construire une ordonnance numérique |
| | | UC-078 | Gérer les versions d'une ordonnance numérique |
| | | UC-079 | Envoyer une ordonnance numérique |
| | | UC-080 | Rechercher une ordonnance numérique |
| | | UC-081 | Consulter la délivrance d'une ordonnance numérique |
| | Documents & courriers | UC-082 | Rédiger un courrier |
| | | UC-083 | Gérer les modèles de courriers |
| | | UC-084 | Recevoir un document manuellement |
| | | UC-085 | Recevoir un document par MSSanté |
| | | UC-086 | Récupérer un document depuis le DMP |
| | | UC-087 | Envoyer un courrier ou document par MSSanté |
| | | UC-088 | Déposer un courrier ou document sur le DMP |
| | | UC-089 | Accéder aux téléservices documents (DMTi, AATi) |
| | | UC-090 | Produire le volet de synthèse médicale |
| | | UC-091 | Produire le carnet de santé de l'enfant |
| | Rappels | UC-092 | Créer et gérer les rappels d'un patient |
| | Timeline & historique | UC-093 | Consulter la timeline d'un patient |
| | Profil médical agrégé | UC-094 | Consulter le profil médical agrégé d'un patient |
| | Actions pluripro. | UC-095 | Actions pluriprofessionnelles, ETP, RCP |
| **Communication** | Annuaire Santé & contacts | UC-096 | Rechercher un PS dans l'annuaire santé |
| | | UC-097 | Enregistrer un PS ou une structure comme contact |
| | | UC-098 | Consulter et gérer la liste des contacts |
| | | UC-099 | Mettre à jour un contact depuis l'annuaire santé |
| | | UC-100 | Fusionner des contacts |
| | | UC-101 | Ajouter un contact hors annuaire santé |
| | MSSanté | UC-102 | Paramétrer les boîtes MSSanté |
| | | UC-103 | Envoyer un message MSSanté à un ou plusieurs PS |
| | | UC-104 | Envoyer un message avec pièces jointes (dont IHE-XDM) |
| | | UC-105 | Recevoir et afficher un message MSSanté |
| | | UC-106 | Enregistrer un message ou PJ dans le dossier patient |
| | DMP / Mon Espace Santé | UC-107 | Alimenter le DMP d'un patient |
| | | UC-108 | Consulter le DMP d'un patient |
| | Messagerie instantanée | UC-109 | Envoyer et recevoir des messages instantanés |
| | | UC-110 | Gérer des tâches inter-professionnelles |
| **Agenda** | Agenda praticien | UC-111 | Gérer l'agenda d'un praticien |
| | Prise de RDV patient | UC-112 | Prendre un rendez-vous en ligne (patient) |
| | Agenda pluri-professionnel | UC-113 | Consulter et gérer l'agenda pluri-professionnel |
| **Statistiques** | Statistiques d'activité | UC-114 | Consulter les statistiques d'usage des téléservices |
| | | UC-115 | Consulter les statistiques "forfait structure" |
| | | UC-116 | Consulter les indicateurs MSP |
| | Recherche patientèle | UC-117 | Rechercher dans l'historique des prescriptions |
| | | UC-118 | Effectuer une recherche multicritères |
| **Téléconsultation / Téléexpertise** | Téléconsultation | UC-119 | Réaliser une téléconsultation |
| | Téléexpertise | UC-120 | Demander ou fournir une téléexpertise |
| **Import données** | Import XMED | UC-121 | Restaurer un backup XMED |
| | | UC-122 | Migrer les patients depuis XMED |
| **Export données** | Export données LGC | UC-123 | Exporter les données du LGC |
| **Mode hors ligne** | Consultation hors ligne | UC-124 | Consulter la synthèse patient hors ligne |
| | | UC-125 | Prendre des notes hors ligne |
| | Réintégration | UC-126 | Réintégrer les notes à la reconnexion |

*Note : UC-004 (Exigences de sécurité SEGUR) a été reclassé en exigences non fonctionnelles (ENF). Les nomenclatures (ex-UC-127 à UC-130) et normes (ex-UC-131 à UC-138) seront également traitées en ENF.*

## Diagramme des cas d'utilisation

### Authentification & Sécurité

```mermaid
graph LR
    subgraph Acteurs
        TOUS([Tous utilisateurs])
        PS([Professionnels de santé])
        ADMIN([Administrateur Olaqin])
    end

    subgraph Authentification
        UC001[UC-001 : S'authentifier<br/>email / MDP]
        UC002[UC-002 : S'authentifier<br/>via PSC]
        UC003[UC-003 : Gérer sa session]
        UC009[UC-009 : Afficher et<br/>accepter les CGU]
    end

    subgraph Sécurité & Reporting
        UC005[UC-005 : Réaliser un<br/>audit forensic]
        UC006[UC-006 : Consulter le<br/>reporting d'usage]
    end

    TOUS --> UC001
    PS --> UC002
    UC001 -.->|extend| UC009
    UC002 -.->|extend| UC009
    UC001 -->|include| UC003
    UC002 -->|include| UC003
    ADMIN --> UC005
    ADMIN --> UC006
```

*Les diagrammes des autres packages seront générés au fil de la rédaction des UC.*

## Cas d'utilisation détaillés

### Authentification & Sécurité

#### Authentification

##### UC-001 : S'authentifier par email / mot de passe

**Résumé :** Le praticien ou le personnel du cabinet s'identifie avec ses identifiants email et mot de passe pour accéder au LGC.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, Professionnel de santé non médecin, Assistant médical, Employé administratif.

**Fréquence d'utilisation :** Plusieurs fois par jour par utilisateur.

**État initial :** L'utilisateur n'est pas authentifié. La page de login est affichée.

**État final :** L'utilisateur est authentifié. Un JWT et un refresh token sont générés. L'utilisateur accède au tableau de bord.

**Relations :**
- Include : UC-003 — Gestion de la session après authentification réussie.
- Extend : UC-009 — Affichage des CGU si première connexion ou mise à jour des CGU.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur accède à l'URL du LGC. |
| 1b | ← Système | Le système affiche la page d'authentification avec les champs email et mot de passe, et le lien vers l'authentification PSC. (IHM-001) |
| 2a | → Acteur | L'utilisateur saisit son email et son mot de passe, puis valide. |
| 2b | ← Système | Le système vérifie les identifiants, génère un JWT et un refresh token, et redirige vers le tableau de bord. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2b | Si l'email n'est pas reconnu | Message "Identifiants incorrects" (IHM-001). Retour étape 2a. |
| 2b | Si le mot de passe est incorrect | Message "Identifiants incorrects" (IHM-001). Retour étape 2a. |
| 2b | Si le compte est désactivé | Message "Compte désactivé, contactez votre administrateur". |
| 2b | Si le nombre de tentatives échouées dépasse le seuil | Message "Compte temporairement verrouillé". Voir RG-0002. |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0001 | 2b | Le message d'erreur ne distingue pas email inconnu et mot de passe incorrect (sécurité anti-énumération). |
| RG-0002 | 2b | Après N tentatives échouées consécutives, le compte est temporairement verrouillé pendant une durée D. (N et D à préciser.) |
| RG-0004 | 2b | Un flux de réinitialisation de mot de passe existe et est accessible depuis la page d'authentification. (À détailler ultérieurement.) |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-001 | Page d'authentification : champs email et mot de passe, bouton de connexion, lien "Mot de passe oublié", bouton "Se connecter avec Pro Santé Connect", lien vers les CGU. |

**Objets participants :** Utilisateur, Session, JWT, Refresh Token.

**Contraintes non fonctionnelles :** Voir ENF (sécurité SEGUR — à définir).

**Critères d'acceptation / Cas de tests :**

- **CA-UC-001-01 :** Soit un utilisateur avec un compte actif (email: test@cabinet.fr, MDP valide), Quand il saisit ses identifiants et valide, Alors le système le redirige vers le tableau de bord et un JWT est présent dans la session.
- **CA-UC-001-02 :** Soit un utilisateur avec un email valide mais un mot de passe incorrect, Quand il valide, Alors le message "Identifiants incorrects" est affiché et aucun JWT n'est généré.
- **CA-UC-001-03 :** Soit un utilisateur qui a échoué N fois consécutives, Quand il tente une (N+1)ème connexion, Alors le message "Compte temporairement verrouillé" est affiché.
- **CA-UC-001-04 :** Soit un utilisateur dont le compte est désactivé, Quand il saisit des identifiants valides, Alors le message "Compte désactivé, contactez votre administrateur" est affiché.

---

##### UC-002 : S'authentifier via Pro Santé Connect

**Résumé :** Le professionnel de santé s'identifie via Pro Santé Connect (carte CPS ou e-CPS) au travers du proxy e-santé pour accéder au LGC.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, Professionnel de santé non médecin.

**Fréquence d'utilisation :** Plusieurs fois par jour.

**État initial :** L'utilisateur n'est pas authentifié. La page de login est affichée.

**État final :** L'utilisateur est authentifié via PSC. Un JWT et un refresh token sont générés. L'utilisateur accède au tableau de bord.

**Relations :**
- Include : UC-003 — Gestion de la session après authentification réussie.
- Extend : UC-009 — Affichage des CGU si première connexion ou mise à jour des CGU.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur clique sur "Se connecter avec Pro Santé Connect" sur la page d'authentification. (IHM-001) |
| 1b | ← Système | Le système redirige vers le proxy e-santé, qui redirige vers la page d'authentification PSC. |
| 2a | → Acteur | L'utilisateur s'authentifie sur PSC (carte CPS, e-CPS ou autre moyen PSC). |
| 2b | ← Système | PSC retourne un jeton d'identité au proxy e-santé. Le proxy transmet l'identité au LGC. Le système vérifie que le PS est enregistré, génère un JWT et un refresh token, et redirige vers le tableau de bord. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2b | Si l'authentification PSC échoue (carte non lue, timeout) | Message "Échec de l'authentification PSC". Retour étape 1b. |
| 2b | Si le PS n'est pas enregistré dans le LGC | Message "Aucun compte associé à cette identité PSC, contactez votre administrateur". |
| 1b | Si le proxy e-santé est indisponible | Message "Service d'authentification PSC indisponible". Proposition de se connecter par email/MDP (dérouler UC-001). |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0005 | 2b | PSC peut être obligatoire pour accéder à certains téléservices (INSi, DMP, MSSanté, ordonnance numérique) même après authentification email/MDP. (À qualifier.) |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-001 | Page d'authentification (partagée avec UC-001). |

**Objets participants :** Utilisateur, Session, JWT, Refresh Token, Proxy e-santé, Jeton PSC.

**Contraintes non fonctionnelles :** Voir ENF (sécurité SEGUR — à définir).

**Critères d'acceptation / Cas de tests :**

- **CA-UC-002-01 :** Soit un PS enregistré dans le LGC, Quand il s'authentifie via PSC avec succès, Alors le système le redirige vers le tableau de bord et un JWT est présent dans la session.
- **CA-UC-002-02 :** Soit un PS non enregistré dans le LGC, Quand l'authentification PSC réussit, Alors le message "Aucun compte associé" est affiché.
- **CA-UC-002-03 :** Soit le proxy e-santé indisponible, Quand l'utilisateur clique sur "Se connecter avec PSC", Alors le message d'indisponibilité est affiché avec la possibilité de se connecter par email/MDP.

---

##### UC-003 : Gérer sa session (JWT, refresh, déconnexion)

**Résumé :** Le système gère le cycle de vie de la session utilisateur : maintien par refresh token, expiration automatique, et déconnexion volontaire. Les connexions simultanées sont autorisées.

**Acteurs :** Tous les utilisateurs, Cron / services système.

**Fréquence d'utilisation :** Continue (à chaque requête).

**État initial :** L'utilisateur est authentifié (UC-001 ou UC-002 déjà exécuté).

**État final :** Session maintenue (refresh transparent) ou terminée (déconnexion volontaire ou expiration).

**Relations :**
- Include : Aucune.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal — refresh automatique) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | Le JWT de l'utilisateur expire pendant une session active. |
| 1b | ← Système | Le système utilise le refresh token pour générer un nouveau JWT de manière transparente. L'utilisateur n'est pas interrompu. |

**Étapes (cas nominal — déconnexion volontaire) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur clique sur "Se déconnecter". |
| 1b | ← Système | Le système invalide le JWT et le refresh token de la session courante, puis redirige vers la page d'authentification. (IHM-001) |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 1b (refresh) | Si le refresh token est expiré ou invalide | Déconnexion automatique. Redirection vers la page d'authentification avec message "Session expirée, veuillez vous reconnecter". |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0003 | 1b | Les connexions simultanées sont autorisées. Chaque session possède son propre couple JWT / refresh token. La déconnexion d'une session n'invalide pas les autres. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-001 | Page d'authentification (redirection après déconnexion ou expiration). |

**Objets participants :** Session, JWT, Refresh Token.

**Contraintes non fonctionnelles :** Durée du JWT et du refresh token à préciser. Durée d'inactivité maximale avant déconnexion automatique à préciser.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-003-01 :** Soit un utilisateur authentifié dont le JWT vient d'expirer mais dont le refresh token est valide, Quand il effectue une action, Alors un nouveau JWT est généré et l'action est exécutée sans interruption.
- **CA-UC-003-02 :** Soit un utilisateur authentifié dont le refresh token est expiré, Quand il effectue une action, Alors il est redirigé vers la page d'authentification avec le message "Session expirée".
- **CA-UC-003-03 :** Soit un utilisateur authentifié sur deux navigateurs simultanément, Quand il se déconnecte du premier, Alors la session du second reste active.
- **CA-UC-003-04 :** Soit un utilisateur authentifié, Quand il clique sur "Se déconnecter", Alors le JWT et le refresh token sont invalidés et la page d'authentification est affichée.

---

#### Sécurité SEGUR

*Note : UC-004 (Appliquer les exigences de sécurité SEGUR) a été reclassé en exigences non fonctionnelles (ENF). Les exigences de chiffrement, traçabilité des accès, gestion des habilitations et conformité RGPD seront documentées dans la section "Exigences non fonctionnelles".*

##### UC-005 : Réaliser un audit forensic

**Résumé :** Un administrateur Olaqin consulte les journaux d'activité du système pour investiguer un incident de sécurité ou un accès anormal. Les journaux couvrent tous les événements : accès (login, consultation de dossier) et modifications de données (CRUD patient, prescription, etc.).

**Acteurs :** Administrateur Olaqin.

**Fréquence d'utilisation :** Rare, à la demande (investigation suite à incident ou suspicion).

**État initial :** Un incident ou une suspicion d'accès anormal a été signalé.

**État final :** L'administrateur dispose des traces d'activité nécessaires à l'investigation, éventuellement exportées.

**Relations :**
- Include : Aucune.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'administrateur Olaqin accède à l'interface de journaux d'activité. |
| 1b | ← Système | Le système affiche les filtres de recherche : période, utilisateur, type d'action (lecture, création, modification, suppression, authentification), ressource concernée. (IHM-002) |
| 2a | → Acteur | L'administrateur définit ses critères de recherche. |
| 2b | ← Système | Le système affiche la liste des événements correspondants : horodatage, utilisateur, action, ressource, résultat (succès/échec). |
| 3a | → Acteur | L'administrateur sélectionne un événement pour en voir le détail. |
| 3b | ← Système | Le système affiche le détail complet de l'événement : adresse IP, identifiant de session, données avant/après modification si applicable. |
| 4a | → Acteur | L'administrateur exporte les résultats. |
| 4b | ← Système | Le système génère un fichier d'export horodaté et signé. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2b | Si aucun événement ne correspond aux critères | Message "Aucun résultat pour les critères sélectionnés". Retour étape 2a. |
| 2b | Si la plage de recherche est trop large (> seuil) | Message "Veuillez réduire la période de recherche". Retour étape 2a. |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0006 | 1a | Seul le profil Administrateur Olaqin a accès à l'interface de journaux d'activité. |
| RG-0007 | 3b | Les journaux sont immuables : aucune modification ni suppression n'est possible. |
| RG-0008 | 4b | Le fichier d'export est horodaté et signé pour garantir son intégrité. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-002 | Interface de journaux d'activité : filtres (période, utilisateur, type d'action, ressource), liste des événements avec tri et pagination, vue détail d'un événement, bouton d'export. |

**Objets participants :** Journal d'activité, Événement, Utilisateur, Session.

**Contraintes non fonctionnelles :** Rétention des journaux à préciser. Performance de recherche sur gros volumes à préciser.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-005-01 :** Soit un administrateur Olaqin authentifié, Quand il recherche les événements d'un utilisateur sur les 7 derniers jours, Alors la liste des événements (connexions, consultations, modifications) est affichée avec horodatage.
- **CA-UC-005-02 :** Soit un événement de modification d'un dossier patient, Quand l'administrateur consulte le détail, Alors les données avant et après modification sont affichées.
- **CA-UC-005-03 :** Soit un administrateur qui exporte des résultats, Quand il clique sur exporter, Alors un fichier horodaté et signé est téléchargé.
- **CA-UC-005-04 :** Soit un utilisateur non administrateur, Quand il tente d'accéder à l'interface de journaux, Alors l'accès est refusé.

---

#### Reporting

##### UC-006 : Consulter le reporting d'usage en temps réel

**Résumé :** Un administrateur Olaqin consulte un tableau de bord d'usage du LGC : connexions actives, nombre de consultations, utilisation des téléservices.

**Acteurs :** Administrateur Olaqin.

**Fréquence d'utilisation :** À la demande.

**État initial :** L'administrateur est authentifié.

**État final :** Le tableau de bord d'usage est affiché avec les métriques actualisées.

**Relations :**
- Include : Aucune.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'administrateur Olaqin accède au module de reporting. |
| 1b | ← Système | Le système affiche le tableau de bord d'usage en temps réel : connexions actives, nombre de consultations, utilisation des téléservices (INSi, DMP, MSSanté). (IHM-003) |
| 2a | → Acteur | L'administrateur filtre par période, par cabinet ou par type de métrique. |
| 2b | ← Système | Le système met à jour l'affichage avec les données filtrées. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 1b | Si les données de reporting sont temporairement indisponibles | Message "Données en cours de chargement, veuillez réessayer". |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0009 | 1a | Seul le profil Administrateur Olaqin a accès au module de reporting. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-003 | Tableau de bord de reporting : métriques de connexions actives, nombre de consultations (jour/semaine/mois), utilisation des téléservices, filtres par période et par cabinet. |

**Objets participants :** Métrique d'usage, Session, Téléservice.

**Contraintes non fonctionnelles :** Temps de rafraîchissement du tableau de bord à préciser.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-006-01 :** Soit un administrateur Olaqin authentifié, Quand il accède au module de reporting, Alors le tableau de bord affiche les connexions actives, le nombre de consultations et l'utilisation des téléservices.
- **CA-UC-006-02 :** Soit un administrateur qui filtre par la période "7 derniers jours", Quand il applique le filtre, Alors les métriques sont recalculées sur cette période.
- **CA-UC-006-03 :** Soit un utilisateur non administrateur, Quand il tente d'accéder au module de reporting, Alors l'accès est refusé.

---

### Administration structure

```mermaid
graph LR
    subgraph Acteurs
        ADMIN([Administrateur Olaqin])
        PS([Praticiens])
        TOUS([Tous utilisateurs])
    end

    subgraph Gestion structure
        UC007[UC-007 : Configurer la<br/>structure médicale]
    end

    subgraph Gestion utilisateurs
        UC008[UC-008 : Créer et gérer<br/>un compte utilisateur]
        UC009[UC-009 : Afficher et<br/>accepter les CGU]
        UC010[UC-010 : Renseigner infos<br/>complémentaires praticien]
    end

    subgraph Préférences
        UC011[UC-011 : Configurer les<br/>préférences utilisateur]
    end

    ADMIN --> UC007
    ADMIN --> UC008
    UC008 -->|include| UC007
    TOUS --> UC009
    PS --> UC010
    UC010 -.->|extend| UC096[UC-096 : Rechercher PS<br/>dans annuaire santé]
    TOUS --> UC011
```

#### Gestion de la structure

##### UC-007 : Configurer la structure médicale

**Résumé :** L'administrateur Olaqin configure la structure médicale lors de la souscription : informations du cabinet (nom, adresse, FINESS, téléphone, email, spécialités, horaires), et rattachement des praticiens. Un praticien peut être rattaché à plusieurs sites.

**Acteurs :** Administrateur Olaqin.

**Fréquence d'utilisation :** Rare (à la souscription, puis modification ponctuelle).

**État initial :** La souscription à l'offre Stellair LGC a été validée.

**État final :** La structure médicale est configurée et prête à accueillir les comptes utilisateurs.

**Relations :**
- Include : Aucune.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'administrateur Olaqin accède à l'interface d'administration des structures. |
| 1b | ← Système | Le système affiche la liste des cabinets existants avec possibilité de créer, modifier ou consulter. (IHM-004) |
| 2a | → Acteur | L'administrateur crée ou sélectionne un cabinet. |
| 2b | ← Système | Le système affiche le formulaire de configuration : nom, adresse, numéro FINESS, téléphone, email, spécialités exercées, horaires d'ouverture. (IHM-005) |
| 3a | → Acteur | L'administrateur renseigne les informations et valide. |
| 3b | ← Système | Le système enregistre la configuration et affiche le récapitulatif. |
| 4a | → Acteur | L'administrateur rattache un ou plusieurs praticiens au cabinet. |
| 4b | ← Système | Le système enregistre les rattachements praticien-cabinet. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 3b | Si le numéro FINESS est invalide ou déjà utilisé | Message "Numéro FINESS invalide ou déjà rattaché à un autre cabinet". Retour étape 3a. |
| 4b | Si le praticien est déjà rattaché à ce cabinet | Message "Ce praticien est déjà rattaché à cette structure". |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0010 | 1a | Seul le profil Administrateur Olaqin peut créer et configurer une structure médicale. |
| RG-0011 | 4b | Un praticien peut être rattaché à plusieurs sites/cabinets simultanément. |
| RG-0012 | 4b | Le rattachement et le détachement d'un praticien sont gérés exclusivement par l'Administrateur Olaqin. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-004 | Liste des cabinets : tableau avec nom, adresse, nombre de praticiens rattachés, actions (créer, modifier, consulter). |
| IHM-005 | Formulaire de configuration cabinet : nom, adresse, FINESS, téléphone, email, spécialités, horaires d'ouverture, liste des praticiens rattachés avec possibilité d'ajout/retrait. |

**Objets participants :** Structure médicale (Cabinet), Praticien, Site.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-007-01 :** Soit un administrateur Olaqin authentifié, Quand il crée un cabinet avec un FINESS valide et une adresse complète, Alors le cabinet apparaît dans la liste des structures.
- **CA-UC-007-02 :** Soit un cabinet existant, Quand l'administrateur rattache un praticien, Alors le praticien apparaît dans la liste des praticiens du cabinet.
- **CA-UC-007-03 :** Soit un praticien déjà rattaché au cabinet A, Quand l'administrateur le rattache au cabinet B, Alors le praticien est rattaché aux deux cabinets simultanément.
- **CA-UC-007-04 :** Soit un FINESS déjà utilisé par un autre cabinet, Quand l'administrateur tente de créer un cabinet avec ce FINESS, Alors un message d'erreur est affiché.

---

#### Gestion des utilisateurs

##### UC-008 : Créer et gérer un compte utilisateur

**Résumé :** L'administrateur Olaqin crée un compte utilisateur lors de la souscription, lui attribue un profil (médecin titulaire, remplaçant, interne, PSNM, assistant, employé admin), le rattache à un ou plusieurs cabinets, et gère son cycle de vie (activation, désactivation). Toute modification de compte (y compris email et mot de passe) passe par l'administrateur.

**Acteurs :** Administrateur Olaqin.

**Fréquence d'utilisation :** Ponctuel (souscription, arrivée/départ d'un collaborateur).

**État initial :** La structure médicale est configurée (UC-007 déjà exécuté).

**État final :** Le compte utilisateur est créé et actif. L'utilisateur peut s'authentifier.

**Relations :**
- Include : UC-007 — La structure médicale doit exister avant de créer un utilisateur.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'administrateur Olaqin accède à l'interface de gestion des utilisateurs. |
| 1b | ← Système | Le système affiche la liste des utilisateurs existants avec possibilité de créer, modifier, activer ou désactiver. (IHM-006) |
| 2a | → Acteur | L'administrateur crée un nouvel utilisateur : nom, prénom, email, profil (rôle), cabinet(s) rattaché(s). |
| 2b | ← Système | Le système crée le compte, génère un mot de passe temporaire et envoie un email d'activation à l'utilisateur. |
| 3a | → Acteur | L'administrateur confirme la création. |
| 3b | ← Système | Le système affiche le récapitulatif du compte créé. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2b | Si l'email est déjà utilisé par un autre compte | Message "Un compte existe déjà avec cet email". Retour étape 2a. |
| 2b | Si aucun cabinet n'est rattaché | Message "Veuillez rattacher au moins un cabinet". Retour étape 2a. |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0013 | 1a | Seul le profil Administrateur Olaqin peut créer et gérer les comptes utilisateurs. |
| RG-0014 | 2b | Un utilisateur doit être rattaché à au moins un cabinet. |
| RG-0015 | 2b | Le profil (rôle) détermine les droits d'accès aux fonctionnalités du LGC. Les droits par profil sont définis dans les RG des UC concernés. |
| RG-0016 | 2b | La désactivation d'un compte n'entraîne pas la suppression des données. Le compte est marqué inactif et l'accès est bloqué. |
| RG-0023 | 2b | Toute modification d'un compte utilisateur (email, mot de passe, profil, rattachements) est réalisée exclusivement par l'Administrateur Olaqin. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-006 | Gestion des utilisateurs : liste des comptes avec nom, email, profil, statut (actif/inactif), cabinets rattachés. Actions : créer, modifier, activer, désactiver. |

**Objets participants :** Utilisateur, Profil (rôle), Structure médicale (Cabinet).

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-008-01 :** Soit un administrateur Olaqin avec un cabinet configuré, Quand il crée un compte avec email, profil "Médecin titulaire" et rattachement au cabinet, Alors le compte apparaît dans la liste et un email d'activation est envoyé.
- **CA-UC-008-02 :** Soit un email déjà utilisé, Quand l'administrateur tente de créer un compte avec cet email, Alors le message "Un compte existe déjà" est affiché.
- **CA-UC-008-03 :** Soit un compte actif, Quand l'administrateur le désactive, Alors le statut passe à "inactif" et l'utilisateur ne peut plus se connecter (voir CA-UC-001-04).
- **CA-UC-008-04 :** Soit un compte désactivé, Quand l'administrateur consulte les données de l'utilisateur, Alors toutes les données sont toujours accessibles (pas de suppression).

---

##### UC-009 : Afficher et accepter les CGU

**Résumé :** Lors de la première connexion ou après une mise à jour des CGU, le système affiche les conditions générales d'utilisation. L'utilisateur doit les accepter pour accéder au LGC.

**Acteurs :** Tous les utilisateurs (Médecin titulaire, Médecin remplaçant, Interne, PSNM, Assistant médical, Employé administratif).

**Fréquence d'utilisation :** Rare (première connexion, mise à jour CGU).

**État initial :** L'utilisateur vient de s'authentifier (UC-001 ou UC-002). Les CGU n'ont pas été acceptées ou ont été mises à jour depuis la dernière acceptation.

**État final :** L'utilisateur a accepté les CGU et accède au tableau de bord.

**Relations :**
- Include : Aucune.
- Extend : UC-001 (condition : CGU non acceptées ou mises à jour). UC-002 (même condition).
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur vient de s'authentifier. |
| 1b | ← Système | Le système détecte que les CGU n'ont pas été acceptées (ou qu'une nouvelle version est disponible) et affiche les CGU. (IHM-007) |
| 2a | → Acteur | L'utilisateur lit et accepte les CGU. |
| 2b | ← Système | Le système enregistre l'acceptation (utilisateur, version CGU, date) et redirige vers le tableau de bord. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2a | Si l'utilisateur refuse les CGU | Message "L'acceptation des CGU est obligatoire pour utiliser le LGC". L'utilisateur est déconnecté. Dérouler UC-003 (déconnexion). |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0017 | 1b | L'acceptation des CGU est obligatoire. Sans acceptation, aucun accès au LGC. |
| RG-0018 | 2b | L'historique des acceptations est conservé : utilisateur, version des CGU, date et heure d'acceptation. |
| RG-0019 | 1b | À chaque mise à jour des CGU, tous les utilisateurs doivent accepter la nouvelle version à leur prochaine connexion. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-007 | Écran d'acceptation des CGU : texte des CGU (scrollable), bouton "Accepter", bouton "Refuser". |

**Objets participants :** CGU, Acceptation CGU, Utilisateur.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-009-01 :** Soit un utilisateur qui se connecte pour la première fois, Quand l'authentification réussit, Alors l'écran des CGU est affiché avant l'accès au tableau de bord.
- **CA-UC-009-02 :** Soit un utilisateur qui a accepté les CGU v1.0, Quand les CGU sont mises à jour en v2.0 et qu'il se reconnecte, Alors l'écran des CGU v2.0 est affiché.
- **CA-UC-009-03 :** Soit un utilisateur qui accepte les CGU, Quand il clique sur "Accepter", Alors l'acceptation est enregistrée avec la version et la date, et le tableau de bord est affiché.
- **CA-UC-009-04 :** Soit un utilisateur qui refuse les CGU, Quand il clique sur "Refuser", Alors il est déconnecté et redirigé vers la page d'authentification.

---

##### UC-010 : Renseigner les informations complémentaires du praticien

**Résumé :** Le praticien complète son profil avec ses informations professionnelles : numéro RPPS/ADELI, spécialité, qualifications, signature numérisée, adresse MSSanté. Ces informations sont utilisées pour pré-remplir les en-têtes d'ordonnances et de courriers.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, Professionnel de santé non médecin.

**Fréquence d'utilisation :** Rare (à la première utilisation, puis modification ponctuelle).

**État initial :** Le compte utilisateur est créé et actif (UC-008 déjà exécuté). L'utilisateur est authentifié.

**État final :** Le profil praticien est complet et utilisable pour les prescriptions et courriers.

**Relations :**
- Include : Aucune.
- Extend : UC-096 — Vérification optionnelle du RPPS dans l'annuaire santé. (À clarifier.)
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | Le praticien accède à son profil. |
| 1b | ← Système | Le système affiche le formulaire de profil praticien. (IHM-008) |
| 2a | → Acteur | Le praticien renseigne ses informations : RPPS/ADELI, spécialité, qualifications, signature numérisée, adresse MSSanté. |
| 2b | ← Système | Le système valide et enregistre les informations. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2b | Si le numéro RPPS est invalide (format incorrect) | Message "Numéro RPPS invalide". Retour étape 2a. |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0020 | 2b | Le numéro RPPS est vérifié en format. La vérification dans l'annuaire santé est optionnelle (à clarifier — lien potentiel avec UC-096). |
| RG-0021 | 2b | Les informations du profil praticien sont utilisées pour pré-remplir les en-têtes d'ordonnances et de courriers. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-008 | Formulaire profil praticien : RPPS/ADELI, spécialité, qualifications, upload de signature numérisée, adresse MSSanté. |

**Objets participants :** Praticien, Profil professionnel, Signature.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-010-01 :** Soit un praticien authentifié avec un profil vierge, Quand il renseigne son RPPS, sa spécialité et sa signature, Alors les informations sont enregistrées et affichées dans le profil.
- **CA-UC-010-02 :** Soit un praticien qui saisit un RPPS au format invalide, Quand il valide, Alors le message "Numéro RPPS invalide" est affiché.
- **CA-UC-010-03 :** Soit un praticien avec un profil complet, Quand il crée une ordonnance, Alors les en-têtes sont pré-remplis avec ses informations professionnelles.

---

#### Préférences

##### UC-011 : Configurer les préférences utilisateur

**Résumé :** L'utilisateur personnalise son expérience : thème d'affichage, modèle de consultation par défaut, modèle d'ordonnance par défaut, notifications (email, in-app).

**Acteurs :** Tous les utilisateurs (Médecin titulaire, Médecin remplaçant, Interne, PSNM, Assistant médical, Employé administratif).

**Fréquence d'utilisation :** Rare (configuration initiale, puis ajustements ponctuels).

**État initial :** L'utilisateur est authentifié.

**État final :** Les préférences sont enregistrées et appliquées immédiatement à l'interface.

**Relations :**
- Include : Aucune.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur accède aux paramètres / préférences. |
| 1b | ← Système | Le système affiche les préférences actuelles avec possibilité de modification. (IHM-009) |
| 2a | → Acteur | L'utilisateur modifie ses préférences et valide. |
| 2b | ← Système | Le système enregistre les préférences et les applique immédiatement à l'interface. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2b | Si une valeur de préférence est invalide | Message d'erreur sur le champ concerné. Retour étape 2a. |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0022 | 2b | Les préférences sont propres à chaque utilisateur. Elles n'affectent pas les autres utilisateurs du même cabinet. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-009 | Paramètres / préférences : thème d'affichage, modèle de consultation par défaut, modèle d'ordonnance par défaut, préférences de notification (email, in-app). |

**Objets participants :** Préférences utilisateur, Utilisateur.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-011-01 :** Soit un utilisateur authentifié, Quand il modifie le thème d'affichage et valide, Alors le thème est appliqué immédiatement sans rechargement de page.
- **CA-UC-011-02 :** Soit un utilisateur qui a configuré un modèle d'ordonnance par défaut, Quand il crée une nouvelle prescription, Alors le modèle par défaut est pré-sélectionné.
- **CA-UC-011-03 :** Soit deux utilisateurs du même cabinet avec des préférences différentes, Quand chacun se connecte, Alors chacun voit ses propres préférences appliquées.

---

### Dossier patient

#### Identité & fiche administrative

```mermaid
graph LR
    subgraph Acteurs
        CLIN([Cliniciens])
        TOUS([Tous utilisateurs])
    end

    UC012[UC-012 : Rechercher patient<br/>header]
    UC013[UC-013 : Rechercher patient<br/>avancée]
    UC014[UC-014 : Créer fiche<br/>manuellement]
    UC015[UC-015 : Créer fiche<br/>carte Vitale]
    UC016[UC-016 : Appeler INSi]
    UC017[UC-017 : Renouveler INSi]
    UC018[UC-018 : Qualifier INS]
    UC019[UC-019 : Consulter fiche]
    UC020[UC-020 : Modifier fiche]
    UC021[UC-021 : File active]

    TOUS --> UC012
    TOUS --> UC013
    TOUS --> UC014
    TOUS --> UC015
    TOUS --> UC019
    TOUS --> UC020
    CLIN --> UC016
    CLIN --> UC017
    CLIN --> UC018
    CLIN --> UC021

    UC012 -.->|extend| UC014
    UC014 -->|include| UC016
    UC015 -->|include| UC016
    UC017 -.->|extend| UC016
    UC020 -.->|extend| UC017
```

##### UC-012 : Rechercher un patient (header)

**Résumé :** L'utilisateur recherche un patient via la barre de recherche présente en permanence dans le header de l'application (recherche rapide par nom, prénom ou date de naissance).

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, PSNM, Assistant médical, Employé administratif.

**Fréquence d'utilisation :** Très fréquent (plusieurs dizaines de fois par jour).

**État initial :** L'utilisateur est authentifié. Le header est visible.

**État final :** Le patient est identifié et son dossier est accessible.

**Relations :**
- Include : Aucune.
- Extend : UC-014 — Si le patient n'existe pas, proposition de le créer.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur saisit un texte dans la barre de recherche du header (nom, prénom ou date de naissance). |
| 1b | ← Système | Le système affiche en temps réel une liste de patients correspondants (autocomplétion). Chaque résultat affiche : nom, prénom, date de naissance, INS si disponible. |
| 2a | → Acteur | L'utilisateur sélectionne un patient dans la liste. |
| 2b | ← Système | Le système ouvre le dossier du patient sélectionné. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 1b | Si aucun patient ne correspond | Message "Aucun patient trouvé". Proposition de créer un nouveau patient (dérouler UC-014). |
| 1b | Si la liste dépasse le nombre maximal de résultats affichables | Message "Affinez votre recherche". La liste est tronquée. |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0024 | 1b | La recherche est déclenchée à partir de 3 caractères saisis. |
| RG-0025 | 1b | La recherche porte sur le nom de naissance, le nom d'usage, le prénom et la date de naissance. |
| RG-0026 | 2b | L'accès au dossier patient est soumis au profil de l'utilisateur. L'assistant médical et l'employé administratif n'accèdent qu'aux données autorisées par leur profil. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-010 | Barre de recherche patient dans le header : champ texte avec autocomplétion, liste déroulante de résultats (nom, prénom, date de naissance, INS). |

**Objets participants :** Patient, Identité INS.

**Contraintes non fonctionnelles :** L'autocomplétion doit être fluide — temps de réponse à préciser (voir ENF).

**Critères d'acceptation / Cas de tests :**

- **CA-UC-012-01 :** Soit un patient "Dupont Marie" existant, Quand l'utilisateur saisit "Dup" dans le header, Alors "Dupont Marie" apparaît dans la liste d'autocomplétion.
- **CA-UC-012-02 :** Soit aucun patient correspondant à "Zzzzz", Quand l'utilisateur saisit "Zzzzz", Alors le message "Aucun patient trouvé" est affiché avec un lien de création.
- **CA-UC-012-03 :** Soit l'utilisateur saisit seulement 2 caractères, Quand il attend, Alors aucune recherche n'est déclenchée.

---

##### UC-013 : Rechercher un patient (recherche avancée)

**Résumé :** L'utilisateur effectue une recherche multicritères depuis la liste des patients : nom, prénom, date de naissance, INS, numéro de sécurité sociale, sexe, praticien référent.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, PSNM, Assistant médical, Employé administratif.

**Fréquence d'utilisation :** Plusieurs fois par jour.

**État initial :** L'utilisateur est authentifié.

**État final :** La liste filtrée de patients est affichée.

**Relations :**
- Include : Aucune.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur accède à la liste des patients et ouvre le panneau de recherche avancée. |
| 1b | ← Système | Le système affiche le formulaire de recherche avancée avec les critères disponibles. (IHM-014) |
| 2a | → Acteur | L'utilisateur renseigne un ou plusieurs critères et lance la recherche. |
| 2b | ← Système | Le système affiche la liste des patients correspondants avec pagination. |
| 3a | → Acteur | L'utilisateur sélectionne un patient. |
| 3b | ← Système | Le système ouvre le dossier du patient sélectionné. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2b | Si aucun patient ne correspond | Message "Aucun résultat pour les critères saisis". |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0037 | 2a | Un praticien peut filtrer la liste pour n'afficher que "ses" patients (relation M:M praticien-patient). |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-014 | Recherche avancée patient : champs nom, prénom, date de naissance, INS, NSS, sexe, praticien référent. Résultats en tableau avec tri et pagination. |

**Objets participants :** Patient, Identité INS, Praticien.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-013-01 :** Soit 5000 patients en base, Quand l'utilisateur recherche par nom "Martin" et sexe "F", Alors seuls les patients correspondants sont affichés avec pagination.
- **CA-UC-013-02 :** Soit un praticien Dr. Dupont avec 200 patients rattachés, Quand il filtre par "Mes patients", Alors seuls ses 200 patients sont affichés.

---

##### UC-014 : Créer la fiche administrative d'un patient manuellement

**Résumé :** L'utilisateur crée un nouveau patient en saisissant manuellement ses informations administratives. L'identité est provisoire jusqu'à qualification par appel INSi.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, PSNM, Assistant médical, Employé administratif.

**Fréquence d'utilisation :** Plusieurs fois par jour.

**État initial :** L'utilisateur est authentifié. Le patient n'existe pas dans le système.

**État final :** La fiche patient est créée avec une identité provisoire.

**Relations :**
- Include : UC-016 — Appel INSi proposé après création.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur accède au formulaire de création de patient. |
| 1b | ← Système | Le système affiche le formulaire de saisie : état civil (nom de naissance, nom d'usage, prénoms, sexe, date de naissance, lieu de naissance), coordonnées (adresse, téléphone, email), NSS, médecin traitant. (IHM-011) |
| 2a | → Acteur | L'utilisateur renseigne les informations et valide. |
| 2b | ← Système | Le système récupère automatiquement le COG à partir des données de naissance. Le système crée le patient avec le statut d'identité "provisoire" et propose de lancer l'appel INSi (UC-016). |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2b | Si un patient avec les mêmes données d'identité existe déjà | Message "Un patient avec ces informations existe déjà" avec lien vers le dossier existant. Retour étape 2a. |
| 2b | Si le lieu de naissance ne permet pas de récupérer le COG | Message "Lieu de naissance non reconnu. Veuillez vérifier ou saisir le COG manuellement". |
| 2a | Si les champs obligatoires ne sont pas renseignés | Message d'erreur sur les champs manquants. Retour étape 2a. |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0027 | 2b | L'identité d'un patient créé manuellement est au statut "provisoire" tant qu'elle n'a pas été qualifiée par l'INSi. |
| RG-0028 | 2b | Le COG est récupéré automatiquement à partir de la commune et du pays de naissance. |
| RG-0029 | 2a | Les champs obligatoires pour la création sont : nom de naissance, premier prénom, sexe, date de naissance. |
| RG-0038 | 2b | À la création, le patient est automatiquement rattaché au praticien qui le crée (relation M:M praticien-patient). |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-011 | Fiche administrative patient (création, consultation, modification) : état civil, coordonnées, NSS, INS (NIR/NIA, OID, statut), médecin traitant, praticiens rattachés. |

**Objets participants :** Patient, Identité INS, Praticien, COG.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-014-01 :** Soit un utilisateur authentifié, Quand il crée un patient avec nom "Martin", prénom "Jean", sexe "M", date de naissance "1985-03-15", Alors le patient est créé avec le statut d'identité "provisoire" et l'appel INSi est proposé.
- **CA-UC-014-02 :** Soit un patient "Martin Jean 1985-03-15" déjà existant, Quand l'utilisateur tente de créer un patient identique, Alors le message "Ce patient existe déjà" est affiché avec un lien vers le dossier.
- **CA-UC-014-03 :** Soit un utilisateur qui ne remplit pas le nom de naissance, Quand il valide, Alors un message d'erreur sur le champ obligatoire est affiché.
- **CA-UC-014-04 :** Soit un patient créé par le Dr. Dupont, Quand la création est confirmée, Alors le patient apparaît dans la liste "Mes patients" du Dr. Dupont.

---

##### UC-015 : Créer la fiche administrative via lecture carte Vitale

**Résumé :** L'utilisateur crée un patient en lisant sa carte Vitale. Les informations administratives sont pré-remplies à partir des données de la carte. La lecture est actuellement simulée par un fichier de test.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, PSNM, Assistant médical, Employé administratif.

**Fréquence d'utilisation :** Plusieurs fois par jour.

**État initial :** L'utilisateur est authentifié. Un lecteur de carte Vitale est disponible (ou simulation active).

**État final :** La fiche patient est créée avec les données de la carte Vitale.

**Relations :**
- Include : UC-016 — Appel INSi proposé après lecture carte.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur déclenche la lecture de la carte Vitale. |
| 1b | ← Système | Le système lit les données de la carte (ou du fichier de simulation) et pré-remplit le formulaire de création patient : nom, prénom, date de naissance, NSS. (IHM-011) |
| 2a | → Acteur | L'utilisateur vérifie les données pré-remplies, complète si nécessaire (coordonnées, médecin traitant) et valide. |
| 2b | ← Système | Le système crée le patient et propose de lancer l'appel INSi (UC-016). |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 1b | Si la carte n'est pas lue (erreur lecteur, carte invalide, fichier de test absent) | Message "Impossible de lire la carte Vitale". Proposition de saisie manuelle (dérouler UC-014). |
| 2b | Si le patient existe déjà dans le système | Message "Ce patient existe déjà" avec lien vers le dossier. Proposition de mettre à jour les données. |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0030 | 1b | La lecture de la carte Vitale est actuellement simulée par un fichier de test. L'intégration réelle du lecteur est à planifier. |
| RG-0038 | 2b | À la création, le patient est automatiquement rattaché au praticien qui le crée. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-011 | Fiche administrative patient (partagée avec UC-014, UC-019, UC-020). |

**Objets participants :** Patient, Carte Vitale, Identité INS.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-015-01 :** Soit un fichier de simulation de carte Vitale disponible, Quand l'utilisateur déclenche la lecture, Alors le formulaire est pré-rempli avec les données du fichier.
- **CA-UC-015-02 :** Soit l'échec de la lecture carte Vitale, Quand le système détecte l'erreur, Alors le message d'erreur est affiché avec la proposition de saisie manuelle.
- **CA-UC-015-03 :** Soit un patient déjà existant dont les données correspondent à la carte lue, Quand le système détecte le doublon, Alors il propose de mettre à jour le dossier existant.

---

##### UC-016 : Appeler le téléservice INSi

**Résumé :** Le système appelle le téléservice INSi pour vérifier et qualifier l'identité d'un patient à partir de ses traits d'identité. L'appel est actuellement simulé.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, PSNM, Assistant médical.

**Fréquence d'utilisation :** À chaque création ou mise à jour d'identité patient.

**État initial :** La fiche patient existe avec des données d'identité saisies (UC-014 ou UC-015 exécuté).

**État final :** L'identité est qualifiée (INS vérifié et statut "validée") ou reste "provisoire" (échec).

**Relations :**
- Include : Aucune (ce UC est inclus par UC-014 et UC-015).
- Extend : UC-017 — Renouvellement d'appel.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur déclenche l'appel INSi depuis la fiche patient. |
| 1b | ← Système | Le système envoie les traits d'identité (nom, prénom, date de naissance, sexe, NSS) au téléservice INSi via le proxy e-santé. |
| 2a | ← Système | L'INSi retourne le matricule INS (NIR ou NIA) et l'OID. |
| 2b | ← Système | Le système met à jour la fiche patient : INS, OID, statut d'identité passe à "validée". Le résultat est affiché. (IHM-012) |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 1b | Si le proxy e-santé ou le téléservice INSi est indisponible | Message "Téléservice INSi indisponible". L'identité reste en statut "provisoire". |
| 2a | Si l'INSi ne trouve pas de correspondance | Message "Aucune identité trouvée. Vérifiez les traits d'identité saisis". L'identité reste "provisoire". |
| 2a | Si l'INSi retourne plusieurs correspondances | Le système affiche la liste des correspondances et demande à l'utilisateur de sélectionner la bonne. |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0031 | 1b | L'appel INSi est actuellement simulé. L'intégration réelle de l'API INSi est à planifier. |
| RG-0032 | 2b | Le statut d'identité suit la progression : provisoire → validée → qualifiée. |
| RG-0033 | 2b | Le contrôle du premier prénom de naissance est effectué par comparaison avec la liste des prénoms retournée par l'INSi. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-012 | Section identité INS de la fiche patient : INS (NIR/NIA), OID, statut d'identité (provisoire/validée/qualifiée), bouton "Appeler INSi", bouton "Qualifier l'identité", historique des appels. |

**Objets participants :** Patient, Identité INS, Téléservice INSi, Proxy e-santé.

**Contraintes non fonctionnelles :** Temps de réponse de l'appel INSi à préciser (voir ENF).

**Critères d'acceptation / Cas de tests :**

- **CA-UC-016-01 :** Soit un patient avec identité "provisoire" et des traits valides, Quand l'utilisateur lance l'appel INSi, Alors l'INS est retourné et le statut passe à "validée".
- **CA-UC-016-02 :** Soit le téléservice INSi indisponible, Quand l'utilisateur lance l'appel, Alors le message d'indisponibilité est affiché et le statut reste "provisoire".
- **CA-UC-016-03 :** Soit des traits d'identité ne correspondant à aucun assuré, Quand l'appel INSi est effectué, Alors le message "Aucune identité trouvée" est affiché.
- **CA-UC-016-04 :** Soit des traits retournant plusieurs correspondances, Quand l'appel INSi est effectué, Alors la liste est affichée et l'utilisateur peut sélectionner la bonne identité.

---

##### UC-017 : Renouveler un appel INSi

**Résumé :** L'utilisateur relance un appel INSi pour un patient dont l'identité n'a pas pu être qualifiée lors d'un appel précédent, ou dont les données d'identité ont été corrigées.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, PSNM, Assistant médical.

**Fréquence d'utilisation :** Occasionnel.

**État initial :** La fiche patient existe. Un appel INSi précédent a échoué ou les données d'identité ont été corrigées.

**État final :** L'identité est qualifiée (statut "validée") ou reste en échec avec motif.

**Relations :**
- Include : Aucune.
- Extend : UC-016 — Renouvellement de l'appel.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

Identiques à UC-016. L'utilisateur peut avoir corrigé les traits d'identité entre-temps.

**Exceptions :**

Identiques à UC-016.

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0039 | 1a | Le renouvellement d'appel INSi est autorisé sans limite de nombre. Chaque appel est tracé dans l'historique. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-012 | Section identité INS (partagée avec UC-016, UC-018). |

**Objets participants :** Patient, Identité INS, Téléservice INSi.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-017-01 :** Soit un patient avec identité "provisoire" et des traits corrigés, Quand l'utilisateur relance l'appel INSi, Alors l'INS est retrouvé et le statut passe à "validée".
- **CA-UC-017-02 :** Soit un patient ayant fait l'objet de 3 appels INSi, Quand l'utilisateur consulte l'historique, Alors les 3 appels sont listés avec date, résultat et opérateur.

---

##### UC-018 : Restituer et qualifier l'INS d'un patient

**Résumé :** Le système affiche l'INS d'un patient et permet de qualifier l'identité (passage de "validée" à "qualifiée") après vérification d'un document d'identité officiel par le praticien.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, PSNM, Assistant médical.

**Fréquence d'utilisation :** À la première consultation physique du patient.

**État initial :** L'identité du patient est au statut "validée" (UC-016 exécuté avec succès).

**État final :** L'identité est au statut "qualifiée".

**Relations :**
- Include : Aucune.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur accède à la section identité de la fiche patient. |
| 1b | ← Système | Le système affiche l'INS (NIR/NIA, OID), le statut d'identité et le bouton "Qualifier l'identité". (IHM-012) |
| 2a | → Acteur | L'utilisateur vérifie le document d'identité officiel du patient (CNI, passeport, titre de séjour) et clique sur "Qualifier l'identité". |
| 2b | ← Système | Le système passe le statut à "qualifiée" et enregistre la date et l'auteur de la qualification. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 1b | Si l'identité est encore au statut "provisoire" | Le bouton "Qualifier" est désactivé. Message "L'identité doit d'abord être validée par l'INSi". |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0034 | 2a | La qualification nécessite la vérification d'un document d'identité officiel (CNI, passeport, titre de séjour). |
| RG-0035 | 2b | La qualification est tracée : utilisateur, date, heure. Elle est irréversible sauf correction administrative. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-012 | Section identité INS (partagée avec UC-016, UC-017). |

**Objets participants :** Patient, Identité INS.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-018-01 :** Soit un patient avec identité "validée", Quand l'utilisateur clique sur "Qualifier l'identité", Alors le statut passe à "qualifiée" avec la date et l'auteur enregistrés.
- **CA-UC-018-02 :** Soit un patient avec identité "provisoire", Quand l'utilisateur consulte la section identité, Alors le bouton "Qualifier" est désactivé.
- **CA-UC-018-03 :** Soit un patient avec identité "qualifiée", Quand un autre utilisateur consulte la fiche, Alors l'identité est affichée comme qualifiée avec la date et l'auteur de qualification.

---

##### UC-019 : Consulter la fiche administrative d'un patient

**Résumé :** L'utilisateur consulte les informations administratives d'un patient : état civil, coordonnées, INS, médecin traitant, statut d'identité, praticiens rattachés.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, PSNM, Assistant médical, Employé administratif.

**Fréquence d'utilisation :** Très fréquent.

**État initial :** Le patient existe dans le système. L'utilisateur est authentifié.

**État final :** La fiche administrative est affichée.

**Relations :**
- Include : Aucune.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur accède à la fiche d'un patient (via UC-012 ou UC-013). |
| 1b | ← Système | Le système affiche la fiche administrative complète en mode consultation. (IHM-011) |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 1b | Si l'utilisateur n'a pas les droits suffisants pour certaines données | Les données restreintes sont masquées selon le profil de l'utilisateur (voir RG-0026). |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0026 | 1b | L'accès aux données est soumis au profil. L'employé administratif ne voit que les données administratives. |
| RG-0040 | 1b | La relation patient-praticien (M:M) est visible : la fiche affiche la liste des praticiens rattachés au patient. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-011 | Fiche administrative patient (partagée — mode consultation en lecture seule). |

**Objets participants :** Patient, Identité INS, Praticien.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-019-01 :** Soit un médecin titulaire authentifié, Quand il accède à la fiche d'un patient, Alors toutes les informations administratives sont affichées (état civil, coordonnées, INS, praticiens rattachés).
- **CA-UC-019-02 :** Soit un employé administratif authentifié, Quand il accède à la fiche d'un patient, Alors seules les données administratives autorisées sont visibles.

---

##### UC-020 : Modifier la fiche administrative d'un patient

**Résumé :** L'utilisateur modifie les informations administratives d'un patient (coordonnées, médecin traitant, praticiens rattachés). Les données d'identité INS ne sont pas modifiables directement — toute correction nécessite un nouvel appel INSi.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, PSNM, Assistant médical, Employé administratif.

**Fréquence d'utilisation :** Régulier.

**État initial :** La fiche patient existe. L'utilisateur est authentifié.

**État final :** La fiche est mise à jour.

**Relations :**
- Include : Aucune.
- Extend : UC-017 — Si modification des traits d'identité, relance INSi nécessaire.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur ouvre la fiche administrative en mode édition. |
| 1b | ← Système | Le système affiche le formulaire pré-rempli. Les champs d'identité INS (nom de naissance, prénoms, date de naissance, sexe) sont grisés. (IHM-011) |
| 2a | → Acteur | L'utilisateur modifie les informations modifiables et valide. |
| 2b | ← Système | Le système enregistre les modifications. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 2a | Si l'utilisateur souhaite corriger un trait d'identité INS | Message "La modification des traits d'identité nécessite un nouvel appel INSi". Proposition de dérouler UC-017. |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0036 | 1b | Les traits d'identité INS (nom de naissance, prénoms, date de naissance, sexe) ne sont pas modifiables directement. Toute correction nécessite un nouvel appel INSi (UC-017). |
| RG-0041 | 2b | La modification de la relation patient-praticien (ajout ou retrait d'un praticien rattaché) est autorisée depuis cette fiche. |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-011 | Fiche administrative patient (partagée — mode édition avec champs INS grisés). |

**Objets participants :** Patient, Identité INS, Praticien.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-020-01 :** Soit un patient existant, Quand l'utilisateur modifie l'adresse et valide, Alors l'adresse est mise à jour.
- **CA-UC-020-02 :** Soit un patient avec identité qualifiée, Quand l'utilisateur tente de modifier le nom de naissance, Alors le champ est grisé et un message propose de relancer l'INSi.
- **CA-UC-020-03 :** Soit un patient rattaché au Dr. Dupont, Quand le Dr. Martin ajoute le patient à ses patients, Alors le patient est rattaché aux deux praticiens.

---

##### UC-021 : Gérer la file active des patients

**Résumé :** Le praticien consulte la liste des patients vus récemment ou ayant des rendez-vous planifiés (file active). Il peut accéder directement à un dossier patient depuis cette vue.

**Acteurs :** Médecin titulaire, Médecin remplaçant, Interne / Docteur junior, PSNM.

**Fréquence d'utilisation :** Plusieurs fois par jour.

**État initial :** L'utilisateur est authentifié.

**État final :** La file active est affichée.

**Relations :**
- Include : Aucune.
- Extend : Aucune.
- Généralisation : Aucune.

**Étapes (cas nominal) :**

| # | Direction | Description |
|---|---|---|
| 1a | → Acteur | L'utilisateur accède à la file active. |
| 1b | ← Système | Le système affiche la liste des patients de la file active du praticien : patients du jour (avec rendez-vous), patients vus récemment. (IHM-013) |
| 2a | → Acteur | L'utilisateur sélectionne un patient. |
| 2b | ← Système | Le système ouvre le dossier du patient. |

**Exceptions :**

| Id étape | Condition | Réaction du système |
|---|---|---|
| 1b | Si la file active est vide | Message "Aucun patient dans la file active". |

**Règles de gestion :**

| n° RG | Id étape | Énoncé |
|---|---|---|
| RG-0042 | 1b | La file active est propre à chaque praticien. Elle affiche uniquement les patients rattachés au praticien connecté. |
| RG-0043 | 1b | La file active inclut les patients avec rendez-vous du jour et les patients vus dans les N derniers jours. (N à préciser.) |

**IHM :**

| Id IHM | Description |
|---|---|
| IHM-013 | File active : liste des patients du jour (RDV planifiés) et patients récents. Pour chaque patient : nom, prénom, heure RDV, motif, statut consultation. |

**Objets participants :** Patient, Rendez-vous, Consultation, Praticien.

**Contraintes non fonctionnelles :** Aucune spécifique.

**Critères d'acceptation / Cas de tests :**

- **CA-UC-021-01 :** Soit un praticien avec 5 RDV planifiés aujourd'hui, Quand il accède à la file active, Alors les 5 patients sont affichés avec heure et motif.
- **CA-UC-021-02 :** Soit un praticien qui a vu un patient hier, Quand il accède à la file active, Alors ce patient apparaît dans la section "patients récents".
- **CA-UC-021-03 :** Soit un praticien sans aucun RDV ni patient récent, Quand il accède à la file active, Alors le message "Aucun patient dans la file active" est affiché.

## Objets participants

<!-- À compléter lors de l'étape 3 — Compléments -->

| Objet | Description |
|---|---|
| À compléter | |

## Exigences non fonctionnelles

<!-- À compléter lors de l'étape 3 — Compléments -->

## Glossaire projet

| Terme | Définition |
|---|---|
| LGC | Logiciel de Gestion de Cabinet. Application destinée à la gestion de l'activité médicale d'un cabinet libéral. |
| DMP | Dossier Médical Partagé (anciennement Dossier Médical Personnel). Dossier numérique hébergé dans Mon Espace Santé, alimenté par les professionnels de santé. |
| PSC | Pro Santé Connect. Service national d'authentification des professionnels de santé. |
| MSSanté | Messagerie Sécurisée de Santé. Système de messagerie permettant l'échange sécurisé de documents médicaux entre professionnels de santé. |
| INSi | Identité Nationale de Santé intégrée. Téléservice permettant de vérifier et qualifier l'identité d'un patient via son NIR. |
| NIR | Numéro d'Inscription au Répertoire (numéro de sécurité sociale). Identifiant unique du patient. |
| NIA | Numéro d'Identifiant Attente. Identifiant temporaire attribué aux assurés en attente de NIR. |
| OID | Object Identifier. Identifiant technique de l'organisme émetteur de l'INS. |
| INS | Identité Nationale de Santé. Identifiant unique du patient dans le système de santé français, composé du matricule INS et de l'OID. |
| RPPS | Répertoire Partagé des Professionnels de Santé. Identifiant unique des professionnels de santé. |
| ADELI | Automatisation DEs LIstes. Répertoire des professionnels de santé (en cours de remplacement par RPPS). |
| FINESS | Fichier National des Établissements Sanitaires et Sociaux. Identifiant des structures de santé. |
| HDS | Hébergeur de Données de Santé. Certification obligatoire pour tout hébergeur de données de santé à caractère personnel. |
| SEGUR | Ségur du numérique en santé. Programme national visant à accélérer la numérisation du système de santé français. |
| LAP | Logiciel d'Aide à la Prescription. Module certifié HAS assistant le prescripteur dans le choix et la sécurisation des prescriptions médicamenteuses. |
| CIM-10 | Classification Internationale des Maladies, 10e révision. Nomenclature de codification des diagnostics. |
| LOINC | Logical Observation Identifiers Names and Codes. Nomenclature internationale pour les analyses de biologie. |
| CIP13 | Code Identifiant de Présentation à 13 chiffres. Identifiant unique d'une présentation de médicament en France. |
| SNOMED CT | Systematized Nomenclature of Medicine — Clinical Terms. Terminologie clinique de référence. |
| ATC | Classification Anatomique, Thérapeutique et Chimique. Système de classification des médicaments par l'OMS. |
| SaaS | Software as a Service. Modèle de distribution logicielle où l'application est hébergée dans le cloud et accessible via navigateur. |
| Proxy e-santé | Composant intermédiaire assurant la communication sécurisée entre le LGC et les téléservices de santé (PSC, INSi, DMP, MSSanté). |
| Stellair Intégral | Solution de facturation SESAM-Vitale 100% en ligne, éditée par Olaqin. |
| PPS | Prescription de Produits de Santé. Ordonnance de médicaments, accessoires et dispositifs médicaux. |
| ALD | Affection de Longue Durée. Pathologie reconnue comme nécessitant un traitement prolongé et coûteux, prise en charge à 100%. |
| SESAM-Vitale | Système de facturation et de télétransmission des feuilles de soins électroniques. |
| IHE XDM | Profil d'intégration IHE pour l'échange de documents médicaux sur support amovible ou par messagerie. |
| CGU | Conditions Générales d'Utilisation. Document contractuel que l'utilisateur doit accepter pour accéder au LGC. |
| COG | Code Officiel Géographique. Code identifiant les communes et territoires français, utilisé pour les lieux de naissance. |

## Glossaire SDD

| Terme | Définition |
|---|---|
| **Spec** | Document qui décrit exactement ce que le logiciel doit faire. Point de vérité unique du projet. |
| **Cas d'utilisation (UC)** | Scénario complet décrivant l'interaction entre un acteur et le système pour atteindre un objectif. Granularité principale de la spec. |
| **Acteur** | Type d'utilisateur (profil) qui modifie l'état interne du système. Peut être humain ou système. |
| **Cas nominal** | Scénario principal d'un UC où tout se passe bien, sans erreur ni exception. |
| **Exception** | Situation anormale survenant à une étape d'un UC. Mène à un traitement local, un branchement ou un renvoi vers un autre UC. |
| **Règle de gestion (RG)** | Contrainte métier rattachée à une étape d'un UC. Identifiée par RG-XXXX. |
| **Critère d'acceptation** | Condition vérifiable prouvant qu'un UC est satisfait. Formulé en Soit/Quand/Alors. |
| **Hors périmètre** | Ce que le logiciel ne fait explicitement pas. Aussi important que ce qu'il fait. |
| **Niveau de support** | Degré de prise en charge d'une fonctionnalité : **Supporté** (implémenté), **Ignoré** (no-op silencieux), **Erreur** (rejeté avec message explicite). |
| **Package** | Regroupement de cas d'utilisation. Deux niveaux : niveau 2 (≈ Epic), niveau 1 (≈ Feature). |
| **Include** | Relation entre UC : un UC inclut obligatoirement un autre UC. |
| **Extend** | Relation entre UC : un UC étend optionnellement un autre UC sous condition. |
| **Généralisation** | Relation entre UC : un UC hérite d'un UC parent et le spécialise. Peu fréquent. |
| **Traçabilité** | Lien vérifiable entre un UC et son implémentation. Chaque UC a un identifiant unique référencé dans le code. |
| **Reproductibilité** | Capacité à obtenir le même résultat à partir de la même spec, quel que soit l'agent qui implémente. |
| **Critique** | Priorité : le logiciel ne fonctionne pas sans. Bloque la livraison. |
| **Important** | Priorité : nécessaire en production, mais non bloquant pour un premier livrable. |
| **Souhaité** | Priorité : amélioration reportable sans compromettre la viabilité. |
