<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# les deux, mon capitaine :

détaille chaque mini-fichier YAML associé
un focus précis : boucles, blocks, asynchrone

On garde le même projet et on passe en mode “atelier avancé”, mais toujours guidé.

Je récapitule vite le contexte, puis on détaille :

- chaque mini-fichier YAML manquant,
- puis un focus clair sur : **boucles**, **blocks**, **asynchrone**.

Si tu me dis après que tu veux encore plus, on creusera chaque thème.

***

## 1. Rappel d’arborescence

On part sur :

```text
ansible-training/
├─ ansible.cfg
├─ inventories/
│   └─ dev/hosts.ini
├─ group_vars/
│   ├─ webservers.yml
│   └─ all_vault.yml
├─ playbooks/
│   ├─ deploy_web.yml      # niveau débutant
│   └─ site.yml            # intermédiaire/avancé
└─ roles/
   └─ webserver_role/
      ├─ tasks/
      │  ├─ main.yml
      │  ├─ install_nginx.yml
      │  └─ manage_site.yml
      ├─ handlers/main.yml
      ├─ templates/index.html.j2
      └─ meta/main.yml
```

Je te détaille maintenant tous les fichiers.

***

## 2. Fichiers du rôle webserver_role

### 2.1 `roles/webserver_role/tasks/install_nginx.yml`

```yaml
---
- name: Installer les paquets nécessaires
  ansible.builtin.apt:
    name:
      - nginx
    state: present
    update_cache: yes

- name: S'assurer que Nginx est démarré et activé
  ansible.builtin.service:
    name: nginx
    state: started
    enabled: yes
```


### 2.2 `roles/webserver_role/tasks/manage_site.yml`

(ici on met boucles, templates, register, when, tags)

```yaml
---
- name: Créer les répertoires web pour plusieurs sites
  ansible.builtin.file:
    path: "/var/www/{{ item }}/"
    state: directory
    owner: www-data
    group: www-data
    mode: "0755"
  loop: "{{ web_sites }}"
  tags: sites

- name: Déployer la page d'accueil principale sur le site 'default'
  ansible.builtin.template:
    src: index.html.j2
    dest: "/var/www/html/index.html"
    owner: www-data
    group: www-data
    mode: "0644"
  notify: Restart nginx
  tags: site_main

- name: Vérifier si Nginx écoute sur le port {{ nginx_port }}
  ansible.builtin.command: "ss -tlnp | grep :{{ nginx_port }}"
  register: nginx_port_check
  changed_when: false
  failed_when: false
  tags: check

- name: Afficher l'état du port Nginx
  ansible.builtin.debug:
    var: nginx_port_check.stdout
  when: nginx_port_check.rc == 0
  tags: check

- name: Tâche exécutée une seule fois (run_once)
  ansible.builtin.debug:
    msg: "Cette tâche est exécutée une seule fois pour tout le play."
  run_once: true
  tags: info
```


### 2.3 `roles/webserver_role/tasks/main.yml`

(avec block / rescue / always, imports/includes)

```yaml
---
- name: Bloc principal de configuration Nginx
  block:
    - import_tasks: install_nginx.yml      # statique
    - include_tasks: manage_site.yml       # dynamique

  rescue:
    - name: Gestion d'erreur si l'installation échoue
      ansible.builtin.debug:
        msg: "ERREUR: L'installation ou la configuration Nginx a échoué. Pense à vérifier les logs."

  always:
    - name: Toujours afficher un message de fin de bloc
      ansible.builtin.debug:
        msg: "Bloc Nginx terminé (succès ou échec)."
```


### 2.4 `roles/webserver_role/handlers/main.yml`

```yaml
---
- name: Restart nginx
  ansible.builtin.service:
    name: nginx
    state: restarted
```


### 2.5 `roles/webserver_role/templates/index.html.j2`

```html
<!doctype html>
<html>
  <head><title>{{ site_title }}</title></head>
  <body>
    <h1>Bienvenue sur {{ site_title }}</h1>
    <p>Serveur : {{ inventory_hostname }}</p>
    <p>Environnement : {{ environment | default('dev') }}</p>
  </body>
</html>
```


### 2.6 `roles/webserver_role/meta/main.yml` (simple)

