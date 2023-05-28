# Documenting git commands/notes 

## Set name and email

```bash
 git config --global user.email "atulthosar@gmail.com"
 git config --global user.name "Atul Thosar"
```
Remove --global flag in case you want to set name/email for local repository only

## Undo last commit (w/o removing the files)
```bash
git reset --soft HEAD~1
```

## Undo last commit (with removing the files)
```bash
git reset --hard HEAD~1
```

## Git User Stat
List the number of lines added, removed by a particular user

```bash
git log --author="Atul Thosar" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s removed lines: %s total lines: %s\n", add, subs, loc }'
```
