# 网络图标库（dist/ps-icons）

动作「PS便捷菜单 测试版」的**网络图标库**数据源。**仓库是唯一源头**，本机只是缓存。

## 文件

- `index.json` —— 图标清单，单文件约 136KB：
  ```json
  {
    "version": "2.1.0",
    "source": "mdi (Pictogrammers, Apache-2.0) via api.iconify.design",
    "groups": [{ "name": "图层 / 对象", "icons": ["layers", "..."] }],
    "icons": { "layers": { "d": "M...SVG path...", "cn": "图层" } }
  }
  ```
  - `d`：SVG 的 path 数据。动作侧用 WPF `Geometry.Parse` **现画成矢量**——不存图片、不做栅格化，
    所以这个库不受私有仓 raw 鉴权影响，加载也最快。
  - `cn`：中文名，供选择器里用中文搜索。
  - `w`：描边宽度。**只有写了 `w` 才是描边型，其余一律按填充画**——mdi 的 path 描述的是实心形状，
    误按描边画只会得到外轮廓（形状全变样、密排小方块变成粗疙瘩）。改动渲染后请照
    `build_icon_pack.py` 注释里的方法：把同一段几何按两种画法各栅格化一张图，与源 SVG 并排比对。

## 以后怎么改图标（只在仓库里改，本机不用管）

1. 在主仓改 `remote-updater/scripts/build_icon_pack.py` 顶部的 `GROUPS`（生成后会自动同步到本仓与动作缓存）：
   ```python
   ("图层 / 对象", [
       ("layers", "图层"),          # (mdi 图标名, 中文名)
       ("layers-plus", "新建图层"),
   ]),
   ```
   图标名去 <https://icon-sets.iconify.design/mdi/> 搜（右下角有名字），中文名自己起、给搜索用。
2. 跑生成器（**会同时更新本机缓存**，所以本机不需要另做任何事）：
   ```bash
   python remote-updater/scripts/build_icon_pack.py
   ```
   - 带增量缓存：已抓到的图标不重抓，只补新增的，通常几秒就好。
   - 名字写错会被报出来（`抓取失败`），不会静默丢掉。
   - 想先看效果：`python remote-updater/scripts/preview_icon_pack.py` 生成分组预览网页。
   - 不想动本机缓存：加 `--no-local`。
3. `git add dist/ps-icons/index.json` → commit → push。

推上去之后，动作里点「↻ 刷新网络库」就能拿到新版；其它机器也会自动跟上。

## 动作侧怎么读

- 优先读本机缓存 `%AppData%\Quicker\ps_icons.json`（离线可用、最快）。
- 「↻ 刷新网络库」依次尝试四个通道，任一成功即用（提示里会带出每个通道的失败原因）：
  - **⓪ Gitee 镜像（首选）** `gitee.com/weizhiOWO/quicker-actions/raw/main/...` —— 国内直连可用、公开仓无需 token。
    注意 Gitee 的 raw 会 302 跳到 `raw.giteeusercontent.com`，跨主机后不带鉴权头，**所以这条要求仓库是公开的**。
  - ① GitHub `raw`（走系统代理） ② 同址**绕过代理直连** ③ `api.github.com` contents 接口（base64）。
    GitHub 仓库是私有的，请求会自动带上 `%LocalAppData%\Quicker\RemoteCache\.ghtoken` 里的 token。
- **本仓库同时推到两个远端**：`origin` = GitHub（私有，主）、`gitee` = Gitee 镜像（公开）。
  改完记得两边都推：`git push origin main && git push gitee main`（或见下方"一次推两边"）。
- 若刷新一直失败（例如代理没覆盖 Quicker.exe），**本地缓存照常可用**——只要在开发机上跑过生成器就同步好了。

## 换图标集

想换整套（比如从 mdi 换成 Material Symbols）：改 `build_icon_pack.py` 里的 `API` 前缀与 `source` 字段，
并把 `GROUPS` 的名字换成新图标集的（去 icon-sets.iconify.design 对应页面查名字）。清单格式不用动。

## 本仓与本仓的直链

分发仓是**独立仓库 `quicker-dist`**（公开）：

- Gitee（主，国内直连）：`https://gitee.com/weizhiOWO/quicker-dist/raw/main/ps-icons/index.json`
- GitHub（备）：`https://raw.githubusercontent.com/weizhi123sdo/quicker-dist/main/ps-icons/index.json`

主仓 `quicker-actions`（私有）里已不再保留 `dist/`。
