``` bash
# 初始化项目
git init
git status
git add .
git commit -m "<提交信息>"
git branch -a 
git remote add origin <git远端仓库地址>
git branch -M main
git push -u origin main

# 取消追踪，从工作区中移除
git rm -r --cached 文件夹名 
git commit -m "从仓库中移除该文件夹，并应用 .gitignore 规则"


```