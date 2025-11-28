# 🧠 Quiz Ansible complet

---

## 🔹 Niveau débutant (10 questions)

### Q1. Qu’est-ce qu’Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>

Ansible est un outil d’automatisation (configuration, déploiement, orchestration) agentless, basé sur SSH et des playbooks YAML.
</details>

### Q2. Qu’est-ce qu’un playbook ?
<details>
<summary>Clique pour voir la réponse</summary>

Un playbook est un fichier YAML qui décrit quels hôtes cibler et quelles tâches exécuter, dans quel ordre.
</details>

### Q3. Qu’est-ce qu’un inventaire ?
<details>
<summary>Clique pour voir la réponse</summary>

Un inventaire est la liste des hôtes gérés par Ansible, organisée éventuellement en groupes (ini, yaml, dynamique…).
</details>

### Q4. Qu’est-ce qu’un module Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>

Un module est une “brique” qui réalise une action (ex: ansible.builtin.apt, service, file, user…). Les tâches appellent des modules.
</details>

### Q5. Que signifie “idempotent” ?
<details>
<summary>Clique pour voir la réponse</summary>

Relancer plusieurs fois la même tâche ne change plus rien si l’état souhaité est déjà atteint.
</details>

### Q6. À quoi sert `ansible.builtin.ping` ?
<details>
<summary>Clique pour voir la réponse</summary>

Tester que Ansible peut se connecter et exécuter du code Python sur la cible.
</details>

### Q7. Fichier d’inventaire défaut d’Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>

`/etc/ansible/hosts` (sauf si ansible.cfg en définit un autre).
</details>

### Q8. Quelle commande pour exécuter un playbook ?
<details>
<summary>Clique pour voir la réponse</summary>

`ansible-playbook mon_playbook.yml`
</details>

### Q9. À quoi sert `become: true` ?
<details>
<summary>Clique pour voir la réponse</summary>

Exécuter la tâche avec élévation de privilège (souvent via sudo).
</details>

### Q10. Deux formats courants d’inventaire ?
<details>
<summary>Clique pour voir la réponse</summary>

Format INI et format YAML (et aussi inventaire dynamique).
</details>

---

## 🔸 Niveau intermédiaire (15 questions)

### Q11. Qu’est-ce qu’un rôle Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>

Une structure standardisée pour regrouper tâches, variables, templates, handlers, fichiers… réutilisables.
</details>

### Q12. À quoi sert `group_vars/` ?
<details>
<summary>Clique pour voir la réponse</summary>

Définir des variables par groupe d’hôtes (ex: group_vars/webservers.yml).
</details>

### Q13. Priorité des variables: où se placent les variables de playbook ?
<details>
<summary>Clique pour voir la réponse</summary>

Elles ont une priorité plus haute que les variables de rôle, mais plus basse que les extra-vars (`-e`).
</details>

### Q14. Différence `copy` vs `template` ?
<details>
<summary>Clique pour voir la réponse</summary>

`copy` envoie un fichier tel quel, `template` passe par Jinja2 et permet d’utiliser des variables/conditions.
</details>

### Q15. À quoi sert un handler ?
<details>
<summary>Clique pour voir la réponse</summary>

Tâche spéciale appelée via `notify` (souvent pour restart/reload un service) et exécutée seulement si nécessaire.
</details>

### Q16. Où placer les dépendances d’un rôle ?
<details>
<summary>Clique pour voir la réponse</summary>

Dans `meta/main.yml` sous `dependencies`.
</details>

### Q17. Comment chiffrer un fichier de variables ?
<details>
<summary>Clique pour voir la réponse</summary>

Avec Ansible Vault : `ansible-vault encrypt group_vars/prod.yml`.
</details>

### Q18. Commande pour tester la syntaxe d’un playbook ?
<details>
<summary>Clique pour voir la réponse</summary>

`ansible-playbook mon_playbook.yml --syntax-check`
</details>

### Q19. À quoi sert `when:` ?
<details>
<summary>Clique pour voir la réponse</summary>

À exécuter une tâche seulement si une condition (expression Jinja2) est vraie.
</details>

### Q20. Quelle est la bonne pratique pour les modules: noms courts ou FQCN ?
<details>
<summary>Clique pour voir la réponse</summary>

