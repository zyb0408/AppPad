# AppPad - macOS Launchpad 复刻版

一个功能强大、高度可定制的macOS应用启动器，复刻并增强了原生Launchpad的体验。

## ✨ 主要特性

### 已实现功能
- ✅ **全屏透明毛玻璃界面** - 类似原生Launchpad的视觉效果
- ✅ **应用自动扫描** - 自动发现系统中所有已安装的应用
- ✅ **智能搜索** - 支持拼音搜索和首字母搜索
- ✅ **分页浏览** - 手势翻页，页面指示器
- ✅ **全局快捷键** - Option + Space 快速唤起
- ✅ **平滑动画** - 缩放+淡入淡出效果
- ✅ **菜单栏集成** - 常驻菜单栏，快速访问
- ✅ **丰富的设置** - 图标大小、网格布局、动画速度等
- ✅ **文件夹支持** - 创建、命名、展开和管理应用文件夹
- ✅ **可靠的文本输入** - 搜索框和文件夹名称编辑完全可用

### 开发中功能
- 🚧 **拖拽重排序** - 自由调整应用图标位置
- 🚧 **编辑模式** - 长按进入编辑模式，删除应用
- 🚧 **触发角** - 鼠标移到屏幕角落激活
- 🚧 **启动时启动** - 系统启动时自动运行（使用 ServiceManagement）

## 🚀 快速开始

### 系统要求
- macOS 14.0 (Sonoma) 或更高版本
- Xcode 15.0+ (用于构建)
- Swift 6.0+

### 构建方法

#### 方法一：使用Xcode（推荐）
```bash
# 1. 克隆或下载项目
cd /Users/yingbin/Downloads/Projects/AppPad

# 2. 打开Xcode项目
open Package.swift

# 3. 在Xcode中按 Cmd+R 运行
```

#### 方法二：命令行构建
```bash
# 构建
swift build -c release

# 运行
.build/release/AppPad
```

### 首次运行

1. **授予权限**：首次运行时，系统可能要求授予以下权限：
   - 辅助功能访问（用于全局快捷键）
   - 完全磁盘访问（用于扫描所有应用）

2. **配置快捷键**：
   - 默认快捷键：`Option + Space`
   - 可在设置中查看和配置

## 📖 使用指南

### 基本操作

#### 打开AppPad
- 按 `Option + Space`（全局快捷键）
- 点击菜单栏图标 → "Toggle AppPad"

#### 关闭AppPad
- 按 `Esc` 键
- 点击背景空白区域
- 再次按 `Option + Space`

#### 搜索应用
1. 打开AppPad后，直接开始输入
2. 支持中文拼音搜索
3. 支持首字母缩写（如：wx → 微信）

#### 翻页
- 双指在触控板上左右滑动
- 点击底部页面指示器圆点

#### 文件夹操作
- **查看文件夹内容**：点击文件夹图标
- **编辑文件夹名称**：点击文件夹展开后，在名称字段输入新名称
- **从文件夹移出应用**：打开文件夹后，右键点击应用选择"从文件夹移出"
- **关闭文件夹**：点击背景暗化区域

#### 启动应用
- 点击应用图标
- 应用启动后，AppPad自动隐藏

### 设置选项

打开设置：点击菜单栏图标 → "Settings..."

#### 外观标签页
- **图标大小**：40-120px，默认80px
- **网格列数**：4-12列，默认7列
- **网格行数**：3-10行，默认5行
- **背景模糊**：0-100%，默认100%

#### 行为标签页
- **手势灵敏度**：翻页冷却时间，0.1-1.5秒
- **动画速度**：打开/关闭动画时长
- **全局快捷键**：启用/禁用 Option+Space

#### 通用标签页
- **开机启动**：系统启动时自动运行（开发中）
- **版本信息**：查看当前版本
- **重置设置**：恢复默认配置

## 🎨 自定义

### 修改快捷键
当前版本默认使用 `Option + Space`。未来版本将支持自定义快捷键组合。

### 调整网格布局
根据屏幕大小和个人喜好调整：
- **小屏幕**：建议 5列 × 4行
- **标准屏幕**：建议 7列 × 5行（默认）
- **大屏幕**：建议 9列 × 6行

### 图标大小建议
- **紧凑布局**：40-60px
- **标准布局**：70-90px（默认80px）
- **宽松布局**：100-120px

## 🛠️ 开发

