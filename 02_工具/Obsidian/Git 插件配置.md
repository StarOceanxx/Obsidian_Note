``` bash
git init
git remote add origin <git远端仓库地址>
git branch -M main

git status
git add .
git rm -r --cached 文件夹名 
git commit -m "从仓库中移除该文件夹，并应用 .gitignore 规则"
```