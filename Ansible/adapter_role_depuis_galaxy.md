# si je veux adapter ce rôle, comment je fais ?

[https://galaxy.ansible.com/ui/standalone/roles/sarathkgit/nginx_geerlingguy/](https://galaxy.ansible.com/ui/standalone/roles/sarathkgit/nginx_geerlingguy/)

Pour adapter le rôle `sarathkgit.nginx_geerlingguy` depuis Ansible Galaxy, voici les étapes recommandées :

***

## 🔄 Méthodes pour adapter un rôle Galaxy

### 1. **Fork + Clone (Recommandé pour modification permanente)**

```bash
# 1. Fork le rôle sur GitHub depuis la page Galaxy
# 2. Clonez votre fork localement
git clone https://github.com/VOTRE_USERNAME/nginx_geerlingguy.git

# 3. Installez-le localement
ansible-galaxy install -r requirements.yml
```

**Avantages** : Vous contrôlez les mises à jour et pouvez contribuer en amont.

***

### 2. **Téléchargement direct + Modification**

```bash
# 1. Téléchargez le rôle
ansible-galaxy install sarathkgit.nginx_geerlingguy --roles-path ./roles/

# 2. Copiez dans votre projet
cp -r roles/sarathkgit.nginx_geerlingguy roles/nginx_custom/

# 3. Modifiez le rôle dans roles/nginx_custom/
```


***

### 3. **Utilisation avec override de variables (Sans modification)**

```yaml
# Dans votre playbook
- name: Déployer NGINX avec customisations
  hosts: web
  roles:
    - role: sarathkgit.nginx_geerlingguy
      nginx_vhosts:
        - listen: ['80']
          server_name: "mon-site.com"
          root: "/var/www/mon-site"
      nginx_upstreams: []  # Désactive les upstreams si non nécessaires
```

**Avantages** : Pas de duplication, mise à jour facile.

***

## 🛠️ Structure typique d'adaptation

```
mon-projet/
├── roles/
│   ├── nginx_custom/          # Votre version modifiée
│   │   ├── defaults/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── meta/main.yml
├── requirements.yml           # Dépendances Galaxy
├── playbook.yml
└── README.md
```


***

## 📝 Exemple `requirements.yml` avec version locale

```yaml
# Version Galaxy originale (non modifiée)
- name: geerlingguy.mysql
  version: ">=5.1.0,<6.0.0"

# Votre rôle customisé (local)
collections:
  - name: community.general
```


***

## 🎯 Bonnes pratiques

1. **Ne modifiez jamais un rôle Galaxy directement** → Copiez-le d'abord.
2. **Renommez le rôle** : `nginx_custom` au lieu de `nginx_geerlingguy`.
3. **Mettez à jour `meta/main.yml`** :

```yaml
galaxy_info:
  role_name: nginx_custom
  author: votre_nom
  description: NGINX adapté pour mon projet
  min_ansible_version: "2.10"
```

4. **Documentez vos changements** dans `README.md`.

***

## 🚀 Commandes rapides

```bash
# Installation Galaxy
ansible-galaxy install sarathkgit.nginx_geerlingguy

# Copie et renommage
cp -r roles/sarathkgit.nginx_geerlingguy roles/nginx_custom

# Test du rôle modifié
ansible-playbook playbook.yml --check
```


***

**La méthode 3 (override variables) est souvent suffisante pour 80% des cas. Utilisez fork/clone seulement si vous avez besoin de modifier la logique interne du rôle.** 🔧

