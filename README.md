# 📁 Structure du projet

Le repository est organisé afin de séparer clairement le projet Symfony de son environnement d'infrastructure.

```text
HOMIA/
│
├── App/                         # Application Symfony
│   ├── assets/
│   ├── config/
│   ├── migrations/
│   ├── public/
│   ├── src/
│   ├── templates/
│   ├── tests/
│   ├── var/
│   ├── composer.json
│   └── ...
│
├── Docker/                      # Configuration de l'environnement Docker
│   ├── FrankenPHP/
│   ├── PHP/
│   ├── bdd/
│   └── ...
│
├── docker-compose.yml           # Orchestration des conteneurs
├── Makefile                     # Commandes simplifiées du projet
├── .gitignore                   # Fichiers exclus du repository
├── LICENSE                      # Licence MIT
└── README.md                    # Documentation du projet
```

### `App/`

Contient l'ensemble de l'application Symfony.

Le code applicatif reste ainsi isolé de la configuration de l'infrastructure.

### `Docker/`

Contient les fichiers nécessaires à la construction et à la configuration de l'environnement Docker.

Cette partie regroupe notamment les informations et configurations liées aux serveurs utilisés par HOMIA.

### `docker-compose.yml`

Décrit les différents services nécessaires au fonctionnement de l'environnement HOMIA.

### `Makefile`

Centralise les commandes courantes afin de simplifier l'utilisation du projet.

Exemples :

```bash
make up
make down
make install
make test
make bash
```

Les commandes disponibles seront documentées au fur et à mesure de l'évolution du projet.

### `.gitignore`

Définit les fichiers et répertoires qui ne doivent pas être versionnés.

Les données sensibles et fichiers générés localement doivent notamment rester exclus du repository.

### `LICENSE`

Contient la licence MIT du projet.

### `README.md`

Documentation principale du projet, comprenant notamment :

* présentation de HOMIA ;
* architecture ;
* stack technique ;
* installation ;
* workflow Git ;
* roadmap ;
* règles de contribution.
