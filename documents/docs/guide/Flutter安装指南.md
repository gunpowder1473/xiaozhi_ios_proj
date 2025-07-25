# Flutter安装与配置指南

本文档提供了AI Assistant应用的安装和配置详细说明，包括环境搭建、依赖安装和平台特定的配置步骤。

## 1. Flutter SDK安装

### Windows
1. 下载 [Flutter SDK](https://flutter.dev/docs/get-started/install/windows)
2. 解压到不带特殊字符和空格的目录（如 `C:\flutter`）
3. 将 `flutter\bin` 添加到系统 PATH 变量
4. 打开命令提示符或PowerShell，运行 `flutter doctor` 以验证并解决潜在问题

### macOS
1. 使用 Homebrew 安装（推荐）:
   ```bash
   brew install --cask flutter
   ```
2. 或下载 [Flutter SDK](https://flutter.dev/docs/get-started/install/macos) 并手动解压
3. 将 Flutter 添加到 PATH:
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```
4. 运行 `flutter doctor` 检查配置

### Linux
1. 下载 [Flutter SDK](https://flutter.dev/docs/get-started/install/linux)
2. 解压文件:
   ```bash
   tar xf flutter_linux_3.7.0-stable.tar.xz
   ```
3. 添加 Flutter 到 PATH:
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```
4. 运行 `flutter doctor` 进行配置检查

## 2. 安装开发工具

推荐使用以下IDE之一进行开发:

- **Visual Studio Code**
  - 安装 [Flutter 插件](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
  - 安装 [Dart 插件](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)

- **Android Studio / IntelliJ IDEA**
  - 安装 Flutter 和 Dart 插件 (Preferences > Plugins > 搜索 "Flutter")

## 3. 平台特定设置

### Android开发
1. 安装 [Android Studio](https://developer.android.com/studio)
2. 安装 Android SDK (通过 Android Studio 的 SDK Manager)
3. 设置 Android 设备进行开发:
   - 启用 USB 调试（开发者选项）
   - 或使用 Android 模拟器

### iOS开发 (仅限macOS)
1. 安装 [Xcode](https://apps.apple.com/us/app/xcode/id497799835)
2. 配置 iOS 模拟器或实际设备
3. 安装 CocoaPods:
   ```bash
   sudo gem install cocoapods
   ```

### Web开发
1. 确保已安装 Chrome 浏览器
2. 启用 Flutter web 支持:
   ```bash
   flutter config --enable-web
   ```

### Windows/macOS/Linux桌面应用开发
1. 启用对应平台支持:
   ```bash
   # Windows
   flutter config --enable-windows-desktop
   
   # macOS
   flutter config --enable-macos-desktop
   
   # Linux
   flutter config --enable-linux-desktop
   ```

## 4. 项目设置

1. 克隆项目仓库:
   ```bash
   git clone https://github.com/your-username/xintong_ai.git
   cd xintong_ai
   ```

2. 获取依赖:
   ```bash
   flutter pub get
   ```

3. 根据需要配置 Firebase 或其他云服务 (如适用)

## 5. 配置AI服务

### 小智服务配置
1. 在应用中导航至"设置" > "小智服务"
2. 输入以下信息:
   - 名称: 为该配置指定一个识别名称
   - WebSocket URL: 小智服务端的WebSocket连接地址
   - MAC地址: 设备MAC地址（适用于蓝牙设备）
   - 令牌: 认证令牌

### Dify配置
1. 访问 [Dify官网](https://dify.ai/) 创建账户并获取API密钥
2. 在应用设置中添加新的Dify配置:
   - 名称: 自定义配置名称
   - API Key: 从Dify控制台获取的密钥
   - API URL: Dify服务的API端点

### OpenAI配置
1. 从 [OpenAI开发者平台](https://platform.openai.com/) 获取API密钥
2. 在应用设置中配置:
   - API Key: OpenAI API密钥
   - 组织ID (可选): 如有组织账户需填写
   - 模型: 选择所需的GPT模型（如gpt-4、gpt-3.5-turbo）
   - 系统提示: 设置默认的系统提示词

## 6. 运行应用

```bash
# 在连接的设备上运行
flutter run

# 指定平台运行
flutter run -d windows
flutter run -d macos
flutter run -d chrome
flutter run -d <device-id>
```

## 7. 构建发布版本

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 8. 权限说明

应用可能需要以下权限:
- **麦克风**: 用于语音识别和录音功能
- **蓝牙**: 用于连接物联网设备
- **相机**: 用于视觉识别功能
- **存储**: 用于保存音频和图片文件

请确保在使用相应功能前授予所需权限。

## 9. 故障排除

### 常见问题

1. **Flutter SDK 未找到**
   - 确认 Flutter 已正确添加到系统 PATH
   - 检查 `flutter doctor` 输出是否有错误

2. **依赖获取失败**
   - 尝试使用国内镜像源:
     ```bash
     export PUB_HOSTED_URL=https://pub.flutter-io.cn
     export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
     ```
   - 清除缓存后重试:
     ```bash
     flutter clean
     flutter pub cache repair
     flutter pub get
     ```

3. **编译错误**
   - 查看详细错误信息: `flutter run -v`
   - 确保使用支持的 Flutter SDK 版本 (^3.7.0)

4. **iOS构建失败**
   - 删除 Pods 目录并重新安装:
     ```bash
     cd ios
     rm -rf Pods
     pod install
     cd ..
     flutter run
     ```

5. **Android Gradle 同步失败**
   - 编辑 `android/gradle.properties` 添加代理设置或使用国内镜像

## 10. 参考资源

- [Flutter 官方文档](https://flutter.dev/docs)
- [Dart 官方文档](https://dart.dev/guides)
- [Flutter Pub 包管理](https://pub.dev/)
- [Flutter 社区中文资源](https://flutter.cn/) 