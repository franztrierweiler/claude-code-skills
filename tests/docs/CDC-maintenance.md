# MaintiX — Cahier des charges

## 1. Présentation

**MaintiX** est une plateforme de coordination d'interventions de maintenance industrielle. Elle remplace partiellement un logiciel GMAO (Gestion de Maintenance Assistée par Ordinateur) vieillissant en apportant une couche de coordination terrain en temps réel, tout en conservant la GMAO comme référentiel d'équipements et d'historique.

**Problème résolu :** les techniciens de maintenance reçoivent leurs ordres d'intervention par email ou téléphone, remplissent des fiches papier sur le terrain, puis ressaisissent les données dans la GMAO au bureau. Ce processus génère des délais (24-48h entre l'intervention et la saisie), des erreurs de ressaisie, et une absence de visibilité en temps réel pour le dispatcher.

**Utilisateurs cibles :** sociétés de maintenance industrielle de 20 à 200 techniciens, intervenant sur des sites clients (usines, entrepôts, infrastructures).

## 2. Acteurs

| Acteur | Type | Description |
|---|---|---|
| Technicien | Humain | Intervient sur le terrain via une application mobile. Peut travailler en zone sans réseau (mode offline). Consulte les fiches équipement, saisit les comptes-rendus, demande des pièces. |
| Dispatcher | Humain | Planifie et assigne les interventions. Suit l'avancement en temps réel. Gère les urgences et réaffectations. |
| Responsable site | Humain | Représentant du site client. Valide les interventions terminées, signale des anomalies, consulte les rapports. |
| GMAO | Système | Logiciel existant (IBM Maximo). Référentiel des équipements, historique de maintenance, contrats. MaintiX synchronise avec la GMAO mais ne la remplace pas. |
| Capteurs machines | Système | Capteurs IoT installés sur les équipements critiques. Émettent des mesures (température, vibration, pression) via MQTT. Déclenchent des alertes si les seuils sont dépassés. |

## 3. Contraintes techniques

- **Langage :** Python 3.12+ (backend), framework FastAPI
- **Base de données :** PostgreSQL 16
- **Application mobile :** Progressive Web App (PWA) avec capacité offline (Service Worker + IndexedDB)
- **Déploiement :** cloud, instance unique (pas de multi-tenants dans la première version)
- **Multi-utilisateurs :** plusieurs dispatchers et techniciens travaillent simultanément. Les conflits d'assignation doivent être gérés (un technicien ne peut pas être assigné deux fois au même créneau).
- **Mode offline :** le technicien doit pouvoir consulter ses interventions assignées, saisir un compte-rendu et photographier un équipement sans connexion réseau. La synchronisation se fait automatiquement au retour du réseau.
- **Intégration GMAO :** API REST bidirectionnelle avec IBM Maximo. MaintiX lit les équipements et les ordres de travail (OT), et écrit les comptes-rendus et les consommations de pièces.
- **Intégration capteurs :** broker MQTT (Mosquitto). Les capteurs publient sur des topics par équipement. MaintiX consomme les messages et déclenche des alertes.
- **Géolocalisation :** API de géolocalisation du navigateur pour positionner les techniciens sur la carte du dispatcher.

## 4. Contraintes réglementaires

- **Sécurité des interventions :** chaque intervention sur un équipement classé "critique" nécessite une validation préalable du responsable site (permis de travail). L'absence de validation bloque le démarrage de l'intervention dans MaintiX.
- **Traçabilité :** l'historique complet de chaque intervention (qui, quand, quoi, pièces utilisées) doit être conservé 10 ans (exigence contractuelle et réglementaire pour les sites classés ICPE).
- **RGPD :** les données de géolocalisation des techniciens ne sont collectées que pendant les heures de travail. Le technicien peut désactiver la géolocalisation. Les données sont purgées après 6 mois.

## 5. Système existant — GMAO IBM Maximo

