import 'package:xc_launch/gen/generated_routes.g.dart' as r;
import 'package:xc_platform/xc_platform.dart';

/// Module：业务包对外唯一出口。
class LaunchModule extends Module {
  @override
  final String name = 'xc_launch';

  /// 路由表由 @GRoute 注解生成，新增页面只需重跑 `dart run xc_codegen`。
  @override
  Map<String, ComponentBuilder> get routes => r.routes;

  @override
  Future<void>? get syncTask => _preload();

  /// 启动期同步任务：写在业务包内部，主壳不用知道具体做了什么。
  ///
  /// 启动页是进 App 的第一屏，这里留给「必须在首帧前完成」的预热
  /// （真实项目里是配置缓存、日志落地、SDK init）。
  Future<void> _preload() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
