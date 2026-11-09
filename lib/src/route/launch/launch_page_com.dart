import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Action;
import 'package:xc_index/xc_index.dart';
import 'package:xc_platform/xc_platform.dart';
import 'package:xc_ui/xc_ui.dart';

import '../../api/boot_api.dart';
import '../../../gen/assets_gen.dart';
import 'launch_routes.dart';

part 'launch_page_com.g.dart';

// ===========================================================================
// Model：一个类装完三段 —— ① 状态 ② 业务(@gaction) ③ 普通方法
// 意图工厂不写在 Model 里：由 .g.dart 按 @gaction 签名生成（LaunchModelIntents）
// ===========================================================================
class LaunchModel extends WModel {
  // ① 状态：一行一个字段
  var appName = '响彻星空';
  var slogan = '让声音抵达星空';

  /// 剩余秒数；归零即进主框架。
  var countdown = 3;

  /// 本次倒计时的总秒数，只用来算进度条与文案（后端可配）。
  var total = 3;

  /// 启动结束标记：View 见到它就停下自己、把栈换成主框架。
  ///
  /// 跳转本身要 context，是 View 的事；Model 只负责把「该走了」说出来。
  var finished = false;

  Timer? _timer;

  @override
  void init() {
    // 计时器也是一份要随 Model 释放的资源，登记一次即可（start 只换实例）
    addDisposable(() => _timer?.cancel());
    // 首屏请求：进来就拉启动配置
    onBoot();
  }

  // ② 业务：@gaction() 方法，生成的 switch 按签名强匹配到这里
  @gaction()
  Future<void> onBoot() async {
    pageState.loading();
    finished = false;
    try {
      final Map<String, Object?> res = await BootApi.fetchBootConfig().resume();
      final Object? data = res['data'];
      if (data is! Map<String, Object?>) {
        // 拉到了但没内容：空态，给一个重试入口
        pageState.empty('没有拿到启动配置');
        return;
      }
      final Object? name = data['appName'];
      if (name is String && name.isNotEmpty) {
        appName = name;
      }
      final Object? text = data['slogan'];
      if (text is String && text.isNotEmpty) {
        slogan = text;
      }
      final Object? seconds = data['countdown'];
      total = seconds is int && seconds > 0 ? seconds : 3;
      countdown = total;
      pageState.content();
      _startCountdown();
    } catch (error) {
      pageState.fail('启动失败：$error');
    }
  }

  /// 用户点「跳过」：不等倒计时，直接走。
  @gaction()
  void onSkip() => _finish();

  // ③ 普通方法：不加 @gaction()，就是普通函数
  //    计时器每秒回调一次，属于本类内部流转，View 不需要（也 dispatch 不到）。
  void onTick() {
    if (countdown <= 1) {
      countdown = 0;
      _finish();
      return;
    }
    countdown--;
  }

  void _finish() {
    if (finished) {
      return; // 倒计时归零与「跳过」可能同时到达，只认第一次
    }
    _timer?.cancel();
    finished = true;
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => onTick());
  }
}

// ===========================================================================
// View：只收 model（只读）+ dispatch（只写）
// build 返回一个 Obs：先看「走没走」，再按 pageState 四态多态返回整块页面
// ===========================================================================
class LaunchView extends StatelessWidget {
  const LaunchView({super.key, required this.model, required this.dispatch});

  final LaunchModel model;
  final Dispatcher dispatch;

  @override
  Widget build(BuildContext context) {
    final PageState pageState = model.pageState;
    return Obs(
      builder: (BuildContext context) {
        // 该走了：不再渲染启动页，交给闸门去换栈
        if (model.finished) {
          return const _EnterGate();
        }
        return switch (pageState.status) {
          PageStatus.loading => _sky(const LoadingView()),
          PageStatus.empty => _sky(
              EmptyHintView(
                text: pageState.message ?? '暂无数据',
                onRetry: () => dispatch(LaunchModelIntents.boot()),
              ),
            ),
          PageStatus.error => _sky(
              ErrorHintView(
                message: pageState.message ?? '启动失败',
                onRetry: () => dispatch(LaunchModelIntents.boot()),
              ),
            ),
          PageStatus.content => _sky(_brand(context)),
        };
      },
    );
  }

