<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# peux tu faire la même chose pour le niveau intermédiaire, en reprenant le T.P du niveau débutant, donc, une évolution. Pour garder le fil.

On va faire une vraie **suite** du TP débutant, en restant sur ton mini-projet Nginx + bonnes pratiques. On va cette fois couvrir toutes les **questions intermédiaires** (Q11–Q25) en faisant évoluer ton projet.

Rappel: on est au Step 2 de notre lesson plan global (niveau intermédiaire).

***

## 🎯 Objectif intermédiaire

À partir de ton projet débutant `~/ansible-training`, on va :

- introduire **un rôle** `webserver_role`
- utiliser **group_vars**
- ajouter **handlers**
- utiliser **copy/template**
- jouer avec **when**, **tags**, **register**
- utiliser **ansible-vault**
- exécuter un **ad-hoc command**

Je te donne tout pas à pas.

***

## 1️⃣ Structurer en rôle (Q11, Q16)

On va transformer ton playbook Nginx en **rôle**.

1. Place-toi dans le projet:
```bash
cd ~/ansible-training
mkdir -p roles/webserver_role/{tasks,handlers,templates}
```

2. Crée `roles/webserver_role/tasks/main.yml`:
```yaml
---
- name: Installer Nginx
  ansible.builtin.apt:
    name: nginx
    state: present
    update_cache: yes

- name: Déployer page index
  ansible.builtin.template:
    src: index.html.j2
    dest: /var/www/html/index.html
    owner: www-data
    group: www-data
    mode: "0644"
  notify: Restart nginx

- name: S'assurer que Nginx est démarré
  ansible.builtin.service:
    name: nginx
    state: started
    enabled: yes
```

3. Crée le handler: `roles/webserver_role/handlers/main.yml` (Q15)
```yaml
---
- name: Restart nginx
  ansible.builtin.service:
    name: nginx
    state: restarted
```

4. Crée un template simple: `roles/webserver_role/templates/index.html.j2` (Q14)
```html
<!doctype html>
<html>
  <head><title>{{ site_title }}</title></head>
  <body>
    <h1>Bienvenue sur {{ site_title }}</h1>
    <p>Serveur : {{ inventory_hostname }}</p>
  </body>
</html>
```


***

## 2️⃣ Variables \& group_vars (Q12, Q13)

1. Crée `group_vars/webservers.yml`:
```bash
mkdir -p group_vars
```

```yaml
# group_vars/webservers.yml
site_title: "Mon site Dev Ansible"
nginx_port: 80
```

2. Nouveau playbook `playbooks/site.yml`:
```yaml
---
- name: Stack web complète
  hosts: webservers
  become: true

  roles:
    - role: webserver_role
```

Ici tu as:

- **Q11**: rôle
- **Q12**: `group_vars`
- **Q13**: si plus tard tu déclares `site_title` dans le playbook, il écrasera celui de `group_vars`.

***

## 3️⃣ Vault + fichier vars chiffré (Q17)

1. Crée un fichier sensible pour dev (ex: mot de passe DB):
```bash
mkdir -p group_vars
ansible-vault create group_vars/all_vault.yml
```

Mets par exemple:

```yaml
db_password: "super-secret"
```

Note le mot de passe vault utilisé.

2. Utilise-le dans le rôle (juste en debug pour l’instant):

Ajoute à la fin de `roles/webserver_role/tasks/main.yml`:

```yaml
- name: Afficher (en debug) qu'on a bien une variable chiffrée
  ansible.builtin.debug:
    msg: "Mot de passe DB chargé (longueur={{ db_password | length }})"
  no_log: true
```

Pour lancer:

```bash
ansible-playbook playbooks/site.yml --ask-become-pass --ask-vault-pass
```


***

## 4️⃣ Conditions, register, tags, ad-hoc (Q18–Q25)

1. **Syntax check** (Q18):
```bash
ansible-playbook playbooks/site.yml --syntax-check
```

2. Ajoute une tâche conditionnelle avec `when` + `register` (Q19, Q22):

Dans `roles/webserver_role/tasks/main.yml`, avant le handler debug:

```yaml
- name: Vérifier si Nginx écoute sur le port {{ nginx_port }}
  ansible.builtin.command: "ss -tlnp | grep :{{ nginx_port }}"
  register: nginx_port_check
  changed_when: false
  failed_when: false
  tags: check
```

Ensuite:

```yaml
- name: Afficher l'état du port Nginx
  ansible.builtin.debug:
    var: nginx_port_check.stdout
  when: nginx_port_check.rc == 0
  tags: check
```

3. Utilisation des **tags** (Q24):

Tu peux lancer uniquement les checks:

```bash
ansible-playbook playbooks/site.yml --tags check --ask-become-pass --ask-vault-pass
```

4. **run_once / limit / ad-hoc** (Q21, Q23, Q25)

- Ad-hoc:

```bash
ansible webservers -m ansible.builtin.command -a "uptime"
```

- `run_once` (ajoute une tâche dans tasks/main.yml):

```yaml
- name: Tâche exécutée une seule fois
  ansible.builtin.debug:
    msg: "Cette tâche ne s'exécute qu'une fois"
  run_once: true
```


***

## 5️⃣ Récap: comment ça couvre l’intermédiaire

Tu as maintenant utilisé en pratique:

- Q11 rôle → `roles/webserver_role`
- Q12 group_vars → `group_vars/webservers.yml`
- Q13 priorité → tu peux tester en redéfinissant `site_title` dans le playbook
- Q14 copy vs template → tu utilises `template`
- Q15 handler → `Restart nginx`
- Q16 dépendances rôle → (on pourra les ajouter dans `meta/` plus tard)
- Q17 vault → `group_vars/all_vault.yml` chiffré
- Q18 syntax-check → `--syntax-check`
- Q19 when → `when: nginx_port_check.rc == 0`
- Q20 FQCN → `ansible.builtin.*` partout
- Q21 pas de shell inutile → usage de modules dédiés + `command` avec contrôle
- Q22 register → `nginx_port_check`
- Q23 limit/run_once → `run_once: true`
- Q24 tags → `--tags check`
- Q25 ad-hoc → `ansible webservers -m ansible.builtin.command -a "uptime"`

***

Question pour vérifier que tu suis bien le fil:
Est-ce que ton `ansible-playbook playbooks/site.yml --syntax-check` passe sans erreur avec cette nouvelle structure (rôles + group_vars + vault), ou tu as un message d’erreur particulier ?
<span style="display:none">[^1][^10][^2][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://syslearn.fr/ansible-son-fonctionnement/

[^2]: https://xavki.blog/faire-son-premier-playbook-avec-ansible/

[^3]: https://blog.stephane-robert.info/docs/infra-as-code/gestion-de-configuration/ansible/

[^4]: https://www.reddit.com/r/redhat/comments/1oaud0d/what_are_some_good_resources_for_getting_started/

[^5]: https://docs.rockylinux.org/10/fr/books/learning_ansible/02-advanced/

[^6]: https://www.redhat.com/fr/topics/automation/what-is-an-ansible-rulebook

[^7]: https://techblog.deepki.com/debuter-avec-ansible/

[^8]: https://linux.goffinet.org/ansible/presentation-produit-ansible/

[^9]: https://www.it-connect.fr/ansible-pour-gerer-des-serveurs-linux/

[^10]: https://pierreau.fr/pro/Share/DevOps.Ansible.pdf

