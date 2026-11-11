// What Auburn computes from the records: rest and its rhythm, progress lines, a goal's reach,
// what a routine offers, and a set's starting load. Each follows its file in Spec/Features.
import 'model.dart';

DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);
int daysBetween(DateTime a, DateTime b) => (dayOf(b).difference(dayOf(a)).inHours / 24).round();

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String fmtDay(DateTime? d) => d == null ? '—' : '${d.day} ${_months[d.month - 1]}${d.year == DateTime.now().year ? '' : ' ${d.year}'}';
String fmtKg(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
String fmtTime(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

// ---- Rest (Spec/Features/Rest.md) ----

enum RestStep { shouldnt, maybe, should, overdue }

const restStepLabels = ["Shouldn't", 'Maybe', 'Should', 'Overdue'];

enum StepSource { fixed, rhythm, hand }

class RestReading {
  RestReading(this.group);
  final MuscleGroup group;
  bool tracked = false;
  DateTime? lastMain;
  DateTime? lastSupporting;
  int? days;
  RestStep? step;
  StepSource source = StepSource.fixed;
  int maybeFrom = 3, shouldFrom = 4, overdueFrom = 5;
  List<int> gaps = [];
  double? usualGap;
  int? backAfter;
}

double _middle(List<int> values) {
  final v = [...values]..sort();
  final n = v.length;
  return n.isOdd ? v[n ~/ 2].toDouble() : (v[n ~/ 2 - 1] + v[n ~/ 2]) / 2;
}

List<int> _lastSix(List<int> gaps, [int? end]) {
  end ??= gaps.length;
  return gaps.sublist(end - 6 < 0 ? 0 : end - 6, end);
}

Map<MuscleGroup, RestReading> readRest() {
  final byId = {for (final e in store.exercises) e.id: e};
  final mainDays = {for (final g in MuscleGroup.values) g: <DateTime>{}};
  final readings = {for (final g in MuscleGroup.values) g: RestReading(g)};
  for (final w in store.workouts) {
    for (final c in w.commits) {
      final ex = byId[c.exerciseId];
      if (ex == null) continue;
      for (final s in c.sets) {
        if (s.grade == Grade.warmup) continue;
        final day = dayOf(s.loggedAt);
        for (final g in ex.mainMovers) {
          mainDays[g]!.add(day);
        }
        for (final g in ex.supporting) {
          final r = readings[g]!;
          if (r.lastSupporting == null || day.isAfter(r.lastSupporting!)) r.lastSupporting = day;
        }
      }
    }
  }
  for (final e in store.exercises) {
    if (e.archived) continue;
    for (final g in e.mainMovers) {
      readings[g]!.tracked = true;
    }
  }
  final today = DateTime.now();
  for (final g in MuscleGroup.values) {
    final r = readings[g]!;
    final days = mainDays[g]!.toList()..sort();
    if (days.isEmpty) continue;
    r.lastMain = days.last;
    r.days = daysBetween(days.last, today);
    final gaps = [for (var i = 1; i < days.length; i++) daysBetween(days[i - 1], days[i])];
    r.gaps = _lastSix(gaps);
    if (gaps.length >= 3) {
      r.usualGap = _middle(r.gaps);
      r.source = StepSource.rhythm;
      r.shouldFrom = r.usualGap!.ceil();
      r.maybeFrom = r.shouldFrom - 1;
      r.overdueFrom = (r.usualGap! * 1.5).ceil();
      if (r.overdueFrom <= r.shouldFrom) r.overdueFrom = r.shouldFrom + 1;
    }
    final hand = store.restSteps.where((s) => s.group == g).firstOrNull;
    if (hand != null) {
      r.source = StepSource.hand;
      r.maybeFrom = hand.maybeFrom;
      r.shouldFrom = hand.shouldFrom;
      r.overdueFrom = hand.overdueFrom;
    }
    final d = r.days!;
    r.step = d >= r.overdueFrom
        ? RestStep.overdue
        : d >= r.shouldFrom
            ? RestStep.should
            : d >= r.maybeFrom
                ? RestStep.maybe
                : RestStep.shouldnt;
    // Back after a long gap: the latest gap, or the one before it, was more than twice the usual gap before it.
    for (final i in [gaps.length - 1, gaps.length - 2]) {
      if (i < 3) continue;
      if (gaps[i] > 2 * _middle(_lastSix(gaps, i))) {
        r.backAfter = gaps[i];
        break;
      }
    }
  }
  return readings;
}

// ---- Progress (Spec/Features/Progress.md) ----

class Point {
  Point(this.date, this.value);
  final DateTime date;
  final double value;
}

/// One point per workout, drawn from the sets the line is given.
List<Point> exerciseLine(String exerciseId, Param parameter, bool Function(LoggedSet) given, {DateTime? until}) {
  final points = <Point>[];
  final workouts = [...store.workouts]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  for (final w in workouts) {
    double? best;
    for (final c in w.commits) {
      if (c.exerciseId != exerciseId) continue;
      for (final s in c.sets) {
        if (s.grade == null || !given(s)) continue;
        if (until != null && s.loggedAt.isAfter(until)) continue;
        final double? v = parameter == Param.load ? s.loadKg : (s.test ? s.reps?.toDouble() : null);
        if (v != null && (best == null || v > best)) best = v;
      }
    }
    if (best != null) points.add(Point(dayOf(w.startedAt), best));
  }
  return points;
}

// ---- Goals (Spec/Features/Goals.md) ----

/// Whether the target's conditions let this set through, whatever its value.
bool letsThrough(Target t, LoggedSet s) {
  if (s.grade == null || !t.grades.contains(s.grade)) return false;
  if (t.parameter == Param.load) return true;
  if (!s.test || s.reps == null) return false;
  return t.minLoadKg == null || s.loadKg >= t.minLoadKg!;
}

bool reaches(Target t, LoggedSet s) =>
    letsThrough(t, s) && (t.parameter == Param.load ? s.loadKg >= t.value : s.reps! >= t.value);

List<LoggedSet> _setsOf(String exerciseId) => [
      for (final w in store.workouts)
        for (final c in w.commits)
          if (c.exerciseId == exerciseId) ...c.sets
    ]..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

/// Marks every active goal's target the facts now reach, and withdraws a mark its fact no longer supports.
/// Returns whether anything changed. The caller saves.
bool checkGoals() {
  var changed = false;
  for (final g in store.goals) {
    final t = g.target;
    if (g.state != GoalState.active || t == null || t.kept) continue;
    final sets = _setsOf(t.exerciseId);
    if (t.reachedAt != null) {
      final fact = sets.where((s) => s.id == t.reachedById).firstOrNull;
      if (fact != null && reaches(t, fact)) continue;
      t.reachedAt = null;
      t.reachedById = null;
      changed = true;
    }
    for (final s in sets) {
      if (!s.loggedAt.isAfter(g.activatedAt!)) continue;
      if (t.passedUntil != null && !s.loggedAt.isAfter(t.passedUntil!)) continue;
      if (reaches(t, s)) {
        t.reachedAt = s.loggedAt;
        t.reachedById = s.id;
        changed = true;
        break;
      }
    }
  }
  return changed;
}

List<Goal> owedPrompts() =>
    [for (final g in store.goals) if (g.state == GoalState.active && g.target?.reachedAt != null && !g.target!.kept) g];

Goal copyGoal(Goal g) {
  final copy = Goal(
    name: g.name, explanation: g.explanation, exerciseIds: {...g.exerciseIds},
    fromGoalId: g.id, target: g.target?.unreachedCopy(),
  );
  store.goals.add(copy);
  return copy;
}

void _leaveRoutines(Goal g) {
  for (final r in store.routines) {
    r.items.removeWhere((i) => i.goalId == g.id);
  }
}

void keepReach(Goal g) {
  g.target!.kept = true;
  g.state = GoalState.reached;
  g.endedAt = g.target!.reachedAt;
  _leaveRoutines(g);
}

/// An undone mark passes over that fact and every fact before it; the target waits for the next.
void undoReach(Goal g) {
  final t = g.target!;
  t.passedUntil = t.reachedAt;
  t.reachedAt = null;
  t.reachedById = null;
  checkGoals();
}

void abandon(Goal g, String why) {
  g.state = GoalState.abandoned;
  g.endedAt = DateTime.now();
  g.abandonedBecause = why;
  _leaveRoutines(g);
}

/// Why a draft cannot be made active yet, or null when it can.
String? cannotActivate(Goal g) {
  final t = g.target;
  if (g.name.trim().isEmpty) return 'It has no name.';
  if (t == null) return 'It has no target.';
  if (!g.exerciseIds.contains(t.exerciseId)) return 'Its target sits on an exercise that is not in the goal.';
  if (store.exercise(t.exerciseId)?.archived ?? true) return 'Its target sits on an archived exercise.';
  if (t.grades.isEmpty) return 'Its target names no grade.';
  return null;
}

/// The gap runs from the best point since the goal was made active to the target;
/// until a point arrives, from the last point before it.
({double? from, double? gap}) goalGap(Goal g) {
  final t = g.target;
  if (t == null) return (from: null, gap: null);
  final line = exerciseLine(t.exerciseId, t.parameter, (s) => letsThrough(t, s), until: g.endedAt);
  if (line.isEmpty) return (from: null, gap: null);
  final since = g.activatedAt == null ? <Point>[] : line.where((p) => !p.date.isBefore(dayOf(g.activatedAt!))).toList();
  final from = since.isEmpty ? line.last.value : since.map((p) => p.value).reduce((a, b) => a > b ? a : b);
  final gap = t.value - from;
  return (from: from, gap: gap < 0 ? 0 : gap);
}

// ---- Routines (Spec/Features/Routines.md) ----

class OfferedGroup {
  OfferedGroup(this.goal, this.exercises);
  final Goal? goal;
  final List<Exercise> exercises;
}

/// The routine's exercises available at this gym, each offered once, at its first place in the order.
/// An exercise tied to another gym is replaced by its alternate available here, or left out.
List<OfferedGroup> routineOffer(Routine r, String gymId) {
  final seen = <String>{};
  Exercise? resolve(String? id) {
    final e = store.exercise(id);
    if (e == null) return null;
    Exercise? pick = (!e.archived && e.availableAt(gymId)) ? e : null;
    if (pick == null && !e.archived) {
      for (final a in e.alternateIds) {
        final alt = store.exercise(a);
        if (alt != null && !alt.archived && alt.availableAt(gymId)) {
          pick = alt;
          break;
        }
      }
    }
    if (pick == null || !seen.add(pick.id)) return null;
    return pick;
  }

  final groups = <OfferedGroup>[];
  for (final item in r.items) {
    if (item.goalId != null) {
      final goal = store.goal(item.goalId);
      if (goal == null || goal.state != GoalState.active) continue;
      groups.add(OfferedGroup(goal, [for (final id in goal.exerciseIds) resolve(id)].nonNulls.toList()));
    } else {
      final e = resolve(item.exerciseId);
      if (e != null) groups.add(OfferedGroup(null, [e]));
    }
  }
  return groups;
}

/// Whether a goal may join a routine tied to these gyms.
bool goalFitsGyms(Goal g, Set<String> gymIds) {
  if (gymIds.isEmpty) return true;
  final e = store.exercise(g.target?.exerciseId);
  return e != null && gymIds.any(e.availableAt);
}

// ---- Sets (Spec/Features/Sets.md) ----

const plateKeys = [20.0, 10.0, 5.0, 2.5, 1.25];

List<double> platesFor(double total, double bar) {
  var side = (total - bar) / 2;
  final plates = <double>[];
  for (final p in plateKeys) {
    while (side >= p - 1e-9) {
      plates.add(p);
      side -= p;
    }
  }
  return plates;
}

double lowestLoad(Exercise ex) => switch (ex.loadKind) {
      LoadKind.plates => ex.barKg ?? 20,
      LoadKind.stack || LoadKind.dumbbells => ex.stepKg ?? 2.5,
      LoadKind.bodyweight => 0,
    };

double loadStep(Exercise ex) => switch (ex.loadKind) {
      LoadKind.stack || LoadKind.dumbbells => ex.stepKg ?? 2.5,
      _ => 2.5,
    };

/// The load starts at the previous set of this commit; for the first set, at the first working set
/// of this exercise's last commit; for an exercise never done, at its bar, its lowest step, or 0.
double startLoad(Workout current, Commit commit, Exercise ex) {
  if (commit.sets.isNotEmpty) return commit.sets.last.loadKg;
  final earlier = store.workouts.where((w) => w.id != current.id).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  for (final w in earlier) {
    for (final c in w.commits) {
      if (c.exerciseId != ex.id) continue;
      final working = c.sets.where((s) => s.grade != Grade.warmup).firstOrNull;
      if (working != null) return working.loadKg;
    }
  }
  return lowestLoad(ex);
}

int? lastTestReps(String exerciseId) {
  final tests = _setsOf(exerciseId).where((s) => s.test && s.reps != null);
  return tests.isEmpty ? null : tests.last.reps;
}

/// The goals an exercise serves.
List<Goal> goalsServedBy(String exerciseId) => [for (final g in store.goals) if (g.exerciseIds.contains(exerciseId)) g];
