# Quizz 40 questions débutant.

***
# 🧠 Quiz Ansible – Niveau débutant (0 → 10)

Projet fil rouge :  
Tu gères une petite infra avec Ansible pour déployer **Nginx**, créer des **users**, gérer des **fichiers**, organiser des **rôles**, sécuriser des **secrets avec Vault** et vérifier la qualité avec **ansible-lint**.

Les questions montent en difficulté progressivement (0 = tout débutant, 10 = bord de l’intermédiaire).

---

## 🔹 Niveau 0–2 : Bases absolues (Q1–Q10)

### Q1. Qu’est-ce qu’Ansible et à quoi sert-il dans ce projet Nginx + users ?
<details>
<summary>Clique pour voir la réponse</summary>
Ansible est un outil d’automatisation de configuration et de déploiement, qui va nous permettre d’installer Nginx, gérer des utilisateurs, des fichiers, des rôles et des secrets de façon reproductible.
</details>

### Q2. Qu’est-ce qu’un **playbook** dans Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>
Un playbook est un fichier YAML qui décrit quels hôtes cibler et quelles tâches exécuter, dans quel ordre, pour atteindre un état désiré.
</details>

### Q3. Comment exécuter un playbook nommé `site.yml` ?
<details>
<summary>Clique pour voir la réponse</summary>
En utilisant la commande :
`ansible-playbook site.yml`
</details>

### Q4. Qu’est-ce qu’un **inventaire** dans Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>
C’est la liste des hôtes gérés par Ansible, souvent organisée en groupes (ex : `[webservers]`), et fournie via un fichier (INI, YAML) ou un plugin dynamique.
</details>

### Q5. Dans ce projet, quel groupe d’hôtes utiliserais-tu pour tes serveurs Nginx ?
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple un groupe `[webservers]` dans l’inventaire, qui contiendra les serveurs sur lesquels Nginx sera déployé.
</details>

### Q6. Quelle commande ad-hoc utiliser pour tester la connexion SSH à tous les `webservers` ?
<details>
<summary>Clique pour voir la réponse</summary>
`ansible webservers -m ansible.builtin.ping`
</details>

### Q7. À quoi sert l’option `-i` dans la commande `ansible` ou `ansible-playbook` ?
<details>
<summary>Clique pour voir la réponse</summary>
Elle permet d’indiquer explicitement le chemin de l’inventaire à utiliser, par exemple `-i inventories/dev/hosts.ini`.
</details>

### Q8. Pourquoi est-il recommandé de créer un fichier `ansible.cfg` dans le projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour définir des paramètres par défaut (inventaire, gestion des retries, host_key_checking…) spécifiques au projet, sans polluer la configuration globale du système.
</details>

### Q9. Quelle option utilise-t-on pour exécuter des tâches avec élévation de privilèges (sudo) ?
<details>
<summary>Clique pour voir la réponse</summary>
On utilise `become: true` dans le playbook, et au besoin `--ask-become-pass` (`-K`) en ligne de commande.
</details>

### Q10. Pourquoi Ansible est-il dit “agentless” et en quoi est-ce une bonne pratique pour ce projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Il n’installe pas d’agent sur les machines gérées : il utilise SSH (ou connexion locale). Cela simplifie la gestion, réduit la surface d’attaque et rend le déploiement plus léger.
</details>

---

## 🔹 Niveau 3–4 : Modules, idempotence, Nginx, users, fichiers (Q11–Q20)

### Q11. Qu’est-ce qu’un **module** dans Ansible (ex : `ansible.builtin.apt`) ?
<details>
<summary>Clique pour voir la réponse</summary>
C’est une brique de base qui effectue une action précise (installer un paquet, gérer un fichier, un service, un user, etc.). Les tâches du playbook appellent des modules.
</details>

### Q12. Pourquoi est-il recommandé d’utiliser les **FQCN** (`ansible.builtin.xxx`) plutôt que les noms courts de modules ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour éviter les ambiguïtés entre collections, être explicite sur la provenance du module et rester compatible avec ansible-lint et les bonnes pratiques récentes.
</details>

### Q13. Que signifie l’**idempotence** dans le contexte d’un playbook qui installe Nginx ?
<details>
<summary>Clique pour voir la réponse</summary>
Que relancer le playbook plusieurs fois ne modifie plus l’état si Nginx est déjà correctement installé et configuré : Ansible ne fait rien de plus.
</details>

### Q14. Pourquoi est-ce une mauvaise pratique d’utiliser `ansible.builtin.shell: "apt install nginx -y"` pour installer Nginx ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que ça casse l’idempotence et la portabilité, alors qu’il existe un module dédié (`ansible.builtin.apt`) qui gère mieux l’état, les erreurs et les distributions.
</details>