Bonne pratique: utiliser les FQCN, ex: `ansible.builtin.file`.
</details>

### Q21. Comment éviter d’utiliser `shell` pour gérer des paquets ?
<details>
<summary>Clique pour voir la réponse</summary>

En utilisant les modules dédiés (`ansible.builtin.apt`, `yum`, `dnf`, etc.).
</details>

### Q22. À quoi sert `register:` ?
<details>
<summary>Clique pour voir la réponse</summary>

Stocker le résultat d’une tâche dans une variable pour l’utiliser plus tard (conditions, debug…).
</details>

### Q23. Comment limiter l’exécution à un seul hôte d’un groupe ?
<details>
<summary>Clique pour voir la réponse</summary>

En ciblant l’hôte dans `-l` (limit) ou en utilisant `run_once: true` pour la tâche.
</details>

### Q24. À quoi sert `tags:` ?
<details>
<summary>Clique pour voir la réponse</summary>

Marquer des tâches pour ne lancer qu’un sous-ensemble avec `--tags` ou `--skip-tags`.
</details>

### Q25. Comment exécuter une commande ad-hoc sur un groupe d’hôtes ?
<details>
<summary>Clique pour voir la réponse</summary>

`ansible webservers -m ansible.builtin.command -a "uptime"`
</details>

---

## 🔺 Niveau avancé (20 questions)

### Q26. Différence `import_tasks` vs `include_tasks` ?
<details>
<summary>Clique pour voir la réponse</summary>

`import_tasks` est statique (résolu au parse time), `include_tasks` est dynamique (résolu à l’exécution, donc utilisable avec when/loops).
</details>

### Q27. Différence `import_role` vs `include_role` ?
<details>
<summary>Clique pour voir la réponse</summary>

Même logique: import = statique, include = dynamique (peut être conditionnel, dans des boucles).
</details>

### Q28. Comment gérer un inventaire dynamique (ex: cloud) ?
<details>
<summary>Clique pour voir la réponse</summary>

En utilisant des scripts ou plugins d’inventaire dynamique (ex: AWS, GCP, Azure) configurés dans `inventory` et `ansible.cfg`.
</details>

### Q29. Comment assurer l’idempotence quand on utilise `command`/`shell` ?
<details>
<summary>Clique pour voir la réponse</summary>

En utilisant `creates:` ou `removes:` et/ou `changed_when:` / `failed_when:` pour contrôler manuellement l’état.
</details>

### Q30. Différence entre `delegate_to` et `run_once` ?
<details>
<summary>Clique pour voir la réponse</summary>

`run_once` exécute une tâche une seule fois (sur un hôte du batch), `delegate_to` fait exécuter la tâche sur un autre hôte (ex: bastion, DB).
</details>

### Q31. Quand utiliser `serial` dans un play ?
<details>
<summary>Clique pour voir la réponse</summary>

Pour faire des déploiements par lot (rolling update), ex: `serial: 10` pour 10 hôtes à la fois.
</details>

### Q32. Comment intégrer Ansible avec CI/CD (ex: GitLab CI, GitHub Actions) ?
<details>
<summary>Clique pour voir la réponse</summary>

En lançant `ansible-lint` puis `ansible-playbook` depuis les jobs CI, avec inventaire et secrets fournis via variables/temp files.
</details>

### Q33. Quel est l’intérêt de Molecule ?
<details>
<summary>Clique pour voir la réponse</summary>

Tester les rôles Ansible (lint, converge, verify, destroy) de façon reproductible, souvent avec des conteneurs.
</details>

### Q34. Comment forcer l’utilisation d’un ansible.cfg spécifique ?
<details>
<summary>Clique pour voir la réponse</summary>

En lançant Ansible depuis le répertoire qui contient `ansible.cfg` ou avec `ANSIBLE_CONFIG=/chemin/ansible.cfg`.
</details>

### Q35. Que permet `check_mode` ?
<details>
<summary>Clique pour voir la réponse</summary>

Simuler l’exécution sans appliquer les changements (dry-run): `ansible-playbook play.yml --check`.
</details>

### Q36. À quoi sert `changed_when: false` ?
<details>
<summary>Clique pour voir la réponse</summary>

