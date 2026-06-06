#!/bin/bash

# ================= 版本号输入 =================
read -p "请输入版本号 (例如 1.0.6): " VERSION
if [ -z "$VERSION" ]; then
    echo -e "\033[0;31m错误: 版本号不能为空\033[0m"
    exit 1
fi
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo -e "\033[0;31m错误: 版本号格式不正确，应为 x.y.z (例如 1.0.6)\033[0m"
    exit 1
fi

# ================= 配置区域 =================
APP_NAME="AppPad"
DMG_NAME="${APP_NAME}_${VERSION}.dmg"
BUILD_DIR=".build_dist"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
ENTITLEMENTS="AppPad.entitlements"
EXECUTABLE_NAME="AppPad"

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 检查环境变量
if [ -z "$APPLE_SIGNING_IDENTITY" ] || [ -z "$APPLE_API_ISSUER" ] || [ -z "$APPLE_API_KEY" ] || [ -z "$APPLE_API_KEY_PATH" ]; then
    echo -e "${RED}错误: 缺少必要的环境变量。请确保 APPLE_SIGNING_IDENTITY, APPLE_API_ISSUER, APPLE_API_KEY, APPLE_API_KEY_PATH 已设置。${NC}"
    exit 1
fi

BUILD_DATE=$(date +"%Y.%m.%d")
echo -e "${GREEN}=== 开始打包流程: ${APP_NAME} v${VERSION} (${BUILD_DATE}) ===${NC}"
echo -e "签名身份: ${APPLE_SIGNING_IDENTITY}"

# 1. 清理工作目录
echo -e "${YELLOW}[1/7] 清理构建目录...${NC}"
rm -rf "$BUILD_DIR"
rm -f "$DMG_NAME"
mkdir -p "$BUILD_DIR"

# 更新 SettingsView.swift 中的版本号和构建日期
SETTINGS_FILE="Sources/AppPad/SettingsView.swift"
if [ -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}更新版本号和构建日期...${NC}"
    sed -i '' -E 's/(SettingsRowView\(label: "版本", labelWidth: labelWidth\) \{[[:space:]]*$)/\1/' "$SETTINGS_FILE"
    sed -i '' -E '/SettingsRowView\(label: "版本"/{ n; s/Text\("[0-9]+\.[0-9]+\.[0-9]+"\)/Text("'"$VERSION"'")/; }' "$SETTINGS_FILE"
    sed -i '' -E '/SettingsRowView\(label: "构建日期"/{ n; s/Text\("[0-9]{4}\.[0-9]{2}\.[0-9]{2}"\)/Text("'"$BUILD_DATE"'")/; }' "$SETTINGS_FILE"
    echo -e "${GREEN}版本: ${VERSION}, 构建日期: ${BUILD_DATE}${NC}"
fi

# 2. 编译 Release 版本
echo -e "${YELLOW}[2/7] 编译 Release 版本...${NC}"
swift build -c release --arch arm64 --arch x86_64 || {
    echo -e "${RED}编译失败${NC}"
    exit 1
}

# 获取编译产物路径 (排除 dSYM)
BINARY_PATH=$(find .build -name "$EXECUTABLE_NAME" -type f -not -path "*.dSYM*" | grep -i "release" | head -n 1)

if [ -z "$BINARY_PATH" ]; then
    echo -e "${RED}错误: 未找到编译后的二进制文件${NC}"
    exit 1
fi

echo -e "找到二进制文件: $BINARY_PATH"

# 3. 组装 App Bundle
echo -e "${YELLOW}[3/7] 组装 App Bundle...${NC}"
mkdir -p "${APP_PATH}/Contents/MacOS"
mkdir -p "${APP_PATH}/Contents/Resources"

# 复制二进制
cp "$BINARY_PATH" "${APP_PATH}/Contents/MacOS/${EXECUTABLE_NAME}"

# 生成应用图标 (.icns)
ICON_SOURCE="Sources/AppPad/Resources/Assets.xcassets/AppIcon.appiconset"
ICONSET_DIR="${BUILD_DIR}/AppIcon.iconset"
ICNS_FILE="${APP_PATH}/Contents/Resources/AppIcon.icns"

