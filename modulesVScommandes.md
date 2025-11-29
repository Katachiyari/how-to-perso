### 🛠️ Cheat Sheet : Shell vs Ansible (Best Practices)

## 📦 Gestion des Paquets \& Services

| Action Shell (Legacy) | Module Ansible (Recommandé) | Exemple minimal |
| :-- | :-- | :-- |
| `apt-get install nginx` | **`ansible.builtin.apt`** | `name: nginx state: present` |
| `yum install httpd` | **`ansible.builtin.yum`** (ou `dnf`) | `name: httpd state: present` |
| `systemctl start nginx` | **`ansible.builtin.service`** | `name: nginx state: started` |
| `systemctl enable nginx` | **`ansible.builtin.service`** | `name: nginx enabled: true` |
| `systemctl restart nginx` | **`ansible.builtin.service`** | `name: nginx state: restarted` |
| `pip install requests` | **`ansible.builtin.pip`** | `name: requests state: present` |

#### 📂 Fichiers \& Dossiers

| Action Shell (Legacy) | Module Ansible (Recommandé) | Exemple minimal |
| :-- | :-- | :-- |
| `mkdir -p /var/www/site` | **`ansible.builtin.file`** | `path: /var/www/site state: directory` |
| `chmod 755 /file` | **`ansible.builtin.file`** | `path: /file mode: '0755'` |
| `chown user:group /file` | **`ansible.builtin.file`** | `path: /file owner: user group: group` |
| `ln -s /src /dest` | **`ansible.builtin.file`** | `src: /src dest: /dest state: link` |
| `rm -rf /path` | **`ansible.builtin.file`** | `path: /path state: absent` |
| `cp source.txt dest.txt` | **`ansible.builtin.copy`** | `src: source.txt dest: dest.txt` |
| `wget http://url/file` | **`ansible.builtin.get_url`** | `url: http://... dest: /tmp/file` |
| `tar -xvf archive.tar.gz` | **`ansible.builtin.unarchive`** | `src: archive.tar.gz dest: /tmp/` |

#### 📝 Modification de contenu (Texte)

| Action Shell (Legacy) | Module Ansible (Recommandé) | Exemple minimal |
| :-- | :-- | :-- |
| `echo "text" > file` | **`ansible.builtin.copy`** | `content: "text" dest: file` |
| `sed -i 's/foo/bar/g'` | **`ansible.builtin.replace`** | `path: file regexp: 'foo' replace: 'bar'` |
| `grep "line" file >> file` | **`ansible.builtin.lineinfile`** | `path: file line: "line" state: present` |
| `cat template.conf` | **`ansible.builtin.template`** | `src: tpl.j2 dest: /etc/conf` |

#### 👤 Utilisateurs \& Groupes

| Action Shell (Legacy) | Module Ansible (Recommandé) | Exemple minimal |
| :-- | :-- | :-- |
| `useradd -m deploy` | **`ansible.builtin.user`** | `name: deploy state: present` |
| `groupadd developers` | **`ansible.builtin.group`** | `name: developers state: present` |
| `usermod -aG sudo bob` | **`ansible.builtin.user`** | `name: bob groups: sudo append: true` |
| `ssh-copy-id ...` | **`ansible.posix.authorized_key`** | `user: deploy key: "{{ ssh_pub_key }}"` |

#### 🔧 Commandes système \& Divers

| Action Shell (Legacy) | Module Ansible (Recommandé) | Exemple minimal |
| :-- | :-- | :-- |
| `reboot` | **`ansible.builtin.reboot`** | `msg: "Rebooting after update"` |
| `cron -e` | **`ansible.builtin.cron`** | `name: "Backup" job: "/bin/backup.sh"` |
| `git clone ...` | **`ansible.builtin.git`** | `repo: https://... dest: /src` |
| `mount /dev/sdb1 /mnt` | **`ansible.posix.mount`** | `path: /mnt src: /dev/sdb1 state: mounted` |
| `ping` | **`ansible.builtin.ping`** | *(Pas de paramètre, test de connexion)* |
| `sh script.sh` | **`ansible.builtin.script`** | `cmd: /local/path/to/script.sh` |
| *N'importe quoi d'autre* | **`ansible.builtin.command`** | `cmd: /bin/my_custom_tool --flag` |


***

### 💡 Astuce de Pro :

Si tu hésites entre `shell` et un module, demande-toi : *"Est-ce que je veux juste lancer une commande, ou est-ce que je veux atteindre un état ?"*

* Lancer une commande ➔ `command` ou `shell` (dernier recours).
* Atteindre un état (installé, présent, démarré) ➔ **Utilise le module dédié ci-dessus.**

*Garde cette liste sous le coude pour tes TPs !*

***
**On revient à notre scénario catastrophe "Le déploiement fantôme" ?** Tu as les 3 questions en attente pour valider ton niveau Expert Architecte ! 😉
<span style="display:none">[^1][^10][^2][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://docs.ansible.com/projects/ansible/latest/command_guide/cheatsheet.html

[^2]: https://blog.stephane-robert.info/docs/infra-as-code/gestion-de-configuration/ansible/modules/

[^3]: https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/index.html

[^4]: https://spacelift.io/blog/ansible-cheat-sheet

[^5]: https://github.com/germainlefebvre4/ansible-cheatsheet

[^6]: https://linux.goffinet.org/ansible/modules-ansible/

[^7]: https://cyberpanel.net/blog/ansible-cheat-sheet

[^8]: https://wiki-tech.io/Configuration/Ansible/Modules

[^9]: https://github.com/paulfinol/ansible-cheat-sheet

[^10]: https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/version_test.html

