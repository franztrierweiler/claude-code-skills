# BiblioSoft — Cahier des charges

## 1. Présentation

**BiblioSoft** est un logiciel de gestion de bibliothèque municipale. Il permet aux adhérents de consulter le catalogue, emprunter et retourner des livres, et gérer leurs réservations. Les bibliothécaires gèrent le catalogue, les adhérents et les opérations de prêt.

**Problème résolu :** les bibliothèques municipales de taille modeste (1 à 5 employés, 5 000 à 30 000 ouvrages) utilisent encore des registres papier ou des logiciels obsolètes non connectés. BiblioSoft leur offre une solution moderne, accessible en ligne, sans infrastructure locale à maintenir.

**Utilisateurs cibles :** bibliothèques municipales de communes de 2 000 à 20 000 habitants.

## 2. Acteurs

| Acteur | Type | Description |
|---|---|---|
| Adhérent | Humain | Personne inscrite à la bibliothèque. Consulte le catalogue, emprunte, retourne, réserve. |
| Bibliothécaire | Humain | Employé de la bibliothèque. Gère le catalogue, les adhérents, les prêts, les retours, les relances. |
| Système | Système | Batch planifié. Envoie les relances automatiques, expire les réservations, calcule les pénalités. |

## 3. Contraintes techniques

