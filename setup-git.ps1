# Script PowerShell pour initialiser Git et pousser le projet
# À exécuter sur Windows AVANT de déployer sur le VPS

Write-Host "🚀 Initialisation du dépôt Git..." -ForegroundColor Green

# Vérifier si Git est installé
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git n'est pas installé !" -ForegroundColor Red
    Write-Host "Téléchargez Git depuis : https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Git est installé" -ForegroundColor Green

# Initialiser Git si pas déjà fait
if (-not (Test-Path ".git")) {
    Write-Host "📁 Initialisation du dépôt Git..." -ForegroundColor Cyan
    git init
    Write-Host "✓ Dépôt initialisé" -ForegroundColor Green
} else {
    Write-Host "✓ Dépôt Git déjà initialisé" -ForegroundColor Green
}

# Demander l'URL du dépôt distant
Write-Host ""
Write-Host "📝 Configuration du dépôt distant" -ForegroundColor Cyan
Write-Host "Créez d'abord un dépôt sur GitHub ou GitLab, puis collez l'URL ici." -ForegroundColor Yellow
Write-Host ""
$repoUrl = Read-Host "URL du dépôt distant (ex: https://github.com/username/minecraft-server.git)"

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "❌ URL vide, abandon." -ForegroundColor Red
    exit 1
}

# Vérifier si remote existe déjà
$remoteExists = git remote | Select-String "origin"

if ($remoteExists) {
    Write-Host "⚠️  Remote 'origin' existe déjà. Mise à jour..." -ForegroundColor Yellow
    git remote set-url origin $repoUrl
} else {
    Write-Host "➕ Ajout du remote 'origin'..." -ForegroundColor Cyan
    git remote add origin $repoUrl
}

Write-Host "✓ Remote configuré" -ForegroundColor Green

# Ajouter tous les fichiers
Write-Host ""
Write-Host "📦 Ajout des fichiers..." -ForegroundColor Cyan
git add .

# Vérifier qu'il y a des changements
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "⚠️  Aucun changement à commiter" -ForegroundColor Yellow
} else {
    # Commit
    Write-Host "💾 Création du commit..." -ForegroundColor Cyan
    $commitMessage = Read-Host "Message du commit (Entrée pour message par défaut)"
    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        $commitMessage = "Initial commit - Stack Minecraft + Monitoring"
    }
    git commit -m $commitMessage
    Write-Host "✓ Commit créé" -ForegroundColor Green
}

# Pousser sur le dépôt distant
Write-Host ""
Write-Host "🚀 Push vers le dépôt distant..." -ForegroundColor Cyan

# Vérifier si la branche main existe, sinon créer
$currentBranch = git branch --show-current
if ([string]::IsNullOrWhiteSpace($currentBranch) -or $currentBranch -eq "master") {
    Write-Host "🔄 Renommage de la branche en 'main'..." -ForegroundColor Cyan
    git branch -M main
}

try {
    git push -u origin main
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ Projet poussé avec succès !" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 PROCHAINES ÉTAPES :" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1️⃣  Connectez-vous à votre VPS :" -ForegroundColor White
    Write-Host "   ssh root@vps114744.serveur-vps.net" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2️⃣  Clonez le projet :" -ForegroundColor White
    Write-Host "   git clone $repoUrl" -ForegroundColor Gray
    Write-Host "   cd $(Split-Path -Leaf $repoUrl -Replace '.git$','')" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3️⃣  Lancez le script de déploiement :" -ForegroundColor White
    Write-Host "   chmod +x deploy.sh" -ForegroundColor Gray
    Write-Host "   ./deploy.sh" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Puis accédez à :" -ForegroundColor Yellow
    Write-Host "   Landing: http://vps114744.serveur-vps.net" -ForegroundColor Gray
    Write-Host "   Grafana: http://vps114744.serveur-vps.net:81" -ForegroundColor Gray
    Write-Host "   Minecraft: vps114744.serveur-vps.net:12000" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Ou suivez le guide GUIDE_RAPIDE.md" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "❌ Erreur lors du push" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Vérifiez :" -ForegroundColor Yellow
    Write-Host "   - L'URL du dépôt est correcte" -ForegroundColor Gray
    Write-Host "   - Vous avez les droits d'accès au dépôt" -ForegroundColor Gray
    Write-Host "   - Vous êtes authentifié (token ou SSH)" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
