// The tube's frame rate — a probe sharing this app; see Lab/Log.md. Throwaway code.
//
// The tube redraws at a set rate instead of every frame, the tilt sensor reads at a set
// speed, and the display is asked for a refresh rate. The readout shows what the phone
// actually runs at and how warm the battery gets.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Perf {
  // Reads every 10 s from the start, so a run is measured even with the controls closed.
  Perf._() {
    read();
    Timer.periodic(const Duration(seconds: 10), (_) => read());
  }

  static final instance = Perf._();

  final _channel = const MethodChannel('auburn/perf');

  /// The tube's redraws a second; 0 holds it still.
  static const rates = [30, 60, 120, 0];
  int rate = 30;

  static const sensors = [('UI', SensorInterval.uiInterval), ('NORMAL', SensorInterval.normalInterval), ('GAME', SensorInterval.gameInterval)];
  int sensor = 0;

  /// The display refresh rate asked for; 0 leaves it to the system.
  static const refreshes = [75, 60, 120, 0];
  int refresh = 75;

  double? _startBattery;
  DateTime _start = DateTime.now();
  String status = 'NOT READ YET';

  Future<void> setRefresh(int hz) async {
    refresh = hz;
    try {
      await _channel.invokeMethod('setRefresh', hz);
    } catch (_) {}
  }

  /// Starts the 20-minute run over: temperature and time are measured from now.
  void restartRun() {
    _startBattery = null;
    _start = DateTime.now();
  }

  Future<void> read() async {
    try {
      final s = Map<String, dynamic>.from(await _channel.invokeMethod('status') as Map);
      final battery = (s['battery'] as num?)?.toDouble();
      _startBattery ??= battery;
      final rise = battery == null || _startBattery == null ? '' : ' (${(battery - _startBattery!) >= 0 ? '+' : ''}${(battery - _startBattery!).toStringAsFixed(1)})';
      final t = DateTime.now().difference(_start);
      final mmss = '${t.inMinutes.toString().padLeft(2, '0')}:${(t.inSeconds % 60).toString().padLeft(2, '0')}';
      final modes = (s['modes'] as List).map((m) => (m as num).round()).join('/');
      status = 'TUBE ${rate == 0 ? 'STILL' : '$rate FPS'} · TILT ${sensors[sensor].$1} · DISPLAY ${(s['refresh'] as num).round()} HZ '
          '(ASKED ${refresh == 0 ? 'NONE' : refresh}; MODES $modes) · BATTERY ${battery?.toStringAsFixed(1) ?? '?'} °C$rise · RUN $mmss';
    } catch (e) {
      status = 'PERF UNREAD: $e';
    }
  }
}