Forcer une tâche à être considérée comme “unchanged” même si le module la marque “changed” (utile pour des tâches de check).
</details>

### Q37. Comment gérer des configurations différentes par environnement (dev / preprod / prod) ?
<details>
<summary>Clique pour voir la réponse</summary>

En séparant inventaires et variables (`inventories/dev`, `inventories/prod`, `group_vars/env_*`, etc.).
</details>

### Q38. Que permet `strategy: free` ?
<details>
<summary>Clique pour voir la réponse</summary>

Les hôtes avancent indépendamment dans le play, au lieu d’être synchronisés tâche par tâche.
</details>

### Q39. Comment limiter la parallélisation globale d’Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>

Avec `forks` (dans ansible.cfg ou `-f`) pour le nombre de connexions parallèles.
</details>

### Q40. Comment récupérer des facts custom ?
<details>
<summary>Clique pour voir la réponse</summary>

En déposant des scripts dans `/etc/ansible/facts.d/` ou en utilisant `set_fact` dans des plays.
</details>

### Q41. Qu’est-ce qu’une collection Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>

Un paquetage (modules, plugins, rôles) versionné, distribué via Galaxy/Automation Hub (ex: `community.general`).
</details>

### Q42. Comment utiliser `ansible-lint` dans un projet ?
<details>
<summary>Clique pour voir la réponse</summary>

En l’installant puis en l’exécutant sur le répertoire : `ansible-lint .`, souvent intégré en pre-commit ou CI.
</details>

### Q43. Comment gères-tu les secrets: Vault seul ou Vault + autre système (HashiCorp Vault, etc.) ?
<details>
<summary>Clique pour voir la réponse</summary>

Réponse attendue: Ansible Vault pour chiffrer les variables, éventuellement couplé à un gestionnaire de secrets externe (HashiCorp Vault, AWS SSM, etc.), avec plugins de lookup.
</details>

### Q44. Comment géres-tu la compatibilité entre versions d’Ansible et des collections ?
<details>
<summary>Clique pour voir la réponse</summary>

En figeant les versions dans `requirements.yml`, en testant avec Molecule/CI, et en lisant les notes de version avant upgrade.
</details>

### Q45. Quand utiliser `block/rescue/always` ?
<details>
<summary>Clique pour voir la réponse</summary>

Pour gérer des séquences de tâches avec gestion d’erreur structurée (try/catch finally).
</details>

---

## 🏆 Questions “pro DevOps / entretien” (5 questions)

### Q46. Comment structurerais-tu un gros repo Ansible pour gérer plusieurs applis et environnements (Dev/QA/Prod) proprement ?
<details>
<summary>Clique pour voir une réponse possible</summary>

Réponse attendue: séparation claire `inventories/`, `roles/`, `playbooks/`, group_vars/host_vars par env, éventuellement mono-repo avec dossiers par domaine, collections, conventions de nommage, etc.
</details>

### Q47. Comment garantir que tes playbooks restent fiables dans le temps (tests, lint, CI/CD) ?
<details>
<summary>Clique pour voir une réponse possible</summary>

Réponse attendue: ansible-lint, Molecule, tests automatiques en CI, environnements de staging, revue de code, versioning des rôles/collections.
</details>

### Q48. Comment gères-tu les changements disruptifs (breaking changes) lors d’une montée de version d’Ansible ou d’une collection critique ?
<details>
<summary>Clique pour voir une réponse possible</summary>

Réponse attendue: tests en environnement isolé, lecture des release notes, branches de migration, feature flags / toggles, déploiement progressif.
</details>

### Q49. Comment utiliserais-tu Ansible dans une stratégie de déploiement blue/green ou canary ?
<details>
<summary>Clique pour voir une réponse possible</summary>

Réponse attendue: inventaires séparés ou tags, `serial`, `delegate_to` pour manipuler les load balancers, rôles dédiés à la gestion du trafic, rollback automatisé.
</details>

### Q50. Quels indicateurs (metrics) regarderais-tu pour mesurer l’efficacité de ton automatisation Ansible ?
<details>
<summary>Clique pour voir une réponse possible</summary>

Réponse attendue: temps de déploiement, taux d’échec, fréquence des rollbacks, couverture d’automatisation, MTTR, pourcentages de déploiements automatisés vs manuels.
</details>
