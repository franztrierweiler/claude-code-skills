Le fichier docs/SPEC-racine-*.md contient la spécification complète du projet MaintiX. Identifie-le dans docs/.

Crée une extension pour la fonction « Alertes capteurs » en suivant le processus complet du skill sdd-uc-spec-write (mode extension), sans poser de questions. Considère chaque information comme validée par le pilote du projet.

La fonction Alertes capteurs couvre :
- Intégration des capteurs IoT installés sur les équipements critiques (température, vibration, pression) via MQTT
- Réception et traitement des mesures en temps réel
- Déclenchement d'alertes lorsque les seuils sont dépassés
- Conversion d'une alerte en intervention (création automatique ou manuelle)
- Tableau de bord des mesures et de l'historique des alertes

Acteurs concernés : Dispatcher (suivi des alertes), Technicien (consultation terrain), Capteurs machines (émetteur MQTT).

Contraintes : alertes < 10 secondes entre la mesure et la notification, rétention des mesures 2 ans, MQTT/Mosquitto comme broker.

Le fichier d'extension doit être écrit dans docs/ en respectant la convention de nommage du skill (SPEC-extension-<NomProjet>-<NomFonction>.md).
