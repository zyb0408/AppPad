# AppPad 技术说明书 (Technical Specification)

## 1. 技术栈选择

- 开发语言：Swift 6.0+ (利用其强类型和并发安全性)。

- UI 框架：SwiftUI (用于构建流体布局) + AppKit 桥接 (处理系统级窗口控制)。

- 渲染引擎：Metal (用于实现 macOS 26 要求的 Liquid Glass 动态光影效果)。

- 数据持久化：SwiftData (存储用户自定义的图标排序和分组信息)。

## 2. 核心技术模块
### A. 应用程序检索 (App Discovery)
- 使用 MDQuery (Metadata Query) 或 NSWorkspace 扫描路径。

- 技术要点：不仅要扫描 /Applications，还要扫描 ~/Applications 以及 /System/Applications。

### B. 窗口层级管理 (Window Management)
- Level：设置窗口层级为 NSWindow.Level.mainMenu + 1，确保覆盖在 Dock 和其他应用之上。

- Collection Behavior：设置为 .canJoinAllSpaces 和 .fullScreenAuxiliary。

## 3. 核心代码结构建议 (Swift)
```swift
// 建议的模型结构
struct AppIcon: Identifiable, Codable {
    let id: UUID
    let name: String
    let bundleIdentifier: String
    let iconPath: String
    var position: Int // 用于排序
    var folderId: UUID? // 如果属于某个文件夹
}
```