### 项目结构
```
AppPad/
├── Sources/AppPad/
│   ├── AppPadApp.swift              # 应用入口 + AppDelegate
│   ├── ContentView.swift            # 主视图，处理分页和文件夹叠加层
│   ├── MainWindow.swift             # 自定义NSWindow，处理全屏和文本输入
│   ├── SettingsView.swift           # 设置界面
│   ├── ClickableHostingView.swift    # 自定义NSView，用于检测背景点击
│   ├── Models/
│   │   ├── AppIcon.swift            # 应用图标模型（内存中）
│   │   └── DataModels.swift         # SwiftData实体（AppIconEntity, FolderEntity等）
│   ├── Services/
│   │   ├── AppScanner.swift         # Actor-based应用扫描服务
│   │   ├── GlobalHotkeyManager.swift # Carbon API全局快捷键
│   │   └── WindowAnimationManager.swift # NSAnimationContext窗口动画
│   ├── ViewModels/
│   │   └── AppListViewModel.swift   # 中央状态容器（应用列表、搜索、文件夹）
│   ├── Extensions/
│   │   └── Color+Hex.swift          # 颜色十六进制扩展
│   └── Views/
│       ├── SearchField.swift        # SwiftUI搜索框组件
│       ├── DraggableAppIcon.swift   # 可拖拽的应用图标
│       ├── FolderIconView.swift     # 文件夹图标（带mini网格预览）
│       ├── FolderExpandedView.swift # 文件夹展开视图（可编辑名称）
│       ├── PageGestureView.swift    # 手势处理（分页、长按）
│       └── IconGridView.swift       # 应用图标网格（支持应用和文件夹）
├── Package.swift                     # Swift Package配置
├── CLAUDE.md                         # Claude AI开发指南
└── README.md                         # 项目文档
```

### 技术栈
- **UI框架**：SwiftUI + AppKit（混合方案）
- **数据持久化**：SwiftData（实体：AppIconEntity、FolderEntity、UserPreferencesEntity）
- **全局快捷键**：Carbon API
- **动画**：NSAnimationContext + SwiftUI Transitions
- **响应式**：Combine + @AppStorage + @StateObject
- **并发**：Actor-based（AppScanner）+ Task/MainActor
- **窗口管理**：自定义NSWindow + NSPanel属性

### 贡献指南
欢迎贡献！请查看 `IMPROVEMENTS.md` 了解待完成的功能。

## 📋 未来工作计划

### 高优先级
1. ✅ ~~完成SwiftData集成~~ （已完成）
2. ✅ ~~实现文件夹功能~~ （已完成）
3. ✅ ~~修复文本输入问题~~ （已完成 v1.1.0）
4. 实现拖拽重排序并持久化
5. 完成删除应用功能（编辑模式）

### 中优先级
6. 搜索结果突出显示和键盘导航
7. 热角支持（角落检测 + 窗口显示）
8. 自定义快捷键配置UI
9. 启动时启动（ServiceManagement框架）

### 低优先级
10. Metal渲染优化（Liquid Glass效果）
11. 图标缓存层（NSImage）
12. 120fps动画目标
13. 主题系统增强

## 📝 更新日志

### v1.1.0 (2026-02-22)
- ✅ 文件夹支持完整实现（创建、命名、展开、应用管理）
- ✅ 文本输入修复（搜索框和文件夹名称编辑）
- ✅ SwiftData集成完成
- ✅ 改进的UI/UX（文件夹预览网格、展开动画）
- ✅ 应用图标和图标主题优化

### v1.0.0 (2026-02-04)
- ✅ 初始版本发布
- ✅ 基础应用扫描和显示
- ✅ 全局快捷键支持
- ✅ 平滑动画效果
- ✅ 增强的设置界面
- ✅ 拼音搜索支持

## 🐛 已知问题

1. **权限问题**：首次运行需要授予多项权限
   - 辅助功能（用于全局快捷键）
   - 完全磁盘访问（用于扫描所有应用）

2. **拖拽重排序**：UI已准备就绪但数据持久化未完成

### ✅ 最近修复

**文本输入问题（2026-02-07）** - 已解决
- 原因：NSPanel 的 `.fullSizeContentView` 样式掩码阻止了文本输入
- 解决方案：移除 `.fullSizeContentView`，添加 `worksWhenModal = true` 属性
- 结果：搜索框和文件夹名称编辑现在完全可用

## 📄 许可证

本项目仅供学习和个人使用。

## 🙏 致谢

灵感来源于macOS原生Launchpad，致力于提供更好的用户体验和更多的自定义选项。

## 📧 联系方式

如有问题或建议，请提交Issue。

---

**注意**：本项目正在积极开发中。查看上面的"未来工作计划"部分了解开发路线图。