- **Langage :** Python 3.12+, framework FastAPI
- **Base de données :** PostgreSQL 16
- **Frontend :** application web responsive (pas d'application mobile native)
- **Déploiement :** cloud multi-tenants — chaque bibliothèque est un tenant isolé (données séparées, configuration propre, nom de domaine personnalisable)
- **Multi-utilisateurs côté client :** plusieurs adhérents accèdent simultanément au catalogue et à leur espace personnel
- **Multi-utilisateurs côté bibliothèque :** plusieurs bibliothécaires travaillent en parallèle sur les opérations de prêt, retour et gestion du catalogue
- **Authentification :** email + mot de passe pour les adhérents, SSO (SAML) optionnel pour les bibliothécaires

## 4. Contraintes réglementaires

- **RGPD :** les données personnelles des adhérents (nom, email, adresse, historique d'emprunts) sont soumises au RGPD. Droit d'accès, de rectification et de suppression. L'historique d'emprunts est purgé après 12 mois.
- Pas de données de santé, pas de données financières (pas de paiement en ligne).

## 5. Cas d'utilisation / Domaines fonctionnels

### Gestion du catalogue

- **Ajouter un ouvrage** : le bibliothécaire saisit les métadonnées (titre, auteur, ISBN, catégorie, éditeur, année). Un ouvrage peut avoir plusieurs exemplaires.
- **Modifier un ouvrage** : modifier les métadonnées d'un ouvrage existant.
- **Retirer un ouvrage** : retirer un ouvrage du catalogue. Les exemplaires en cours de prêt doivent être retournés d'abord. L'ouvrage reste dans la base avec un statut "retiré" pour l'historique.
- **Rechercher un ouvrage** : recherche par titre, auteur, ISBN, catégorie. Recherche plein texte sur le titre et l'auteur. Afficher la disponibilité (nombre d'exemplaires disponibles / total).

### Gestion des adhérents

- **Inscrire un adhérent** : le bibliothécaire saisit nom, prénom, date de naissance, adresse, email, téléphone. Attribution automatique d'un numéro d'adhérent. L'adhésion est valable 1 an.
- **Renouveler une adhésion** : prolonger d'1 an à partir de la date d'expiration.
- **Suspendre un adhérent** : le bibliothécaire peut suspendre un adhérent (impayés, comportement). Un adhérent suspendu ne peut plus emprunter ni réserver.
- **Supprimer un adhérent** : suppression logique. Les données sont anonymisées (RGPD) mais l'historique agrégé est conservé pour les statistiques.

### Emprunts et retours

- **Emprunter un livre** : l'adhérent (via le bibliothécaire au comptoir ou en ligne) emprunte un exemplaire disponible. Règles :
  - Maximum 5 emprunts simultanés par adhérent
  - Durée de prêt : 21 jours
  - Pas d'emprunt si adhésion expirée ou adhérent suspendu
  - Pas d'emprunt si pénalité impayée supérieure à 5 €
- **Retourner un livre** : enregistrement du retour par le bibliothécaire. Si retard, calcul automatique de la pénalité : 0,20 € par jour de retard, plafonnée à 10 €.
- **Prolonger un prêt** : l'adhérent peut prolonger une fois de 14 jours, sauf si le livre est réservé par un autre adhérent.

### Réservations

- **Réserver un livre** : l'adhérent réserve un ouvrage dont tous les exemplaires sont empruntés. Maximum 3 réservations simultanées. File d'attente FIFO si plusieurs réservations sur le même ouvrage.
- **Annuler une réservation** : l'adhérent peut annuler à tout moment.
- **Notification de disponibilité** : quand un exemplaire est retourné et qu'une réservation existe, le premier adhérent en file reçoit un email. Il a 48 heures pour venir chercher le livre, sinon la réservation est annulée et le suivant est notifié.

### Relances et pénalités (batch système)

- **Relance de retard** : à J+1 après la date de retour prévue, email de relance automatique. Relance répétée à J+7 et J+14.
- **Expiration des réservations** : les réservations non récupérées après 48h sont automatiquement annulées (vérification toutes les heures).
- **Calcul des pénalités** : recalcul quotidien des pénalités en cours.

## 6. Exigences non fonctionnelles

- **Performance :** temps de réponse < 500ms pour la recherche catalogue (sur une base de 30 000 ouvrages). Temps de réponse < 200ms pour les opérations de prêt/retour.
- **Disponibilité :** 99% hors maintenance planifiée. Fenêtre de maintenance : dimanche 2h-5h.
- **Scalabilité :** supporter jusqu'à 200 tenants (bibliothèques) et 500 utilisateurs simultanés au total.
- **Sécurité :** mots de passe hashés (bcrypt, coût 12). Sessions JWT avec expiration à 8h. Cloisonnement strict des données entre tenants (row-level security PostgreSQL).
- **Observabilité :** logs structurés (JSON), métriques Prometheus (temps de réponse, erreurs, emprunts/jour par tenant).
- **Portabilité :** déploiement conteneurisé (Docker). Compatible avec tout cloud offrant PostgreSQL managé.

## 7. Hors périmètre

- Pas de paiement en ligne (les pénalités sont réglées au comptoir).
- Pas de catalogue inter-bibliothèques (chaque tenant est autonome).
- Pas de gestion de documents numériques (ebooks, audiobooks).
- Pas de gestion de salles ou d'événements.
- Pas d'application mobile native (le site web responsive suffit).
- Pas de module d'acquisition / commande fournisseur.

## 8. Architecture imposée

| Composant | Responsabilité |
|---|---|
| API REST | Backend FastAPI, point d'entrée unique |
| Base de données | PostgreSQL 16, une base par tenant (schéma partagé, row-level security) |
| Frontend | SPA web responsive |
| Batch | Jobs planifiés (relances, expirations, pénalités) |
| Email | Service d'envoi d'emails (SMTP ou API tierce type SendGrid) |

## 9. Diagramme de contexte

```
┌─────────────────────────────────────────────────┐
│                  Mairie / Commune                │
│                                                  │
│   ┌──────────────┐       ┌───────────────────┐  │
│   │ Bibliothèque │       │ Adhérents         │  │
│   │              │       │ (domicile, mobile) │  │
│   │ [Poste       │       │                   │  │
│   │  biblio-     │       │ [Navigateur web]  │  │
│   │  thécaire]   │       └─────────┬─────────┘  │
│   └──────┬───────┘                 │             │
│          │                         │             │
│          └────────┐     ┌──────────┘             │
│                   ▼     ▼                        │
│            ┌──────────────┐                      │
│            │  BiblioSoft  │                      │
│            │  (cloud)     │──── Email (SMTP)     │
│            └──────────────┘                      │
│                                                  │
└─────────────────────────────────────────────────┘
```
