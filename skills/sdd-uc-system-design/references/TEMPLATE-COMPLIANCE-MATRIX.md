# [Nom du projet] — Matrice de conformité

> | | |
> |---|---|
> | **Document** | COMPLIANCE_MATRIX.md |
> | **Version** | 1.0 |
> | **Date** | [YYYY-MM-DD] |
> | **Auteur** | [Nom] |
> | **Spec de référence** | [nom du fichier SPEC] v[X.Y] |
> | **Architecture de référence** | ARCHITECTURE.md v[X.Y] |
> | **Sécurité de référence** | SECURITY.md v[X.Y] |
> | **Généré par** | sdd-uc-system-design v3.3.0 |

## 1. Contexte réglementaire

<!-- Identifier le secteur d'activité, les réglementations applicables,
et les UC / ENF de la spec qui déclenchent des obligations de conformité.
Chaque référentiel doit être justifié par un UC ou ENF « mère » de la spec. -->

| Référentiel | Secteur | Exigence mère (spec) | Obligation |
|-------------|---------|------------------------|------------|
| [ex: HDS] | [ex: Santé] | [ex: UC-007] | [ex: Hébergement certifié pour données de santé] |
| [ex: RGPD] | [ex: Transversal] | [ex: UC-003, ENF-002] | [ex: Protection des données personnelles] |

## 2. Périmètre de conformité

<!-- Décrire ce qui est couvert et ce qui ne l'est pas.
Si certains référentiels ne s'appliquent que partiellement, le préciser. -->

[Description du périmètre]

## 3. Légende des statuts

| Statut | Signification |
|--------|---------------|
| ✅ | Implémenté et vérifié |
| 🔄 | En cours d'implémentation |
| ⏳ | Planifié (non démarré) |
| ❌ | Non applicable |

<!-- ================================================================
     SECTIONS PAR RÉFÉRENTIEL
     Ajouter une section par référentiel réglementaire identifié.
     Les exemples ci-dessous (HDS, RGPD, PGSSI-S) sont fournis à titre
     indicatif pour le secteur de la santé. Les remplacer par les
     référentiels effectivement applicables au projet.

     Convention de numérotation :
     - Préfixe = acronyme du référentiel (HDS, RGPD, PGSSI, PCI, SOC, etc.)
     - Numéro séquentiel à deux chiffres : HDS-01, HDS-02, ...
     - Cette numérotation est INDÉPENDANTE de celle de la spec (UC-xxx, ENF-xxx).
     - Le lien vers la spec est assuré par la colonne "Exigence mère"
       dans le tableau § 1.
     ================================================================ -->

## 4. [Référentiel 1 — ex: HDS (Hébergement de Données de Santé)]

Référentiel : [ex: Décret n°2018-137, Article L.1111-8 du Code de la santé publique]

| ID | Exigence | Description | Implémentation | Preuve de conformité | Responsable | Échéance | Statut |
|----|----------|-------------|----------------|----------------------|-------------|----------|--------|
| [ex: HDS-01] | [ex: Hébergeur certifié] | [ex: Hébergement chez un prestataire certifié HDS] | [ex: Azure France Central] | [ex: Certificat HDS Microsoft Azure] | [ex: Ops] | [ex: 2026-06-01] | ⏳ |
| [ex: HDS-02] | [ex: Localisation France] | [ex: Données stockées exclusivement en France] | [ex: Région `francecentral`] | [ex: `terraform/main.tf` - `location = "francecentral"`] | [ex: Ops] | [ex: 2026-06-01] | ⏳ |

---

## 5. [Référentiel 2 — ex: RGPD]

Référentiel : [ex: Règlement (UE) 2016/679]

| ID | Exigence | Description | Implémentation | Preuve de conformité | Responsable | Échéance | Statut |
|----|----------|-------------|----------------|----------------------|-------------|----------|--------|
| [ex: RGPD-01] | [ex: Base légale] | [ex: Chaque traitement a une base légale identifiée] | [ex: Registre des traitements] | [ex: Document DPO] | [ex: DPO] | [ex: 2026-05-15] | ⏳ |

---

## 6. [Référentiel N]

<!-- Ajouter une section par référentiel supplémentaire.
Supprimer les sections non applicables. -->

Référentiel : [Source normative]

| ID | Exigence | Description | Implémentation | Preuve de conformité | Responsable | Échéance | Statut |
|----|----------|-------------|----------------|----------------------|-------------|----------|--------|
| [PREFIXE-01] | [Titre] | [Description] | [Implémentation] | [Preuve] | [Responsable] | [YYYY-MM-DD] | ⏳ |

---

## 7. Synthèse de conformité

<!-- Tableau de synthèse avec le taux de couverture par référentiel.
Mis à jour à chaque changement de statut. -->

| Référentiel | Total exigences | ✅ | 🔄 | ⏳ | ❌ | Couverture |
|-------------|----------------|----|----|----|----|------------|
| [ex: HDS] | [ex: 10] | [0] | [0] | [10] | [0] | [0%] |
| [ex: RGPD] | [ex: 8] | [0] | [0] | [8] | [0] | [0%] |

---

## Changelog

<!-- Ne pas inclure en v1.0. Décommenter à partir de la v1.1.

| Version | Date | Auteur | Modifications |
|---------|------|--------|---------------|
| 1.1 | YYYY-MM-DD | [Auteur] | [Description des modifications] |
| 1.0 | YYYY-MM-DD | [Auteur] | Version initiale |
-->
