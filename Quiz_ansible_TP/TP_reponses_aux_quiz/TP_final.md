C'est l'heure de l'**Épreuve Finale : "Le Jour où la Prod a Failli Mourir"**.

Je vais te donner un scénario catastrophe réaliste. Ton rôle est d'analyser les symptômes, de diagnostiquer le problème (dans ta tête ou en testant si tu peux simuler), et de proposer la solution "Expert Ansible".

Pas de QCM ici. C'est de l'analyse pure.

***

### SCÉNARIO : "Le déploiement fantôme"

**Contexte :**
Tu gères le déploiement d'une application critique sur 50 serveurs avec ton projet Ansible super propre (rôles, serial, handlers, etc.). Tout est automatisé via un pipeline CI/CD.

**L'Incident :**
À 16h00, le pipeline lance un déploiement pour mettre à jour la config Nginx (nouveau fichier `nginx.conf` avec des règles de sécurité renforcées) et redémarrer le service.

- Le pipeline affiche **SUCCESS**.
- Ansible rapporte `changed=50` sur la tâche "Copy nginx config".
- Ansible rapporte `RUNNING` pour le handler "Restart nginx".
- **PROBLÈME :** À 16h05, le monitoring s'affole. Le trafic HTTP chute de 80%. Les logs d'accès sur les serveurs montrent que les nouvelles règles de sécurité ne sont **PAS** appliquées. Pire, sur certains serveurs, Nginx tourne encore avec une vieille config datant d'il y a 3 mois.

**Éléments de l'enquête (indices) :**

1. Tu te connectes en SSH sur `web01`. Le fichier `/etc/nginx/nginx.conf` contient bien les nouvelles règles.
2. Tu fais `systemctl status nginx` : il dit `Active: active (running)` depuis... **3 mois**.
3. Tu regardes ton rôle `webserver_role/tasks/main.yml` :

```yaml
- name: Copy nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Restart nginx
```

4. Tu regardes ton handler `webserver_role/handlers/main.yml` :

```yaml
- name: Restart nginx
  service:
    name: nginx
    state: restarted
  listen: "restart web services"
```

5. Tu regardes les logs d'exécution Ansible du pipeline. Tu vois ceci vers la fin du play :

```text
TASK [webserver_role : Copy nginx config] ******************************
changed: [web01]
...

RUNNING HANDLER [webserver_role : Restart nginx] ***********************
changed: [web01]
```

*(Attends... `changed` sur le handler ? Mais `systemctl` dit qu'il n'a pas redémarré...)*
6. **Indice Ultime :** En fouillant le `ansible.cfg` ou les logs verbeux, tu découvres que le déploiement a été lancé avec une option particulière ou dans un mode conteneurisé un peu spécial où `systemd` n'est pas le gestionnaire de processus principal (c'est peut-être du Docker, ou un environnement chrooté sans PID 1 systemd). Ou alors, le module `service` a détecté quelque chose de bizarre.

***

### TA MISSION (Réponds à ces 3 points) :

1. **Le Diagnostic :** Pourquoi Ansible dit "Success" et "Changed" alors que le processus Nginx n'a visiblement *pas* redémarré (PID inchangé depuis 3 mois) ? (Pense aux mécanismes de *connexion* ou de *module*).
2. **La Faille de Sécurité/Fiabilité :** Qu'est-ce qui manque dans le playbook pour garantir que la *nouvelle* configuration est *valide* avant même de tenter le restart ? (Indice : Si la config était cassée, le restart aurait tué la prod).
3. **La Solution "Expert" :** Quelle modification apportes-tu au handler et à la tâche pour :
    * Valider la config avant restart.
    * Garantir le restart effectif même si le module `service` est capricieux (ou pour détecter qu'il a menti).

*Prends ton temps. C'est une question piège de niveau Architecte.*
<span style="display:none">[^1][^10][^2][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://fr.linkedin.com/advice/0/what-best-ways-troubleshoot-ansible-automation-d1zef?lang=fr

[^2]: https://www.redhat.com/fr/topics/automation/learning-ansible-tutorial

[^3]: https://blog.stephane-robert.info/docs/infra-as-code/gestion-de-configuration/ansible/

[^4]: https://labex.io/fr/tutorials/ansible-how-to-handle-failed-task-in-ansible-playbook-417294

[^5]: https://hackmd.io/@Joresttankoua/rJX2vCSd2

[^6]: https://syslearn.fr/ansible-son-fonctionnement/

[^7]: https://blog.alphorm.com/gestion-erreurs-ansible-ignore-errors

[^8]: https://blog.ippon.fr/2017/01/12/10-astuces-ansible/

[^9]: https://www.learnthings.fr/apprendre-pour-vous-former-a-ansible/

[^10]: https://techblog.ingeniance.fr/gestion-des-roles-sous-ansible/