### Q15. Quel module utiliser pour installer des paquets Nginx sur Debian/Ubuntu dans les règles ?
<details>
<summary>Clique pour voir la réponse</summary>
Le module `ansible.builtin.apt` avec `name: nginx` et `state: present`, plutôt qu’une commande shell brute.
</details>

### Q16. Quel module privilégier pour gérer des **fichiers de configuration Nginx** à partir de templates Jinja2 ?
<details>
<summary>Clique pour voir la réponse</summary>
Le module `ansible.builtin.template`, qui permet de générer des fichiers à partir de templates Jinja2 avec des variables dynamiques.
</details>

### Q17. Pourquoi est-il important de définir explicitement `owner`, `group` et `mode` quand tu crées un fichier de conf Nginx ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour maîtriser les permissions (sécurité), garantir un comportement prévisible d’un run à l’autre, et respecter les recommandations ansible-lint.
</details>

### Q18. Quel module utilises-tu pour créer des utilisateurs système pour Nginx ou des comptes d’admin ?
<details>
<summary>Clique pour voir la réponse</summary>
Le module `ansible.builtin.user`, qui permet de gérer création, modification, suppression et groupes des utilisateurs.
</details>

### Q19. Pourquoi vaut-il mieux utiliser `ansible.builtin.file` pour gérer un répertoire `/var/www/` plutôt qu’une commande `mkdir` ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que `file` est idempotent, gère les permissions, l’état (absent/present) et peut être relancé sans effet de bord, contrairement à une commande shell.
</details>

### Q20. Comment vérifier que ton playbook Nginx est idempotent en pratique ?
<details>
<summary>Clique pour voir la réponse</summary>
En l’exécutant deux fois de suite et en vérifiant que la seconde exécution affiche `changed=0`, sans erreurs.
</details>

---

## 🔹 Niveau 5–6 : Variables, group_vars, rôles, handlers, organisaton (Q21–Q30)

### Q21. Pourquoi est-il recommandé de séparer les variables dans `group_vars/` plutôt que de tout mettre dans le playbook ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour séparer données et logique, faciliter la réutilisation, la surcharge par environnement (dev/prod) et conserver des playbooks plus lisibles.
</details>

### Q22. Que stockerais-tu par exemple dans `group_vars/webservers.yml` pour ton projet Nginx + users ?
<details>
<summary>Clique pour voir la réponse</summary>
Des variables comme `nginx_port`, `site_title`, la liste des sites (`web_sites`), éventuellement des paramètres de users spécifiques au groupe webservers.
</details>

### Q23. Qu’est-ce qu’un **rôle** dans Ansible et pourquoi en créer un pour Nginx ?
<details>
<summary>Clique pour voir la réponse</summary>
Un rôle est une structure standardisée (tasks, handlers, templates, vars, files…) pour organiser et réutiliser la configuration. Un rôle `webserver_role` pour Nginx rend le code plus propre et réutilisable.
</details>

### Q24. Quelle est la structure minimale d’un rôle Ansible bien formé ?
<details>
<summary>Clique pour voir la réponse</summary>
Un dossier `roles/mon_role/` avec au minimum `tasks/main.yml`, et souvent `handlers/main.yml`, `templates/`, `files/`, `vars/`, `meta/` selon les besoins.
</details>

### Q25. Pourquoi est-il préférable de mettre la logique Nginx dans un rôle (`webserver_role`) plutôt que directement dans `site.yml` ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour respecter le principe DRY, réutiliser le rôle dans d’autres projets, faciliter les tests (Molecule) et la lisibilité globale du playbook.
</details>

### Q26. À quoi sert un **handler** dans ce projet (par exemple, `Restart nginx`) ?
<details>
<summary>Clique pour voir la réponse</summary>
À exécuter une action (souvent un restart de service) seulement quand une tâche notifie un changement, ce qui évite des redémarrages inutiles.
</details>

### Q27. Où places-tu généralement les handlers pour un rôle Nginx ?
<details>
<summary>Clique pour voir la réponse</summary>
Dans `roles/webserver_role/handlers/main.yml`, pour rester cohérent et organisé.
</details>

### Q28. Pourquoi est-il déconseillé de redémarrer un service directement dans chaque tâche, sans handler ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que tu risques de redémarrer trop souvent, même sans changement réel, ce qui est inefficace et potentiellement perturbant en prod. Le handler n’est appelé qu’en cas de changement.
</details>

### Q29. Que signifie “Factoriser” le code dans le contexte de ce projet Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>
Réduire la duplication en mettant en commun les parties récurrentes (dans des rôles, tasks incluses, group_vars, etc.) pour avoir un code plus maintenable.
</details>

