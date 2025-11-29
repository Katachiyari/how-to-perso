# 🧠 Quiz Ansible – Niveau avancé / pro (50 questions)

Fil rouge :  
Projet Ansible structuré (inventaires dev/prod, rôles web/users, Vault, Jinja avancé, lookups, ansible-lint, pré-CI).  
On pousse maintenant vers l’architecture, la fiabilité, la prod, et le mode “entretien DevOps”.

---

## 🔹 1. Gestion des tâches, blocks, erreurs (Q1–Q10)

### Q1. Pourquoi utiliser un `block` avec `rescue` et `always` autour de l’installation/config de Nginx dans ton rôle ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour regrouper des tâches critiques, gérer les erreurs de manière propre (rollback, logs, messages explicites) et garantir l’exécution de certaines actions quoi qu’il arrive (cleanup, logs).
</details>

### Q2. Donne un exemple de situation où tu utiliserais `rescue` dans ton projet.
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple si l’installation de Nginx échoue (problème de repo), tu peux logguer l’erreur, envoyer une alerte, ou désactiver certaines configs pour éviter un état incohérent.
</details>

### Q3. Quand est-ce que `always` dans un block est exécuté ?
<details>
<summary>Clique pour voir la réponse</summary>
Toujours, que les tâches du bloc aient réussi ou échoué, un peu comme un “finally” dans un try/catch.
</details>

### Q4. Pourquoi `failed_when: false` peut être dangereux s’il est mal utilisé ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce qu’il masque de vrais échecs et peut laisser croire que le déploiement s’est bien passé alors que certaines commandes critiques ont échoué.
</details>

### Q5. Donne un cas dans ton projet où `failed_when: false` est justifié.
<details>
<summary>Clique pour voir la réponse</summary>
Sur une tâche de check (ex: `ss -tlnp | grep :{{ nginx_port }}`) où l’absence du port ouvert n’est pas forcément un échec fatal mais une information d’état.
</details>

### Q6. Dans un rôle pro, pourquoi est-il important de contrôler finement `changed_when:` ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour que les rapports Ansible reflètent la réalité (pas de “changed” sur des checks), ce qui est crucial pour l’audit et la détection des vrais changements d’état.
</details>

### Q7. Comment peux-tu forcer une tâche de type `command` à être considérée comme “unchanged” si elle ne modifie pas l’état ?
<details>
<summary>Clique pour voir la réponse</summary>
En mettant `changed_when: false` dans la tâche.
</details>

### Q8. Pourquoi est-il souvent préférable d’éviter `ignore_errors: true` sur des tâches critiques ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que tu risques de continuer un déploiement alors qu’une étape essentielle a échoué, ce qui peut amener un état cassé ou incohérent.
</details>

### Q9. Comment utiliser `max_fail_percentage` pour rendre les déploiements plus sûrs sur un grand parc ?
<details>
<summary>Clique pour voir la réponse</summary>
En définissant `max_fail_percentage` dans le play pour stopper le déploiement si trop d’hôtes échouent, au lieu de continuer massivement.
</details>

### Q10. Que signifie “fail fast” dans un contexte de déploiement Ansible avancé ?
<details>
<summary>Clique pour voir la réponse</summary>
Arrêter le plus tôt possible en cas d’erreur sérieuse, plutôt que de tenter de finir le play sur tous les hôtes, pour limiter les dégâts.
</details>

---

## 🔹 2. Stratégies d’exécution, parallélisme, rolling update (Q11–Q20)

### Q11. À quoi sert l’option `serial` dans un play, par exemple `serial: 2` ?
<details>
<summary>Clique pour voir la réponse</summary>
À traiter les hôtes par petits groupes (2 par 2 ici), pour faire des déploiements progressifs (rolling update) au lieu de tout déployer en parallèle.
</details>

### Q12. Donne un cas d’usage de `serial` dans ton projet Nginx.
<details>
<summary>Clique pour voir la réponse</summary>
Si tu as 10 serveurs web en prod, tu peux faire un rolling update de Nginx 2 par 2 (`serial: 2`) pour réduire l’impact d’un problème sur tous les serveurs.
</details>

### Q13. Que fait l’option `strategy: free` par rapport à la stratégie par défaut ?
<details>
<summary>Clique pour voir la réponse</summary>
Avec `free`, chaque hôte avance à son propre rythme dans les tâches, au lieu d’attendre que tous les hôtes terminent une tâche avant de passer à la suivante.
</details>

