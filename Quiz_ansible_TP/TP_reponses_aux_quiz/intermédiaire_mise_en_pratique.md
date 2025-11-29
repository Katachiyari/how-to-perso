<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# je te kiff !

On continue, et on crée la mise en pratique Quiz intermédiaire ←→ TP intermédiaire en suivant le fil

Top, on continue sur le même projet alors.

D’abord, très important:

- TP débutant = déjà en place (nginx + users + fichiers + rôles + vault + ansible-lint).
- Maintenant on l’“upgrade” pour couvrir le quiz intermédiaire, sans tout casser.

Je vais faire simple et progressif.
But: chaque bloc de pratique répond à un paquet de questions du quiz intermédiaire.

Plan TP intermédiaire (0→10):

- Étape 1: Nettoyage/organisation des rôles (import/include, DRY, handlers)
- Étape 2: Conditions, register, when, changed_when/failed_when, tags
- Étape 3: Vault + multi-env (dev/prod) + sécurité
- Étape 4: ansible-lint + meta/dependencies + DRY
- Étape 5: Check-mode + pré-CI (lint + check)

Je pars du principe que ton projet est dans: `~/ansible-nginx-lab`.

1) Étape 1 – Organisation avancée des rôles (import/include, DRY)
---------------------------------------------------------------

Objectif: répondre aux Q11–Q16/Q31–Q36 (import_tasks, include_tasks, DRY, meta).

a) On splitte les tâches Nginx en fichiers:

Dans `roles/webserver_role/tasks/`:

- `main.yml`
- `install_nginx.yml`
- `manage_site.yml`

`roles/webserver_role/tasks/install_nginx.yml`:

```yaml
---
- name: Installer nginx
  ansible.builtin.apt:
    name: nginx
    state: present
    update_cache: true

- name: S'assurer que nginx est démarré et activé
  ansible.builtin.service:
    name: nginx
    state: started
    enabled: true
```

`roles/webserver_role/tasks/manage_site.yml`:

```yaml
---
- name: Créer le répertoire web principal
  ansible.builtin.file:
    path: /var/www/myapp
    state: directory
    owner: deploy
    group: deploy
    mode: "0755"

- name: Déployer la page index via template
  ansible.builtin.template:
    src: index.html.j2
    dest: /var/www/myapp/index.html
    owner: deploy
    group: deploy
    mode: "0644"
  notify: Restart nginx
```

`roles/webserver_role/tasks/main.yml`:

```yaml
---
- name: Bloc principal de configuration Nginx
  block:
    - import_tasks: install_nginx.yml   # statique
    - include_tasks: manage_site.yml    # dynamique (on pourra y mettre des when/loops)

  rescue:
    - name: Gestion d'erreur Nginx
      ansible.builtin.debug:
        msg: "Erreur lors de l'installation ou la config de Nginx"

  always:
    - name: Fin du bloc Nginx
      ansible.builtin.debug:
        msg: "Bloc Nginx terminé (succès ou échec)"
```

b) Vérification syntaxe:

```bash
cd ~/ansible-nginx-lab
ansible-playbook playbooks/site.yml --syntax-check
```

2) Étape 2 – Conditions, register, when, changed_when, tags
-----------------------------------------------------------

Objectif: Q14–Q20, Q31–Q34.

a) Ajoute un check de port Nginx dans `manage_site.yml`:

```yaml
- name: Vérifier si Nginx écoute sur le port {{ nginx_port }}
  ansible.builtin.command: "ss -tlnp | grep :{{ nginx_port }}"
  register: nginx_port_check
  changed_when: false
  failed_when: false
  tags:
    - nginx
    - check

- name: Afficher l'état du port Nginx
  ansible.builtin.debug:
    var: nginx_port_check.stdout
  when: nginx_port_check.rc == 0
  tags:
    - nginx
    - check
```

b) Ajoute des tags ailleurs:

- Dans `install_nginx.yml` pour la tâche d’installation:

