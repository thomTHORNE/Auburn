// Lab sketch: Approved screens under the tube. Throwaway code — see Lab/Log.md.
//
// Question: does each screen brought for approval on the canvas, rebuilt in
// Flutter, look, read and handle as intended on the Fold under the tube, in
// each of its themes?
//
// A standing attempt: each screen brought for approval joins the list in _screens.

import 'dart:async';

import 'package:flutter/material.dart';

import 'basics.dart';
import 'screens/boot.dart';
import 'screens/home.dart';
import 'perf.dart';
import 'sounds.dart';
import 'tube.dart';

void main() => runApp(const LabApp());

enum ThemeChoice { system, dark, light }

/// One screen: its number, name, whether it has a light theme, and how to build it.
class ApprovedScreen {
  const ApprovedScreen(this.number, this.name, this.hasLight, this.build, {this.glassHigh = false, this.variants = const []});

  final String number;
  final String name;
  final bool hasLight;

  /// The screen's glass level in Visual Design's basics: Low unless the screen opts into High.
  final bool glassHigh;
  /// States the controls can switch between, such as a workout in progress.
  final List<String> variants;
  final Widget Function(bool dark, int replays, int variant) build;
}

final _screens = <ApprovedScreen>[
  ApprovedScreen('00', 'BOOT', true, (dark, replays, _) => BootScreen(dark: dark, replays: replays), glassHigh: true),
  ApprovedScreen('01', 'NAVIGATION · ROUND 2, FOR APPROVAL', false,
      (dark, replays, variant) => HomeScreen(key: ValueKey(replays), workoutInProgress: variant == 1),
      variants: const ['NO WORKOUT', 'IN WORKOUT']),
];

class LabApp extends StatefulWidget {
  const LabApp({super.key});

  @override
  State<LabApp> createState() => _LabAppState();
}

// The ambience fades out when Auburn leaves the screen and back in when it returns.
class _LabAppState extends State<LabApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      Sounds.instance.setForeground(state == AppLifecycleState.resumed);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auburn · Screens under the tube',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: tube),
      home: const ScreenList(),
    );
  }
}

class ScreenList extends StatelessWidget {
  const ScreenList({super.key});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontFamily: 'monospace', color: Color(0xFFC8C3B0), fontSize: 16, letterSpacing: 1.5);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('SCREENS', style: TextStyle(fontFamily: 'monospace', color: ember, fontSize: 13, letterSpacing: 2)),
            const SizedBox(height: 4),
            const Text('Long-press a running screen for its controls.', style: TextStyle(fontFamily: 'monospace', color: Color(0xFF8A8676), fontSize: 11)),
            const SizedBox(height: 16),
            for (final s in _screens)
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScreenRunner(screen: s))),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0x8CC8C3B0))),
                  child: Text('${s.number} · ${s.name}${s.hasLight ? '   DARK / LIGHT' : ''}', style: style),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ScreenRunner extends StatefulWidget {
  const ScreenRunner({super.key, required this.screen});

  final ApprovedScreen screen;

  @override
  State<ScreenRunner> createState() => _ScreenRunnerState();
}

class _ScreenRunnerState extends State<ScreenRunner> {
  ThemeChoice _theme = ThemeChoice.system;
  bool _tubeOn = true;
  bool _controls = false;
  int _replays = 0;
  int _variant = 0;

  // For checking the glass; each screen starts at its own level from the basics.
  static const _glassLevels = [('LOW', 0.6), ('HIGH', 1.2), ('OFF', 0.0)];
  static const _travels = [('SMALL', 0.35), ('LARGE', 0.7)];
  late int _glass = widget.screen.glassHigh ? 1 : 0;
  int _travel = 0;
  int _centers = 0;

  bool _dark(BuildContext context) => switch (_theme) {
        ThemeChoice.dark => true,
        ThemeChoice.light => false,
        ThemeChoice.system => MediaQuery.of(context).platformBrightness == Brightness.dark,
      };

