# 本地 dev 合并到本地 main

1. **确保 dev 分支代码已提交**：在 `dev` 分支上，确保所有修改都已保存并提交。
``` bash
git checkout dev
git add .
git commit -m "<提交消息>"
```

2. **切换到 main 分支并拉取最新代码**：防止合并时产生不必要的冲突。
``` bash
git checkout main
git pull origin main
```

3. **执行合并操作**：
``` bash
git merge dev
```

4. **推送到远程仓库**：
``` bash
git push origin main
```