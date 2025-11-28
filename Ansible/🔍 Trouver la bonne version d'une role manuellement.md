## 🔍 Trouver la bonne version manuellement


***

### **Méthode 1 : Page Ansible Galaxy (Plus simple)**

1. Allez sur la page du rôle :
https://galaxy.ansible.com/geerlingguy/mysql
2. Cliquez sur **"Versions"** ou faites défiler vers le bas.
Vous verrez toutes les versions disponibles avec dates.

***

### **Méthode 2 : API Ansible Galaxy (Commande)**

```bash
# Lister TOUTES les versions disponibles
ansible-galaxy role list --versions geerlingguy.mysql
```

**Ou avec curl directement :**

```bash
curl -s "https://galaxy.ansible.com/api/v3/roles/?namespace=geerlingguy&name=mysql" | jq '.data[].summary_fields.versions'
```


***

### **Méthode 3 : GitHub Releases (Repository source)**

1. Allez sur le repo GitHub :
https://github.com/geerlingguy/ansible-role-mysql/releases
2. Consultez les **tags/releases** pour voir les versions publiées.

***

### **Méthode 4 : Commande Galaxy avec verbose**

```bash
ansible-galaxy role install geerlingguy.mysql --no-deps -vvv
```

Affiche toutes les versions disponibles avant échec.

***

## ✅ Exemple pratique complet

```bash
# 1. Vérifier les versions disponibles
ansible-galaxy role list --versions geerlingguy.mysql

# 2. Tester installation d'une version spécifique (dry-run)
ansible-galaxy role install geerlingguy.mysql==5.1.0 -p ./roles --force --dry-run

# 3. Installer la bonne version
ansible-galaxy role install geerlingguy.mysql==5.1.0 -p ./roles
```


***

## 📋 Versions stables recommandées (mysql)

| Version | Statut | Recommandé |
| :-- | :-- | :-- |
| `5.1.0` | ✅ Stable | **OUI** |
| `4.3.5` | ✅ Stable | OUI |
| `6.0.0` | ⚠️ Major | Attention |


***

## 🚀 Commande rapide (toutes les infos)

```bash
# Une seule commande pour tout voir
curl -s "https://galaxy.ansible.com/api/v3/roles/?namespace=geerlingguy&name=mysql" | \
jq -r '.data[0].summary_fields.versions[] | "\(.version) - \(.created)"' | \
sort -V -r | head -10
```

**Résultat** : Liste des 10 dernières versions avec dates.

***

**La méthode Galaxy page web est la plus visuelle et rapide pour débuter !** 🌐