### Q14. Dans quel cas `strategy: free` peut-il poser problème ?
<details>
<summary>Clique pour voir la réponse</summary>
Quand certaines tâches dépendent fortement de la synchronisation entre hôtes (par exemple migration d’un cluster DB nécessitant une séquence stricte).
</details>

### Q15. Pourquoi est-il rarement conseillé de mettre `forks` très haut (50+ par exemple) sans réflexion ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que cela peut surcharger la machine de contrôle, les réseaux, les serveurs distants, et rendre le déploiement instable ou lent à cause de la contention.
</details>

### Q16. Comment peux-tu limiter temporairement le nombre d’hôtes touchés lors d’un test de playbook en prod ?
<details>
<summary>Clique pour voir la réponse</summary>
En utilisant `--limit` pour cibler seulement un sous-ensemble d’hôtes (ex: `--limit webservers[0:1]` ou un sous-groupe).
</details>

### Q17. Que signifie `run_once: true` dans une tâche exécutée sur un groupe d’hôtes ?
<details>
<summary>Clique pour voir la réponse</summary>
La tâche ne sera exécutée qu’une seule fois (sur un seul hôte), même si le play cible plusieurs hôtes.
</details>

### Q18. Donne un exemple dans ton projet où `run_once` serait approprié.
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple, pour générer un artefact commun (certificat, archive, etc.) ou pour exécuter une tâche d’orchestration (mise à jour d’un load balancer).
</details>

### Q19. Comment combiner `run_once` et `delegate_to` pour orchestrer un composant central (ex: un load balancer) ?
<details>
<summary>Clique pour voir la réponse</summary>
En mettant `run_once: true` sur la tâche et `delegate_to: nom_du_lb`, de sorte que la tâche s’exécute une seule fois sur l’hôte délégué.
</details>

### Q20. Pourquoi est-il important en prod de bien maîtriser `serial`, `limit`, `forks`, `run_once` avant de lancer un gros déploiement ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que ce sont les leviers qui permettent de contrôler le risque, l’impact, la vitesse, et la fiabilité de tes déploiements sur un parc important.
</details>

---

## 🔹 3. Orchestration, delegate_to, blue/green, canary (Q21–Q30)

### Q21. À quoi sert `delegate_to` dans Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>
À exécuter une tâche sur un hôte différent de celui ciblé par le play (par exemple, un bastion, un load balancer, une machine de gestion).
</details>

### Q22. Donne un exemple concret de tâche dans ton projet que tu pourrais `delegate_to` une machine “bastion”.
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple, une tâche qui met à jour un DNS, un load balancer, ou qui récupère des infos d’un service central, plutôt que d’exécuter ça sur chaque webserver.
</details>

### Q23. Qu’est-ce qu’un déploiement “blue/green” en quelques mots ?
<details>
<summary>Clique pour voir la réponse</summary>
C’est une stratégie où l’on a deux ensembles de serveurs : un “blue” (actif) et un “green” (nouvelle version). On bascule le trafic de blue vers green une fois le nouveau déploiement validé.
</details>

### Q24. Comment Ansible peut-il aider à mettre en place un blue/green sur ton projet Nginx ?
<details>
<summary>Clique pour voir la réponse</summary>
En gérant deux groupes d’hôtes (blue et green), en déployant sur green, puis en modifiant la config d’un load balancer (ou DNS) via `delegate_to` pour rediriger le trafic.
</details>

### Q25. Qu’est-ce qu’un déploiement “canary” ?
<details>
<summary>Clique pour voir la réponse</summary>
Un déploiement où une petite portion des serveurs reçoit la nouvelle version en premier, pour vérifier le comportement avant de l’étendre à tout le parc.
</details>

### Q26. Comment pourrais-tu approximativement simuler une stratégie canary avec Ansible et ton inventaire ?
<details>
<summary>Clique pour voir la réponse</summary>
En ayant un sous-groupe d’hôtes “canary” dans l’inventaire et en lançant d’abord le playbook uniquement sur ce groupe, avant de l’exécuter sur tout `webservers`.
</details>

