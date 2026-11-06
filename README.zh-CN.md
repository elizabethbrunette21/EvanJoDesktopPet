# EvanJoDesktopPet

[English](README.md) | **简体中文**

EvanJoDesktopPet 是一款在 macOS 和 Windows 上运行的本地桌面宠物。macOS 版使用 SwiftUI 和 AppKit 构建，Windows 版使用 .NET 8 和 WPF 构建。

EvanJoDesktopPet 是一款已正式发布的 macOS 桌面宠物应用。Evan Jo 是首个内置角色，窗口与行为引擎采用可复用结构，方便未来角色继续使用同一套应用架构。

## 下载

### Homebrew

```bash
brew install --cask elizabethbrunette21/tap/evan-jo-desktop-pet
```

### 直接下载

[下载 EvanJoDesktopPet 0.1.0 macOS 安装包（.dmg）](https://github.com/elizabethbrunette21/EvanJoDesktopPet/releases/download/v0.1.0/EvanJoDesktopPet-0.1.0.dmg)

- 需要 macOS 11.0 或更高版本
- 支持 Apple Silicon 和 Intel Mac
- 使用 Apple Developer ID 签名
- 已通过 Apple 公证

### Windows x64 预览版

[下载 Windows ZIP 安装包](https://github.com/elizabethbrunette21/EvanJoDesktopPet/releases/download/windows-v0.1.0-preview.2/EvanJoDesktopPet-Windows-x64.zip)。解压后双击 `Install.cmd`，即可安装完整应用、创建 **Evan Jo Desktop Pet** 桌面快捷方式并打开宠物。需要 Windows 10 或更高版本，无需单独安装 .NET，也无需管理员权限。更新前请先退出宠物。此预览版尚未签名，Windows 可能显示发布者警告。

[Windows 构建和安装说明](DesktopPet/EvanJoDesktopPet.Windows/README.md)

[查看全部版本](https://github.com/elizabethbrunette21/EvanJoDesktopPet/releases)

## macOS 版功能

- 不抢占键盘焦点的透明无边框悬浮窗口
- 支持拖动、可见屏幕范围限制和位置保存与恢复
- 提供自动与固定姿势、重置位置和退出功能的上下文菜单
- 为 Idle、Happy、Loading、Speechless和Brainwave提供 SwiftUI 分层动画
- 使用支持安全取消和状态切换的自动姿势调度逻辑
- 不依赖后端、账户、分析服务、网络服务或第三方依赖

## 本地构建要求（macOS）

- macOS 11 或更高版本
- 带有 macOS SDK 的 Xcode

## 本地构建

使用 Xcode 打开 `DesktopPet/EvanJoDesktopPet.xcodeproj`，然后运行 `EvanJoDesktopPet` target。

也可以通过以下命令执行关闭签名的命令行构建：

```bash
xcodebuild \
  -project DesktopPet/EvanJoDesktopPet.xcodeproj \
  -target EvanJoDesktopPet \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 仓库结构

```text
DesktopPet/
  EvanJoDesktopPet/           应用源码和运行时素材
  EvanJoDesktopPet.xcodeproj/ Xcode 项目
  EvanJoDesktopPet.Windows/   Windows 应用及打包脚本
  docs/                       架构与素材文档
```

角色原始参考图、生成任务、Xcode 用户状态、签名材料和本地构建产物均有意排除在版本控制之外。

应用所需的运行时素材均已包含在 `DesktopPet/EvanJoDesktopPet/Resources/Assets.xcassets` 中。本地 `DesktopPet/SourceAssets` 目录保存源素材和回滚材料，不纳入版本控制，也不是公开运行时依赖。

## 项目状态

0.1.0 版本已经完成手动运行测试、发布打包、Developer ID 签名和 Apple 公证。

GitHub Release 已提供经过签名和 Apple 公证的 Universal macOS 安装包。

## 贡献

提交 Pull Request 前，请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 安全与隐私

应用仅在本机运行，不会发起网络请求。安全问题的报告方式请参阅 [SECURITY.md](SECURITY.md)。

## 开源与许可证

源代码和项目文档采用 [MIT License](LICENSE)。

Evan Jo 的名称、身份、角色设计、插画、动画图层、特效及其他视觉素材不属于 MIT License，也不是开源素材。视觉素材仅可在非商业场景下，为构建、运行、测试和评估本项目而使用；禁止单独复用、重新分发、制作衍生视觉作品或用于商业用途。视觉素材的允许用途与限制请参阅 [ASSET_LICENSE.md](ASSET_LICENSE.md)。
