// GENERATED CODE - DO NOT MODIFY BY HAND
// 由 xc_codegen 生成：dart run xc_codegen
part of 'launch_page_com.dart';

/// LaunchModel 的状态接管实现：Model 里声明的每个状态字段
/// 在这里被 Atom 接管（读走 getter 订阅、写走 setter 通知）。
/// 标了 @gignore 的字段不生成，保持声明原样、天然只读。
class _$LaunchModelImpl extends LaunchModel {
  late final Atom<String> _appName = atom<String>('响彻星空');
  late final Atom<String> _slogan = atom<String>('让声音抵达星空');
  late final Atom<int> _countdown = atom<int>(3);
  late final Atom<int> _total = atom<int>(3);
  late final Atom<bool> _finished = atom<bool>(false);
  late final Atom<Timer?> __timer = atom<Timer?>(null);

  @override
  String get appName => _appName.value;
  @override
  set appName(String value) => _appName.value = value;

  @override
  String get slogan => _slogan.value;
  @override
  set slogan(String value) => _slogan.value = value;

  @override
  int get countdown => _countdown.value;
  @override
  set countdown(int value) => _countdown.value = value;

  @override
  int get total => _total.value;
  @override
  set total(int value) => _total.value = value;

  @override
  bool get finished => _finished.value;
  @override
  set finished(bool value) => _finished.value = value;

  @override
  Timer? get _timer => __timer.value;
  @override
  set _timer(Timer? value) => __timer.value = value;
}

/// 供 Component.createModel 使用：返回状态接管实现。
LaunchModel createLaunchModel() => _$LaunchModelImpl();

/// LaunchModel 的意图工厂：按 @gaction 方法签名生成，参数顺序 = payload 顺序。
///
/// View 只从这里拿 Action：`dispatch(LaunchModelIntents.submit(...))`；
/// Model 里不写 static Action（写了生成器会报 [ERROR]）。
abstract final class LaunchModelIntents {
  static Action boot() => Action('LaunchModel.onBoot', <Object?>[]);
  static Action skip() => Action('LaunchModel.onSkip', <Object?>[]);
}

/// LaunchModel 的 dispatch：switch 按 Action 名 + payload 列表做签名强匹配。
///
/// 只有标注 @gaction 的业务方法才生成分支；普通方法不进 switch。
/// payload 是位置参数列表，顺序与 @gaction 方法的参数声明顺序一致；
/// 名字、个数或类型对不上都会落到 default 抛错，不会静默穿透。
/// 由 Component 持有（`Component.dispatcher`），Model 自己拿不到 dispatch。
Dispatcher createLaunchModelDispatcher(LaunchModel model) => (Action action) {
      switch (action) {
        case Action(name: 'LaunchModel.onBoot', payload: []):
          model.onBoot();
        case Action(name: 'LaunchModel.onSkip', payload: []):
          model.onSkip();
        default:
          throw ArgumentError.value(action.name, 'action', '未注册的 Action');
      }
    };
