## 40  questions niveau intermédiaires, 

# 🧠 Quiz Ansible – Niveau intermédiaire (0 → 10)

Projet fil rouge :  
Tu continues à faire évoluer ton projet Ansible “Nginx + users + fichiers + rôles + vault + ansible-lint” vers un niveau plus pro (multi-env, handlers avancés, includes, tests, CI, etc.).

Les questions montent en difficulté progressivement.

---

## 🔹 Niveau 0–2 : Rôles, group_vars, handlers, organisation (Q1–Q10)

### Q1. Pourquoi est-il préférable de définir `site_title` dans `group_vars/webservers.yml` plutôt que directement dans le template `index.html.j2` ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour séparer la logique (templates) des données (variables), faciliter les changements par environnement, et éviter de modifier le code Ansible pour changer un simple texte.
</details>

### Q2. Dans ton projet, à quel endroit Ansible va chercher en priorité une variable appelée `site_title` : dans `group_vars/webservers.yml` ou dans des `vars:` définies dans le playbook ?
<details>
<summary>Clique pour voir la réponse</summary>
Les `vars:` définies directement dans le playbook ont une priorité plus haute que celles de `group_vars`, donc elles l’emportent.
</details>

### Q3. Pourquoi avoir séparé la logique en deux rôles (`users_role` et `webserver_role`) est une bonne pratique pour ce projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que cela découpe les responsabilités (gestion des users vs webserver), facilite la réutilisation, la compréhension, les tests et la collaboration.
</details>

### Q4. Comment fais-tu pour utiliser `webserver_role` uniquement sur certains hôtes (ex: ceux du groupe `webservers`) ?
<details>
<summary>Clique pour voir la réponse</summary>
En ciblant uniquement le groupe `webservers` dans le playbook (`hosts: webservers`) et en incluant le rôle dans ce play.
</details>

### Q5. Quelle est la différence entre mettre une tâche dans `playbooks/site.yml` et la mettre dans `roles/webserver_role/tasks/main.yml` ?
<details>
<summary>Clique pour voir la réponse</summary>
Dans le playbook, c’est une logique ponctuelle; dans le rôle, c’est une logique factorisée et réutilisable, mieux organisée.
</details>

### Q6. Pourquoi tous les handlers liés à Nginx doivent-ils être regroupés dans `roles/webserver_role/handlers/main.yml` ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour que toutes les actions liées au service Nginx soient centralisées, facilement trouvables et réutilisées dans tout le rôle.
</details>

### Q7. Dans ton rôle Nginx, pourquoi utiliser `notify: Restart nginx` plutôt que d’appeler directement `service: state=restarted` à la fin de chaque tâche ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour ne redémarrer Nginx que lorsqu’un changement a réellement lieu, éviter les redémarrages inutiles et améliorer la stabilité en prod.
</details>

### Q8. Quand tu ajoutes une nouvelle tâche dans ton rôle, quel est le premier réflexe pour rester propre niveau arborescence ?
<details>
<summary>Clique pour voir la réponse</summary>
Vérifier si la tâche doit aller dans `tasks/main.yml` ou dans un fichier de tâches séparé (inclu avec `import_tasks`/`include_tasks`) pour garder `main.yml` lisible.
</details>

### Q9. Pourquoi est-il conseillé de garder `playbooks/site.yml` le plus simple possible en déléguant la majorité de la logique aux rôles ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour que le playbook soit un “orchestrateur” facile à lire (qui appelle des rôles), et non un amas de détails techniques difficile à maintenir.
</details>

### Q10. Si tu veux ajouter un rôle `firewall_role` plus tard, comment l’intégrer proprement dans ton projet actuel ?
<details>
<summary>Clique pour voir la réponse</summary>
En créant `roles/firewall_role/` avec sa structure, puis en l’ajoutant dans le playbook `site.yml` sous `roles:`, éventuellement avec son propre `group_vars` si nécessaire.
</details>

---

## 🔹 Niveau 3–4 : Includes/imports, conditions, register, when, tags (Q11–Q20)

### Q11. Quelle est la différence principale entre `import_tasks` et `include_tasks` dans un rôle comme `webserver_role` ?
<details>
<summary>Clique pour voir la réponse</summary>
`import_tasks` est statique (résolu au parsing du playbook), alors que `include_tasks` est dynamique (résolu à l’exécution et peut être conditionnel).
</details>

### Q12. Pourquoi utiliser `import_tasks: install_nginx.yml` pour les tâches d’installation de base ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que ces tâches sont toujours nécessaires et ne dépendent pas de conditions dynamiques, donc un import statique rend la structure plus claire.
</details>

