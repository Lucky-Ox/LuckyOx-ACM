# GitHub 每日同步

`Sync-GitHub.ps1` 将仓库根目录中未被 `.gitignore` 忽略的新增、修改、删除记录提交并推送到 `origin/main`。没有改动时不创建提交；先前提交尚未推送时仍会重试推送。脚本需要 PowerShell 7.2 或更高版本、Git 和可用的 GitHub 登录。

## 手动运行

在仓库根目录执行：

```powershell
pwsh -NoProfile -File .\scripts\Sync-GitHub.ps1
```

只查看待同步文件，不提交或推送：

```powershell
pwsh -NoProfile -File .\scripts\Sync-GitHub.ps1 -DryRun
```

## 每天 23:00 自动运行

```powershell
pwsh -NoProfile -File .\scripts\Install-DailySync.ps1 -Time '23:00'
```

Windows 任务名称为 `LuckyOx-ACM-DailySync`。时间使用 Windows 本地时区；当前电脑为北京时间。任务在当前用户已登录时后台运行，不需要打开 CLion 或 Codex。电脑关机时无法执行；错过计划时间后，Windows 会在条件允许时补跑。失败后每隔 10 分钟重试，最多 3 次。

修改运行时间可以重新执行安装命令，例如将 `23:00` 改为 `22:00`。暂停任务：

```powershell
Disable-ScheduledTask -TaskName 'LuckyOx-ACM-DailySync'
```

恢复任务：

```powershell
Enable-ScheduledTask -TaskName 'LuckyOx-ACM-DailySync'
```

## 日志和失败处理

日志保存在仓库的 `.git/github-sync.log` 中，不会上传。可用以下命令查看最近的记录：

```powershell
Get-Content .\.git\github-sync.log -Tail 30
```

脚本只处理本地 `main` 分支。远端存在本地尚未包含的提交、Git 操作尚未完成或 GitHub 登录失效时，脚本记录错误并停止；它不会自动拉取合并、重置文件或强制覆盖远端。同步失败的本地提交会保留，问题解决后重新运行即可。

自动提交包括文件删除。运行中保存在磁盘上的内容才会同步；编辑器中尚未保存的内容不会上传。准备保留在本地的文件应加入 `.gitignore`。

## 验证脚本

```powershell
pwsh -NoProfile -File .\scripts\Test-GitHubSync.ps1
```

测试使用临时的本地 Git 仓库，不访问 GitHub，也不改动当前项目的历史。
