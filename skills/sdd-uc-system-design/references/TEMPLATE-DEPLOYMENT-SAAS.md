# Sections spécifiques SaaS — Déploiement

<!-- Sous-template à fusionner dans DEPLOYMENT.md pour les solutions SaaS.
Insérer ces sections après le tronc commun (§ 11 Disaster recovery),
avant le Changelog. Numéroter à la suite du tronc commun. -->

## N. Spécificités SaaS

### N.1 Multi-tenancy

<!-- Stratégie d'isolation : base partagée, schéma par tenant, base par tenant.
Impact sur les performances, la sécurité, les migrations. -->

| Aspect | Stratégie | Détails |
|--------|-----------|---------|
| Isolation données | [ex: Schéma par tenant] | [ex: Colonne `tenant_id` sur chaque table, RLS PostgreSQL] |
| Isolation compute | [ex: Partagé] | [ex: Rate limiting par tenant, quotas API] |
| Isolation réseau | [ex: Partagé] | [ex: Même VPC, filtrage au niveau applicatif] |

### N.2 Scalabilité

<!-- Stratégie de scaling horizontal/vertical.
Auto-scaling rules, limites, coûts associés. -->

| Composant | Type de scaling | Règle | Min | Max | Coût estimé |
|-----------|----------------|-------|-----|-----|-------------|
| [ex: API] | [ex: Horizontal] | [ex: CPU > 70% pendant 5 min] | [ex: 2] | [ex: 10] | [ex: ~50€/instance/mois] |
| [ex: Workers] | [ex: Horizontal] | [ex: Queue depth > 100] | [ex: 1] | [ex: 5] | [ex: ~50€/instance/mois] |

### N.3 Haute disponibilité

<!-- SLA cible, répartition géographique, failover.
Complète le disaster recovery du tronc commun avec les mécanismes
spécifiques au SaaS. -->

| Métrique | Cible | Mécanisme |
|----------|-------|-----------|
| Disponibilité | [ex: 99.9%] | [ex: Multi-AZ, load balancer, auto-healing] |
| Temps de failover | [ex: < 30 secondes] | [ex: Health checks + répartition automatique] |

### N.4 CDN et assets statiques

<!-- Si applicable : CDN, cache, compression, invalidation. -->

| Ressource | CDN | Cache | Invalidation |
|-----------|-----|-------|-------------|
| [ex: Assets frontend (JS, CSS, images)] | [ex: Cloudflare / Azure CDN] | [ex: 1 an, hash dans le nom de fichier] | [ex: Automatique via hash] |
| [ex: Media uploadés] | [ex: CDN avec signed URLs] | [ex: 24h] | [ex: Purge manuelle ou par tag] |

### N.5 Gestion des migrations multi-tenant

<!-- Stratégie de migration de base de données quand les tenants partagent
l'infrastructure. Rolling migrations, compatibilité N-1, downtime. -->

**Stratégie de migration :** [ex: Rolling, compatible N-1, zero-downtime]

**Procédure :**

1. [ex: Déployer la migration en mode backward-compatible]
2. [ex: Déployer la nouvelle version applicative]
3. [ex: Nettoyer les colonnes/tables obsolètes (migration de cleanup)]
