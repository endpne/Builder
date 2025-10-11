#!/bin/bash

set -e

# 清理之前的解压文件
echo "清理之前的解压文件..."
find artifacts -name "*.framework" -type d -exec rm -rf {} + 2>/dev/null || true

# 解压所有的 .xz 文件
echo "解压 XZ 文件..."
find artifacts -name "*.xz" | while read -r xz_file; do
    echo "解压: $xz_file"
    tar -xf "$xz_file" -C "$(dirname "$xz_file")"
done

# 查找解压出的 framework 文件
echo "查找解压出的 framework 文件..."
ios_framework=$(find artifacts/VLCKit-ios -name "*.framework" -type d | head -1)
macos_framework=$(find artifacts/VLCKit-macos -name "*.framework" -type d | head -1)
tvos_framework=$(find artifacts/VLCKit-tvos -name "*.framework" -type d | head -1)
watchos_framework=$(find artifacts/VLCKit-watchos -name "*.framework" -type d | head -1)
xros_framework=$(find artifacts/VLCKit-xros -name "*.framework" -type d | head -1)

# 检查是否找到了所有必要的 framework
frameworks=()
if [[ -n "$ios_framework" ]]; then
    frameworks+=("-framework" "$ios_framework")
    echo "找到 iOS framework: $ios_framework"
fi

if [[ -n "$macos_framework" ]]; then
    frameworks+=("-framework" "$macos_framework")
    echo "找到 macOS framework: $macos_framework"
fi

if [[ -n "$tvos_framework" ]]; then
    frameworks+=("-framework" "$tvos_framework")
    echo "找到 tvOS framework: $tvos_framework"
fi

if [[ -n "$watchos_framework" ]]; then
    frameworks+=("-framework" "$watchos_framework")
    echo "找到 watchOS framework: $watchos_framework"
fi

if [[ -n "$xros_framework" ]]; then
    frameworks+=("-framework" "$xros_framework")
    echo "找到 xrOS framework: $xros_framework"
fi

# 检查是否至少有一个 framework
if [[ ${#frameworks[@]} -eq 0 ]]; then
    echo "错误: 没有找到任何 framework 文件"
    exit 1
fi

# 创建 XCFramework
output_xcframework="VLCKitSPM.xcframework"
echo "创建 XCFramework: $output_xcframework"

# 删除已存在的 XCFramework
if [[ -d "$output_xcframework" ]]; then
    rm -rf "$output_xcframework"
fi

# 使用 xcodebuild 创建 XCFramework
xcodebuild -create-xcframework "${frameworks[@]}" -output "$output_xcframework"

echo "✅ XCFramework 创建成功: $output_xcframework"

codesign -fs - --deep *.xcframework