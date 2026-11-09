import 'package:xc_platform/xc_platform.dart';

/// 数据访问层：只声明请求，不写业务判断。
class BootApi {
  BootApi._();

  /// 启动配置：App 名、标语、倒计时秒数（真实后端这里是「启动参数 + 是否强制更新」）。
  static RequestTask<Map<String, Object?>> fetchBootConfig() => RequestTask<Map<String, Object?>>(
        r'app$boot',
        decode: (Map<String, Object?> raw) => raw,
      );
}
