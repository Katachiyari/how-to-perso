##Maintenant on va:

- Faire évoluer le TP intermédiaire en consolidant EXACTEMENT les 2–3 briques manquantes:
    - filtres Jinja (listes/dicos, conditions),
    - lookups utiles,
    - un début de “mode CI” propre,
- toujours sur le même fil rouge: nginx + users + fichiers + rôles + vault + ansible-lint.

Je te propose 3 petites évolutions très concrètes du projet (toutes intermédiaires) :

Plan (TP intermédiaire consolidé):

- Step 1: Jinja avancé dans le rôle web (multi-sites, conditions, defaults).
- Step 2: Lookups utiles (env, file, password) intégrés proprement au projet.
- Step 3: Mini “pré-CI” local: lint + check + règles de sécurité simples.

On y va.

Step 1 – Jinja avancé dans le rôle web
--------------------------------------

Objectif: manipuler listes/dicos, conditions, defaults → répondre à plein de questions de tes quizzes.

1) On ajoute la notion de multi-sites web.

Dans `group_vars/webservers.yml`, ajoute:

```yaml
site_title: "Mon site DEV géré par Ansible"
nginx_port: 80
environment: dev

web_sites:
  - name: site1
    root: /var/www/site1
  - name: site2
    root: /var/www/site2
  - name: admin
    root: /var/www/admin
    restricted: true
```

2) On adapte le rôle pour créer ces répertoires.

Dans `roles/webserver_role/tasks/manage_site.yml`, remplace/complète:

```yaml
- name: Créer les répertoires de chaque site
  ansible.builtin.file:
    path: "{{ item.root }}"
    state: directory
    owner: deploy
    group: deploy
    mode: "0755"
  loop: "{{ web_sites }}"
  loop_control:
    label: "{{ item.name }}"
  tags: nginx
```

3) On rend le template plus dynamique.

`roles/webserver_role/templates/index.html.j2`:

```html
<!doctype html>
<html>
  <body>
    <h1>{{ site_title }}</h1>
    <p>Serveur : {{ inventory_hostname }}</p>
    <p>Environnement : {{ environment | default('dev') }}</p>

    <h2>Sites déclarés</h2>
    <ul>
    {% for s in web_sites | default([]) %}
      <li>
        {{ s.name }} ({{ s.root }})
        {% if s.restricted | default(false) %}
          - accès restreint
        {% endif %}
      </li>
    {% endfor %}
    </ul>
  </body>
</html>
```

Points importants:

- `default([])` pour éviter les erreurs si `web_sites` est absent.
- Condition sur `restricted`.
- Boucles sur une liste de dicos (niveau intermédiaire solide).

4) Test:
```bash
cd ~/ansible-nginx-lab
ansible-playbook playbooks/site.yml --ask-become-pass --ask-vault-pass
```

Puis ouvre `/var/www/myapp/index.html` pour voir le rendu.

Question rapide: tu vois bien les 3 sites listés avec “accès restreint” pour admin ?

Step 2 – Lookups intégrés au projet
-----------------------------------

Objectif: utiliser lookups (env, file, password) de façon réaliste dans ton projet.

1) Lookup env: trace d’audit.

On veut afficher le HOME de la machine de contrôle dans un debug (pour te montrer l’usage).

Dans `roles/webserver_role/tasks/manage_site.yml`, ajoute:

```yaml
- name: Debug du HOME du contrôleur (exemple lookup env)
  ansible.builtin.debug:
    msg: "HOME du contrôleur = {{ lookup('env', 'HOME') }}"
  tags: debug
```

2) Lookup file: charger un snippet Nginx.

Crée un fichier:

```bash
mkdir -p snippets
echo "# snippet custom pour Nginx" > snippets/custom.conf
```

Dans `roles/webserver_role/tasks/manage_site.yml`, ajoute:

