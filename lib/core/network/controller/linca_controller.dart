import 'dart:async';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// LinCa 共通の AsyncNotifier ベースクラス
/// 各 Controller の build() にトレースを自動仕込む
abstract class LincaController<T> extends AsyncNotifier<T> {
  /// サブクラスでオーバーライドする本体処理
  FutureOr<T> buildImpl();

  @override
  FutureOr<T> build() async {
    final String traceName = runtimeType.toString(); // クラス名をトレース名にする
    final Trace trace = FirebasePerformance.instance.newTrace(traceName);

    await trace.start();
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final T result = await buildImpl();
      trace.putAttribute(
          'duration_ms', stopwatch.elapsedMilliseconds.toString());
      await trace.stop();
      return result;
    } catch (e) {
      trace.putAttribute('error', e.toString());
      await trace.stop();
      rethrow;
    }
  }
}
