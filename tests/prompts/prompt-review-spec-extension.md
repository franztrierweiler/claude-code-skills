Tu es un auditeur qualité de spécifications logicielles SDD (Spec Driven Development).

Lis la spec racine (fichier docs/SPEC-racine-*.md), l'extension (fichier docs/SPEC-extension-*.md) et le prompt d'extension dans tests/prompts/prompt-uc-spec-extension.md qui décrit la fonction attendue.

Évalue la complétude et la qualité du document d'extension en vérifiant les points suivants :

## 1. Cartouche
- Le cartouche contient-il les 11 champs requis (Document, UUID, Version, Date, Auteur, Statut, Type, Spec racine, UUID racine, Préfixe, Généré par) ?
- Le champ Spec racine pointe-t-il vers le bon fichier ?
- L'UUID racine correspond-il à celui de la spec racine ?
- Le préfixe est-il cohérent avec le nom de la fonction ?

## 2. Couverture fonctionnelle
- Les cas d'utilisation décrits dans le prompt d'extension sont-ils tous présents sous forme de UC préfixés ?
- Liste les UC manquants s'il y en a.

## 3. Identifiants préfixés
- Tous les identifiants de l'extension portent-ils le préfixe (UC-PFX-XXX, RG-PFX-XXXX, CA-UC-PFX-XXX-NN, ENF-PFX-XXX) ?
- Les références à la spec racine utilisent-elles des identifiants sans préfixe (UC-XXX, RG-XXXX) ?
- Y a-t-il des mélanges ou incohérences ?

## 4. Table des dépendances
- La section « Dépendances vers la spec racine » est-elle présente et renseignée ?
- Chaque UC/RG racine référencé dans les UC de l'extension apparaît-il dans la table ?
- La nature de la dépendance est-elle précisée (Include / Extend / Donnée en entrée / Prérequis) ?

## 5. Règles de gestion
- Les contraintes du prompt (alertes < 10 secondes, rétention 2 ans, MQTT) sont-elles traduites en RG préfixées ?
- Les valeurs numériques sont-elles fidèles au prompt ?

## 6. Exigences non fonctionnelles
- Les ENF spécifiques à la fonction (temps de réponse capteurs, rétention mesures) sont-elles documentées avec des valeurs mesurables ?

## 7. Structure et traçabilité
- Chaque UC a-t-il au moins un critère d'acceptation au format Soit/Quand/Alors ?
- Le glossaire fonction contient-il uniquement des termes nouveaux (pas de doublons avec la racine) ?

## 8. Autonomie
- Un agent IA qui reçoit la spec racine + cette extension pourrait-il implémenter la fonction sans poser de question ?

## Format de sortie

Produis un rapport structuré avec pour chaque point :
- ✅ Conforme — si le point est entièrement couvert
- ⚠️ Partiel — si le point est couvert mais incomplet (détailler ce qui manque)
- ❌ Absent — si le point n'est pas couvert

Termine par une note globale sur 10 et une liste des 3 améliorations prioritaires.