### Q27. Pourquoi la gestion de l’orchestration (ordre, bascule de trafic, rollback) est-elle plus critique que la simple “installation Nginx” dans un contexte avancé ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que ce sont ces étapes qui définissent si un déploiement se passe sans interruption de service, avec une bonne gestion des échecs et un retour en arrière possible.
</details>

### Q28. Comment utiliserais-tu `block` + `rescue` dans un scénario de blue/green ?
<details>
<summary>Clique pour voir la réponse</summary>
En mettant la mise à jour des serveurs green et la bascule du load balancer dans un `block`, et en faisant un rollback sur blue dans le `rescue` si quelque chose échoue.
</details>

### Q29. En quoi Ansible est-il adapté à l’orchestration applicative et pas seulement à la configuration système ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce qu’il permet de décrire et de séquencer des actions sur plusieurs composants (web, DB, LB, DNS…), avec conditions, délégués, blocs, etc.
</details>

### Q30. Quels sont les risques si tu fais un déploiement “all-in-one” sur tous les webservers sans serial ni canary ?
<details>
<summary>Clique pour voir la réponse</summary>
Si le déploiement casse quelque chose, tu peux casser tous les serveurs à la fois, avec une indisponibilité globale et un rollback plus compliqué.
</details>

---

## 🔹 4. Inventaires dynamiques, facts avancés, hostvars, groupvars (Q31–Q40)

### Q31. Qu’est-ce qu’un inventaire dynamique (dynamic inventory) ?
<details>
<summary>Clique pour voir la réponse</summary>
Un inventaire dont les hôtes et leurs variables sont obtenus dynamiquement (par exemple depuis AWS, GCP, un CMDB, etc.), via un script ou un plugin.
</details>

### Q32. Donne un exemple de contexte où un inventaire dynamique serait plus adapté que ton inventaire actuel en fichier.
<details>
<summary>Clique pour voir la réponse</summary>
Dans un environnement cloud où les serveurs sont créés/supprimés fréquemment (auto-scaling), il serait difficile de maintenir un fichier d’inventaire statique à jour.
</details>

### Q33. À quoi sert `hostvars` dans un playbook avancé ?
<details>
<summary>Clique pour voir la réponse</summary>
À accéder aux variables d’un autre hôte depuis un hôte donné, par exemple pour récupérer l’IP d’une base de données ou d’un load balancer.
</details>

### Q34. Donne un exemple où tu pourrais utiliser `hostvars` dans ton projet.
<details>
<summary>Clique pour voir la réponse</summary>
Si tu as un groupe `dbservers`, tes webservers pourraient récupérer `hostvars['db1']['db_ip']` pour configurer le fichier de connexion à la DB.
</details>

### Q35. Quelle est la différence entre `group_vars/webservers.yml` et `host_vars/monserveur.yml` ?
<details>
<summary>Clique pour voir la réponse</summary>
`group_vars/webservers.yml` définit des variables partagées par tous les hôtes du groupe `webservers`, alors que `host_vars/monserveur.yml` définit des variables spécifiques à un seul hôte.
</details>

### Q36. Pourquoi les `facts` (via le module `setup`) sont-ils utiles pour des playbooks avancés ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce qu’ils donnent des informations détaillées sur l’hôte (OS, interfaces, disques, etc.), permettant d’adapter automatiquement les tâches selon la plateforme ou la configuration.
</details>

### Q37. Donne un exemple de décision que tu pourrais prendre en fonction d’un fact dans ce projet.
<details>
<summary>Clique pour voir la réponse</summary>
Installer des paquets différents selon la distribution ou la version de l’OS (Debian vs Ubuntu), ou configurer différemment Nginx selon la RAM disponible.
</details>

### Q38. Qu’est-ce qu’un `custom fact` et comment peux-tu en utiliser un dans ton projet ?
<details>
<summary>Clique pour voir la réponse</summary>
Un script ou fichier placé dans `/etc/ansible/facts.d/` qui expose des variables propres à ton environnement. Tu peux ensuite les lire via `ansible_local` pour adapter tes playbooks.
</details>

### Q39. Pourquoi est-il important, dans un contexte avancé, de bien maîtriser la hiérarchie de priorité des variables (vars precedence) ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que mal comprendre qui écrase quoi (group_vars, host_vars, vars, extra-vars…) peut mener à des surprises en prod et à des comportements difficiles à comprendre.
</details>

