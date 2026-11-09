// Flutter 自带的 Action 与框架的 Action 重名，这里只隐藏 Flutter 那个
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:xc_launch/src/route/launch/launch_page_com.dart';
import 'package:xc_platform/xc_platform.dart';

void main() {
  setUp(() => XcHttp.install(const MockXcHttpClient(latency: Duration.zero)));

  /// 起一个走完 init（内部会拉一次启动配置）的 Model。
  Future<LaunchModel> bootedModel() async {
    final LaunchModel model = createLaunchModel()..ensureInitialized();
    await pumpEventQueue(); // 等 mock 请求回来
    return model;
  }

  test('启动配置进状态：App 名、标语、倒计时都来自接口', () async {
    final LaunchModel model = await bootedModel();

    expect(model.appName, '响彻星空');
    expect(model.slogan, '让声音抵达星空');
    expect(model.countdown, 3);
    expect(model.total, 3);
    expect(model.finished, isFalse);
    expect(model.pageState.status, PageStatus.content);

    model.dispose();
  });

  test('倒计时归零：finished 置真，再 tick 不会重复触发', () async {
    final LaunchModel model = await bootedModel();

    model.onTick();
    model.onTick();
    expect(model.countdown, 1);
    expect(model.finished, isFalse);

    model.onTick(); // 1 → 0，直接收尾
    expect(model.countdown, 0);
    expect(model.finished, isTrue);

    model.onTick();
    expect(model.countdown, 0);
    expect(model.finished, isTrue);

    model.dispose();
  });

  test('跳过：不等倒计时，立刻 finished', () async {
    final LaunchModel model = await bootedModel();

    model.onSkip();
    expect(model.finished, isTrue);

    model.dispose();
  });

  test('dispatch：参数类型不符 / 普通方法都进不了 switch', () async {
    final LaunchModel model = await bootedModel();
    final Dispatcher dispatch = createLaunchModelDispatcher(model);

    expect(
      () => dispatch(const Action('LaunchModel.onSkip', <Object?>['x'])),
      throwsArgumentError,
    );

    // onTick 是普通方法：不进 switch，只能本类内部调
    expect(
      () => dispatch(const Action('LaunchModel.onTick')),
      throwsArgumentError,
    );

    dispatch(LaunchModelIntents.skip());
    expect(model.finished, isTrue);

    model.dispose();
  });

  testWidgets('四态：loading 只留转圈，错误态给重试，内容态出倒计时', (WidgetTester tester) async {
    final LaunchModel model = createLaunchModel();
    final Dispatcher dispatch = createLaunchModelDispatcher(model);

    model.pageState.loading();
    await tester.pumpWidget(
      MaterialApp(home: LaunchView(model: model, dispatch: dispatch)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('跳过'), findsNothing);

    model.pageState.fail('拉不到启动配置');
    await tester.pump();
    expect(find.text('拉不到启动配置'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    model.pageState.content();
    await tester.pump();
    expect(find.text('跳过'), findsOneWidget);
    expect(find.text('3 秒后进入'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    model.dispose();
  });
}
