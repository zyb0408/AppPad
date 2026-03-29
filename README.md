# AppPad

AppPad 是一个基于 SwiftUI + AppKit 构建的 macOS Launchpad 替代品。它提供全屏应用网格、中文/英文/拼音搜索、文件夹管理、全局快捷键、可选热角，以及可自定义的界面手势。

当前版本：`1.0.3`

## 主要特性

### 已实现
- 全屏启动器界面，支持缩放 + 淡入淡出动画
- 自动扫描 `/Applications`、`/System/Applications` 和 `~/Applications`
- 优先显示应用的本地化名称
- 搜索支持中文名、英文名、拼音全拼、拼音首字母
- 每次打开都会重置为新的搜索会话，并自动聚焦搜索框
- 分页浏览与页面指示器
- 全局快捷键唤醒，支持在设置中自定义
- 可选热角触发：左上 / 右上 / 左下 / 右下
- 应用内可自定义手势：
  - 左滑 / 右滑 / 上滑 / 下滑
  - 向内捏合 / 向外展开
- 根级应用支持插入式拖拽重排
- 编辑模式下拖拽应用到另一个应用上创建文件夹
- 拖拽应用到文件夹图标中，将应用加入文件夹
- 编辑模式下支持删除应用，并将应用移到废纸篓
- 文件夹重命名、展开、删除、从文件夹中移出应用
- 菜单栏常驻
- 登录时启动
- 设置页支持重置为默认配置

### 当前限制
- 手势只在 AppPad 已打开且位于前台时生效；后台全局触控板手势不在支持范围内

## 系统要求

- macOS 14.0 或更高版本
- Xcode 15+
- Swift 6

## 快速开始

### 使用 Xcode

```bash
cd /Users/yingbin/Downloads/Projects/AppPad
open Package.swift
```

然后在 Xcode 中按 `Cmd+R` 运行。

### 使用命令行

```bash
cd /Users/yingbin/Downloads/Projects/AppPad
swift build
.build/debug/AppPad
```

发布构建：

```bash
swift build -c release
.build/release/AppPad
```

## 首次运行

首次使用时，macOS 可能会要求授予以下权限：

- 辅助功能：用于全局快捷键
- 登录项权限：启用“登录时启动”时由系统处理

如果全局快捷键没有响应，请先检查“系统设置 > 隐私与安全性 > 辅助功能”。

## 使用说明

### 打开与关闭

打开 AppPad：
- 默认快捷键 `Option + Space`
- 菜单栏图标
- 已启用的热角

关闭 AppPad：
- `Esc`
- 点击背景空白区域
- 使用已映射为“关闭 AppPad”的界面手势
- 再次触发快捷键或热角动作（取决于你的热角设置）

### 搜索

打开 AppPad 后可以直接输入，支持：

- 中文名称搜索
- 英文名称搜索
- 拼音全拼搜索
- 拼音首字母搜索

示例：
- `微信`
- `WeChat`
- `weixin`
- `wx`

每次重新打开 AppPad 时：
- 搜索内容会被清空
- 光标会自动回到搜索框

### 翻页与手势

默认界面手势：
- 左滑：上一页
- 右滑：下一页
- 上滑：无动作
- 下滑：关闭 AppPad
- 向内捏合：无动作
- 向外展开：无动作

这些动作都可以在设置页中重新映射。

### 文件夹与拖拽

- 普通状态下拖拽应用到另一个应用：按目标位置插入重排
- 编辑模式下拖拽应用到另一个应用：创建文件夹
- 拖拽应用到文件夹图标：加入文件夹
- 点击文件夹：展开
- 在展开视图中直接编辑文件夹名称
- 在展开视图中可将应用移出文件夹

进入编辑模式：
- 长按应用图标
- 点击应用右上角删除标记后，会先弹出确认框
- 确认后 AppPad 会尝试把应用移到废纸篓
- 如果系统应用或权限不足导致删除失败，界面会给出处理提示

### 启动应用

- 点击应用图标即可启动
- 启动后 AppPad 会自动隐藏

## 设置说明

设置窗口分为三个标签页。

### 外观

- 图标大小：`40-120 px`
- 网格列数：`4-12`
- 网格行数：`3-10`
- 背景颜色
- 背景透明度

### 行为

- 界面手势开关
- 手势冷却时间
- 每个手势对应的动作映射
- 热角开关
- 热角位置
- 热角触发动作
- 动画速度
- 全局快捷键启用/禁用
- 自定义全局快捷键

### 通用

- 登录时启动
- 当前版本
- 构建日期
- 恢复默认设置

## 默认配置

- 版本：`1.0.3`
- 构建日期：`2026.03.29`
- 图标大小：`80 px`
- 网格：`7 x 5`
- 动画速度：`0.2 秒`
- 默认快捷键：`Option + Space`
- 热角：默认关闭

## 项目结构

```text
AppPad/
├── Sources/AppPad/
│   ├── AppPadApp.swift
│   ├── ContentView.swift
│   ├── MainWindow.swift
│   ├── SettingsView.swift
│   ├── ClickableHostingView.swift
│   ├── Models/
│   │   ├── AppIcon.swift
│   │   └── DataModels.swift
│   ├── Services/
│   │   ├── AppScanner.swift
│   │   ├── AppPadInputManager.swift
│   │   ├── GlobalHotkeyManager.swift
│   │   ├── LaunchAtLoginManager.swift
│   │   └── WindowAnimationManager.swift
│   ├── ViewModels/
│   │   └── AppListViewModel.swift
│   ├── Extensions/
│   │   └── Color+Hex.swift
│   └── Views/
│       ├── SearchField.swift
│       ├── DraggableAppIcon.swift
│       ├── FolderIconView.swift
│       ├── FolderExpandedView.swift
│       ├── HotkeyRecorderView.swift
│       ├── IconGridView.swift
│       └── PageGestureView.swift
├── Package.swift
├── FEATURE_COMPARISON.md
├── AGENTS.md
└── README.md
```

## 技术栈

- UI：SwiftUI + AppKit
- 数据持久化：SwiftData
- 全局快捷键：Carbon API
- 动画：`NSAnimationContext`
- 响应式状态：`Combine`、`@StateObject`、`@AppStorage`
- 并发：`actor` + `Task` + `MainActor`

## 已知问题

- `swift build` 会提示 `Info.plist` 和 `Assets.xcassets` 是未声明资源；当前不影响本地构建，但后续可以在 `Package.swift` 里进一步整理
- 后台全局触控板手势不是目标能力；全局入口使用快捷键和热角

## 开发建议

常用命令：

```bash
swift build
swift build -c release
./run.sh
```

如果需要清理构建缓存：

```bash
rm -rf .build
```

## 路线图

优先级较高的后续工作：

1. 增强搜索结果高亮与键盘导航
2. 持续优化图标加载和动画流畅度

## 许可证

本项目仅供学习和个人使用。