  /// 四态共用的骨架：深空渐变 + 星点，内容区随态切换。
  Widget _sky(Widget body) => Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF0A0F22), Color(0xFF161B3D), Color(0xFF070A14)],
              stops: <double>[0, 0.55, 1],
            ),
          ),
          child: Stack(
            children: <Widget>[
              const Positioned.fill(
                child: IgnorePointer(child: CustomPaint(painter: _StarFieldPainter())),
              ),
              SafeArea(child: body),
            ],
          ),
        ),
      );

  /// 内容态：品牌 + 倒计时 + 跳过。
  Widget _brand(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double progress = model.total <= 0 ? 0 : 1 - model.countdown / model.total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Spacer(flex: 3),
          const Center(child: _LogoGlow()),
          const SizedBox(height: 28),
          Text(
            model.appName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            model.slogan,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, letterSpacing: 2, color: scheme.onSurfaceVariant),
          ),
          const Spacer(flex: 4),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  model.countdown > 0 ? '${model.countdown} 秒后进入' : '正在进入…',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ),
              TextButton(
                key: const Key('launch-skip'),
                onPressed: () => dispatch(LaunchModelIntents.skip()),
                child: const Text('跳过'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 3,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

/// 启动完成后的「出栈门」：自己不渲染业务内容，只在首帧后把当前页换成主框架。
///
/// 跳转要用 context，只能由 View 侧做；放在 StatefulWidget 里是为了保证
/// post-frame 回调只注册一次（Obs 重建时 State 会被复用，不会重复跳）。
class _EnterGate extends StatefulWidget {
  const _EnterGate();

  @override
  State<_EnterGate> createState() => _EnterGateState();
}

class _EnterGateState extends State<_EnterGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      // replace 而不是 push：启动页不该留在返回栈里
      XcRouter.replace<void>(context, IndexRoutes.page);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: LoadingView());
}

/// 圆形 logo：图来自本包自己的 assets（不经过壳），外发光靠容器阴影。
class _LogoGlow extends StatelessWidget {
  const _LogoGlow();

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(color: primary.withValues(alpha: 0.45), blurRadius: 42, spreadRadius: 6),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          XcLaunchAssets.imagesLaunchMark,
          width: 108,
          height: 108,
          fit: BoxFit.cover,
          // 资源缺失时不至于炸掉整页
          errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF161B3D)),
        ),
      ),
    );
  }
}

/// 星点背景：固定种子，每次画出来都是同一片星空（不用做动画，省一层 repaint）。
class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(7);
    final Paint paint = Paint();
    for (int i = 0; i < 90; i++) {
      final Offset offset = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final double radius = 0.6 + random.nextDouble() * 1.2;
      paint.color = Colors.white.withValues(alpha: 0.15 + random.nextDouble() * 0.55);
      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter oldDelegate) => false;
}

// ===========================================================================
// Component：建 Model、拿 dispatch、吐 View
// ===========================================================================
@GRoute(LaunchRoutes.page)
class LaunchComponent extends Component<LaunchModel> {
  const LaunchComponent({super.key, super.route});

  /// 生成的接管实现：状态才具备响应式
  @override
  LaunchModel createModel() => createLaunchModel();

  /// 生成的 dispatch：switch 按签名强匹配 Action
  @override
  Dispatcher dispatcher(LaunchModel model) => createLaunchModelDispatcher(model);

  @override
  Widget buildView(BuildContext context, LaunchModel model, Dispatcher dispatch) =>
      LaunchView(model: model, dispatch: dispatch);
}
