# Evan 桌面小人

重新设计的 Evan：红眼、深色长发、眼睛上方两枚红色蛾眉。macOS 与 Windows 使用同一套代码和角色素材。

## 开发

安装 Node.js 24 LTS，然后在项目目录运行（macOS 终端、Windows PowerShell 均可）：

```sh
npm ci
npm start
```

点击小人会回应，拖动可以移动，右键打开菜单。菜单栏／系统托盘的两点红眉图标可以找回隐藏的小人或退出程序。空白边缘支持鼠标穿透；当前小人的交互区域为矩形，并非逐像素穿透。窗口位置、“自由走动”和“暂停动画”保存在系统应用数据目录，重启后恢复，不写入仓库。

现已接入 17 种连续动作状态，会自动眨眼、走动、转身、坐下和休息，包含视频中的敲锣与骷髅头杆子。右键“做个动作”可逐个查看；关闭“自由走动”可留在原地，勾选“暂停动画”可完全暂停。所有表情无嘴，无眯眼笑脸。详见 [动作说明](docs/motion.md) 与 [视频道具动作](docs/prop-actions.md)。

启动后会主动在桌面走动，拖到哪里就从那里继续。新版使用连续步态、起停缓动和边缘转向，保留透明窗口。系统开启“减弱动态效果”时按系统偏好静止。

角色保持原版圆头短腿，直接轻摆原有的两条腿，不添加脚掌、脚趾或脚底。桌面显示已整体缩小 20%。

## 检查与打包

```sh
npm test
npm run smoke
```

`smoke` 会使用独立的临时配置创建真实桌面窗口，检查动作素材、全部状态、点击回应、暂停／隐藏恢复、休息与实际走动，随后自动退出，不影响日常使用的设置或已运行的小人。截图保存在系统临时目录 `evan-motion-smoke/`。

在 Mac 上执行 `npm run build:mac`，生成支持 Apple Silicon 和 Intel 的通用 DMG、ZIP。在 Windows 上执行 `npm run build:win`，生成 x64 安装程序及免安装 ZIP。产物在 `dist/`。`npm run pack` 可以先生成当前系统的应用目录；打包后执行 `npm run smoke:packaged`，检查当前系统的实际应用。

`.github/workflows/build.yml` 在推送 main、codex 分支、PR 或手动触发时，分别使用 macOS 和 Windows runner 执行单元测试、源码启动检查、打包及打包后启动检查，再上传构建附件。检查必须收到完整通过标记并正常退出。

[双端 CI 已通过](https://github.com/elizabethbrunette21/EvanJoDesktopPet/actions/runs/44058345033)，可在该页面下载 Mac 通用包和 Windows x64 包。启动检查分别验证正常动画与减弱动态效果，日常使用仍遵循系统偏好。

当前为未签名开发版本；正式分发前仍需配置 macOS 签名／公证及 Windows 代码签名。Windows ARM64 尚未列入构建目标。

安装方法与两端实机检查见 [安装与验收](docs/install-and-check.md)，已完成的本机检查见 [验证记录](docs/validation.md)。

## 目录

```text
src/                         两端共用的桌面壳、互动与显示逻辑
assets/characters/evan/       两端共用的透明角色素材
assets/tray.png              两点红眉托盘图标
docs/                        角色设定、生成提示词与架构决策
test/                        窗口坐标与异常数据检查
.github/workflows/build.yml  双系统构建
RESTORE.txt                  旧项目的原始恢复说明，原样保留
```

这次从本目录重新建立共享实现，新版放在原仓库的 `codex/evan-cross-platform` 分支，原主分支和备份保留。大体积原始视频保留在原位置，不提交进仓库。

原仓库的 [代码许可证](LICENSE) 与 [角色素材许可](ASSET_LICENSE.md) 原样保留；角色素材包括本分支 `assets/`、`docs/references/` 与 `output/` 中的视觉内容，独立于代码许可证。

角色说明见 [docs/character.md](docs/character.md)，技术约定见 [docs/architecture.md](docs/architecture.md)。