MaintiX ne remplace pas la GMAO. Elle s'interface avec elle. Le périmètre de l'interfaçage est le suivant :

### Données lues depuis la GMAO (synchronisation périodique toutes les 15 min)

- **Équipements** : arborescence des équipements par site, fiches techniques, historique de maintenance
- **Ordres de travail (OT)** : OT planifiés, priorité, équipement associé, description
- **Contrats** : périmètre contractuel par site (équipements couverts, SLA)
- **Stock de pièces** : quantités disponibles par magasin et par site

### Données écrites vers la GMAO (synchronisation au fil de l'eau)

- **Comptes-rendus d'intervention** : date, durée, technicien, actions réalisées, observations
- **Consommations de pièces** : pièces utilisées, quantités, numéros de série si applicable
- **Statut des OT** : mise à jour du statut (en cours, terminé, en attente pièce)

### Fonctions GMAO non reprises par MaintiX

- Gestion des achats et approvisionnements
- Gestion des contrats et facturation
- Planification préventive à long terme (MaintiX ne gère que le planning opérationnel à 2 semaines)
- Gestion documentaire (plans, manuels — restent dans la GMAO)

## 6. Cas d'utilisation

### Gestion des interventions

- **Créer une intervention** : le dispatcher crée une intervention à partir d'un OT GMAO ou manuellement (intervention d'urgence). Champs : équipement, site, type (correctif, préventif, prédictif), priorité (P1 urgence 4h, P2 24h, P3 planifié), description, compétences requises.
- **Assigner une intervention** : le dispatcher assigne un technicien en fonction de sa disponibilité, sa localisation, ses compétences. Vérification automatique : pas de chevauchement horaire, compétences requises présentes. Le technicien reçoit une notification push.
- **Réassigner une intervention** : le dispatcher peut réassigner une intervention non démarrée à un autre technicien (absence, surcharge). L'ancien technicien est notifié.
- **Annuler une intervention** : le dispatcher ou le responsable site peut annuler une intervention non démarrée. Motif obligatoire. L'intervention annulée reste visible dans l'historique.

### Exécution terrain

- **Consulter le planning** : le technicien voit ses interventions du jour et de la semaine, triées par priorité puis par heure. Disponible offline.
- **Démarrer une intervention** : le technicien signale le début. Si l'équipement est critique, le permis de travail du responsable site doit être validé (sinon blocage). La géolocalisation est enregistrée. L'heure de début est horodatée.
- **Saisir un compte-rendu** : le technicien décrit les actions réalisées, le diagnostic, les observations. Il peut ajouter des photos (max 5, max 5 Mo chacune). Il sélectionne les pièces consommées dans la liste du stock (synchronisée depuis la GMAO). Disponible offline — synchronisation au retour du réseau.
- **Demander une pièce** : si une pièce nécessaire n'est pas en stock sur le site, le technicien crée une demande. Le dispatcher est notifié. L'intervention passe en statut "en attente pièce".
- **Terminer une intervention** : le technicien marque l'intervention terminée. Le compte-rendu est obligatoire. Le statut passe à "terminée — en attente validation". Le responsable site est notifié.
- **Suspendre une intervention** : le technicien peut suspendre une intervention en cours (pause déjeuner, attente pièce, fin de journée). Motif obligatoire. L'intervention peut être reprise plus tard.

### Validation et suivi

- **Valider une intervention** : le responsable site valide l'intervention terminée. Il peut ajouter des observations. Le statut passe à "validée". Le compte-rendu est synchronisé vers la GMAO.
- **Refuser une intervention** : le responsable site refuse l'intervention (travail incomplet, problème constaté). Motif obligatoire. L'intervention repasse en statut "à replanifier". Le dispatcher est notifié.
- **Émettre un permis de travail** : le responsable site valide le permis de travail pour un équipement critique avant le démarrage de l'intervention. Durée de validité : 8 heures.

### Alertes capteurs

