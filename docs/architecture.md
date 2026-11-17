# 双端约定

## 一份共享实现

Electron 负责透明置顶窗口、系统托盘和安装包；普通 HTML/CSS/JavaScript 负责角色显示及点击回应。不引入前端框架、服务器、数据库或在线依赖。安装依赖需要网络，应用运行不需要网络。

`src/main.cjs` 只处理系统窗口、屏幕坐标、托盘及位置／偏好保存；`src/preload.cjs` 提供有限的 IPC 接口；`src/pet.js` 管理拖动事件和点击互动。macOS 专属的 Dock／空间处理留在主进程的系统分支中。角色资源不按系统复制。

渲染进程关闭 Node 集成，开启隔离和沙箱，限制加载来源，禁止打开新窗口和页面导航。IPC 只接受当前主窗口的顶层页面。

## 构建与验证边界

固定依赖版本并提交 npm 锁文件。Mac 通用包和 Windows x64 包在 CI 中分别使用对应系统构建，不把“Mac 能启动”或“Mac 交叉打包成功”算作 Windows 已验收。两端 CI 都需要执行单元测试、真实 Electron 启动检查、打包及打包后的应用启动检查。

启动检查在取得单实例锁之前切换到独立的临时配置与缓存，不读取或改写日常配置。偏好只持久保存“自由走动”和“暂停动画”；隐藏、休息、朝向属于当前会话状态。偏好写入先创建临时文件，再原子替换，损坏的数据使用默认值。

本地检查能验证坐标逻辑、应用启动和资源加载；拖动手感、不同缩放比例、多屏、透明穿透、托盘行为与系统签名提示仍需两端真机验收。不要宣称未运行过的 Windows 构建或交互已经通过。

## 官方依据

- [Electron 透明窗口](https://www.electronjs.org/docs/latest/tutorial/custom-window-styles)
- [electron-builder 跨平台构建](https://www.electron.build/docs/features/multi-platform-build/)
- [electron-builder GitHub Actions](https://www.electron.build/docs/features/github-actions/)

## 旧版恢复

保留根目录 `RESTORE.txt`，不下载、解压或覆盖旧备份。经用户指定，新版使用原仓库的 `codex/evan-cross-platform` 分支并保留原主分支历史；原代码与素材许可原样保留并随应用打包。
