#  AppPad 需求说明书 (Software Requirements Specification)

## 1. 项目目标
重新构建一个符合 macOS 26 审美，且具备高度自定义能力的应用程序启动器，找回并超越原版 Launchpad 的体验。

## 2. 核心功能需求 (Functional Requirements)
### 可视化应用网格 (Icon Grid)：

- 自动扫描系统及用户目录下所有已安装的 .app 应用程序。

- 支持自定义图标大小、间距及每行显示的数量。

### 分组管理 (Smart Folders)：

- 支持拖拽图标重叠以创建文件夹。

- 允许用户为文件夹命名，并设置图标颜色标签。

### 快捷激活 (Activation)：

- 支持自定义全局快捷键（如 Option + Space）。

- 支持“触发角（Hot Corners）”或自定义触控板手势启动。

### 极速搜索 (Instant Search)：

- 在界面打开时直接输入文字即可过滤图标。

### 卸载模式 (Edit Mode)：

- 长按图标进入抖动模式，支持直接点击删除非系统应用。

## 3. 非功能需求 (Non-functional Requirements)
### 视觉风格：

- 必须支持 macOS 26 的 Liquid Glass 材质，具有真实的物理反射和半透明毛玻璃效果。

### 性能目标：

- 利用 M3 Max 的 GPU 加速，确保开启动画在 120Hz 刷新率下无掉帧。

### 低资源占用：

- 在后台运行时，内存占用应低于 100MB。