### Q13. Donne un cas dans ton projet où `include_tasks: manage_site.yml` est plus adapté qu’un `import_tasks`.
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple, si la gestion des sites (vhosts, multi-sites) doit être exécutée seulement dans certaines conditions ou avec certaines variables, `include_tasks` permet d’y mettre des `when`, des boucles, etc.
</details>

### Q14. À quoi sert `register:` dans ta tâche qui vérifie si Nginx écoute sur un port (`ss -tlnp | grep :{{ nginx_port }}`) ?
<details>
<summary>Clique pour voir la réponse</summary>
À stocker le résultat de la commande (`stdout`, `rc`, etc.) dans une variable (ex: `nginx_port_check`) pour l’utiliser ensuite dans des `when` ou des `debug`.
</details>

### Q15. Pourquoi as-tu mis `changed_when: false` sur cette tâche de check de port ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce qu’il s’agit d’une vérification de l’état et non d’une modification, on ne veut pas que cette tâche soit comptée comme un changement dans le récapitulatif.
</details>

### Q16. Dans quel cas utiliserais-tu `failed_when: false` sur une tâche de check dans ce projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Lorsque tu veux éviter que le play échoue si la commande renvoie un code de retour non nul (par exemple, si le port n’est pas encore ouvert, ce n’est pas forcément un échec du déploiement).
</details>

### Q17. Donne un exemple concret de `when:` sur une tâche dans `webserver_role` lié à la variable `environment`.
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple, ne déployer certains fichiers ou activer certains modules Nginx que si `environment == 'prod'`.
</details>

### Q18. Pourquoi utiliser des `tags` comme `tags: nginx` et `tags: users` dans ton projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour pouvoir exécuter uniquement une partie des tâches (par exemple `--tags nginx` pour ne gérer que la partie webserver) sans toucher aux autres.
</details>

### Q19. Donne un cas où tu lancerais `ansible-playbook playbooks/site.yml --tags users`.
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple, si tu dois créer/mettre à jour des utilisateurs sur les serveurs sans vouloir redéployer Nginx ou modifier les fichiers web.
</details>

### Q20. Pourquoi est-il utile de combiner `tags` et `--check` sur ce projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour simuler seulement une partie du déploiement (ex: `--tags nginx --check`) et voir ce qui changerait côté Nginx, sans toucher au reste.
</details>

---

## 🔹 Niveau 5–6 : Vault, multi-env, bonnes pratiques sécurité (Q21–Q30)

### Q21. Pourquoi as-tu mis les secrets (ex: `db_password`) dans `group_vars/all_vault.yml` plutôt que dans `group_vars/webservers.yml` ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour séparer les données sensibles (chiffrées avec Vault) des autres variables non sensibles, ce qui clarifie la gestion des secrets et facilite leur usage multi-groupes.
</details>

### Q22. Quelle commande utilises-tu pour chiffrer un fichier de variables existant comme `group_vars/all_vault.yml` ?
<details>
<summary>Clique pour voir la réponse</summary>
`ansible-vault encrypt group_vars/all_vault.yml`
</details>

### Q23. Quand tu exécutes ton playbook, pourquoi dois-tu ajouter `--ask-vault-pass` ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que Ansible doit connaître le mot de passe Vault pour pouvoir déchiffrer les fichiers de variables chiffrés avant d’exécuter le playbook.
</details>

### Q24. Que se passe-t-il si tu oublies `--ask-vault-pass` alors que ton playbook utilise `all_vault.yml` chiffré ?
<details>
<summary>Clique pour voir la réponse</summary>
Ansible ne peut pas déchiffrer le fichier, provoque une erreur et le playbook échoue avant de commencer les tâches.
</details>

### Q25. Comment structurerais-tu les inventaires et variables si tu ajoutes un environnement `prod` en plus de `dev` ?
<details>
<summary>Clique pour voir la réponse</summary>
En ajoutant par exemple `inventories/prod/hosts.ini`, et des fichiers `group_vars/webservers.yml` spécifiques pour prod (ou `group_vars/webservers_prod.yml`), avec des secrets chiffrés adaptés à prod.
</details>

### Q26. Pourquoi est-il dangereux de commiter un fichier `group_vars/all_vault.yml` non chiffré dans un dépôt Git public ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que tous les secrets (mots de passe, clés API, etc.) seraient exposés publiquement, ce qui représente un énorme risque de sécurité.
</details>

### Q27. Comment peux-tu t’assurer que tu n’oublies pas de chiffrer un fichier de secrets avant de le pousser sur Git ?
<details>
<summary>Clique pour voir la réponse</summary>
En mettant en place une règle dans ansible-lint, des hooks pre-commit ou simplement une discipline: vérifier les fichiers sensibles + les suffixes (`*_vault.yml`) avant commit.
</details>