if [ -d "$ICON_SOURCE" ]; then
    echo -e "${YELLOW}正在生成应用图标...${NC}"
    mkdir -p "$ICONSET_DIR"

    # 复制并重命名图标文件为 iconutil 需要的格式
    cp "${ICON_SOURCE}/icon_16x16.png" "${ICONSET_DIR}/icon_16x16.png" 2>/dev/null
    cp "${ICON_SOURCE}/icon_16x16@2x.png" "${ICONSET_DIR}/icon_16x16@2x.png" 2>/dev/null
    cp "${ICON_SOURCE}/icon_32x32.png" "${ICONSET_DIR}/icon_32x32.png" 2>/dev/null
    cp "${ICON_SOURCE}/icon_32x32@2x.png" "${ICONSET_DIR}/icon_32x32@2x.png" 2>/dev/null
    cp "${ICON_SOURCE}/icon_128x128.png" "${ICONSET_DIR}/icon_128x128.png" 2>/dev/null
    cp "${ICON_SOURCE}/icon_128x128@2x.png" "${ICONSET_DIR}/icon_128x128@2x.png" 2>/dev/null
    cp "${ICON_SOURCE}/icon_256x256.png" "${ICONSET_DIR}/icon_256x256.png" 2>/dev/null
    cp "${ICON_SOURCE}/icon_256x256@2x.png" "${ICONSET_DIR}/icon_256x256@2x.png" 2>/dev/null
    cp "${ICON_SOURCE}/icon_512x512.png" "${ICONSET_DIR}/icon_512x512.png" 2>/dev/null
    cp "${ICON_SOURCE}/icon_512x512@2x.png" "${ICONSET_DIR}/icon_512x512@2x.png" 2>/dev/null

    # 使用 iconutil 生成 .icns 文件
    iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE" 2>/dev/null

    if [ -f "$ICNS_FILE" ]; then
        echo -e "${GREEN}应用图标生成成功${NC}"
        ICON_PLIST_ENTRY="    <key>CFBundleIconFile</key>
    <string>AppIcon</string>"
    else
        echo -e "${YELLOW}警告: 图标生成失败，将使用默认图标${NC}"
        ICON_PLIST_ENTRY=""
    fi
else
    echo -e "${YELLOW}警告: 未找到图标资源目录，将使用默认图标${NC}"
    ICON_PLIST_ENTRY=""
fi

# 创建 Info.plist
cat >"${APP_PATH}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.yingbin.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
${ICON_PLIST_ENTRY}
</dict>
</plist>
EOF
# 注意: LSUIElement true 表示它是菜单栏应用/后台应用，根据之前提到的 MenuBarExtra 和 LSUIElement 设置

echo -e "${GREEN}App Bundle 组装完成: ${APP_PATH}${NC}"

# 4. 签名 App (Hardened Runtime)
echo -e "${YELLOW}[4/7] 正在签名 App (Hardened Runtime)...${NC}"

# 确保 entitlements 存在
if [ ! -f "$ENTITLEMENTS" ]; then
    echo -e "${RED}缺少 entitlements 文件${NC}"
    exit 1
fi

codesign --force --verify --verbose \
    --sign "$APPLE_SIGNING_IDENTITY" \
    --options runtime \
    --entitlements "$ENTITLEMENTS" \
    --deep \
    "$APP_PATH" || {
    echo -e "${RED}签名失败${NC}"
    exit 1
}

# 验证签名
codesign --verify --verbose "$APP_PATH" || {
    echo -e "${RED}签名验证失败${NC}"
    exit 1
}

echo -e "${GREEN}App 签名成功${NC}"

# 5. 创建 DMG
echo -e "${YELLOW}[5/7] 创建 DMG 安装包...${NC}"
# 创建临时文件夹用于生成 DMG
DMG_SRC="${BUILD_DIR}/dmg_source"
mkdir -p "$DMG_SRC"
cp -r "$APP_PATH" "$DMG_SRC/"
# 创建 Applications 软链接
ln -s /Applications "$DMG_SRC/Applications"

# 生成 DMG
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_SRC" \
    -ov -format UDZO \
    "$DMG_NAME" >/dev/null || {
    echo -e "${RED}DMG 创建失败${NC}"
    exit 1
}

echo -e "${GREEN}DMG 创建成功: ${DMG_NAME}${NC}"

# 6. 签名 DMG
echo -e "${YELLOW}[6/7] 正在签名 DMG...${NC}"
codesign --sign "$APPLE_SIGNING_IDENTITY" "$DMG_NAME" || {
    echo -e "${RED}DMG 签名失败${NC}"
    exit 1
}
echo -e "${GREEN}DMG 签名成功${NC}"

# 7. 公证 (Notarize)
echo -e "${YELLOW}[7/7] 提交公证 (这可能需要几分钟)...${NC}"
echo -e "${YELLOW}注意: 如果因为网络超时失败，请尝试重新运行脚本或检查网络(可能需要VPN)。${NC}"

xcrun notarytool submit "$DMG_NAME" \
    --key "$APPLE_API_KEY_PATH" \
    --key-id "$APPLE_API_KEY" \
    --issuer "$APPLE_API_ISSUER" \
    --wait

if [ $? -ne 0 ]; then
    echo -e "${RED}公证失败。通常是因为网络连接超时或 Apple 服务器无响应。${NC}"
    echo -e "${RED}请检查网络后重试。${NC}"
    exit 1
fi
echo -e "${GREEN}公证通过！${NC}"

# 8. 装订票据 (Staple)
echo -e "${YELLOW}[8/8] 装订公证票据...${NC}"
xcrun stapler staple "$DMG_NAME" || {
    echo -e "${RED}装订失败${NC}"
    exit 1
}

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}🎉 打包完成！${NC}"
echo -e "${GREEN}输出文件: $(pwd)/${DMG_NAME}${NC}"
echo -e "${GREEN}您可以将此文件发送给朋友了。${NC}"
echo -e "${GREEN}==========================================${NC}"
