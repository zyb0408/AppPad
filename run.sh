#!/bin/bash

# AppPad 快速启动脚本
# 用于在Xcode中打开并运行项目

set -e

echo "🚀 AppPad 快速启动脚本"
echo "======================="
echo ""

# 检查是否在正确的目录
if [ ! -f "Package.swift" ]; then
    echo "❌ 错误：请在AppPad项目根目录运行此脚本"
    exit 1
fi

echo "📦 项目目录：$(pwd)"
echo ""

# 检查Xcode是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误：未找到Xcode，请先安装Xcode"
    exit 1
fi

echo "✅ Xcode已安装"
echo ""

# 选择操作
echo "请选择操作："
echo "1) 在Xcode中打开项目"
echo "2) 命令行构建（Debug）"
echo "3) 命令行构建（Release）"
echo "4) 清理构建缓存"
echo ""
read -p "请输入选项 (1-4): " choice

case $choice in
    1)
        echo ""
        echo "📂 正在打开Xcode..."
        open Package.swift
        echo "✅ 已在Xcode中打开项目"
        echo "💡 提示：在Xcode中按 Cmd+R 运行项目"
        ;;
    2)
        echo ""
        echo "🔨 正在构建 (Debug模式)..."
        swift build
        echo ""
        echo "✅ 构建完成！"
        echo "💡 运行命令：.build/debug/AppPad"
        ;;
    3)
        echo ""
        echo "🔨 正在构建 (Release模式)..."
        swift build -c release
        echo ""
        echo "✅ 构建完成！"
        echo "💡 运行命令：.build/release/AppPad"
        ;;
    4)
        echo ""
        echo "🧹 正在清理构建缓存..."
        rm -rf .build
        echo "✅ 清理完成！"
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac

echo ""
echo "🎉 完成！"
