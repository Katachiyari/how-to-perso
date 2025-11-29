# 🚀 Projet Fil Rouge : Automatisation Nginx Avancée avec Ansible

Ce dépôt contient l'intégralité du projet réalisé dans le cadre du cursus **"Ansible : De Zéro à Expert"**. Il illustre la mise en place d'une infrastructure Web (Nginx) automatisée, sécurisée et orchestrée, en suivant les meilleures pratiques de l'industrie (Infrastructure as Code).

***

## 📋 Table des Matières

1. [Objectifs du Projet](#-objectifs-du-projet)
2. [Architecture Technique](#-architecture-technique)
3. [Structure du Projet](#-structure-du-projet)
4. [Progression \& Fonctionnalités](#-progression--fonctionnalit%C3%A9s)
    * [Niveau 1 : Les Fondations](#niveau-1--les-fondations-d%C3%A9butant)
    * [Niveau 2 : Industrialisation](#niveau-2--industrialisation-interm%C3%A9diaire)
    * [Niveau 3 : Orchestration Pro](#niveau-3--orchestration-pro-avanc%C3%A9-1)
    * [Niveau 4 : Qualité \& CI/CD](#niveau-4--qualit%C3%A9--cicd-avanc%C3%A9-2)
5. [Comment utiliser ce projet](#-comment-utiliser-ce-projet)

***

## 🎯 Objectifs du Projet

* Déployer un serveur web **Nginx** complet de manière idempotente.
* Gérer les utilisateurs, les fichiers de configuration et les secrets (**Ansible Vault**).
* Mettre en place une architecture modulaire basée sur des **Rôles**.
* Assurer la qualité du code via **Ansible-Lint** et des tests automatisés.
* Orchestrer des déploiements sans interruption (**Rolling Updates**, **Blue/Green**).

***

## 🏗 Architecture Technique

* **Contrôleur :** Machine locale / CI Runner
* **Cibles :**
    * Environnement **DEV** : Serveur unique (simulé).
    * Environnement **PROD** : Cluster de 3 serveurs Web (simulés par alias).
* **Composants gérés :**
    * Service Nginx (config dynamique via Jinja2).
    * Utilisateurs système (`deploy`).
    * Secrets chiffrés (mots de passe DB/Utilisateurs).

***

## 📂 Structure du Projet

L'arborescence respecte les standards Ansible Galaxy et Production :

```text
ansible-nginx-lab/
├── ansible.cfg              # Configuration locale du projet
├── .ansible-lint            # Règles de qualité code
├── pipeline.sh              # Script de simulation CI/CD
├── inventories/             # Inventaires séparés par environnement
│   ├── dev/hosts.ini
│   └── prod/hosts.ini
├── group_vars/              # Variables partagées (et Secrets Vault)
│   ├── all_vault.yml        # [ENCRYPTED] Secrets globaux
│   ├── webservers.yml       # Vars communes (ports, users...)
│   └── webservers_prod.yml  # Surcharges spécifiques Prod
├── roles/                   # Logique modulaire
│   ├── webserver_role/      # Installation & Config Nginx
│   │   ├── tasks/           # (install, manage_site, main avec block/rescue)
│   │   ├── handlers/        # (restart nginx)
│   │   ├── templates/       # (nginx.conf.j2, index.html.j2)
│   │   └── meta/            # Dépendances
│   └── users_role/          # Gestion des utilisateurs système
├── playbooks/               # Points d'entrée
│   ├── site.yml             # Playbook principal (Orchestrateur)
│   └── deploy_nginx.yml     # (Legacy) Playbook simple
└── tests/                   # Tests d'intégration
    └── test_webserver.yml   # Validation HTTP (Smoke Test)
```


***

## 📈 Progression \& Fonctionnalités

### Niveau 1 : Les Fondations (Débutant)

* Mise en place de l'inventaire et `ansible.cfg`.
* Modules de base : `ansible.builtin.apt`, `service`, `file`, `copy`, `user`.
* Notion d'**Idempotence** (le playbook peut être relancé sans casser l'existant).


### Niveau 2 : Industrialisation (Intermédiaire)

* **Rôles** : Séparation des responsabilités (`webserver` vs `users`).
* **Variables \& Jinja2** : Templating dynamique des fichiers HTML/Config.
* **Vault** : Chiffrement des mots de passe (base de données, users).
* **Tags** : Exécution partielle (`--tags nginx`).
* **Lookups** : Récupération dynamique de données (`env`, `file`, `password`).


### Niveau 3 : Orchestration Pro (Avancé 1)

* **Rolling Updates** : Utilisation de `serial: 1` pour mettre à jour les serveurs un par un.
* **Gestion d'erreurs** : Blocs `block/rescue/always` pour gérer les échecs et faire des rollbacks automatiques.
* **Délégation** : Usage de `delegate_to` pour simuler la sortie d'un serveur du Load Balancer avant maintenance.


### Niveau 4 : Qualité \& CI/CD (Avancé 2 / Expert)

* **Qualité Code** : Configuration stricte d'`ansible-lint` (FQCN obligatoires).
* **Tests Automatisés** : Smoke tests (`test_webserver.yml`) validant le code HTTP 200 post-déploiement.
* **Pipeline CI/CD** : Script `pipeline.sh` simulant un workflow complet :

1. Linting
2. Security Check (Secrets en clair)
3. Dry-Run (Check Mode)
4. Déploiement Dev
5. Validation Fonctionnelle

***

## 🚀 Comment utiliser ce projet

### 1. Prérequis

* Ansible installé (`pip install ansible`)
* Ansible-Lint installé (`pip install ansible-lint`)


### 2. Lancer le Pipeline de Qualité (CI)

```bash
./pipeline.sh
```


### 3. Déployer en Production (Rolling Update)

```bash
ansible-playbook -i inventories/prod/hosts.ini playbooks/site.yml --ask-vault-pass
```


### 4. Simuler un Rollback (Test de robustesse)

Ajouter la variable `simulate_crash=true` pour voir le mécanisme de sauvetage (`rescue`) en action.

```bash
ansible-playbook -i inventories/prod/hosts.ini playbooks/site.yml -e "simulate_crash=true"
```


***
*Projet réalisé en suivant la méthode progressive "De Zéro à Expert" - 2025.*
<span style="display:none">[^1][^10][^2][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://gitlab.mim-libre.fr/dimail/dimail-infra/-/blob/600845122f670aa9529d89664f5192399d85a2bd/README.md

[^2]: https://github.com/iAugur/ansible-playbook-template/blob/master/README.md

[^3]: https://blog.stephane-robert.info/docs/infra-as-code/gestion-de-configuration/ansible/ecrire-roles/

[^4]: https://linux.goffinet.org/ansible/presentation-produit-ansible/

[^5]: https://github.com/goffinet/ansible-ccna-lab/blob/master/README.md

[^6]: https://techblog.deepki.com/debuter-avec-ansible/

[^7]: https://gitlab.com/to-be-continuous/ansible/-/blob/master/README.md

[^8]: https://code.facil.services/facil/ansible

[^9]: https://poec2021.doxx.fr/06-ansible/cours3/

[^10]: https://git.221b.uk/infrastructure/ansible/-/blob/c9ec8d71098fd02b82df680a80c2aabe91a385e6/README.md

