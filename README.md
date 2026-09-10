# quicker-dist —— 运行时抓取的分发仓

本仓**只放动作运行时需要联网抓取的内容**（原主仓 `quicker-actions` 的 `dist/` 目录）。
单独拆出来是因为：**只有一个公开仓才能让国内直连、且免 token** ——
Gitee 的 raw 会 302 跳到 `raw.giteeusercontent.com`，跨主机后 .NET 会丢掉 `Authorization` 头，
所以私有仓的 raw 根本取不到。

主仓（动作源码、规范文档、技能等）保持私有，不放这里。

## 内容

| 文件 | 谁在拉 |
|---|---|
| `ps-icons/index.json` | 「PS便捷菜单 测试版」的网络图标库（530 个图标，矢量，约 133KB） |
| `maoken-top100.txt` / `maoken-fonts.json` | 猫啃字体清单 |
| `latest.json` / `sample.txt` | remote-updater 框架的版本清单示例 |

## 直链

- **Gitee（主，国内直连）**：`https://gitee.com/weizhiOWO/quicker-actions/raw/main/<路径>`
- **GitHub（备）**：`https://raw.githubusercontent.com/weizhi123sdo/quicker-dist/main/<路径>`

> 注：Gitee 那边的仓库名仍是 `quicker-actions`——它原本是主仓的公开镜像，
> 已**重写历史为本仓内容**（只留可抓取的东西，源码与技能历史一并清除）。
> 保留原名是因为 Gitee 改可见性/建新仓要走 API，而本机只有账号密码、没有私人令牌。
> 若以后想换成规范命名的 `quicker-dist`，建好空仓再改这两处：
> `git remote set-url gitee <新地址>` 与动作里的 `GiteeUrl` 常量。

## 改内容

图标清单由主仓的 `remote-updater/scripts/build_icon_pack.py` 生成后同步到本仓；
其余文件直接改本仓。
