# xc_launch

启动页业务包（独立 git 仓库）：启动配置 + 倒计时 + 跳过，结束后替换为主框架。

## 对外出口

- `LaunchModule`：路由表（`@GRoute` 生成）+ 启动期同步任务，壳工程装配时安装
- `LaunchRoutes.page`：路由名常量
- `XcLaunchAssets.*`：资源常量（`xc assets` 生成）

## 依赖

- `xc_platform` / `xc_ui`：框架包，本地以 path 指向 `../xc_framework/packages/`，
  上远程后换成 git 依赖
- `xc_index`：跳转目标（path: `../xc_index`）

## 被谁引用

`xc_app_module`（App 装配层）通过 git 依赖接入本仓库：

```yaml
xc_launch:
  git:
    url: <本仓库地址>
    ref: main
```

## 开发

```bash
flutter pub get
flutter analyze
flutter test
```
