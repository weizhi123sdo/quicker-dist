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

- Gitee（主，国内直连）：`https://gitee.com/weizhiOWO/quicker-dist/raw/main/<路径>`
- GitHub（备）：`https://raw.githubusercontent.com/weizhi123sdo/quicker-dist/main/<路径>`

## 改内容

图标清单由主仓的 `remote-updater/scripts/build_icon_pack.py` 生成后同步到本仓；
其余文件直接改本仓。
