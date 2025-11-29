<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# on suit le fil pour répondre aux questions du niveau avancé

Excellent, on poursuit le **fil conducteur** avec la mise en pratique du niveau avancé pour couvrir toutes les questions avancées du quiz.

## 🏗️ Mise en pratique avancée Ansible

_**Fil rouge : Tu construis un projet réel en jouant avec toutes les briques avancées.**_

Nous allons :

- Étendre ton rôle (début/inter) pour y intégrer :
    - blocs, rescue, always
    - includes/imports
    - boucles avancées et lookups
    - inventaire dynamique simulé
    - custom facts, set_fact, filtrages
    - stratégies d’exécution, forks
    - gestion fine de l’idempotence
    - asynchrone, délégation, serial
    - utilisation de collections, galaxy
    - ...et plus, selon toutes les Q26–Q45 !

***

### 📂 Step 1 : Préparer l’environnement avancé

```
ansible-training/
├─ ansible.cfg
├─ inventories/
│   ├─ dev/
│   │   └─ hosts.ini
│   └─ dynamic/   (pour plus tard)
├─ group_vars/
│   └─ all_vault.yml
├─ playbooks/
│   ├─ site.yml
│   └─ extra_checks.yml
├─ roles/
│   └─ webserver_role/ (étendu avancé)
│       ├─ tasks/
│       ├─ handlers/
│       ├─ templates/
│       └─ meta/
│            └─ main.yml
```


***

### 🗂️ Step 2 : Utilisation avancée des rôles et blocs (Q26–Q27, Q45)

Dans `roles/webserver_role/tasks/main.yml` :

```yaml
---
- name: Appliquer bloc principal
  block:
    - import_tasks: install_nginx.yml  # Q26: import_tasks = statique
    - include_tasks: manage_site.yml   # Q26: include_tasks = dynamique

  rescue:
    - name: Message rescue
      ansible.builtin.debug:
        msg: "Nginx installation a échoué. Rollback!"

  always:
    - name: Toujours afficher ce message
      ansible.builtin.debug:
        msg: "Fin du bloc d'installation"
```

Dans `tasks/`, ajoute des fichiers `install_nginx.yml`, `manage_site.yml` pour scinder la logique.

***

### 🔁 Step 3 : Boucles avancées, lookups, facts customisés (Q28, Q40)

#### Boucles avec lookups (import d’utilisateurs via une liste)

Dans `manage_site.yml` :

```yaml
- name: Créer les répertoires web pour les sites multiples
  ansible.builtin.file:
    path: "/var/www/{{ item }}/"
    state: directory
    owner: www-data
    mode: '0755'
  loop: "{{ lookup('file', 'sites.csv').split('\n') }}"
```

Avec `files/sites.csv` contenant :

```
site1
site2
site3
```


#### Définir un facteur custom (Q40)

Dans `/etc/ansible/facts.d/mon_fact.fact` (sur ta VM cible si besoin) :

```ini
[general]
environment=production
```

Dans un play :

```yaml
- name: Charger les facts custom
  setup:
    filter: ansible_local
- debug:
    var: ansible_local.mon_fact.general.environment
```


***

### 🎚️ Step 4 : Inventory dynamique simulé (Q28)

Ajoute un script ou un inventaire YAML dynamique dans `inventories/dynamic/hosts_dynamic.yml` :

```yaml
plugin: yaml
hosts:
  webserver1:
    ansible_host: 127.0.0.1
    environment: prod
  webserver2:
    ansible_host: 127.0.0.2
    environment: dev
```

Déclare-le dans `ansible.cfg` :

```
[defaults]
inventory = inventories/dynamic/hosts_dynamic.yml
```


***

### 🚀 Step 5 : Playbook asynchrone, délégation, serial, forks, stratégie (Q31, Q32, Q35, Q38, Q39)

Dans `playbooks/site.yml` :

```yaml
- hosts: webservers
  become: true
  serial: 1       # Q31 (rolling update)
  strategy: free  # Q38
  max_fail_percentage: 30
  forks: 2        # Q39
  roles:
    - webserver_role

  tasks:
    - name: Déploiement asynchrone
      ansible.builtin.command: "sleep 30 && echo Fini"
      async: 60
      poll: 0

    - name: Tâche déléguée au bastion
      ansible.builtin.debug:
        msg: "Tâche exécutée sur le bastion"
      delegate_to: bastion_host
```