  @override
  Widget build(BuildContext context) {
    final dark = !widget.screen.hasLight || _dark(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => setState(() => _controls = !_controls),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The screen under the tube. The controls sit outside the shader.
            Tube(
              on: _tubeOn,
              glass: _glassLevels[_glass].$2,
              travel: _travels[_travel].$2,
              centers: _centers,
              readout: _controls,
              rate: Perf.instance.rate == 0 ? -1 : (Perf.instance.rate >= 120 ? 0 : Perf.instance.rate),
              sensorInterval: Perf.sensors[Perf.instance.sensor].$2,
              child: widget.screen.build(dark, _replays, _variant),
            ),
            if (_controls) Align(alignment: Alignment.topCenter, child: SafeArea(child: _bar(dark))),
          ],
        ),
      ),
    );
  }

  // Stands in for the volume in Settings.
  Widget _volumeSlider() => Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.black.withValues(alpha: 0.85),
        child: Row(children: [
          const Text('VOLUME', style: TextStyle(fontFamily: 'monospace', color: cyanWhite, fontSize: 12, letterSpacing: 1)),
          Expanded(
            child: Slider(
              value: Sounds.instance.volume,
              divisions: 20,
              activeColor: cyanWhite,
              onChanged: (v) => setState(() => Sounds.instance.setVolume(v)),
            ),
          ),
          Text('${(Sounds.instance.volume * 100).round()}%',
              style: const TextStyle(fontFamily: 'monospace', color: cyanWhite, fontSize: 12)),
        ]),
      );

  Widget _bar(bool dark) {
    Widget key(String label, VoidCallback onTap) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                color: Colors.black.withValues(alpha: 0.85),
                child: Text(label,
                    style: const TextStyle(fontFamily: 'monospace', color: cyanWhite, fontSize: 12, letterSpacing: 1)),
              ),
            ),
          ),
        );
    final themeLabel = switch (_theme) {
      ThemeChoice.system => 'SYSTEM·${dark ? 'D' : 'L'}',
      ThemeChoice.dark => 'DARK',
      ThemeChoice.light => 'LIGHT',
    };
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          if (widget.screen.hasLight)
            key(themeLabel, () => setState(() => _theme = ThemeChoice.values[(_theme.index + 1) % ThemeChoice.values.length])),
          key(_tubeOn ? 'TUBE ON' : 'TUBE OFF', () => setState(() => _tubeOn = !_tubeOn)),
          key('REPLAY', () => setState(() => _replays++)),
          key(Sounds.instance.soundOn ? 'SOUND ON' : 'SOUND OFF', () => setState(() => Sounds.instance.setSoundOn(!Sounds.instance.soundOn))),
          key('BACK', () => Navigator.of(context).pop()),
        ]),
        Row(children: [
          key('GLASS ${_glassLevels[_glass].$1}', () => setState(() => _glass = (_glass + 1) % _glassLevels.length)),
          key('TRAVEL ${_travels[_travel].$1}', () => setState(() => _travel = (_travel + 1) % _travels.length)),
          key('CENTER', () => setState(() => _centers++)),
        ]),
        Row(children: [
          key('TUBE ${Perf.instance.rate == 0 ? 'STILL' : '${Perf.instance.rate} FPS'}', () => setState(() {
                final r = Perf.rates;
                Perf.instance.rate = r[(r.indexOf(Perf.instance.rate) + 1) % r.length];
              })),
          key('TILT ${Perf.sensors[Perf.instance.sensor].$1}', () => setState(() => Perf.instance.sensor = (Perf.instance.sensor + 1) % Perf.sensors.length)),
          key('DISPLAY ${Perf.instance.refresh == 0 ? 'SYSTEM' : '${Perf.instance.refresh} HZ'}', () => setState(() {
                final r = Perf.refreshes;
                Perf.instance.setRefresh(r[(r.indexOf(Perf.instance.refresh) + 1) % r.length]);
              })),
          key('RESTART RUN', () => setState(Perf.instance.restartRun)),
        ]),
        Row(children: [
          key(Sounds.instance.ignoreSilent ? 'SILENT IGNORED' : 'SILENT MUTES',
              () => setState(() => Sounds.instance.setIgnoreSilent(!Sounds.instance.ignoreSilent))),
        ]),
        _volumeSlider(),
        const _SoundReadout(),
        if (widget.screen.variants.length > 1)
          Row(children: [
            key(widget.screen.variants[_variant], () => setState(() => _variant = (_variant + 1) % widget.screen.variants.length)),
          ]),
      ]),
    );
  }
}

/// The sound engine's state, refreshed twice a second while the controls are open.
class _SoundReadout extends StatefulWidget {
  const _SoundReadout();

  @override
  State<_SoundReadout> createState() => _SoundReadoutState();
}

class _SoundReadoutState extends State<_SoundReadout> {
  late final Timer _tick = Timer.periodic(const Duration(milliseconds: 500), (_) {
    Perf.instance.read();
    setState(() {});
  });

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tick;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.all(8),
      color: Colors.black.withValues(alpha: 0.85),
      child: Text('${Sounds.instance.status}\n${Perf.instance.status}',
          style: const TextStyle(fontFamily: 'monospace', color: cyanWhite, fontSize: 10, height: 1.4)),
    );
  }
}
