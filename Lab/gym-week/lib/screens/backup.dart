// Export and import: every record as one JSON file, so a week's data outlives the build it was logged in.
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../logic.dart';
import '../model.dart';
import '../ui.dart';

const _format = 'auburn-lab-gym-week';

Future<void> exportData(BuildContext context) async {
  final now = DateTime.now();
  final stamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final raw = jsonEncode({'format': _format, 'version': 1, 'exportedAt': now.toIso8601String(), ...store.toJson()});
  String? path;
  try {
    path = await FilePicker.platform.saveFile(fileName: 'auburn-$stamp.json', bytes: utf8.encode(raw));
  } catch (e) {
    if (context.mounted) await confirm(context, 'Not exported', note: '$e', yes: 'OK');
    return;
  }
  if (path == null || !context.mounted) return;
  await confirm(context, 'Exported', note: '${store.workouts.length} workouts, ${store.exercises.length} exercises, ${store.goals.length} goals and ${store.routines.length} routines, as auburn-$stamp.json.', yes: 'OK');
}

Future<void> importData(BuildContext context) async {
  if (store.current != null) {
    await confirm(context, 'End the workout first', note: 'An import replaces everything, the workout in progress included.', yes: 'OK');
    return;
  }
  Map<String, dynamic> j;
  try {
    final picked = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    final bytes = picked?.files.single.bytes;
    if (bytes == null) return;
    j = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    if (j['format'] != _format) throw const FormatException('This is not an Auburn export.');
  } catch (e) {
    if (context.mounted) await confirm(context, 'Not imported', note: e is FormatException ? e.message : '$e', yes: 'OK');
    return;
  }
  if (!context.mounted) return;
  final workouts = (j['workouts'] as List? ?? []).length;
  final ok = await confirm(context, 'Replace everything on this phone?',
      note: 'The file holds $workouts workouts, exported ${fmtDay(DateTime.tryParse(j['exportedAt'] ?? ''))}. This phone holds ${store.workouts.length}. Everything here is replaced by the file.', yes: 'Replace');
  if (!ok) return;
  final before = jsonEncode(store);
  try {
    store.read(j);
    checkGoals();
    store.save();
  } catch (e) {
    store.read(jsonDecode(before));
    store.save();
    if (context.mounted) await confirm(context, 'Not imported', note: 'The file could not be read, and nothing was changed.\n$e', yes: 'OK');
  }
}