```yaml
- name: Charger un snippet Nginx depuis un fichier (lookup file)
  ansible.builtin.set_fact:
    custom_snippet: "{{ lookup('file', 'snippets/custom.conf') }}"
  tags: debug

- name: Afficher un extrait du snippet (juste pour vérifier)
  ansible.builtin.debug:
    msg: "Snippet custom = {{ custom_snippet | truncate(50) }}"
  tags: debug
```

3) Lookup password: générer un mot de passe par machine (exemple).

Crée un dossier pour les secrets locaux:

```bash
mkdir -p local_secrets
```

Dans `roles/users_role/tasks/main.yml`, complète:

```yaml
- name: Générer un mot de passe local pour l'utilisateur deploy (si absent)
  ansible.builtin.set_fact:
    deploy_password: "{{ lookup('password', 'local_secrets/{{ inventory_hostname }}.pass length=16') }}"
  no_log: true
  tags: users

- name: Créer l'utilisateur deploy avec un mot de passe local (exemple)
  ansible.builtin.user:
    name: deploy
    shell: /bin/bash
    state: present
    password: "{{ deploy_password | password_hash('sha512') }}"
  tags: users
```

Remarques:

- `lookup('password', ...)` crée/relit un mot de passe par hôte, stocké dans `local_secrets/<hostname>.pass`.
- `no_log: true` pour ne pas afficher le secret.
- On le hash avant de l’utiliser.

4) Test lookups:
```bash
ansible-playbook playbooks/site.yml --tags users,debug --ask-become-pass --ask-vault-pass
```

Regarde dans `local_secrets/` les fichiers créés.

Step 3 – Mini “pré-CI” local (lint + check + règles)
----------------------------------------------------

Objectif: transformer ton usage en habitude “semi-pro”.

1) Script simple de “pré-CI”.

À la racine du projet, crée un script (facultatif mais très réaliste):

`run_checks.sh`:

```bash
#!/usr/bin/env bash
set -e

echo "1) ansible-lint ..."
ansible-lint .

echo "2) ansible-playbook --check (dev) ..."
ansible-playbook playbooks/site.yml --check --ask-become-pass --ask-vault-pass

echo "OK: lint + check passés."
```

Rends-le exécutable:

```bash
chmod +x run_checks.sh
```

2) Usage:

Avant un “vrai” run:

```bash
./run_checks.sh
```

Si ça passe, tu peux ensuite lancer:

```bash
ansible-playbook playbooks/site.yml --ask-become-pass --ask-vault-pass
```

3) Mentalité CI:

Ce script est exactement ce que tu ferais dans un job CI:

- étape 1: lint,
- étape 2: check-mode,
- étape 3: éventuellement un run sur un env de test.

Avec ça:

- tu consolides Jinja,
- tu pratiques les lookups utiles,
- tu as une habitude “lint + check” intégrée.

On est vraiment sur un socle intermédiaire “propre”, prêt pour l’avancé.

Question pour vérifier la consolidation:
Dans `users_role`, à quoi sert précisément `lookup('password', 'local_secrets/{{ inventory_hostname }}.pass length=16')` dans ton TP ?
<span style="display:none">[^1][^2][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://blog.stephane-robert.info/docs/infra-as-code/gestion-de-configuration/ansible/

[^2]: https://www.redhat.com/fr/topics/automation/learning-ansible-tutorial

[^3]: https://pierreau.fr/pro/Share/DevOps.Ansible.pdf

[^4]: https://conserto.pro/academy/ansible/

[^5]: https://www.neosoft-training.fr/nos-formations/ansible/

[^6]: https://www.youtube.com/watch?v=7tW4B3hgM_o

[^7]: https://www.hellowork.com/fr-fr/competences/ansible.html

[^8]: https://www.learnthings.fr/formations/informatique/devops/automatisation-devops/ansible/

[^9]: https://openclassrooms.com/fr/courses/2035796-utilisez-ansible-pour-automatiser-vos-taches-de-configuration

