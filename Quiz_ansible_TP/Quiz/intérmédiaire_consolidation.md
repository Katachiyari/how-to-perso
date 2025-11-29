<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# je préfère consolidé le mode intérmédiaire dans ce cas.

On a le temps de bien apprendre.
Soyons solide !
Donc complément d'un questionnaire 20, 30 ou 40 questions (a toi de voir) pour consolider le mode intermédiaire, couvrir les "2–3 briques à consolider"

Tu as raison de vouloir être solide avant de monter d’un cran.

Voici un **complément de 30 questions intermédiaires** (en .md, avec réponses cachées) ciblé sur les 3 briques à consolider :

- filtres Jinja (listes/dicos),
- lookups (env, file, password, etc.),
- inventaires + CI simples.

Toujours dans le même projet fil rouge.

```markdown
# 🧠 Quiz Ansible – Consolidation intermédiaire (30 questions)

Briques ciblées :
- Filtres Jinja (listes/dicos, formatage)
- Lookups (env, file, password, etc.)
- Inventaires + intégration CI simple

Projet fil rouge : nginx + users + fichiers + rôles + vault + ansible-lint.

---

## 🔹 Jinja & manipulation de données (Q1–Q10)

### Q1. Dans ton template `index.html.j2`, pourquoi est-il utile d’afficher `{{ inventory_hostname }}` ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour savoir sur quel hôte le template a été rendu, utile pour déboguer ou distinguer les serveurs d’un cluster.
</details>

### Q2. Si tu as une variable `web_sites: ['site1', 'site2', 'site3']`, comment afficher cette liste dans un template sous forme de chaîne séparée par des virgules ?
<details>
<summary>Clique pour voir la réponse</summary>
Avec `{{ web_sites | join(', ') }}`.
</details>

### Q3. Comment vérifier dans un template si la variable `environment` vaut `prod` ?
<details>
<summary>Clique pour voir la réponse</summary>
Avec une condition Jinja, par exemple :
`{% if environment == 'prod' %} ... {% endif %}`.
</details>

### Q4. Tu as une liste de users `users: [{'name': 'alice'}, {'name': 'bob'}]`. Comment afficher seulement les noms (`alice, bob`) dans un template ?
<details>
<summary>Clique pour voir la réponse</summary>
En combinant `map` et `join` :
`{{ users | map(attribute='name') | join(', ') }}`.
</details>

### Q5. Tu veux afficher la longueur de la variable `db_password` (chargée via Vault) sans afficher le secret. Que mets-tu dans ton template ou debug ?
<details>
<summary>Clique pour voir la réponse</summary>
`{{ db_password | length }}` ou dans une tâche debug :
`msg: "Longueur du mot de passe = {{ db_password | length }}"`.
</details>

### Q6. Pourquoi est-il recommandé d’utiliser `| default('valeur')` sur certaines variables dans les templates ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour éviter des erreurs (undefined variable) et fournir une valeur par défaut quand la variable n’est pas définie pour un environnement donné.
</details>

### Q7. Tu veux afficher `UP` si `nginx_port_check.rc == 0`, sinon `DOWN`. Comment pourrais-tu écrire ça en Jinja dans un template ?
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple :
`{{ 'UP' if nginx_port_check.rc == 0 else 'DOWN' }}`.
</details>

### Q8. Tu as une variable `extra_headers` qui peut être `None` ou une liste de chaînes. Comment l’itérer proprement dans un template sans erreur si elle n’est pas définie ?
<details>
<summary>Clique pour voir la réponse</summary>
Avec :
`{% for h in extra_headers | default([]) %} ... {% endfor %}`.
</details>

### Q9. Pourquoi est-il important de bien maîtriser les filtres Jinja pour générer les fichiers de config Nginx dynamiquement ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que les configs réelles comportent souvent des listes, des options conditionnelles, des blocs optionnels ; bien manier Jinja permet d’avoir des templates propres et flexibles sans dupliquer du code.
</details>

### Q10. Tu veux trier une liste `web_sites` avant de l’afficher en template. Quel filtre utilises-tu ?
<details>
<summary>Clique pour voir la réponse</summary>
Le filtre `sort` :
`{{ web_sites | sort | join(', ') }}`.
</details>

---

## 🔹 Lookups (env, file, password, vars, etc.) (Q11–Q20)

### Q11. À quoi sert la fonction `lookup()` dans Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>
À récupérer des données à partir de différentes sources (fichiers, variables d’environnement, générateurs de mots de passe, etc.) au moment de l’exécution.
</details>

### Q12. Comment récupères-tu la variable d’environnement `HOME` dans une tâche Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>
Avec :
`lookup('env', 'HOME')`, par exemple :
`msg: "{{ lookup('env', 'HOME') }}"`.
</details>

### Q13. Tu as un fichier `files/extra.conf` à inclure dans une config Nginx via template. Comment lire son contenu avec lookup dans une variable ?
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple :
`set_fact: extra_conf: "{{ lookup('file', 'files/extra.conf') }}"`.
</details>

### Q14. Quelle différence entre `copy: src=files/toto` et `lookup('file', 'files/toto')` ?
<details>
<summary>Clique pour voir la réponse</summary>
`copy` copie un fichier du contrôleur vers la cible ; `lookup('file')` lit le contenu du fichier dans une variable côté contrôleur (sans forcément le copier).
</details>

### Q15. À quoi peut servir `lookup('password', ...)` dans un projet Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>
À générer ou récupérer un mot de passe (souvent stocké dans un fichier) de façon automatique pour l’utiliser comme secret (par exemple un mot de passe DB).
</details>

### Q16. Comment pourrais-tu générer un mot de passe unique par machine et le stocker dans un fichier local avec `lookup('password')` ?
<details>
<summary>Clique pour voir la réponse</summary>
En utilisant un chemin incluant `inventory_hostname`, par exemple :
`lookup('password', 'secrets/{{ inventory_hostname }}.pass length=32')`.
</details>

### Q17. Pourquoi faut-il faire attention à ne pas afficher en clair le résultat d’un `lookup('password', ...)` dans un debug ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que cela afficherait le secret dans la sortie du playbook et éventuellement dans des logs ou CI, ce qui est un risque de sécurité.
</details>

### Q18. Comment masses-tu une variable de Vault (ex: `db_password`) avec une valeur issue d’un `lookup()` si la valeur Vault n’est pas définie ?
<details>
<summary>Clique pour voir la réponse</summary>
En utilisant `default` combiné à `lookup`, par exemple :
`db_password: "{{ db_password | default(lookup('password', '...')) }}"`.
</details>

### Q19. Quelle est la différence entre `lookup('vars', 'ma_variable')` et l’utilisation directe de `{{ ma_variable }}` ?
<details>
<summary>Clique pour voir la réponse</summary>
`lookup('vars', ...)` va chercher une variable par son nom dans l’espace de variables, ce qui peut être utile quand le nom de la variable est lui-même dynamique.
</details>

### Q20. Pourquoi les lookups sont particulièrement utiles quand on commence à intégrer Ansible avec d’autres systèmes (vault externe, cloud, etc.) ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce qu’ils permettent d’aller chercher dynamiquement des données externes (secrets, IP dynamiques, configs) sans les stocker en dur dans les fichiers de variables.
</details>

---

## 🔹 Inventaires + CI / Qualité (Q21–Q30)

### Q21. Quelle est la différence principale entre un inventaire INI (`hosts.ini`) et un inventaire YAML (`hosts.yml`) ?
<details>
<summary>Clique pour voir la réponse</summary>
INI est plus simple et historique, YAML est plus expressif (peut inclure des variables par hôte/groupe, plugins d’inventaire, etc.).
</details>

### Q22. Pourquoi est-il intéressant, dans ton projet, de garder des inventaires séparés pour `dev` et `prod` même si les hôtes sont uniques ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour isoler les paramètres (variables, secrets, ports, domaines) par environnement et éviter de cibler la prod par erreur en utilisant un inventaire unique.
</details>

### Q23. Comment peux-tu forcer un playbook à utiliser l’inventaire `inventories/prod/hosts.ini` même si `ansible.cfg` pointe sur `inventories/dev/hosts.ini` ?
<details>
<summary>Clique pour voir la réponse</summary>
En utilisant l’option `-i` :
`ansible-playbook playbooks/site.yml -i inventories/prod/hosts.ini`.
</details>

### Q24. Pourquoi est-ce une mauvaise idée de mélanger les hôtes dev et prod dans le même groupe `[webservers]` du même inventaire sans distinction ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce qu’un même playbook pourrait alors toucher dev et prod en même temps, compliquer la gestion des variables spécifiques et augmenter fortement le risque d’erreurs.
</details>

### Q25. Dans une CI simple (GitLab, GitHub Actions…), pourquoi lancer `ansible-lint` en premier puis `ansible-playbook --check` ensuite ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce que `ansible-lint` détecte immédiatement les problèmes de style et de mauvaises pratiques ; si tout est OK, on fait ensuite un “dry run” fonctionnel avec `--check` pour voir les changements potentiels.
</details>

### Q26. Que se passe-t-il si `ansible-lint` échoue dans une pipeline CI bien configurée ?
<details>
<summary>Clique pour voir la réponse</summary>
Le job CI échoue, et par conséquent le pipeline est marqué en échec, empêchant par exemple un déploiement automatique.
</details>

### Q27. Pourquoi est-il utile de faire tourner `ansible-lint` aussi en local, avant même de pousser sur Git ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour corriger les problèmes tôt, éviter des allers-retours avec la CI, et appliquer les bonnes pratiques dès le développement local.
</details>

### Q28. Donne un exemple de “garde-fous” simples à mettre dans ta CI autour de ce projet.
<details>
<summary>Clique pour voir la réponse</summary>
Par exemple : bloquer tout commit contenant un fichier non chiffré `*vault.yml`, ou toute exécution de playbook sans `--check` sur un inventaire de prod.
</details>

### Q29. Pourquoi est-il important de tester au moins avec un “dummy environment” (une VM ou un conteneur) avant de faire tourner Ansible sur de vrais serveurs de prod ?
<details>
<summary>Clique pour voir la réponse</summary>
Pour vérifier que le rôle se comporte comme prévu (chemins, packages, services) sans risquer de casser des services en production.
</details>

### Q30. En quoi la combinaison “rôles bien écrits + inventaires propres + lint + check-mode” te rapproche déjà d’un usage “semi-pro” d’Ansible ?
<details>
<summary>Clique pour voir la réponse</summary>
Parce qu’elle impose une structure maîtrisée, des contrôles systématiques, et une séparation claire des environnements, réduisant fortement les erreurs humaines et rendant les déploiements prédictibles.
</details>
```

Avec ces 30 questions, tu consolides exactement les briques qui manquaient pour être très à l’aise en intermédiaire.

Question pour la suite :
Tu préfères qu’on construise maintenant une **petite mise en pratique dédiée aux filtres Jinja + lookups** (avec ton projet actuel), ou plutôt une **mise en pratique “CI simple” (ansible-lint + check + un faux job CI) ?**

