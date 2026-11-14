// Lab prototype: a week in the gym. Throwaway code; its question and verdict live in Lab/Log.md.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model.dart';
import 'screens/home.dart';
import 'screens/workout.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: tube, systemNavigationBarColor: tube));
  await store.load();
  runApp(const GymWeekApp());
}

class GymWeekApp extends StatelessWidget {
  const GymWeekApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Auburn Lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: tube,
          colorScheme: const ColorScheme.dark(primary: ember, surface: tube),
          splashColor: ember.withValues(alpha: 0.15),
          highlightColor: ember.withValues(alpha: 0.08),
          fontFamily: 'Saira',
        ),
        home: const _Opening(),
      );
}

/// With a workout in progress, Auburn opens straight to it, over home.
class _Opening extends StatefulWidget {
  const _Opening();
  @override
  State<_Opening> createState() => _OpeningState();
}

class _OpeningState extends State<_Opening> {
  @override
  void initState() {
    super.initState();
    if (store.current != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) push(context, const WorkoutScreen());
      });
    }
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}
