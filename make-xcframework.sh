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
ios_frameworks=$(find artifacts/VLCKit-ios -name "*.framework" -type d)
macos_frameworks=$(find artifacts/VLCKit-macos -name "*.framework" -type d)
tvos_frameworks=$(find artifacts/VLCKit-tvos -name "*.framework" -type d)
watchos_frameworks=$(find artifacts/VLCKit-watchos -name "*.framework" -type d)
xros_frameworks=$(find artifacts/VLCKit-xros -name "*.framework" -type d)

# 检查是否找到了所有必要的 framework
frameworks=()
if [[ -n "$ios_frameworks" ]]; then
    for framework in $ios_frameworks; do
        frameworks+=("-framework" "$framework")
        echo "找到 iOS framework: $framework"
    done
fi

if [[ -n "$macos_frameworks" ]]; then
    for framework in $macos_frameworks; do
        frameworks+=("-framework" "$framework")
        echo "找到 macOS framework: $framework"
    done
fi

if [[ -n "$tvos_frameworks" ]]; then
    for framework in $tvos_frameworks; do
        frameworks+=("-framework" "$framework")
        echo "找到 tvOS framework: $framework"
    done
fi

if [[ -n "$watchos_frameworks" ]]; then
    for framework in $watchos_frameworks; do
        frameworks+=("-framework" "$framework")
        echo "找到 watchOS framework: $framework"
    done
fi

if [[ -n "$xros_frameworks" ]]; then
    for framework in $xros_frameworks; do
        frameworks+=("-framework" "$framework")
        echo "找到 xrOS framework: $framework"
    done
fi

# 检查是否至少有一个 framework
if [[ ${#frameworks[@]} -eq 0 ]]; then
    echo "错误: 没有找到任何 framework 文件"
    exit 1
fi

# 创建 XCFramework
output_xcframework="VLCKitSPM-All.xcframework"
echo "创建 XCFramework: $output_xcframework"

# 删除已存在的 XCFramework
if [[ -d "$output_xcframework" ]]; then
    rm -rf "$output_xcframework"
fi

# 使用 xcodebuild 创建 XCFramework
xcodebuild -create-xcframework "${frameworks[@]}" -output "$output_xcframework"

echo "✅ XCFramework 创建成功: $output_xcframework"

codesign -fs - --deep *.xcframework

zip -ry --symlinks VLCKitSPM-All.xcframework.zip VLCKitSPM-All.xcframework
echo "✅ XCFramework 压缩成功: VLCKitSPM-All.xcframework.zip"