***

### 🛡️ Step 6 : Filtres, set_fact et gestion fine de l’état, templates complexes (Q36–Q37, Q41, Q42–Q44)

Dans un rôle ou un playbook :

```yaml
- name: Création conditionnelle
  ansible.builtin.command: "touch /tmp/fichier"
  args:
    creates: "/tmp/fichier"
  changed_when: false   # Q36

- name: Template avancé
  ansible.builtin.template:
    src: index.html.j2
    dest: /var/www/html/index.html
  vars:
    info_serv: "{{ ansible_facts | to_nice_json }}"

- name: set_fact example
  ansible.builtin.set_fact:
    environment: "{{ ansible_local.mon_fact.general.environment | default('dev') }}"
```


***

### 🗃️ Step 7 : Utilisation des collections, galaxy \& meta (Q41, Q44)

Dans `roles/webserver_role/meta/main.yml` :

```yaml
---
dependencies:
  - role: geerlingguy.mysql
    vars:
      mysql_root_password: "{{ db_password }}"
      mysql_databases:
        - name: myapp
```

Fichier `requirements.yml` à la racine :

```yaml
- name: community.general
  version: ">=7.0.0,<8.0.0"
- name: geerlingguy.mysql
  version: "5.1.0"
```

Installer :

```bash
ansible-galaxy install -r requirements.yml -p roles/
```


***

### 📝 Step 8 : Contrôles, check-mode, ansible-lint, ci (Q35, Q42, Q43)

1. **Dry-run** :
```bash
ansible-playbook playbooks/site.yml --check
```

2. **Lint** :
```bash
ansible-lint playbooks/site.yml
```

3. **Vault/Secrets et combos**
    - Utilise à la fois `ansible-vault` et une lookup sur le plugin community.hashi_vault pour simuler une intégration secrets avancée.

***

### 🚩 Step 9 : Block/rescue/always, run_once, delegates, blue/green (Q45, Q30, Q49)

Dans un play qui manipule du blue/green :

```yaml
- name: Blue/Green deploy
  hosts: webservers
  tasks:
    - block:
        - name: Mettre à jour les serveurs blue
          ansible.builtin.debug:
            msg: "Mise à jour blue"
        - name: Basculement green
          ansible.builtin.debug:
            msg: "Switch green"
      rescue:
        - name: Rollback blue
          ansible.builtin.debug:
            msg: "Rollback blue"
      always:
        - name: Nettoyage blue/green
          ansible.builtin.debug:
            msg: "Fin blue/green"
```


***

## Récapitulatif

Chaque morceau ci-dessus correspond à une ou plusieurs des questions avancées du quiz, mais dans un context unifié, progressif et “projet”.
L’élève peut retrouver la signification pratique de chaque syntaxe/option avancée directement **dans l’évolution du même projet**.

***

**Prochaines étapes pour toi** :
Veux-tu que je détaille chaque mini-fichier YAML associé (ex: un vrai exemple de manage_site.yml, install_nginx.yml, etc.) ou tu préfères t’arrêter sur un focus précis (boucles, blocks, asynchrone, …) pour aller plus profondément sur ces pierres d’angle ?
<span style="display:none">[^1][^2][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://www.skillshare.com/fr/classes/ansible-du-debutant-a-avance/270263143

[^2]: https://www.ambient-it.net/formation/ansible-avance/

[^3]: https://github.com/stephrobert/ansible-training

[^4]: https://docs.formatux.fr/DEVOPS-021-Ansible-Niveau-2-TD-Corrections.pdf

[^5]: https://www.sparks-formation.com/formation-ansible-avance

[^6]: https://blog.stephane-robert.info/docs/infra-as-code/gestion-de-configuration/ansible/

[^7]: https://labex.io/fr/exercises/ansible

[^8]: https://www.lifelong-learning.lu/formation/ansible-avance-custom-v2/en

[^9]: https://www.learnthings.fr/livres-pour-mieux-vous-former-a-ansible/

