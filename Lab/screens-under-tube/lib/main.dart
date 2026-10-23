// Lab sketch: Approved screens under the tube. Throwaway code — see Lab/Log.md.
//
// Question: does each screen approved on the canvas, rebuilt in Flutter, look
// and read as intended on the Fold under the tube, in each of its themes?
//
// A standing attempt: each newly approved screen joins the list in _screens.

import 'package:flutter/material.dart';

import 'basics.dart';
import 'screens/boot.dart';
import 'tube.dart';

void main() => runApp(const LabApp());

enum ThemeChoice { system, dark, light }

/// One approved screen: its number, name, whether it has a light theme, and how to build it.
class ApprovedScreen {
  const ApprovedScreen(this.number, this.name, this.hasLight, this.build, {this.glassHigh = false});

  final String number;
  final String name;
  final bool hasLight;

  /// The screen's glass level in Visual Design's basics: Low unless the screen opts into High.
  final bool glassHigh;
  final Widget Function(bool dark, int replays) build;
}

final _screens = <ApprovedScreen>[
  ApprovedScreen('00', 'BOOT', true, (dark, replays) => BootScreen(dark: dark, replays: replays), glassHigh: true),
];

class LabApp extends StatelessWidget {
  const LabApp({super.key});

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
            const Text('APPROVED SCREENS', style: TextStyle(fontFamily: 'monospace', color: ember, fontSize: 13, letterSpacing: 2)),
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
              child: widget.screen.build(dark, _replays),
            ),
            if (_controls) Align(alignment: Alignment.topCenter, child: SafeArea(child: _bar(dark))),
          ],
        ),
      ),
    );
  }

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
          key('BACK', () => Navigator.of(context).pop()),
        ]),
        Row(children: [
          key('GLASS ${_glassLevels[_glass].$1}', () => setState(() => _glass = (_glass + 1) % _glassLevels.length)),
          key('TRAVEL ${_travels[_travel].$1}', () => setState(() => _travel = (_travel + 1) % _travels.length)),
          key('CENTER', () => setState(() => _centers++)),
        ]),
      ]),
    );
  }
}
