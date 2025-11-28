<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# 📂 Best Practices pour la création d’un dépôt GitHub (local ↔ distant)


***

## 🚀 Étapes recommandées

1. **Nommer clairement le dépôt**
Utilisez un nom descriptif et cohérent, évitez les caractères spéciaux ou espaces.
Exemple : `mon-projet-web` ou `api-rest-nodejs`.
2. **Créer le dépôt sur GitHub**
    - Connectez-vous à GitHub et créez un nouveau dépôt.
    - Ne cochez pas "Initialize this repository with a README" si vous avez déjà des fichiers locaux.
3. **Initialiser Git localement**

```bash
git init
git add .
git commit -m "Initial commit"
```

4. **Lier le dépôt local au dépôt distant**

```bash
git remote add origin https://github.com/votre-username/mon-projet.git
```

5. **Envoyer le code vers GitHub**

```bash
git push -u origin main
```

    - Si la branche par défaut est `master`, remplacez `main` par `master`.

***

## ✅ Bonnes pratiques à suivre

- **Utilisez une branche principale claire** (`main` ou `master`).
- **Ajoutez un fichier README.md** décrivant le projet, ses objectifs et comment le lancer.
- **Incluez un .gitignore** pour exclure les fichiers temporaires, logs, secrets, etc.
- **Commitez régulièrement** avec des messages clairs et descriptifs.
- **Utilisez des branches pour les fonctionnalités** (`feature/nom-fonctionnalite`).
- **Mettez à jour le dépôt distant après chaque commit important** (`git push`).

***

## 🛡️ Sécurité et organisation

- **Ne commitez jamais de secrets ou mots de passe** (utilisez `.gitignore` ou un gestionnaire de secrets).
- **Structurez votre projet** avec des dossiers clairs (ex : `src/`, `docs/`, `tests/`).
- **Utilisez des badges dans le README** pour afficher le statut des actions CI/CD, la couverture de tests, etc.

***

## 📚 Références

- [Création de dépôt distants - Documentation GitHub][^1]
- [Configurer un dépôt local pour utiliser un dépôt distant sur GitHub][^2]
- [GitHub Repository Best Practices - DEV Community][^3]
- [How To Put A Project On GitHub: Best Practices][^4]
- [Your First Commit: A Beginner's Journey with Git and GitHub][^5]

***

En suivant ces étapes et bonnes pratiques, vous assurez une création propre, sécurisée et collaborative de votre dépôt GitHub. 🚀
<span style="display:none">[^10][^11][^12][^13][^14][^15][^16][^17][^18][^19][^20][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://docs.github.com/fr/get-started/git-basics/managing-remote-repositories

[^2]: https://www.it-connect.fr/chapitres/git-configurer-un-depot-local-pour-utiliser-un-depot-distant-sur-github/

[^3]: https://dev.to/pwd9000/github-repository-best-practices-23ck

[^4]: https://gitprotect.io/blog/how-to-put-a-project-on-github-best-practices/

[^5]: https://dev.to/unique-tea/your-first-commit-a-beginners-journey-with-git-and-github-ndd

[^6]: https://www.hulkapps.com/fr/blogs/ecommerce-hub/matriser-lart-de-la-cration-dun-dpt-github-un-guide-tape-par-tape

[^7]: https://docs.github.com/fr/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github

[^8]: https://www.atlassian.com/fr/git/tutorials/setting-up-a-repository

[^9]: https://dzone.com/articles/first-commit

[^10]: https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository

[^11]: https://vincentdubroeucq.com/apprendre-git-partie-3-travailler-avec-un-depot-distant/

[^12]: https://gist.github.com/luismts/495d982e8c5b1a0ced4a57cf3d93cf60

[^13]: https://openclassrooms.com/fr/courses/7162856-gerez-du-code-avec-git-et-github/7165692-travaillez-avec-un-depot-distant

[^14]: https://stackoverflow.com/questions/35103508/what-is-the-convention-for-the-content-of-an-initial-first-git-commit

[^15]: https://jmbruel.github.io/teaching/topics/git.html

[^16]: https://docs.gitlab.com/tutorials/make_first_git_commit/

[^17]: https://joost.blog/healthy-github-repository/

[^18]: https://docs.github.com/en/repositories/creating-and-managing-repositories

[^19]: https://gist.github.com/mindplace/b4b094157d7a3be6afd2c96370d39fad

[^20]: https://www.codecademy.com/learn/fscp-22-git-and-github-part-ii/modules/wdcp-22-best-practices-for-github-repositories/cheatsheet

