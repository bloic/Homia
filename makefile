# Makefile pour Devup Business Events

.PHONY: help up down restart build logs shell composer sf db-create db-migrate cache-clear permissions install start fresh clean

# Variable pour exécuter les commandes dans le conteneur
EXEC = docker compose exec frankenphp

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ========================================
# COMMANDES DOCKER DE BASE
# ========================================

up: ## Démarre les conteneurs
	@echo "🚀 Démarrage des conteneurs..."
	docker compose up -d
	@echo "✅ Conteneurs démarrés !"

down: ## Arrête les conteneurs
	@echo "🛑 Arrêt des conteneurs..."
	docker compose down
	@echo "✅ Conteneurs arrêtés !"

restart: ## Redémarre les conteneurs
	@echo "🔄 Redémarrage des conteneurs..."
	docker compose restart
	@echo "✅ Conteneurs redémarrés !"

build: ## Reconstruit les images
	@echo "🏗️ Reconstruction des images..."
	docker compose build --no-cache
	@echo "✅ Images reconstruites !"

logs: ## Affiche les logs de FrankenPHP
	docker compose logs -f frankenphp

logs-all: ## Affiche tous les logs
	docker compose logs -f

shell: ## Ouvre un shell dans le conteneur FrankenPHP
	docker compose exec frankenphp bash

# ========================================
# COMMANDES COMPOSER & SYMFONY
# ========================================

composer: ## Installe les dépendances Composer
	@echo "📦 Installation des dépendances..."
	docker compose exec frankenphp composer install
	@echo "✅ Dépendances installées !"

composer-outdated: ## Vérifie les dépendances obsolètes
	@echo "📦 Installation des dépendances..."
	docker compose exec frankenphp composer outtdated
	@echo "✅ Dépendances obsolètes !"
c-require: ## Installe une dépendance via composer ex: make c-require twig/intl-extra
	@echo "📦 Installation des dépendances..."
	docker compose exec frankenphp composer require $(filter-out $@,$(MAKECMDGOALS))
	@echo "✅ Dépendances installées !"

composer-update: ## Met à jour les dépendances
	@echo "📦 Mise à jour des dépendances..."
	docker compose exec frankenphp composer update
	@echo "✅ Dépendances mises à jour !"

composer-dump-autoload: ## 🔄 Reconstruit l'autoloader Composer
	@echo "🔄 Reconstruction de l'autoloader Composer..."
	docker compose exec frankenphp composer dump-autoload
	@echo "✅ Autoloader reconstruit avec succès"

sf: ## Exécute une commande Symfony (ex: make sf cmd="cache:clear")
	docker compose exec frankenphp php bin/console $(cmd)

cache-clear: ## Vide le cache Symfony
	@echo "🧹 Nettoyage du cache..."
	docker compose exec frankenphp php bin/console cache:clear
	docker compose exec frankenphp chmod -R 777 /app/var
	@echo "✅ Cache vidé !"

# ========================================
# COMMANDES BASE DE DONNÉES
# ========================================

db-create: ## Crée la base de données
	@echo "🗄️ Création de la base de données..."
	docker compose exec frankenphp php bin/console doctrine:database:create --if-not-exists
	@echo "✅ Base de données créée !"

db-migrate: ## Lance les migrations
	@echo "🗄️ Exécution des migrations..."
	docker compose exec frankenphp php bin/console doctrine:migrations:migrate --no-interaction
	@echo "✅ Migrations exécutées !"

db-c-migration: ## Créer la migration
	@echo " 🗄️ Création des migrations..."
	docker compose exec frankenphp php bin/console make:migration
	@echo "✅ Migration créer !"

db-m-migrate: ## Migre la migration en base de donnée
	@echo " 🗄️ Migre la migration en base de donnée"
	docker compose exec frankenphp bin/console doctrine:migration:migrate
	@echo "✅ Migration migrer !"

db-fixtures: ## Charge les fixtures
	@echo "🗄️ Chargement des fixtures..."
	docker compose exec frankenphp php bin/console doctrine:fixtures:load --no-interaction
	@echo "✅ Fixtures chargées !"

