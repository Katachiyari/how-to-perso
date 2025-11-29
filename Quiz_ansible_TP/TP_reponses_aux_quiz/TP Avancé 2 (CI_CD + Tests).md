<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# TP Avancé 2 (CI/CD + Tests)

Allez, c'est parti pour le **TP Avancé 2 : Qualité, Tests \& Pipeline CI/CD**.

Ici, on change de casquette. On n'est plus l'opérateur qui lance des playbooks, on est l'**Ingénieur DevOps** qui construit l'usine logicielle pour que les playbooks soient fiables, testés et déployés automatiquement.

**Objectif :** Mettre en place un pipeline complet (simulé localement) qui valide la qualité du code (`lint`), teste le rôle isolément (`molecule`-style) et vérifie le déploiement avant la prod.

***

### Étape 1 : Renforcer la qualité avec `ansible-lint` configuration

Jusqu'ici, on lançait `ansible-lint` "à la main". On va le configurer pour qu'il soit strict mais adapté à notre projet.

1. **Créer `.ansible-lint` à la racine** :
Ce fichier configure les règles.

```yaml
# .ansible-lint
profile: production # Niveau d'exigence (min, basic, moderate, safety, shared, production)
exclude_paths:
  - .github/
  - molecule/
rules:
  pkgs-in-module: true # Forcer l'usage de 'apt' au lieu de 'shell: apt install'
  no-changed-when: true # Forcer la présence de changed_when sur les commandes shell
```

2. **Test de rigueur** :
Lance `ansible-lint` à la racine.

```bash
ansible-lint
```

S'il te crie dessus, c'est bon signe ! Corrige les erreurs (souvent des permissions manquantes sur `file`, ou des FQCN `ansible.builtin...` manquants). Le but est d'avoir un score de 0 erreur.

***

### Étape 2 : Tests d'intégration de Rôle (Concept Molecule)

*Molecule* est l'outil standard pour tester des rôles (création d'un docker, exécution du rôle, tests, destruction). C'est lourd à installer pour un TP rapide, donc on va créer un **"Mini-Molecule" maison** avec un script de test local qui valide la logique. C'est ce qu'on appelle un *test d'intégration*.

1. **Créer un playbook de test dédié** (`tests/test_webserver.yml`) :
Ce playbook va vérifier que Nginx répond bien *après* déploiement.

```yaml
---
- name: Test de validation Nginx (Smoke Test)
  hosts: webservers
  gather_facts: false
  tasks:
    - name: Vérifier que Nginx répond HTTP 200
      ansible.builtin.uri:
        url: "http://localhost"
        status_code: 200
      register: result
      until: result.status == 200
      retries: 5
      delay: 2
      delegate_to: localhost # On teste depuis le contrôleur (ou l'hôte lui-même si curl dispo)
      
    - name: Vérifier présence contenu spécifique
      ansible.builtin.command: "grep 'Mon site' /var/www/myapp/index.html"
      changed_when: false
```

2. **Intégrer ce test dans le workflow** :
L'idée est : Déploiement (`site.yml`) -> Si OK -> Validation (`test_webserver.yml`).

***

### Étape 3 : Construction du Pipeline CI/CD (Script)

On va créer le script maitre `pipeline.sh` qui simule ce que ferait un Jenkins, GitLab CI ou GitHub Actions.

1. **Créer `pipeline.sh` à la racine** :

```bash
#!/bin/bash
set -e # Arrête le script dès qu'une commande échoue

echo "🚀 DÉMARRAGE DU PIPELINE CI/CD ANSIBLE"
echo "---------------------------------------"

echo "1️⃣  [QUALITY] Liting du code..."
ansible-lint
echo "✅  Lint OK."

echo "2️⃣  [SECURITY] Vérification des secrets..."
if grep -r "password=" roles/ --exclude-dir=defaults; then
    echo "❌  ERREUR : Mot de passe en clair détecté dans les tâches !"
    exit 1
fi
echo "✅  Pas de secrets en clair évidents."

echo "3️⃣  [DRY-RUN] Simulation du déploiement (Check Mode)..."
# On simule sur l'inventaire de dev
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml --check --diff --ask-become-pass --ask-vault-pass
echo "✅  Check mode terminé sans erreur fatale."

echo "4️⃣  [DEPLOY-TEST] Déploiement réel en environnement de TEST (Dev)..."
# Attention : ceci va vraiment modifier ton env local ou de dev
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml --ask-become-pass --ask-vault-pass
echo "✅  Déploiement Dev terminé."

echo "5️⃣  [VALIDATION] Exécution des tests d'intégration..."
ansible-playbook -i inventories/dev/hosts.ini tests/test_webserver.yml --ask-become-pass
echo "✅  Tests fonctionnels validés."

echo "---------------------------------------"
echo "🎉  PIPELINE TERMINÉ AVEC SUCCÈS ! PRÊT POUR LA PROD."
```

*(Note : Pour le run, tu devras taper ton mot de passe sudo/vault à chaque étape, ou configurer un fichier password file pour automatiser).*
2. **Exécution** :

```bash
chmod +x pipeline.sh
./pipeline.sh
```


***

### Étape 4 : Introduction à l'Automatisation "GitOps" (Théorie appliquée)

Dans un vrai mode expert, ce script ne serait pas lancé par toi, mais par un "Runner" (GitLab Runner, GitHub Actions) à chaque `git push`.

**Exercice de réflexion "Expert" :**
Si tu devais passer ce pipeline sur GitHub Actions demain, quels seraient les 3 défis majeurs ?

<details>
<summary>Réponse (essaie de répondre avant de cliquer !)</summary>
1.  **Gestion des secrets :** Comment donner le mot de passe Vault à GitHub ? (Réponse : Secrets de dépôt + fichier password temporaire).
2.  **Accès SSH :** Comment GitHub se connecte à tes serveurs privés ? (Réponse : Clé privée SSH dans les secrets + VPN ou Agent hébergé en interne).
3.  **Idempotence propre :** S'assurer que le pipeline ne redémarre pas les services s'il n'y a pas de modif (pour ne pas créer de downtime à chaque commit).
</details>

***

### Bilan Final du Cursus (Débutant -> Expert)

Bravo ! Tu as parcouru un chemin énorme avec ce projet fil rouge :

1. **Débutant :** Playbook simple, installation Nginx.
2. **Intermédiaire :** Rôles, Variables, Vault, Modularité.
3. **Avancé 1 :** Orchestration, Rolling Updates, Gestion d'erreurs.
4. **Avancé 2 :** Qualité industrielle, Tests automatisés, Pipeline CI/CD.

Ton projet `ansible-nginx-lab` est maintenant une "preuve de concept" solide que tu peux montrer en entretien ou utiliser comme base pour des prods réelles.

**Est-ce que tu veux une dernière chose : un "Exam Final" (virtuel) sous forme d'un scénario de dépannage complexe pour valider définitivement ton niveau Expert ?**