### Q28. Pourquoi est-il recommandé de limiter `become: true` aux tâches qui en ont vraiment besoin ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour réduire l’exposition aux erreurs graves, limiter l’impact d’une mauvaise commande et respecter le principe de moindre privilège.
</details>

### Q29. Donne un exemple de tâche qui n’a pas besoin de `become: true` dans ce projet.
<details>
<summary>Clique pour voir la réponse</summary>
Une tâche qui ne fait qu’afficher un message (`debug`) ou manipuler un fichier dans le home d’un utilisateur non privilégié.
</details>

### Q30. À l’inverse, donne un exemple de tâche qui DOIT avoir `become: true` dans ce projet.
<details>
<summary>Clique pour voir la réponse</summary>
L’installation de Nginx (`apt install nginx` via le module) ou la création de fichiers dans `/etc/nginx` ou `/var/www` nécessitent les privilèges root.
</details>

---

## 🔹 Niveau 7–8 : ansible-lint, qualité, DRY, includes & meta (Q31–Q36)

### Q31. Pourquoi as-tu intégré `ansible-lint` à ton projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour faire une revue automatique des playbooks/rôles, détecter les mauvaises pratiques, uniformiser le style et prévenir les erreurs avant qu’elles ne partent en prod.
</details>

### Q32. Quelle commande utilises-tu pour lancer ansible-lint sur ton projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple : `ansible-lint playbooks/site.yml` (ou directement à la racine du projet : `ansible-lint .`).
</details>

### Q33. Comment ansible-lint t’aide-t-il à respecter le principe DRY dans tes rôles ?
<details>
<summary>Clique pour voir la réponse</summary>
En signalant les répétitions inutiles, les appels `shell` qui pourraient être remplacés par des modules, ou les patterns de code qui mériteraient d’être factorisés dans un rôle ou une tâche importée.
</details>

### Q34. Donne un exemple de refactorisation DRY que tu as fait ou pourrais faire dans `webserver_role`.
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple, sortir toutes les actions d’installation dans un fichier `install_nginx.yml` importé avec `import_tasks`, plutôt que de mélanger installation et configuration dans `main.yml`.
</details>

### Q35. À quoi sert `meta/main.yml` dans un rôle, même s’il est minimal dans ton projet ?
<details>
<summary>Clique pour voir la réponse</summary>
À décrire le rôle (auteur, description, version minimale d’Ansible) et à déclarer d’éventuelles dépendances vers d’autres rôles.
</details>

### Q36. Donne un exemple de dépendance que tu pourrais déclarer dans `roles/webserver_role/meta/main.yml` pour ce projet.
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple, dépendre d’un rôle `users_role` si tu veux t’assurer que l’utilisateur `deploy` est créé avant la configuration des fichiers Nginx.
</details>

---

## 🔹 Niveau 9–10 : Check-mode, stratégie de tests, début d’intégration CI (Q37–Q40)

### Q37. Pourquoi exécuter `ansible-playbook playbooks/site.yml --check` avant un déploiement sur un nouvel environnement (ex: prod) ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour vérifier à l’avance ce que le playbook va changer, détecter des erreurs potentielles de variables ou de chemins, et réduire les risques en prod.
</details>

### Q38. Comment pourrais-tu utiliser `ansible-lint` et `--check` dans une pipeline CI pour ce projet ?
<details>
<summary>Clique pour voir la réponse</summary>
En créant un job qui exécute d’abord `ansible-lint .`, puis un `ansible-playbook playbooks/site.yml --check` avec un inventaire de test, et qui échoue si l’un des deux échoue.
</details>

### Q39. Pourquoi est-ce une bonne idée de tester ton rôle `webserver_role` indépendamment avec un outil comme Molecule (même si tu ne l’as pas encore fait) ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour valider le rôle de manière isolée, dans un environnement jetable (containers/VM), assurer sa qualité et éviter d’introduire des régressions en l’utilisant dans d’autres projets.
</details>

### Q40. D’après toi, qu’est-ce qui manque encore à ton projet pour le faire passer du niveau “intermédiaire” au début du niveau “avancé/expert” ?
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple : inventaires dynamiques, gestion de plusieurs applications, déploiements blue/green, intégration complète CI/CD, tests Molecule, utilisation avancée de collections, stratégies de déploiement progressif.
</details>
```

Tu as maintenant:

- 40 questions intermédiaires,
- toujours liées à ton projet fil rouge,
- structurées pour t’emmener vers le niveau avancé/expert.

Question pour la suite:
Tu veux qu’on attaque maintenant la “mise en pratique intermédiaire” (évolution concrète du projet pour couvrir ce quiz), ou tu préfères d’abord relire et compléter le niveau débutant/pratique si tu as des trous ?