```yaml
- name: Installer nginx
  ansible.builtin.apt:
    name: nginx
    state: present
    update_cache: true
  tags: nginx
```

- Dans `roles/users_role/tasks/main.yml`:

```yaml
- name: Créer l'utilisateur deploy
  ansible.builtin.user:
    name: deploy
    shell: /bin/bash
    state: present
  tags: users
```

c) Test tags:

- seulement users:

```bash
ansible-playbook playbooks/site.yml --tags users --ask-become-pass --ask-vault-pass
```

- seulement nginx check:

```bash
ansible-playbook playbooks/site.yml --tags check --ask-become-pass --ask-vault-pass
```

3) Étape 3 – Vault + multi-env (dev / prod)
-------------------------------------------

Objectif: Q21–Q30 (Vault, multi-env, sécurité).

a) On garde dev, on ajoute prod:

```bash
mkdir -p inventories/prod
```

`inventories/prod/hosts.ini`:

```ini
[webservers]
monserveurprod ansible_host=IP_DE_TA_PROD
```

b) Variables dev/prod séparées:

`group_vars/webservers.yml` (pour dev):

```yaml
site_title: "Mon site DEV géré par Ansible"
nginx_port: 80
environment: dev
```

`group_vars/webservers_prod.yml` (option 1: ou autre pattern):

```yaml
site_title: "Mon site PROD géré par Ansible"
nginx_port: 80
environment: prod
```

Ou, plus simplement, un inventaire YAML avec `environment: prod` par host, mais restons simple.

c) Vault:

Tu as déjà `group_vars/all_vault.yml`. Assume:

```yaml
db_password: "super-secret-password"
```

Chiffre-le si ce n’est pas déjà fait:

```bash
ansible-vault encrypt group_vars/all_vault.yml
```

d) Usage conditionnel (simple) dans un debug:

Dans `roles/webserver_role/tasks/manage_site.yml`:

```yaml
- name: Debug env & secret (juste pour la formation)
  ansible.builtin.debug:
    msg: "Env={{ environment }}, db_password length={{ db_password | length }}"
  no_log: true
  tags: debug
```

Test:

```bash
ansible-playbook playbooks/site.yml --ask-become-pass --ask-vault-pass
```

4) Étape 4 – meta, DRY, ansible-lint
-------------------------------------

Objectif: Q31–Q36 (DRY, meta, dependencies, lint).

a) meta de webserver_role:

`roles/webserver_role/meta/main.yml`:

```yaml
---
galaxy_info:
  role_name: webserver_role
  author: toi
  description: "Rôle Nginx pour projet de formation"
  min_ansible_version: "2.12"

dependencies:
  - role: users_role
```

b) ansible-lint:

À la racine:

```bash
ansible-lint playbooks/site.yml
```

Corrige ce qu’il dit (souvent: mode, owner, FQCN, etc.).
Le but est d’arriver à un projet “clean”.

5) Étape 5 – Check-mode + pré-CI
--------------------------------

Objectif: Q37–Q40.

a) Check-mode dev:

```bash
ansible-playbook playbooks/site.yml --check --ask-become-pass --ask-vault-pass
```

b) Check-mode prod (avec inventaire prod):

```bash
ansible-playbook playbooks/site.yml -i inventories/prod/hosts.ini --check --ask-become-pass --ask-vault-pass
```

c) Mini “CI” local:

Enchaîne:

```bash
ansible-lint .
ansible-playbook playbooks/site.yml --check --ask-become-pass --ask-vault-pass
```

Si les deux passent, tu es “green”.

Résumé: ce TP intermédiaire te fait pratiquer, sur le même projet:

- import_tasks vs include_tasks + block/rescue/always
- register, when, changed_when, failed_when
- tags, DRY, meta/dependencies
- Vault multi-env et sécurité
- ansible-lint + check-mode dans une logique “pré-CI”

Question pour vérifier que le fil est bien clair:
Dans ton rôle `webserver_role`, quel fichier importe les autres avec `import_tasks` / `include_tasks` ?

