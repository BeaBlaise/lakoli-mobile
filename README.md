# Lakoli Mobile

Application mobile Flutter du réseau social éducatif Lakoli, connectée au backend Laravel
existant (`c:\Users\hp\lakoli`) via `/api/v1`.

## Lancer en local

Le backend doit tourner (`php -S 127.0.0.1:8000 ...` depuis `public/`, voir le CLAUDE.md du
projet Laravel). L'URL à utiliser dépend de la cible :

```bash
# Émulateur Android (10.0.2.2 = alias vers 127.0.0.1 de la machine hôte)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1

# Appareil physique sur le même réseau (remplacer par l'IP réelle de la machine)
flutter run --dart-define=API_BASE_URL=http://192.168.1.42:8000/api/v1

# Navigateur Chrome, pour un aperçu rapide sans SDK Android
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

## Tests

```bash
flutter analyze
flutter test                                          # unitaires + widget, hors intégration
flutter test test/integration/                        # nécessite le backend Laravel démarré
```

## Architecture

Voir `lib/` — `core/` (réseau, stockage, routage, erreurs), `domain/` (entités et contrats,
indépendants de l'API), `data/` (modèles JSON + implémentations des repositories),
`presentation/` (écrans, organisés par fonctionnalité).
