# 系统依赖安装

Android-Xiaozhi是基于Flutter开发的跨平台应用，以下是运行和开发项目需要的系统依赖。

## 系统依赖安装

### Windows
1. **安装 Flutter SDK**
   - 请参考 [Flutter安装指南](Flutter安装指南.md) 文档完成Flutter SDK安装

2. **安装 Android Studio**
   - 下载并安装 [Android Studio](https://developer.android.com/studio)
   - 安装 Flutter 和 Dart 插件

3. **安装 Visual Studio Code (可选)**
   - 下载并安装 [Visual Studio Code](https://code.visualstudio.com/)
   - 安装 Flutter 和 Dart 插件

### macOS
1. **安装 Flutter SDK**
   - 请参考 [Flutter安装指南](Flutter安装指南.md) 文档完成Flutter SDK安装

2. **安装 Xcode (用于iOS开发)**
   - 从 App Store 下载并安装 Xcode
   - 安装 Xcode 命令行工具: `xcode-select --install`

3. **安装 Android Studio (用于Android开发)**
   - 下载并安装 [Android Studio](https://developer.android.com/studio)
   - 安装 Flutter 和 Dart 插件

4. **安装 CocoaPods (用于iOS依赖管理)**
   ```bash
   sudo gem install cocoapods
   ```

### Linux (Ubuntu)
1. **安装 Flutter SDK**
   - 请参考 [Flutter安装指南](Flutter安装指南.md) 文档完成Flutter SDK安装

2. **安装开发工具**
   ```bash
   sudo apt-get update
   sudo apt-get install curl unzip git
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
   ```

3. **安装 Android Studio**
   - 下载并安装 [Android Studio](https://developer.android.com/studio)
   - 安装 Flutter 和 Dart 插件

## 项目依赖安装

在克隆项目后，需要安装项目依赖:

```bash
# 进入项目目录
cd xiaozhi-android-client

# 获取Flutter依赖
flutter pub get
```

## 运行应用

完成依赖安装后，可以运行应用:

```bash
# 检查可用设备
flutter devices

# 运行应用
flutter run

# 或指定设备运行
flutter run -d <device_id>
```

## 注意事项
1. 确保Flutter SDK版本与项目要求一致，推荐使用最新稳定版
2. Android开发需要配置好Java环境和Android SDK
3. iOS开发需要macOS系统和Apple开发者账号
4. 首次运行可能需要较长时间构建应用
5. 如遇到问题，请查阅Flutter官方文档或提交Issue