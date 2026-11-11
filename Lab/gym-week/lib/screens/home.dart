// Home: where training stands, and the way to every other screen. A plain stand-in for screen 01.
import 'package:flutter/material.dart';

import '../logic.dart';
import '../model.dart';
import '../ui.dart';
import 'exercises.dart';
import 'goals.dart';
import 'rest.dart';
import 'routines.dart';
import 'workout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    store.addListener(_maybeAsk);
    _maybeAsk();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    store.removeListener(_maybeAsk);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _maybeAsk();
  }

  /// A goal's reach prompt appears when Auburn is opened with no workout in progress, never during one.
  void _maybeAsk() {
    if (_asking || store.current != null) return;
    if (checkGoals()) store.save();
    if (owedPrompts().isEmpty) return;
    _asking = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await askOwedReaches(context);
      _asking = false;
    });
  }

  @override
  Widget build(BuildContext context) => Live((context) {
        final current = store.current;
        final past = store.workouts.where((w) => w.endedAt != null).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final last = past.firstOrNull;
        final rest = readRest();
        final tracked = rest.values.where((r) => r.tracked && r.step != null).toList();
        int count(RestStep s) => tracked.where((r) => r.step == s).length;
        final overdue = tracked.where((r) => r.step == RestStep.overdue).map((r) => r.group.label).toList();
        final active = store.goals.where((g) => g.state == GoalState.active).length;
        final unnamed = store.exercises.where((e) => !e.archived && e.mainMovers.isEmpty && e.supporting.isEmpty).length;
        return Scaffold(
          backgroundColor: tube,
          body: SafeArea(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 24), children: [
              Row(children: [
                Text('AUBURN', style: const TextStyle(fontFamily: 'Gelasio', fontWeight: FontWeight.w700, fontSize: 30, letterSpacing: 9, color: ember)),
                Container(width: 14, height: 26, color: ember, margin: const EdgeInsets.only(left: 4)),
              ]),
              const SizedBox(height: 4),
              Text('LAB · A WEEK IN THE GYM', style: ts(9.5, color: supportingC, bold: true, spacing: 2)),
              const SizedBox(height: 8),
              Text(
                  last == null
                      ? 'NO WORKOUT YET'
                      : 'LAST WORKOUT · ${daysBetween(last.startedAt, DateTime.now())} DAYS AGO · ${store.gym(last.gymId)?.name ?? '?'}'.toUpperCase(),
                  style: ts(11, color: secondaryC, spacing: 1.5)),
              const SizedBox(height: 16),
              if (unnamed > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(color: cyanWhite.withValues(alpha: 0.6), width: 2)),
                  child: Text('$unnamed EXERCISES NAME NO MUSCLE GROUPS YET. REST COUNTS NOTHING FOR THEM UNTIL THEIR MAIN MOVERS ARE NAMED, UNDER EXERCISES.', style: ts(11, color: cyanWhite, spacing: 1)),
                ),
              InkWell(
                onTap: () => push(context, const RestScreen()),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: lineSupporting, width: 3)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(color: ember, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), child: Text('REST AT A GLANCE', style: ts(12, color: obsidian, bold: true, spacing: 3))),
                    const SizedBox(height: 8),
                    Text('${count(RestStep.should)} IN SHOULD · ${count(RestStep.overdue)} OVERDUE · ${count(RestStep.maybe)} IN MAYBE', style: ts(11.5, color: secondaryC)),
                    Text(overdue.isEmpty ? 'NOTHING OVERDUE' : 'OVERDUE · ${overdue.join(', ')}'.toUpperCase(), style: ts(11.5, color: secondaryC)),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => push(context, const GoalsScreen()),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: lineSupporting, width: 3)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(color: ember, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), child: Text('GOALS', style: ts(12, color: obsidian, bold: true, spacing: 3))),
                    const SizedBox(height: 8),
                    Text('$active ACTIVE · ${store.goals.where((g) => g.state == GoalState.draft).length} DRAFTS · ${store.goals.where((g) => g.state == GoalState.reached).length} REACHED', style: ts(11.5, color: secondaryC)),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              Entry(current == null ? 'Start workout' : 'Resume workout',
                  sub: current == null ? null : workoutTitle(current),
                  onTap: () => push(context, current == null ? const StartWorkoutScreen() : const WorkoutScreen())),
              Entry('Past workouts', trailing: '${past.length}', onTap: () => push(context, const PastWorkoutsScreen())),
              Entry('Exercises', trailing: '${store.exercises.where((e) => !e.archived).length}', onTap: () => push(context, const ExercisesScreen())),
              Entry('Routines', trailing: '${store.routines.where((r) => !r.archived).length}', onTap: () => push(context, const RoutinesScreen())),
              Entry('Gyms', trailing: '${store.gyms.where((g) => !g.archived).length}', onTap: () => push(context, const GymsScreen())),
            ]),
          ),
        );
      });
}