### Q40. Donne un exemple de bug qui pourrait venir d’une mauvaise compréhension de la priorité des variables.
<details>
<summary>Clique pour voir la réponse</summary>
Définir un `nginx_port` dans `group_vars`, mais le surcharger involontairement via `vars` dans un play ou via `-e`, et ne pas comprendre pourquoi le port effectif n’est pas celui attendu.
</details>

---

## 🔹 5. CI/CD, qualité, Tower/AWX, “pro mindset” (Q41–Q50)

### Q41. Dans une pipeline CI, pourquoi est-il judicieux de séparer les jobs “lint”, “test (check-mode)” et “déploiement réel” ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour isoler les erreurs de style des erreurs fonctionnelles, et ne déclencher un déploiement réel que si les étapes de qualité et de simulation ont réussi.
</details>

### Q42. Comment pourrais-tu utiliser `ANSIBLE_CONFIG` dans une pipeline pour t’assurer que la bonne config est utilisée ?
<details>
<summary>Clique pour voir la réponse</summary>
En définissant la variable d’environnement `ANSIBLE_CONFIG` vers le `ansible.cfg` du projet dans le job CI, afin que Ansible ne prenne pas un autre fichier de config par défaut.
</details>

### Q43. À quoi sert un outil comme AWX ou Ansible Tower au-dessus d’Ansible CLI ?
<details>
<summary>Clique pour voir la réponse</summary>
À offrir une interface web, une gestion centralisée des inventaires, des credentials, des rôles, une planification de jobs, des logs centralisés et un meilleur contrôle d’accès (RBAC).
</details>

### Q44. Dans un contexte pro, pourquoi est-il important de gérer les credentials (mots de passe, clés SSH) via Tower/AWX ou un store dédié plutôt que dans les playbooks ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour centraliser et sécuriser les secrets, limiter qui peut les voir, journaliser les accès, et éviter qu’ils ne soient exposés dans le code ou les dépôts Git.
</details>

### Q45. Comment intégrerais-tu ton projet actuel dans AWX/Tower ?
<details>
<summary>Clique pour voir la réponse</summary>
En créant un projet pointant sur le dépôt Git de ton code, en définissant des inventaires (dev/prod), des credentials (Vault, SSH), et des job templates pour exécuter les playbooks `site.yml`.
</details>

### Q46. Que signifie “idempotence + observabilité” comme objectif de qualité pour des playbooks avancés ?
<details>
<summary>Clique pour voir la réponse</summary>
Que les playbooks peuvent être relancés sans surprise (idempotence) et qu’ils produisent des logs et des métriques compréhensibles pour savoir ce qui a changé, où et pourquoi.
</details>

### Q47. Pourquoi documenter ton projet Ansible (README, schémas simples, conventions) est critique dans un contexte d’équipe ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour que d’autres puissent comprendre la structure, les conventions, les rôles, les environnements, et contribuer sans tout casser ou perdre du temps à deviner.
</details>

### Q48. Quels types d’alertes ou de dashboards pourrais-tu lier aux exécutions Ansible pour avoir une réelle vision “DevOps” ?
<details>
<summary>Clique pour voir la réponse</summary>
Alertes sur taux d’échec des jobs, temps moyen des déploiements, nombre de serveurs impactés, changements par environnement, couplés à des métriques applicatives (erreurs 5xx, latence).
</details>

### Q49. Pour un entretien DevOps, comment expliquerais-tu en 1–2 minutes ton projet Ansible Nginx + users + vault + lint en mode “pro” ?
<details>
<summary>Clique pour voir la réponse</summary>
En décrivant l’arborescence (inventaires dev/prod, group_vars, rôles séparés web/users), l’usage de Vault pour les secrets, de Jinja/Lookups pour la config dynamique, de ansible-lint et check-mode pour la qualité, et la possibilité de l’intégrer en CI/CD ou AWX.
</details>

### Q50. À ton avis, quelle est la principale différence d’attitude entre un “utilisateur Ansible débutant” et un “praticien avancé/pro” ?
<details>
<summary>Clique pour voir la réponse</summary>
Le pro pense en termes de structure, de risque, de rollback, de test, de CI/CD, de sécurité, de lisibilité pour l’équipe, alors que le débutant pense surtout à “faire marcher la commande”.
</details>
