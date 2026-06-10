#!/bin/bash

# Script de déploiement automatique
# À exécuter sur le VPS après avoir cloné le projet

set -e

echo "🚀 Démarrage du déploiement de la stack Minecraft..."

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    print_error "Docker n'est pas installé !"
    echo "Installez Docker avec : curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
    exit 1
fi

# Vérifier que Docker Compose est installé
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_error "Docker Compose n'est pas installé !"
    echo "Installez Docker Compose avec : sudo apt install docker-compose -y"
    exit 1
fi

print_info "Docker et Docker Compose sont installés ✓"

# Vérifier la présence du plugin Minecraft
if [ ! -f "minecraft/plugins/minecraft-prometheus-exporter-2.5.0.jar" ]; then
    print_warning "Plugin Minecraft Prometheus non trouvé. Téléchargement..."
    mkdir -p minecraft/plugins
    cd minecraft/plugins
    wget -q https://github.com/sladkoff/minecraft-prometheus-exporter/releases/download/v2.5.0/minecraft-prometheus-exporter-2.5.0.jar
    if [ $? -eq 0 ]; then
        print_info "Plugin téléchargé ✓"
    else
        print_error "Échec du téléchargement du plugin"
        exit 1
    fi
    cd ../..
else
    print_info "Plugin Minecraft Prometheus trouvé ✓"
fi

# Obtenir l'IP publique du VPS
print_info "Détection de l'IP publique..."
PUBLIC_IP=$(curl -s ifconfig.me)
if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP=$(curl -s api.ipify.org)
fi

if [ -z "$PUBLIC_IP" ]; then
    print_warning "Impossible de détecter l'IP publique automatiquement"
    read -p "Entrez l'IP publique de votre VPS : " PUBLIC_IP
fi

print_info "IP publique détectée : $PUBLIC_IP"

# Mettre à jour l'IP dans la landing page
print_info "Mise à jour de l'IP dans la landing page..."
sed -i -E "s/(YOUR_VPS_IP|31\.207\.38\.10):12000/${PUBLIC_IP}:12000/g" landing/server.js
print_info "IP mise à jour ✓"

# Arrêter les conteneurs existants si présents
if [ "$(docker ps -q)" ]; then
    print_info "Arrêt des conteneurs existants..."
    docker compose down
fi

# Lancer la stack
print_info "Construction et démarrage de la stack Docker..."
docker compose up -d --build

# Attendre que les services démarrent
print_info "Démarrage des services (cela peut prendre 30-60 secondes)..."
sleep 10

# Vérifier l'état des conteneurs
print_info "Vérification de l'état des conteneurs..."
docker compose ps

# Attendre que Minecraft démarre complètement
print_info "Attente du démarrage complet du serveur Minecraft..."
for i in {1..30}; do
    if docker compose logs minecraft 2>&1 | grep -q "Done"; then
        print_info "Serveur Minecraft démarré ✓"
        break
    fi
    sleep 2
    echo -n "."
done
echo ""

# Afficher les informations d'accès
echo ""
echo "=========================================="
print_info "✅ Déploiement terminé avec succès !"
echo "=========================================="
echo ""
echo "🌐 Accès aux services :"
echo ""
echo "   Landing Page:     http://${PUBLIC_IP}:8080"
echo "   Grafana:          http://${PUBLIC_IP}:81"
echo "   Minecraft Server: ${PUBLIC_IP}:12000"
echo ""
echo "🔐 Identifiants Grafana :"
echo "   Utilisateur: admin"
echo "   Mot de passe: admin"
echo ""
echo "📊 Dashboards Grafana disponibles :"
echo "   - Infrastructure Overview"
echo "   - Minecraft Server Stats"
echo ""
echo "=========================================="
echo ""
print_info "Commandes utiles :"
echo "   Voir les logs:        docker compose logs -f"
echo "   Arrêter:              docker compose down"
echo "   Redémarrer:           docker compose restart"
echo "   État des conteneurs:  docker compose ps"
echo ""

# Afficher les logs en temps réel (optionnel)
read -p "Voulez-vous voir les logs en temps réel ? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker compose logs -f
fi
