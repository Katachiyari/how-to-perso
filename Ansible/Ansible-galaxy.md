# 🚀 Guide Complet ansible-galaxy - Best Practices

> **Maîtriser ansible-galaxy pour automatiser comme un pro** : de la consommation à la création de contenus réutilisables.

---

## 📋 Table des matières
1. [Objectif & Périmètre](#1-objectif--périmètre)
2. [Concepts Clés](#2-concepts-clés--rôles-vs-collections)
3. [Structure d'un Projet Modern](#3-organisation-dun-projet-ansible-moderne)
4. [Consommer des Rôles](#4-consommer-des-rôles-avec-ansible-galaxy)
5. [Consommer des Collections](#5-consommer-des-collections)
6. [Créer un Rôle Propre](#6-créer-un-rôle-propre-avec-ansible-galaxy-init)
7. [Best Practices Avancées](#7-bonnes-pratiques-avancées)
8. [Résumé & Checklist](#8-résumé--checklist-rapide)

---

## 1. Objectif & Périmètre

### 🎯 Ce que tu vas apprendre

Ce guide référence technique détaille l'utilisation d'**`ansible-galaxy`** pour consommer et créer du contenu Ansible (rôles et collections) de manière **professionnelle et scalable**.

✅ **Couvert** :
- Consommation propre de rôles et collections
- Création de rôles standardisés
- Gestion des versions et reproductibilité
- Intégration CI/CD et tests
- Sécurité et bonnes pratiques

❌ **Non couvert** :
- Modules/plugins personnalisés avancés
- Architecture Ansible complexe
- Kubernetes/orchestration

### 👥 Niveau & Prérequis

| Aspect | Détail |
|--------|--------|
| **Niveau** | Débutant → Intermédiaire → Avancé |
| **Prérequis** | Notions Ansible (playbooks, rôles, inventaire) |
| **Durée** | ~2h pour maîtriser les bases + avancé |

### 🎓 Objectif Final

Créer des **projets Ansible autonomes, versionés et collaboratifs**, en évitant les pièges courants comme les installations "à la main" ou les versions non fixées.

---

## 2. Concepts Clés : Rôles vs Collections

### 🔷 Qu'est-ce qu'ansible-galaxy ?

**ansible-galaxy** = **Plateforme web + CLI** pour gérer les dépendances Ansible.

```
┌─────────────────────────────────────┐
│   galaxy.ansible.com (catalogue)    │
│   ↓                                 │
│   ansible-galaxy (CLI locale)       │
│   ├─ search   (chercher)            │
│   ├─ install  (installer)           │
│   ├─ init     (créer)               │
│   └─ publish  (publier)             │
└─────────────────────────────────────┘
```

### 🏗️ Rôles vs Collections

#### 📦 **Rôles** (Briques fines)

| Aspect | Détail |
|--------|--------|
| **Utilité** | Automatiser une tâche spécifique |
| **Exemple** | Installer/configurer Nginx, MySQL, Docker |
| **Contenu** | tasks/, handlers/, defaults/, templates/ |
| **Complexité** | Simple, monothématique |
| **Quand utiliser** | Besoins OS/applicatifs, service unique |

**Structure minimale** :
```
nginx-role/
├── tasks/main.yml          # Logique (installer, configurer)
├── defaults/main.yml       # Variables modifiables
├── handlers/main.yml       # Actions (restart service)
├── templates/              # Configs dynamiques
└── README.md
```

#### 🗂️ **Collections** (Paquets complets)

| Aspect | Détail |
|--------|--------|
| **Utilité** | Regrouper rôles + modules + plugins |
| **Exemple** | `ansible.posix`, `community.general`, `cisco.ios` |
| **Contenu** | rôles + modules Ansible + plugins + docs |
| **Complexité** | Structurée, multi-domaines |
| **Quand utiliser** | Outils transversaux, vendors, portabilité |

**Structure** :
```
community.general/
├── plugins/modules/        # Modules Ansible
├── roles/                  # Rôles inclus
├── docs/                   # Documentation
└── galaxy.yml
```

### 🎯 Comparaison rapide

| Critère | Rôle | Collection |
|---------|------|-----------|
| **Réutilisabilité** | Projet/service spécifique | Transversal, multi-projets |
| **Installation** | `ansible-galaxy role install …` | `ansible-galaxy collection install …` |
| **Versioning** | SemVer (v1.0.0) | SemVer + métadonnées |
| **Exemples** | `geerlingguy.nginx` | `community.general` |
| **Cas d'usage** | 80% des projets | Infrastructure générique |

### 💡 Best Practice

> **Hybride optimal** : Rôles pour la logique métier + Collections pour les fondations.

```
Mon projet Ansible
├── roles/requirements.yml    ← Rôles métier (40%)
├── collections/requirements.yml ← Outils généraux (60%)
└── playbooks/site.yml       ← Orchestre tout
```

---

## 3. Organisation d'un Projet Ansible Moderne

### 📁 Structure recommandée (Autonome)

```
my-ansible-project/
│
├── 📄 ansible.cfg              ← Config locale (ESSENTIELLE)
│
├── 📂 inventory/
│   ├── hosts.ini               ← Inventaire principal
│   └── hosts.yml               ← Alternatif YAML
│
├── 📂 group_vars/
│   ├── all.yml                 ← Vars globales
│   └── webservers.yml          ← Vars par groupe
│
├── 📂 host_vars/
│   └── web01.yml               ← Vars spécifiques hôte
│
├── 📂 playbooks/
│   ├── site.yml                ← Playbook principal
│   ├── deploy.yml              ← Déploiement
│   └── security.yml            ← Hardening
│
├── 📂 roles/
│   ├── requirements.yml        ← Dépendances rôles
│   ├── mon-role/               ← Rôle custom
│   └── *.roles/                ← Rôles installés (Galaxy)
│
├── 📂 collections/
│   ├── requirements.yml        ← Dépendances collections
│   └── ansible_collections/    ← Collections installées
│
├── 📂 tests/                   ← Tests (Molecule)
│   └── molecule.yml
│
├── .gitignore                  ← Ignorer .retry, .vault
├── .vault                      ← Secrets Ansible Vault (optionnel)
└── README.md                   ← Doc projet
```

### ⚙️ Fichier ansible.cfg (Configuration Locale)

**CRUCIAL** : Chaque projet a son `ansible.cfg` local !

```ini
# ansible.cfg - Best Practice Minimal

[defaults]
# Chemins locaux (PAS de /etc/ansible)
inventory = ./inventory
roles_path = ./roles
collections_paths = ./collections

# Sécurité & Performance
host_key_checking = False          # À passer à True en PROD
retry_files_enabled = False        # Désactiver les .retry
gathering = smart                  # Cache les facts
fact_caching = jsonfile
fact_caching_connection = ./cache

# Logs & Debug
log_path = ./logs/ansible.log

[inventory]
# Plugins inventaire
enable_plugins = host_list, script, auto, yaml, ini, toml

[ssh_connection]
pipelining = True                  # Performance
control_path = %(directory)s/%%h-%%r-%%p  # Stabilité SSH
```

### 🔑 Points clés

✅ **Isolation par projet** : Tout localement, rien en global (`/etc/ansible`).  
✅ **Versioning Git** : Commit structure + requirements.yml (tracking).  
✅ **Répétabilité** : Même machine, même jour, même résultat.  
✅ **Collaboration** : Tous les devs partent du même état.

---

## 4. Consommer des Rôles avec ansible-galaxy

### 🔍 Étape 1 : Chercher un Rôle

```bash
# Rechercher par mot-clé
ansible-galaxy role search nginx

# Résultat (Galaxy UI) :
# Name                           Description
# geerlingguy.nginx              Nginx web server
# jasonroyle.nginx               Nginx from source
# ...
```

### 📥 Étape 2 : Définir les Dépendances (✅ BEST PRACTICE)

**Créer `roles/requirements.yml`** :

```yaml
---
# Format YAML pour roles Galaxy

# 🔵 Rôle public (Galaxy official)
- name: geerlingguy.nginx
  version: "3.1.4"                    # 🔒 Version FIXÉE pour reproductibilité

# 🟢 Avec versioning sémantique (compatible)
- name: geerlingguy.mysql
  version: ">=5.1.0,<6.0.0"           # Range sécurisée (maj mineures OK)

# 🟡 Rôle Git (privé/custom)
- name: mycompany.custom-webapp
  src: https://github.com/mycompany/ansible-webapp.git
  version: "v2.1.0"                   # Tag Git
  scm: git

# 🔴 Plusieurs sources (local + Galaxy)
- name: local-firewall
  src: /opt/shared/roles/firewall     # Path local
```

### 💾 Étape 3 : Installer les Rôles

```bash
# Installation standard
ansible-galaxy role install -r roles/requirements.yml -p ./roles

# ✅ Options importantes :
# -r              Depuis fichier requirements
# -p ./roles      Chemin LOCAL (isolation projet)
# --force         Re-installer (maj)

# Vérification
ansible-galaxy role list
# Installed role version
# geerlingguy.nginx                  3.1.4
# geerlingguy.mysql                  5.1.2
```

### 🎬 Étape 4 : Utiliser dans un Playbook

```yaml
---
# playbooks/site.yml

- hosts: webservers
  become: yes

  roles:
    # Syntax simple (Ansible cherche dans ./roles)
    - geerlingguy.nginx
    - geerlingguy.mysql

  # Ou avec vars d'override
  roles:
    - role: geerlingguy.nginx
      vars:
        nginx_port: 8080
        nginx_user: nginx
```

### 🛡️ Best Practices - Rôles

| Pratique | Pourquoi | Comment |
|----------|----------|---------|
| **✅ Fixer les versions** | Reproductibilité, rollback | `version: "3.1.4"` |
| **✅ Utiliser `-p ./roles`** | Isolation projet | Jamais installer globalement |
| **✅ Vérifier la source** | Sécurité | Chercher auteur fiable (geerlingguy, Red Hat) |
| **✅ Tester avant prod** | Éviter surprises | VM locale avec Vagrant/VBox |
| **❌ Éviter "latest"** | Versions cassantes | Toujours fixer explicitement |
| **❌ Pas d'install manuelle** | Non-reproductible | Toujours via requirements.yml |

### 📊 Graphique : Workflow Rôles

```
1. Chercher (Galaxy search)
        ↓
2. Définir (roles/requirements.yml)
        ↓
3. Installer (-p ./roles)
        ↓
4. Vérifier (ansible-galaxy role list)
        ↓
5. Utiliser (playbook → roles: […])
        ↓
6. Tester (ansible-playbook -i inventory playbooks/site.yml)
```

---

## 5. Consommer des Collections

### 📦 Qu'est-ce qu'une Collection ?

Collection = **Paquet Ansible complet** (modules + rôles + plugins) pour un domaine.

**Exemples courants** :

| Collection | Utilité |
|------------|---------|
| `ansible.posix` | Modules système Posix (synchronize, firewalld) |
| `community.general` | Outils généraux (apt, service, git) |
| `amazon.aws` | API AWS (EC2, S3, RDS) |
| `community.docker` | Docker & container ops |
| `cisco.ios` | Équipements Cisco |

### 🔍 Chercher une Collection

```bash
ansible-galaxy collection search docker

# Résultats
# Name                                    Downloads
# community.docker                        1.2M
# glitchfiend.docker-compose              50K
# …
```

### 📥 Définir les Dépendances

**Créer `collections/requirements.yml`** :

```yaml
---
collections:
  # 🔵 Collection community (fiable)
  - name: ansible.posix
    version: "1.5.4"
    source: https://galaxy.ansible.com

  # 🟢 Versioning range (maj compatible)
  - name: community.general
    version: ">=7.0.0,<8.0.0"

  # 🟡 Collection AWS (vendor)
  - name: amazon.aws
    version: "6.1.0"

  # 🔴 Collection privée (URL custom)
  - name: mycompany.internal
    source: https://galaxy.mycompany.com
    version: "1.0.0"
```

### 💾 Installer les Collections

```bash
# Installation
ansible-galaxy collection install -r collections/requirements.yml \
  -p ./collections

# ✅ Options :
# -r                  Depuis fichier requirements
# -p ./collections    Chemin local

# Vérification
ansible-galaxy collection list
# Collection                   Version
# amazon.aws                   6.1.0
# ansible.posix                1.5.4
# community.general            7.2.0
```

### 🎬 Utiliser dans un Playbook

```yaml
---
# playbooks/site.yml

- hosts: all
  gather_facts: yes

  tasks:
    # 🔵 Module depuis collection (namespace.collection.module)
    - name: Synchroniser fichiers (ansible.posix)
      ansible.posix.synchronize:
        src: /local/path/
        dest: /remote/path/

    # 🟢 Module community.general
    - name: Installer paquet (community.general)
      community.general.apt:
        name: nginx
        state: present

    # 🟡 Module AWS (amazon.aws)
    - name: Créer instance EC2
      amazon.aws.ec2_instances:
        image_id: ami-0c55b159cbfafe1f0
        instance_type: t2.micro
```

### 📊 Modules vs Rôles

| Aspect | Module | Rôle (via Collection) |
|--------|--------|----------------------|
| **Granularité** | Une action atomique | Séquence complète |
| **Import** | Direct : `module_name:` | Via `roles:` ou `include_role:` |
| **Exemple** | `apt:` installer paquet | `geerlingguy.nginx:` configurer entièrement |

### 🛡️ Best Practices - Collections

| Pratique | Pourquoi | Comment |
|----------|----------|---------|
| **✅ Installer via requirements** | Versioning, CI/CD | `collections/requirements.yml` |
| **✅ Utiliser namespace complet** | Clarté, éviter conflits | `ansible.posix.synchronize:` |
| **✅ Vérifier documentation** | Éviter surprises | `ansible-doc collection_name` |
| **❌ Installer "latest"** | Dépendances cassantes | Toujours fixer version |
| **❌ Mélanger sources** | Sécurité, maintenance | Une source par collection |

---

## 6. Créer un Rôle Propre avec ansible-galaxy init

### 🏗️ Générer le Squelette

```bash
# Créer un rôle complet
cd mon-projet/roles
ansible-galaxy init mon-role

# Résultat
mon-role/
├── defaults/main.yml
├── files/
├── handlers/main.yml
├── meta/main.yml
├── tasks/main.yml
├── templates/
├── tests/test.yml
├── vars/main.yml
└── README.md
```

### 📂 Rôle de Chaque Dossier

| Dossier | Utilité | Exemple |
|---------|---------|---------|
| **tasks/** | ⚙️ Logique principale | Installer paquets, configurer |
| **defaults/** | 🔧 Variables modifiables | Port, user, packages (PRIORITÉ FAIBLE) |
| **vars/** | 🔒 Variables internes | Constantes système (PRIORITÉ HAUTE) |
| **handlers/** | 🔔 Actions déclenchées | Restart service (via `notify:`) |
| **templates/** | 📝 Configs dynamiques | nginx.conf.j2 avec `{{ port }}` |
| **files/** | 📄 Fichiers statiques | Scripts, clés SSH |
| **meta/** | 📋 Métadonnées | Infos rôle, dépendances Galaxy |
| **tests/** | ✅ Tests Molecule | Scénarios de test |

### 🎯 Exemple Rôle Nginx (Simplifié)

#### tasks/main.yml (CŒUR du rôle)

```yaml
---
# Installer Nginx
- name: Installer Nginx
  apt:
    name: nginx
    state: present
    update_cache: yes
  notify: restart nginx

# Déployer config depuis template
- name: Configurer nginx.conf
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    backup: yes
  notify: restart nginx

# Activer au boot
- name: Activer service Nginx
  systemd:
    name: nginx
    state: started
    enabled: yes

# Tags pour granularité
- name: Tâche optionnelle (tag)
  debug:
    msg: "Ceci peut être skippé"
  tags: [optional]
```

#### defaults/main.yml (Configuration utilisateur)

```yaml
---
# Variables surchargeables (priorité FAIBLE)

nginx_port: 80
nginx_user: www-data
nginx_packages:
  - nginx
  - nginx-modules-geoip

nginx_sites_enabled: true
nginx_ssl_enabled: false
nginx_ssl_cert: /etc/ssl/certs/server.crt
```

#### handlers/main.yml (Actions déclenchées)

```yaml
---
# Actions exécutées via notify:

- name: restart nginx
  systemd:
    name: nginx
    state: restarted
  listen: "restart nginx"

- name: reload nginx
  systemd:
    name: nginx
    state: reloaded
  listen: "reload nginx"
```

#### templates/nginx.conf.j2 (Config dynamique)

```jinja2
# Nginx configuration (Jinja2 template)

http {
    server {
        listen {{ nginx_port }};
        server_name _;
        
        location / {
            root /var/www/html;
            index index.html;
        }
    }
}
```

#### meta/main.yml (Métadonnées Galaxy)

```yaml
---
galaxy_info:
  author: "Ton Nom"
  description: "Rôle Nginx sécurisé pour production"
  min_ansible_version: "2.9"
  
  platforms:
    - name: Debian
      versions:
        - "10"
        - "11"
    - name: Ubuntu
      versions:
        - "20.04"
        - "22.04"
  
  tags:
    - web
    - nginx
    - http-server

dependencies:
  # Rôles requis (optionnel)
  - role: geerlingguy.firewall
    firewall_allowed_tcp_ports:
      - "80"
      - "443"
```

#### README.md (Documentation)

```markdown
# Rôle Nginx

## Utilité
Installer et configurer Nginx de manière sécurisée.

## Variables

| Variable | Défaut | Description |
|----------|--------|-------------|
| `nginx_port` | 80 | Port d'écoute |
| `nginx_user` | www-data | Utilisateur |
| `nginx_ssl_enabled` | false | Activer SSL/TLS |

## Exemple

\`\`\`yaml
- hosts: webservers
  roles:
    - role: mon-nginx
      vars:
        nginx_port: 8080
        nginx_ssl_enabled: true
\`\`\`

## Dépendances
- geerlingguy.firewall

## License
MIT
```

### 🔄 Variables : defaults vs vars

#### defaults/ (Surchargeables)

```yaml
# defaults/main.yml - UTILISATEUR peut override

nginx_port: 80                  # L'user peut changer

# Via inventaire
# [webservers:vars]
# nginx_port=8080

# Ou extra-vars
# -e nginx_port=9000
```

**Priorité FAIBLE** : Facilement surchargeables (inventaire > group_vars > host_vars > extra-vars).

#### vars/ (Fortes)

```yaml
# vars/main.yml - Constantes internes

nginx_conf_path: /etc/nginx     # Path système (ne change pas)
nginx_log_path: /var/log/nginx  # Path système
nginx_internal_id: "v2.1"       # Marqueur interne

# ❌ L'user ne peut pas override facilement
```

**Priorité HAUTE** : Rarement surchargées, réservées aux constantes internes.

### 💡 Règle d'Or

> **90% des vars en `defaults/` pour flexibilité.**  
> **`vars/` seulement pour les constantes internes.**

---

## 7. Bonnes Pratiques Avancées

### 🔐 1. Sécurité & Confiance

#### ✅ Vérifier les Sources

```bash
# Avant d'installer, vérifier :
# 1. Auteur fiable (badge Galaxy)
# 2. Score Galaxy élevé
# 3. Issues/PRs actives
# 4. Communauté active

# Chercher sur https://galaxy.ansible.com
ansible-galaxy search nginx --author geerlingguy
```

#### 🛡️ Auditer les Rôles

```bash
# Utiliser ansible-lint (linter Ansible)
ansible-lint roles/mon-role

# Résultats
# roles/mon-role/tasks/main.yml:5:0: [E301] Commands
#   should not change things if nothing needs doing

# Fixer issues
ansible-lint --fix roles/mon-role
```

#### 🔒 Gérer les Secrets

```yaml
# ❌ JAMAIS en dur
- name: Configurer DB
  mysql_user:
    name: root
    password: "supersecret"     # ❌ MAUVAIS !!!

# ✅ Utiliser Ansible Vault
# crypter les variables sensibles
ansible-vault encrypt group_vars/all.yml

# ✅ Ou variable externe
- name: Configurer DB
  mysql_user:
    name: root
    password: "{{ db_root_password }}"  # De Vault ou CI/CD
```

### 🚀 2. Versioning & Reproductibilité

#### SemVer (Semantic Versioning)

```
Version format : MAJOR.MINOR.PATCH

1.0.0    = v1 (breaking changes possible)
1.2.0    = v1.2 (features compatibles)
1.2.5    = v1.2.5 (bugfixes)
```

#### Strategy requirements.yml

```yaml
---
# Stratégie 1 : Version exacte (production)
- name: geerlingguy.nginx
  version: "3.1.4"              # Pas de surprise

# Stratégie 2 : Range sémantique (dev)
- name: geerlingguy.nginx
  version: ">=3.0.0,<4.0.0"     # Maj mineures OK
  
# Stratégie 3 : Latest (DANGEREUX)
# - name: geerlingguy.nginx
#   (pas de version = latest → risque)
```

#### 📝 Lockfile (CI/CD)

```bash
# Générer lockfile (versions exactes actuelle)
ansible-galaxy role install -r roles/requirements.yml \
  --force-with-deps \
  > roles/requirements.lock.yml

# En CI/CD : utiliser lockfile pour reproductibilité exacte
ansible-galaxy role install -r roles/requirements.lock.yml \
  -p ./roles
```

### 🧪 3. Tests avec Molecule

#### Initialiser tests

```bash
# Installer Molecule
pip install molecule molecule-docker

# Initialiser tests rôle
cd roles/mon-role
molecule init scenario -d docker

# Structure
molecule/
├── converge.yml          # Playbook de test
├── molecule.yml          # Config Molecule
└── verify.yml            # Vérifications post-test
```

#### Exécuter tests

```bash
# Test complet
cd roles/mon-role
molecule test              # Create → Converge → Verify → Destroy

# Étapes individuelles
molecule create            # Créer VM Docker
molecule converge          # Appliquer playbook
molecule verify            # Vérifier résultat
molecule destroy           # Nettoyer
```

#### Exemple molecule.yml

```yaml
---
driver:
  name: docker

platforms:
  - name: ubuntu-20.04
    image: ubuntu:20.04

provisioner:
  name: ansible
  playbooks:
    converge: converge.yml

verifier:
  name: ansible
  playbooks:
    verify: verify.yml
```

### 📦 4. Publication sur Galaxy

#### Préparer le rôle

```bash
# Remplir meta/main.yml (voir section 6.4)
# Ajouter README.md détaillé
# Tester avec Molecule
# Tagguer dans Git

git tag v1.0.0
git push origin v1.0.0
```

#### Publier sur Galaxy

```bash
# 1. S'identifier (compte Galaxy requis)
ansible-galaxy login

# 2. Importer depuis GitHub
# Via interface https://galaxy.ansible.com
# → New → Import from GitHub

# 3. Rôle visible publiquement
# → https://galaxy.ansible.com/tonnom/mon-role
```

---

## 8. Résumé & Checklist Rapide

### 📌 Concepts Clés Résumés

| Concept | Clé | Lien |
|---------|-----|------|
| **ansible-galaxy** | Outil CLI + plateforme web | Gère dépendances Ansible |
| **Rôles** | Briques fines réutilisables | Installer/configurer service |
| **Collections** | Paquets complets (rôles + modules) | Outils transversaux |
| **requirements.yml** | Déclaration dépendances | Reproductibilité garantie |
| **Structure projet** | Isolation locale par projet | Pas de /etc/ansible global |
| **Best practice** | Version fixée dans requirements | Rollback & CI/CD fiables |

### 🎯 Étapes Clés (Flow)

```
CONSOMMER RÔLES/COLLECTIONS
1. Chercher → ansible-galaxy search
2. Définir → roles/requirements.yml, collections/requirements.yml
3. Installer → ansible-galaxy install -r -p ./local
4. Utiliser → playbook roles: […]
5. Tester → ansible-playbook -i inventory

CRÉER UN RÔLE
1. Init → ansible-galaxy init mon-role
2. Remplir → tasks/, defaults/, handlers/, templates/
3. Tester → molecule test
4. Publier → Galaxy import (optionnel)
```

### ✅ Checklist - Nouveau Projet

```
☐ Créer structure (roles/, collections/, ansible.cfg)
☐ Écrire roles/requirements.yml (avec versions)
☐ Écrire collections/requirements.yml (si besoin)
☐ Installer : ansible-galaxy install -r roles/requirements.yml -p ./roles
☐ Tester playbook : ansible-playbook -i inventory playbooks/site.yml
☐ Valider : ansible-lint, molecule test
☐ Versionner Git : init repo, commit, tag v1.0.0
☐ Documentation : README.md projet + rôles
```

### ✅ Checklist - Nouveau Rôle

```
☐ Générer : ansible-galaxy init mon-role
☐ Écrire tasks/main.yml (cœur logique)
☐ Écrire defaults/main.yml (vars surchargeables)
☐ Écrire handlers/main.yml (actions déclenchées)
☐ Ajouter templates/ et files/ (si besoin)
☐ Remplir meta/main.yml (info Galaxy)
☐ Documenter README.md (utilité, vars, exemples)
☐ Tester : molecule test
☐ Fixer ansible-lint : ansible-lint --fix
☐ Publier : Galaxy import (optionnel)
```

### ✅ Checklist - Sécurité

```
☐ Jamais de secrets en dur (Vault, CI/CD env)
☐ Vérifier source rôle (auteur, score Galaxy)
☐ Linter : ansible-lint avant commit
☐ Tags pour granularité (--tags, --skip-tags)
☐ Tester playbook en env local d'abord
☐ Versions fixées dans requirements.yml
☐ Audit régulier rôles installés
```

---

## 🎓 Ressources Complémentaires

| Ressource | Lien |
|-----------|------|
| **Doc Officielle** | https://docs.ansible.com/projects/ansible/latest/galaxy/ |
| **Galaxy Plateforme** | https://galaxy.ansible.com |
| **Rôles Recommandés** | `geerlingguy.*` (Docker, Nginx, MySQL, etc.) |
| **ansible-lint** | https://ansible-lint.readthedocs.io |
| **Molecule Docs** | https://molecule.readthedocs.io |

---

## 💬 Résumé Final

**ansible-galaxy** = Pouvoir des dépendances réutilisables en Ansible.

🎯 **Maîtrises maintenant** :
- ✅ Consommer rôles/collections proprement
- ✅ Créer rôles standardisés
- ✅ Gérer versions et reproductibilité
- ✅ Intégrer CI/CD et tests
- ✅ Sécuriser tes automatisations

🚀 **Prochaines étapes** :
1. Crée un projet neuf (utilise la checklist)
2. Teste avec Molecule
3. Partage tes rôles sur Galaxy
4. Itère, améliore, documente

> **Bonne automatisation !** 🔧✨

---

**Guide créé** : 2025-11-28  
**Niveau** : Débutant → Intermédiaire → Avancé  
**Licence** : CC BY-SA 4.0