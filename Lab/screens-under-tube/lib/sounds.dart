// Sound in the hand — the three sounds as Spec/Sound Design.md has them. Throwaway code.
//
// Every player requests no audio focus, so another app's music keeps playing
// at full volume alongside (Sound Design: "When Auburn plays").

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

const _fade = Duration(milliseconds: 500);

final _context = AudioContext(
  android: const AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
);

class Sounds {
  Sounds._() {
    for (final p in [_boot, _ambience, _powerDown]) {
      _guard('context', p.setAudioContext(_context));
    }
    _guard('loop', _ambience.setReleaseMode(ReleaseMode.loop));
    Timer.periodic(const Duration(seconds: 1), (_) => _checkRinger());
    _checkRinger();
  }

  static final instance = Sounds._();

  final _boot = AudioPlayer();
  final _ambience = AudioPlayer();
  final _powerDown = AudioPlayer();
  final _ringer = const MethodChannel('auburn/ringer');

  /// The Lab's stand-in for the Settings toggle.
  bool soundOn = true;

  /// Silent or vibrate on the phone.
  bool _silent = false;

  /// Whether the ambience should be running: after the boot, with Auburn on screen.
  bool _ambienceWanted = false;
  bool _foreground = true;
  double _volume = 0;
  Timer? _fader;
  Timer? _bootEnd;

  /// For checking: play even when the phone is on silent or vibrate.
  bool ignoreSilent = false;

  // What the Lab's readout shows: the ringer as read, and the last thing that went wrong.
  String _ringerSeen = 'NOT READ YET';
  String lastError = 'NONE';

  bool get _audible => soundOn && (ignoreSilent || !_silent);

  String get status => 'RINGER $_ringerSeen · ${_audible ? 'AUDIBLE' : 'MUTED'} · AMBIENCE ${_ambience.state.name.toUpperCase()} '
      '${_volume.toStringAsFixed(1)} · ERROR $lastError';

  /// Runs a player call and keeps its failure for the readout instead of losing it.
  Future<void> _guard(String what, Future<void> call) async {
    try {
      await call;
    } catch (e) {
      lastError = '$what: $e';
    }
  }

  Future<void> _checkRinger() async {
    try {
      final mode = await _ringer.invokeMethod<int>('ringerMode');
      _ringerSeen = switch (mode) { 0 => 'SILENT', 1 => 'VIBRATE', 2 => 'NORMAL', _ => '$mode' };
      final silent = mode != null && mode != 2; // AudioManager.RINGER_MODE_NORMAL
      if (silent != _silent) {
        _silent = silent;
        _update();
      }
    } catch (e) {
      // No ringer answer: treat it as normal, and say so in the readout.
      _ringerSeen = 'UNREAD';
      lastError = 'ringer: $e';
    }
  }

  void setIgnoreSilent(bool on) {
    ignoreSilent = on;
    _update();
  }

  void setSoundOn(bool on) {
    soundOn = on;
    _update();
  }

  void setForeground(bool foreground) {
    _foreground = foreground;
    _update();
  }

  /// Plays with the boot screen; the ambience starts the moment the boot ends.
  void boot(Duration bootLength) {
    _ambienceWanted = false;
    _ambience.stop();
    _volume = 0;
    if (_audible) _guard('boot', _boot.play(AssetSource('sounds/auburn-boot.wav')));
    _bootEnd?.cancel();
    _bootEnd = Timer(bootLength, () {
      _ambienceWanted = true;
      // Its last 0.6 s is the ambience's last 0.6 s, so the loop follows on at full level.
      if (_audible && _foreground) {
        _volume = 1;
        _guard('ambience', _ambience.play(AssetSource('sounds/auburn-ambience.wav'), volume: 1));
      }
    });
  }

  /// A screen opened without a boot: the ambience fades in if it is not already running.
  void ensureAmbience() {
    if (_ambienceWanted) return;
    _ambienceWanted = true;
    _update();
  }

  /// The ambience fades out over 0.5 s as the power-down begins.
  void powerDown() {
    _ambienceWanted = false;
    _fadeTo(0);
    if (_audible) _guard('power-down', _powerDown.play(AssetSource('sounds/auburn-power-down.wav')));
  }

  /// In the app Auburn quits here; in the Lab the ambience comes back.
  void afterPowerDown() {
    _powerDown.stop();
    _ambienceWanted = true;
    _update();
  }

  void _update() {
    final on = _ambienceWanted && _audible && _foreground;
    if (!_audible) {
      _boot.stop();
      _powerDown.stop();
    }
    _fadeTo(on ? 1 : 0);
  }

  Future<void> _fadeTo(double target) async {
    _fader?.cancel();
    if (target > 0 && _ambience.state != PlayerState.playing) {
      await _guard('ambience', _ambience.play(AssetSource('sounds/auburn-ambience.wav'), volume: _volume));
    }
    const steps = 20;
    final from = _volume;
    var i = 0;
    _fader = Timer.periodic(_fade ~/ steps, (t) {
      i++;
      _volume = from + (target - from) * i / steps;
      _ambience.setVolume(_volume);
      if (i == steps) {
        t.cancel();
        if (target == 0) _ambience.pause();
      }
    });
  }
}