### Q30. Pourquoi est-il recommandé de stocker ton projet Ansible (Nginx + users + vault + rôles) dans Git ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour versionner les changements, collaborer, faire des revues de code, utiliser CI/CD (lint, tests) et pouvoir faire des rollbacks en cas de problème.
</details>

---

## 🔹 Niveau 7–8 : Vault, ansible-lint, sécurité, inventaires multi-env (Q31–Q36)

### Q31. À quoi sert **Ansible Vault** dans ce projet ?
<details>
<summary>Clique pour voir la réponse</summary>
À chiffrer les informations sensibles (mots de passe DB, clés API, secrets…) stockées dans des fichiers de variables, afin de pouvoir les versionner sans les exposer en clair.
</details>

### Q32. Pourquoi ne doit-on jamais mettre un mot de passe en clair dans `group_vars/webservers.yml` si le dépôt est sur GitHub ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que n’importe qui ayant accès au dépôt (ou une fuite de ce dépôt) verrait ces secrets. Il faut les chiffrer avec Vault ou les sortir dans un autre système de secrets.
</details>

### Q33. Comment crées-tu un fichier de variables chiffré avec Vault (par ex. `group_vars/all_vault.yml`) ?
<details>
<summary>Clique pour voir la réponse</summary>
Avec la commande :
`ansible-vault create group_vars/all_vault.yml`
</details>

### Q34. À quoi sert `ansible-lint` sur ce projet Nginx + users + rôles + vault ?
<details>
<summary>Clique pour voir la réponse</summary>
À analyser les playbooks et rôles pour détecter les mauvaises pratiques, les erreurs de style, les modules inadaptés (`shell` inutiles, permissions manquantes, etc.) et à appliquer les best practices.
</details>

### Q35. Donne un exemple de règle que `ansible-lint` pourrait détecter dans un mauvais playbook.
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple : utilisation de `shell` au lieu d’un module dédié, absence de `mode` pour un fichier sensible, absence de `become` pour une action nécessitant les droits root, etc.
</details>

### Q36. Pourquoi est-il recommandé d’avoir des inventaires séparés pour `dev` et `prod` dans ce projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour isoler les environnements, éviter de déployer par erreur en prod, permettre des paramètres différents (ports, users, noms de domaines, etc.) adaptés à chaque environnement.
</details>

---

## 🔹 Niveau 9–10 : Check-mode, tags, DRY, début de logique avancée (Q37–Q40)

### Q37. À quoi sert le **check mode** (`--check`) dans ce projet ?
<details>
<summary>Clique pour voir la réponse</summary>
À simuler l’exécution du playbook sans appliquer réellement les changements, pour voir ce qui serait modifié (utile avant de pousser en prod).
</details>

### Q38. Pourquoi utiliser des **tags** (comme `tags: nginx` ou `tags: users`) dans ce projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour pouvoir exécuter uniquement une partie du playbook (par ex. `--tags nginx`) sans toucher aux autres parties (users, fichiers, etc.), ce qui accélère les déploiements ciblés.
</details>

### Q39. Donne un exemple concret de DRY dans ce projet Nginx + users + fichiers + rôles.
<details>
<summary>Clique pour voir la réponse</summary>
Ex : au lieu de répéter les tâches d’installation Nginx dans plusieurs playbooks, créer un rôle `webserver_role` et l’inclure partout où on en a besoin.
</details>

### Q40. D’un point de vue “proche intermédiaire”, qu’est-ce qu’un bon **projet Ansible** pour ce cas Nginx + users + fichiers + rôles + vault + ansible-lint ?
<details>
<summary>Clique pour voir la réponse</summary>
Un projet avec :
- une arborescence claire (`inventories/`, `playbooks/`, `roles/`, `group_vars/`),
- des rôles factorisés (`webserver_role`, `users_role`, etc.),
- des variables séparées par groupe/environnement,
- les secrets chiffrés avec Vault,
- des modules dédiés et FQCN,
- des handlers pour les services,
- ansible-lint intégré (local ou CI) pour garder des bonnes pratiques.
</details>
```


***

Pour continuer le fil comme tu le souhaites :

- On peut maintenant construire la **mise en pratique complète** (un vrai petit projet) qui permet de répondre à ces 40 questions par l’action, comme on l’a fait pour les niveaux précédents.
- On gardera le même fil rouge : `nginx + users + fichiers + rôles + vault + ansible-lint`, et on fera ensuite évoluer ce projet pour l’intermédiaire et l’avancé.

Question pour vérifier où tu veux aller ensuite :
Tu préfères qu’on commence par la **mise en pratique niveau 0–4** (basique du projet) ou qu’on vise directement une **mise en pratique 0–10** d’un coup, en plusieurs étapes ?

