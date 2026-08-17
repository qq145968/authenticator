# 身份验证器 Authenticator

基于 TOTP 标准（RFC 6238）的开源身份验证器应用，支持离线生成动态验证码，保护您的账户安全。

## 功能特性

- **TOTP 动态验证码** — 每 30 秒自动刷新，完全离线运行，无需网络
- **二维码扫码添加** — 扫描服务商提供的 `otpauth://` 二维码，一步完成账户绑定
- **手动输入密钥** — 支持手动输入 Base32 密钥
- **分组管理** — 按工作、学习等场景整理验证码账户
- **深色模式** — 支持跟随系统切换深色/浅色主题
- **账户搜索** — 快速搜索已添加的验证码账户
- **验证码键盘** — 系统级键盘扩展，无需启动 APP 即可填入验证码（引导页面）

## 技术栈

| 技术 | 说明 |
|------|------|
| Flutter 3.24+ | 跨平台 UI 框架 |
| Dart 3.5+ | 编程语言 |
| Provider | 状态管理 |
| SharedPreferences | 本地数据持久化 |
| mobile_scanner | 二维码扫描 |
| crypto + base32 | TOTP 算法实现 |

## 项目结构

```
lib/
├── main.dart                          # 应用入口
├── app_router.dart                    # 路由配置
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # 主题、颜色、文字样式
│   ├── providers/
│   │   └── app_provider.dart          # 全局状态管理
│   └── utils/
│       └── totp_utils.dart            # TOTP 算法核心
├── data/
│   ├── models/
│   │   ├── account.dart               # 账户数据模型
│   │   └── user.dart                  # 用户数据模型
│   └── repositories/
│       └── account_repository.dart    # 账户数据仓库
└── presentation/
    ├── onboarding/
    │   └── onboarding_page.dart       # 启动引导页（3页）
    ├── login/
    │   └── login_page.dart            # 登录页
    ├── main/
    │   ├── main_page.dart             # 主页面（底部导航）
    │   ├── home_page.dart             # 首页（验证码列表）
    │   ├── keyboard_page.dart         # 键盘启用页
    │   └── profile_page.dart          # 个人中心页
    ├── scan/
    │   └── scan_page.dart             # 扫码页
    └── manual_add/
        └── manual_add_page.dart       # 手动添加页
```

## 本地开发

### 环境要求

- Flutter 3.24.0+
- Dart 3.5.0+
- Android Studio / VS Code
- Android SDK（API 21+）

### 运行项目

```bash
# 安装依赖
flutter pub get

# 运行（Debug 模式）
flutter run

# 分析代码
flutter analyze

# 运行测试
flutter test

# 构建 Release APK
flutter build apk --release
```

## GitHub 编译

本项目已配置 GitHub Actions 自动编译。推送到 `main` 分支或创建 `v*` 标签即可触发自动构建：

### 自动构建

1. **Push 到 main/master** — 自动编译 APK，生成 Artifact 供下载
2. **创建 Tag（如 `v1.0.0`）** — 自动编译并发布 GitHub Release

### 手动触发

在 GitHub 仓库页面 → Actions → Build Android APK → Run workflow

### 下载编译产物

1. 进入 Actions 页面
2. 点击对应的 Workflow Run
3. 在页面底部 Artifacts 区域下载 `authenticator-apk`

### 本地编译 APK

```bash
# 安装依赖
flutter pub get

# 编译 APK（分架构）
flutter build apk --release --split-per-abi

# 编译 App Bundle（用于上架 Google Play）
flutter build appbundle --release
```

编译产物路径：
- APK: `build/app/outputs/flutter-apk/`
- AAB: `build/app/outputs/bundle/release/`

## 支持的 OTP 平台

兼容所有遵循 TOTP 标准的平台，包括但不限于：
- Google
- GitHub
- Amazon (AWS)
- Microsoft
- Facebook
- Dropbox
- 以及上千款其他主流平台

## 安全说明

- 所有验证码均在**本地生成**，不依赖网络
- 密钥使用 SharedPreferences 加密存储
- 支持深色模式，减少公共场合的肩窥风险
- 长按验证码卡片可删除账户

## License

MIT License - 可自由使用、修改和分发