```yaml
---
galaxy_info:
  role_name: webserver_role
  author: toi
  description: "Rôle Nginx complet (débutant→avancé)."
  min_ansible_version: "2.12"

dependencies: []
```


***

## 3. Fichiers de variables

### 3.1 `group_vars/webservers.yml`

```yaml
site_title: "Mon site Dev Ansible"
nginx_port: 80

web_sites:
  - site1
  - site2
  - site3
```


### 3.2 `group_vars/all_vault.yml` (chiffré avec Vault en vrai)

Pour l’instant en clair (puis tu feras `ansible-vault encrypt`):

```yaml
db_password: "super-secret"
```


***

## 4. Playbooks

### 4.1 `playbooks/site.yml` (fil rouge actuel)

```yaml
---
- name: Stack web avancée
  hosts: webservers
  become: true
  vars:
    environment: dev
  roles:
    - role: webserver_role
```

Tu peux jouer avec `--tags`, `--check`, etc.

***

## 5. Focus précis : boucles, blocks, asynchrone

### 5.1 Boucles (loops)

Dans `manage_site.yml`, on utilise :

```yaml
- name: Créer les répertoires web pour plusieurs sites
  ansible.builtin.file:
    path: "/var/www/{{ item }}/"
    state: directory
    owner: www-data
    group: www-data
    mode: "0755"
  loop: "{{ web_sites }}"
```

- `web_sites` vient de `group_vars/webservers.yml`.
- Idée d’exercice : ajoute `site4` dans la liste, relance, vois le `changed` uniquement pour ce site.


### 5.2 Blocks (block / rescue / always)

Dans `tasks/main.yml`:

```yaml
- name: Bloc principal de configuration Nginx
  block:
    - import_tasks: install_nginx.yml
    - include_tasks: manage_site.yml
  rescue:
    - name: Gestion d'erreur si l'installation échoue
      ansible.builtin.debug:
        msg: "ERREUR..."
  always:
    - name: Toujours afficher un message de fin de bloc
      ansible.builtin.debug:
        msg: "Bloc Nginx terminé..."
```

- `block`: groupe logique de tâches.
- `rescue`: ce qui se passe si une tâche du block échoue.
- `always`: exécuté quoi qu’il arrive.

Exercice: simule une erreur (ex: mets un mauvais nom de paquet) et regarde comment `rescue` réagit.

### 5.3 Asynchrone (async / poll)

Ajoute dans `playbooks/site.yml` après le rôle :

```yaml
- name: Test asynchrone
  hosts: webservers
  become: true

  tasks:
    - name: Lancer une commande longue en asynchrone
      ansible.builtin.command: "sleep 15 && echo 'Fin tâche longue'"
      async: 30
      poll: 0

    - name: Afficher qu'on ne bloque pas
      ansible.builtin.debug:
        msg: "Le playbook continue sans attendre la fin de la commande."
```

- `async: 30` → timeout max en secondes.
- `poll: 0` → on ne suit pas la tâche, on l’abandonne à l’hôte.

Exercice :

1) Lance ce playbook.
2) Pendant qu’il tourne, vérifie sur la machine que la commande est bien lancée (ex: `ps aux | grep sleep`).

***

Question de vérification pour garder le fil :
As-tu bien créé au moins ces 3 fichiers et réussi un `ansible-playbook playbooks/site.yml --syntax-check` sans erreur ?

- `roles/webserver_role/tasks/main.yml`
- `roles/webserver_role/tasks/install_nginx.yml`
- `roles/webserver_role/tasks/manage_site.yml`
<span style="display:none">[^1][^2][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://spacelift.io/blog/ansible-playbooks

[^2]: https://blog.stephane-robert.info/docs/infra-as-code/gestion-de-configuration/ansible/ecriture-de-playbooks-ansible/

[^3]: https://docs.ansible.com/projects/ansible/latest/getting_started/get_started_playbook.html

[^4]: https://developers.redhat.com/learning/learn:ansible:yaml-essentials-ansible/resource/resources:ansible-yaml-file-syntax-and-structure

[^5]: https://4sysops.com/archives/ansible-playbook-examples/

[^6]: https://www.rix.fr/blog/cours/ansible/ansible-les-playbooks

[^7]: https://supports.uptime-formation.fr/06-ansible/cours2/

[^8]: https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_intro.html

[^9]: https://blog.alphorm.com/structure-playbook-ansible-taches-variables-modules