- **Recevoir une alerte capteur** : quand un capteur dépasse un seuil configuré, MaintiX crée automatiquement une alerte. Le dispatcher est notifié. L'alerte est rattachée à l'équipement concerné.
- **Convertir une alerte en intervention** : le dispatcher peut transformer une alerte en intervention prédictive (pré-remplie avec l'équipement et le contexte capteur).
- **Acquitter une alerte** : le dispatcher peut acquitter une alerte sans créer d'intervention (faux positif, seuil à recalibrer). Motif obligatoire.

### Synchronisation GMAO

- **Synchroniser les équipements** : job planifié toutes les 15 minutes. Lit les équipements depuis Maximo, met à jour la base locale. Les équipements supprimés dans Maximo sont marqués "inactifs" dans MaintiX (pas de suppression).
- **Synchroniser les OT** : job planifié toutes les 15 minutes. Lit les nouveaux OT et les modifications. Un OT importé peut être transformé en intervention par le dispatcher.
- **Pousser les comptes-rendus** : à chaque validation d'intervention, le compte-rendu et les consommations sont envoyés à Maximo via son API REST.
- **Gérer les erreurs de synchronisation** : si la GMAO est indisponible, les synchronisations sont mises en file d'attente et rejouées. Une alerte est émise au dispatcher après 3 échecs consécutifs.

## 7. Machine à états — Intervention

```
                          ┌──────────────────────────┐
                          │                          │
                          ▼                          │
[Créée] ──> [Assignée] ──> [En cours] ──> [Terminée] ──> [Validée]
                │              │    ▲           │
                │              │    │           │
                │              ▼    │           ▼
                │         [Suspendue]    [Refusée]
                │                           │
                ▼                           ▼
           [Annulée]                  [À replanifier]
                                           │
                                           ▼
                                      [Assignée]
```

Transitions autorisées :

| De | Vers | Déclencheur | Condition |
|---|---|---|---|
| Créée | Assignée | Dispatcher assigne un technicien | Technicien disponible et compétent |
| Assignée | En cours | Technicien démarre | Permis de travail validé si équipement critique |
| Assignée | Annulée | Dispatcher ou responsable site | Motif obligatoire |
| En cours | Suspendue | Technicien suspend | Motif obligatoire |
| Suspendue | En cours | Technicien reprend | — |
| En cours | Terminée | Technicien termine | Compte-rendu obligatoire |
| Terminée | Validée | Responsable site valide | — |
| Terminée | Refusée | Responsable site refuse | Motif obligatoire |
| Refusée | À replanifier | Automatique | — |
| À replanifier | Assignée | Dispatcher réassigne | — |
| En cours | En attente pièce | Technicien demande une pièce | Pièce non disponible sur site |
| En attente pièce | En cours | Pièce reçue | Confirmation dispatcher |

## 8. Exigences non fonctionnelles

- **Performance :** temps de réponse < 300ms pour les opérations courantes en mode connecté. Affichage du planning offline en < 1s.
- **Disponibilité :** 99,5% hors maintenance planifiée. Fenêtre de maintenance : samedi 2h-5h.
- **Mode offline :** le technicien doit pouvoir travailler sans réseau pendant une journée complète (8h). La synchronisation au retour du réseau ne doit pas dépasser 30 secondes pour une journée de données.
- **Temps réel :** les alertes capteurs doivent être affichées chez le dispatcher en moins de 10 secondes après l'émission par le capteur.
- **Capacité :** supporter 200 techniciens simultanés, 50 dispatchers, 1 000 interventions par jour, 500 équipements émettant des mesures toutes les 60 secondes.
- **Sécurité :** authentification OIDC (Keycloak). Rôles : technicien, dispatcher, responsable site, administrateur. Chiffrement des données en transit (TLS 1.3) et au repos (AES-256 pour les photos).
- **Rétention :** historique des interventions conservé 10 ans. Données de géolocalisation purgées après 6 mois. Photos conservées 2 ans.
- **Observabilité :** logs structurés (JSON), métriques Prometheus, alertes sur les échecs de synchronisation GMAO et sur la file d'attente de synchronisation.

## 9. Phases de livraison

### Phase 1 — Planification et dispatch

- **Périmètre :** gestion des interventions (créer, assigner, réassigner, annuler), planning du dispatcher, synchronisation GMAO en lecture (équipements, OT), notification push aux techniciens.
- **Livrable :** le dispatcher peut créer et assigner des interventions, les techniciens reçoivent leur planning.
- **Dépendances :** aucune.

### Phase 2 — Exécution terrain

- **Périmètre :** application mobile PWA, mode offline, saisie des comptes-rendus et photos, demande de pièces, machine à états complète, permis de travail, synchronisation GMAO en écriture (comptes-rendus, consommations).
- **Livrable :** le technicien peut réaliser son intervention complète depuis le terrain, y compris sans réseau.
- **Dépendances :** Phase 1.

### Phase 3 — Alertes et prédictif

- **Périmètre :** intégration capteurs MQTT, alertes en temps réel, conversion alerte → intervention, tableau de bord de suivi des mesures par équipement.
- **Livrable :** le dispatcher reçoit les alertes capteurs et peut déclencher des interventions prédictives.
- **Dépendances :** Phase 2.

## 10. Hors périmètre

- Pas de gestion des achats ni des approvisionnements (reste dans la GMAO).
- Pas de gestion des contrats ni de facturation (reste dans la GMAO).
- Pas de planification préventive à long terme (MaintiX gère le planning opérationnel à 2 semaines maximum).
- Pas de gestion documentaire (plans, manuels, procédures — restent dans la GMAO).
- Pas de multi-tenants en Phase 1 (une instance par société de maintenance).
- Pas de module RH (absences, congés, compétences — gérés en dehors de MaintiX).
- Pas d'application mobile native (la PWA avec capacité offline couvre le besoin).

## 11. Architecture imposée

| Composant | Responsabilité |
|---|---|
| API REST | Backend FastAPI, point d'entrée unique pour le frontend et la GMAO |
| Base de données | PostgreSQL 16, schéma unique |
| Frontend dispatcher | SPA web (React) pour les dispatchers et responsables site |
| Frontend mobile | PWA avec Service Worker et IndexedDB pour le mode offline |
| Broker MQTT | Mosquitto, réception des mesures capteurs |
| Worker alertes | Consomme les messages MQTT, évalue les seuils, crée les alertes |
| Worker sync | Jobs planifiés de synchronisation avec la GMAO (lecture et écriture) |
| File d'attente | Redis, pour les synchronisations GMAO en attente et les notifications push |
| Stockage photos | Object storage (S3-compatible) pour les photos d'intervention |
| Authentification | Keycloak (OIDC) |

## 12. Diagramme de contexte

```
┌──────────────────────────────────────────────────────────────────┐
│                        Site industriel                           │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────────────┐ │
│  │ Responsable │  │ Techniciens │  │ Équipements              │ │
│  │ site        │  │ terrain     │  │                          │ │
│  │ [PC]        │  │ [Mobile]    │  │ [Capteurs IoT ── MQTT]   │ │
│  └──────┬──────┘  └──────┬──────┘  └────────────┬─────────────┘ │
│         │                │                       │               │
└─────────┼────────────────┼───────────────────────┼───────────────┘
          │                │                       │
          └──────┐    ┌────┘               ┌───────┘
                 ▼    ▼                    ▼
          ┌──────────────────────────────────────┐
          │              MaintiX                  │
          │              (cloud)                  │
          └──────┬───────────────┬───────────────┘
                 │               │
        ┌────────┘               └────────┐
        ▼                                 ▼
┌──────────────┐                  ┌──────────────┐
│ Dispatcher   │                  │ GMAO Maximo  │
│ [PC bureau]  │                  │ (existant)   │
└──────────────┘                  └──────────────┘
```