db-reset: ## Réinitialise la base de données
	@echo "🗄️ Réinitialisation de la base de données..."
	docker compose exec frankenphp php bin/console doctrine:database:drop --force --if-exists
	docker compose exec frankenphp php bin/console doctrine:database:create
	docker compose exec frankenphp php bin/console doctrine:migrations:migrate --no-interaction
	@echo "✅ Base de données réinitialisée !"

# ========================================
# PERMISSIONS & MAINTENANCE
# ========================================

permissions: ## Corrige les permissions de var/
	@echo "🔧 Correction des permissions..."
	docker compose exec frankenphp chmod -R 777 /app/var
	@echo "✅ Permissions corrigées !"

clean-cache: ## Supprime complètement le cache
	@echo "🧹 Suppression du cache..."
	docker compose exec frankenphp rm -rf /app/var/cache/*
	docker compose exec frankenphp chmod -R 777 /app/var
	@echo "✅ Cache supprimé !"

# ========================================
# COMMANDES DE DÉMARRAGE COMPLET
# ========================================

install: ## Installation complète du projet
	@echo "🚀 Installation complète du projet..."
	make build
	make up
	@echo "⏳ Attente du démarrage des conteneurs..."
	sleep 5
	make composer
	make db-create
	make db-migrate
	make permissions
	make cache-clear
	@echo "🎉 Installation terminée !"
	@echo "🌐 Application accessible sur http://localhost ou https://localhost"

start: ## Démarre le projet (si déjà installé)
	@echo "🚀 Démarrage du projet..."
	make up
	@echo "⏳ Attente du démarrage..."
	sleep 3
	make permissions
	@echo "✅ Projet démarré !"
	@echo "🌐 Application accessible sur http://localhost ou https://localhost"

fresh: ## Reconstruction complète du projet
	@echo "🔄 Reconstruction complète..."
	make down
	docker compose down --volumes
	make build
	make up
	@echo "⏳ Attente du démarrage..."
	sleep 5
	make composer
	make db-create
	make db-migrate
	make permissions
	make cache-clear
	@echo "🎉 Reconstruction terminée !"
	@echo "🌐 Application accessible sur http://localhost ou https://localhost"

# ========================================
# NETTOYAGE
# ========================================

clean: ## Nettoyage complet (arrête tout et supprime les volumes)
	@echo "🧹 Nettoyage complet..."
	docker compose down --volumes --remove-orphans
	@echo "✅ Nettoyage terminé !"

prune: ## Nettoie Docker complètement
	@echo "🧹 Nettoyage Docker..."
	docker compose down --volumes --remove-orphans
	docker system prune -af --volumes
	@echo "✅ Nettoyage Docker terminé !"

# ========================================
# TESTS & QUALITÉ
# ========================================

test: ## Lance les tests
	@echo "🧪 Exécution des tests..."
	docker compose exec frankenphp vendor/bin/phpunit
	@echo "✅ Tests terminés !"

phpcs: ## Vérification du code avec PHPCS
	@echo "🔍 Vérification PHPCS..."
	$(EXEC) vendor/bin/phpcs

phpcs-check: ## Vérification du code avec PHPCS (rapport détaillé)
	@echo "🔍 Vérification PHPCS..."
	docker compose exec frankenphp vendor/bin/phpcs --report=full

phpcs-fix: ## Corrige automatiquement le code avec PHPCBF
	@echo "🔧 Correction automatique PHPCBF..."
	$(EXEC) vendor/bin/phpcbf || true
	@echo "✅ Corrections appliquées !"

phpstan: ## Analyse statique avec PHPStan
	@echo "🔍 Analyse PHPStan..."
	$(EXEC) vendor/bin/phpstan analyse

lint: ## Vérifie le code (PHPCS + PHPStan)
	@echo "🔍 Vérification du code..."
	make phpcs
	make phpstan
	@echo "✅ Vérification terminée !"

fix: ## Corrige le code puis vérifie (PHPCBF + PHPCS + PHPStan)
	@echo "🔧 Correction et vérification du code..."
	make phpcs-fix
	make phpcs
	make phpstan
	@echo "✅ Correction et vérification terminées !"

# ========================================
# PHPUNIT & AUTRES OUTILS
# ========================================

phpmyadmin: ## Ouvre PHPMyAdmin
	@echo "🌐 PHPMyAdmin accessible sur http://localhost:8080"

status: ## Affiche le statut des conteneurs
	@echo "📊 Statut des conteneurs:"
	docker compose ps