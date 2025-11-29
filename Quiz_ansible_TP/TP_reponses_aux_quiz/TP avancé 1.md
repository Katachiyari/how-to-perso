<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Je te conseille:

d’abord un TP avancé 1 centré sur l’ORCHESTRATION (sur ton projet actuel),
puis un TP avancé 2 centré sur CI/CD + tests (niveau “expert” DevOps).
Vas y c'est parti pour le TP1

Parfait, on se lance dans le **TP Avancé 1 : Orchestration \& Stratégies**.

L'objectif est de transformer ton projet actuel (qui déploie simplement Nginx) en un système capable de faire des mises à jour sans interruption (ou presque) et de gérer les cas d'erreurs proprement.

**Fil rouge :** Tu dois mettre à jour ton parc de serveurs web (simulé) sans casser la prod, en utilisant `serial`, `max_fail_percentage`, `block/rescue`, et `delegate_to`.

***

### Étape 1 : Simuler un "cluster" de production

Pour faire de l'orchestration, il nous faut plusieurs cibles. Comme tu travailles probablement sur une machine locale ou une VM, on va tricher intelligemment avec l'inventaire pour simuler 3 serveurs web.

1. **Modifier l'inventaire de prod** (`inventories/prod/hosts.ini`) :
On va définir 3 alias qui pointent tous vers `localhost` (ou ta VM), mais avec des ports SSH ou des noms différents pour qu'Ansible les traite comme des hôtes distincts dans la boucle.
*Si tu ne peux pas utiliser des ports différents, utilise simplement des alias `ansible_connection=local` pour le TP.*

```ini
[webservers]
web01 ansible_connection=local ansible_host=localhost
web02 ansible_connection=local ansible_host=localhost
web03 ansible_connection=local ansible_host=localhost
```

*Note : En réalité, ce seraient 3 IP différentes. Ici, on simule pour voir l'effet de l'orchestration.*

### Étape 2 : Implémenter le Rolling Update (Mise à jour progressive)

Le but est de ne pas mettre à jour les 3 serveurs en même temps. Si la mise à jour casse Nginx, on ne veut casser qu'un seul serveur, pas tous.

1. **Modifier `playbooks/site.yml`** :
Ajoute `serial` et `max_fail_percentage`.

```yaml
---
- name: Projet Nginx Avancé - Rolling Update
  hosts: webservers
  become: true
  serial: 1                  # Traite 1 hôte à la fois (ou "30%")
  max_fail_percentage: 0     # Si 1 hôte échoue, on arrête TOUT le déploiement

  roles:
    - users_role
    - webserver_role
```

2. **Test du Rolling Update** :
Lance le playbook.

```bash
ansible-playbook -i inventories/prod/hosts.ini playbooks/site.yml
```

**Observe la sortie :** Tu verras qu'Ansible termine complètement le jeu (users + nginx) sur `web01` **AVANT** de commencer `web02`.
*C'est la base du déploiement sans interruption.*

### Étape 3 : Gestion d'erreur et Rollback avec `block/rescue`

On va simuler un crash critique lors de la configuration Nginx et automatiser une action corrective.

1. **Modifier `roles/webserver_role/tasks/main.yml`** :
On va envelopper l'appel aux tâches dans un `block`.

```yaml
---
- name: Déploiement sécurisé de Nginx
  block:
    # Tes imports existants
    - import_tasks: install_nginx.yml
    - include_tasks: manage_site.yml

    # Simulation d'erreur conditionnelle (pour tester le rescue)
    - name: "Simulation crash sur le premier serveur"
      ansible.builtin.fail:
        msg: "Alerte ! Configuration corrompue détectée sur {{ inventory_hostname }}"
      when: inventory_hostname == 'web01' and simulate_crash | default(false)

  rescue:
    - name: "ROLLBACK : Restauration configuration par défaut"
      ansible.builtin.copy:
        src: files/nginx.conf.default  # Assure-toi d'avoir ce fichier ou un dummy
        dest: /etc/nginx/nginx.conf
        mode: '0644'
      notify: Restart nginx

    - name: "Notification d'échec critique"
      ansible.builtin.debug:
        msg: "Le déploiement a échoué sur {{ inventory_hostname }}. Rollback effectué."

  always:
    - name: "Nettoyage des fichiers temporaires (exemple)"
      ansible.builtin.file:
        path: /tmp/nginx_deploy_lock
        state: absent
```

2. **Test du scénario catastrophe** :
Lance le playbook en activant le crash simulé.

```bash
ansible-playbook -i inventories/prod/hosts.ini playbooks/site.yml -e "simulate_crash=true"
```

**Résultat attendu :**
    - `web01` commence.
    - Il arrive à la tâche "Simulation crash".
    - Il **échoue**, mais ne plante pas le script tout de suite grâce au `rescue`.
    - Il exécute le "ROLLBACK".
    - Comme `web01` a été "sauvé" par le rescue, Ansible peut continuer vers `web02` (sauf si tu forces un `fail` dans le rescue).
    - *Note : Dans une vraie prod, on voudrait souvent arrêter le déploiement après le rescue. Pour ça, ajoute `- meta: end_play` dans la partie rescue.*

### Étape 4 : Orchestration avec `delegate_to` (Simulation Load Balancer)

On va simuler le retrait du serveur d'un Load Balancer avant de le toucher.

1. **Ajouter des tâches de Pre/Post tâches dans `playbooks/site.yml`** :
On utilise `pre_tasks` et `post_tasks` pour sortir/entrer le serveur du pool. On simule l'action avec un simple fichier log local (car on n'a pas de vrai F5/HAProxy sous la main).

```yaml
---
- name: Projet Nginx Avancé - Rolling Update
  hosts: webservers
  become: true
  serial: 1

  pre_tasks:
    - name: "LB : Sortir le serveur du pool"
      ansible.builtin.lineinfile:
        path: /tmp/loadbalancer_status.log
        line: "{{ inventory_hostname }} : DRAIN"
        create: true
      delegate_to: localhost   # Action effectuée sur le contrôleur (simule l'API du LB)
      run_once: false          # On le fait pour CHAQUE serveur de la boucle serial

  roles:
    - users_role
    - webserver_role

  post_tasks:
    - name: "LB : Remettre le serveur dans le pool"
      ansible.builtin.lineinfile:
        path: /tmp/loadbalancer_status.log
        line: "{{ inventory_hostname }} : ACTIVE"
        create: true
      delegate_to: localhost
```

2. **Test Final** :
Lance le playbook complet. Regarde le fichier `/tmp/loadbalancer_status.log` (sur ta machine locale) en temps réel (`tail -f`) si possible.
Tu devrais voir la séquence :
    - `web01` DRAIN
    - (Déploiement rôles sur `web01`)
    - `web01` ACTIVE
    - `web02` DRAIN
    - ...

***

### Bilan du TP Avancé 1

Tu viens de mettre en pratique :

1. **Serial** : Pour contrôler le flux de déploiement (Rolling Update).
2. **Block/Rescue** : Pour gérer les erreurs sans tout casser (Self-healing).
3. **Delegate_to** : Pour interagir avec un élément tiers (Load Balancer simulé) depuis le contrôleur.

C'est le cœur de l'orchestration Ansible "Pro".

**Est-ce que tu as réussi à faire tourner ce scénario ?**
Si oui, on peut valider ce bloc et parler du **TP Avancé 2 (CI/CD + Tests)** pour finir en beauté.

