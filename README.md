# 🎮 Serveur Minecraft Monitoré avec Docker

Stack Docker complète incluant un serveur Minecraft Paper, une landing page Node.js et un système de monitoring Prometheus/Grafana.

## 📦 Contenu de la stack

- **Minecraft Server** (Paper) - Port 12000
- **Landing Page** (Node.js + Express + EJS) - Port 8080
- **Grafana** - Port 81
- **Prometheus** - Réseau interne
- **node-exporter** - Métriques système
- **cAdvisor** - Métriques conteneurs
- **Plugin Minecraft Prometheus** - Métriques Minecraft

## 🚀 Installation rapide

### Prérequis

- VPS Linux avec Docker et Docker Compose installés
- Accès SSH au VPS
- Au minimum 4 GB de RAM recommandé

### 1. Cloner le projet sur votre VPS

```bash
git clone <votre-repo-git>
cd hebergeur
```

### 2. Télécharger le plugin Minecraft Prometheus

```bash
cd minecraft/plugins
wget https://github.com/sladkoff/minecraft-prometheus-exporter/releases/download/v2.5.0/minecraft-prometheus-exporter-2.5.0.jar
cd ../..
```

> ⚠️ **Important** : Vérifiez la dernière version sur https://github.com/sladkoff/minecraft-prometheus-exporter/releases

### 3. Lancer la stack

```bash
docker compose up -d --build
```

### 4. Vérifier que tout fonctionne

```bash
docker compose ps
```

Tous les conteneurs doivent être en état `Up`.

## 🌐 Accès aux services

| Service | URL | Identifiants |
|---------|-----|--------------|
| Landing Page | `http://vps114744.serveur-vps.net:8080` | - |
| Grafana | `http://vps114744.serveur-vps.net:81` | admin / admin1 |
| Minecraft | `vps114744.serveur-vps.net:12000` | - |

## 📊 Dashboards Grafana

Deux dashboards sont automatiquement provisionnés :

1. **Infrastructure Overview** : Métriques VPS et conteneurs (CPU, RAM, disque, réseau)
2. **Minecraft Server Stats** : Métriques du serveur Minecraft (joueurs, TPS, chunks, mémoire JVM)

## 🔧 Configuration

### Volumes persistants

- `minecraft_data` : Monde et configuration Minecraft
- `grafana_data` : Données et dashboards Grafana
- `prometheus_data` : Données de métriques Prometheus

### Réseaux

- `minecraft-net` : Communication landing ↔ minecraft
- `monitoring-net` : Communication monitoring (Prometheus, Grafana, exporters)

### Ports exposés

- **8080** : Landing page
- **81** : Grafana
- **12000** : Minecraft (différent du port par défaut 25565)

## 📝 Commandes utiles

### Voir les logs

```bash
# Tous les conteneurs
docker compose logs -f

# Un conteneur spécifique
docker compose logs -f minecraft
docker compose logs -f grafana
```

### Redémarrer un service

```bash
docker compose restart minecraft
```

### Arrêter la stack

```bash
docker compose down
```

### Arrêter et supprimer les volumes (⚠️ PERTE DE DONNÉES)

```bash
docker compose down -v
```

## 🎯 Métriques disponibles

### Node Exporter (machine hôte)

- CPU, RAM, disque, réseau
- Charge système
- Statistiques I/O

### cAdvisor (conteneurs)

- CPU par conteneur
- Mémoire par conteneur  
- Réseau par conteneur
- État des conteneurs

### Minecraft Prometheus

- Nombre de joueurs en ligne
- TPS (Ticks Per Second)
- Durée des ticks
- Mémoire JVM
- Chunks chargés
- Entités

## 🐛 Dépannage

### Le serveur Minecraft ne démarre pas

```bash
docker compose logs minecraft
```

Vérifiez que le plugin `.jar` est bien dans `minecraft/plugins/`.

### Grafana ne se connecte pas à Prometheus

Vérifiez que Prometheus est accessible :

```bash
docker compose exec grafana curl http://prometheus:9090
```

### Les métriques Minecraft n'apparaissent pas

1. Vérifiez que le plugin est chargé :
```bash
docker compose logs minecraft | grep prometheus
```

2. Vérifiez que Prometheus scrape le serveur :
```bash
docker compose exec prometheus wget -qO- http://minecraft:9225/metrics
```

## 📁 Structure du projet

```
hebergeur/
├── docker-compose.yml
├── README.md
├── landing/
│   ├── dockerfile
│   ├── package.json
│   ├── server.js
│   └── views/
│       └── index.ejs
├── prometheus/
│   └── prometheus.yml
├── grafana/
│   └── provisioning/
│       ├── datasources/
│       │   └── datasource.yml
│       └── dashboards/
│           ├── dashboards.yml
│           ├── infrastructure-dashboard.json
│           └── minecraft-dashboard.json
└── minecraft/
    └── plugins/
        └── minecraft-prometheus-exporter-X.X.X.jar
```

## ⚙️ Configuration avancée

### Changer le mot de passe Grafana

Modifiez dans `docker-compose.yml` :

```yaml
environment:
  GF_SECURITY_ADMIN_PASSWORD: VotreNouveauMotDePasse
```

### Augmenter la RAM du serveur Minecraft

Modifiez dans `docker-compose.yml` :

```yaml
environment:
  MEMORY: "4G"  # Au lieu de 2G
```

### Ajouter un reverse proxy Nginx (BONUS)

Créez `nginx/nginx.conf` et ajoutez le service dans `docker-compose.yml`.

## 📜 Licence

Projet académique - TP noté

## 👤 Auteur

Votre nom - TP Déploiement Docker
