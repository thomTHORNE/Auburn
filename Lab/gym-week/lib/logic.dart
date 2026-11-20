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

/// One point: its date and value, and for a readout, the workout and set behind it.
class Point {
  Point(this.date, this.value, {this.workout, this.set, this.given = 0, this.total = 0});
  final DateTime date;
  final double value;
  final Workout? workout;
  final LoggedSet? set; // the first logged of the sets that tie as the point
  final int given; // the workout's sets of the exercise the line was given
  final int total; // and all of them
}

/// One point per workout, drawn from the sets the line is given. A unilateral exercise's line is one side's.
List<Point> exerciseLine(String exerciseId, Param parameter, bool Function(LoggedSet) given, {DateTime? until, Side? side}) {
  final points = <Point>[];
  final workouts = [...store.workouts]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  for (final w in workouts) {
    double? best;
    LoggedSet? bestSet;
    var n = 0, total = 0;
    for (final c in w.commits) {
      if (c.exerciseId != exerciseId) continue;
      for (final s in c.sets) {
        if (side != null && s.side != side) continue;
        total++;
        if (s.grade == null || !given(s)) continue;
        if (until != null && s.loggedAt.isAfter(until)) continue;
        n++;
        final double? v = parameter == Param.load ? s.loadKg : (s.test ? s.reps?.toDouble() : null);
        if (v != null && (best == null || v > best)) {
          best = v;
          bestSet = s;
        }
      }
    }
    if (best != null) points.add(Point(dayOf(w.startedAt), best, workout: w, set: bestSet, given: n, total: total));
  }
  return points;
}

/// The sides an exercise's lines are drawn for: one line, or one per side.
List<Side?> sidesOf(Exercise e) => e.unilateral ? Side.values : [null];

// ---- Goals (Spec/Features/Goals.md) ----

/// Whether the target's conditions let this set through, whatever its value.
bool letsThrough(Target t, LoggedSet s) {
  if (s.grade == null || !t.grades.contains(s.grade)) return false;
  if (t.parameter == Param.load) return true;
  if (!s.test || s.reps == null) return false;
  return t.minLoadKg == null || s.loadKg >= t.minLoadKg!;
}

bool reaches(Target t, LoggedSet s) =>
    letsThrough(t, s) &&
    (t.side == TargetSide.left ? s.side == Side.left : t.side == TargetSide.right ? s.side == Side.right : true) &&
    (t.parameter == Param.load ? s.loadKg >= t.value : s.reps! >= t.value);

/// The fact that reaches a target in a workout, or null. On both sides, each side needs a reaching set in that
/// workout, and the later of the two is the fact.
LoggedSet? _reachIn(Target t, Workout w, bool Function(LoggedSet) counts) {
  final sets = [for (final c in w.commits) if (c.exerciseId == t.exerciseId) ...c.sets]..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
  if (t.side != TargetSide.both) return sets.where((s) => counts(s) && reaches(t, s)).firstOrNull;
  final left = sets.where((s) => counts(s) && s.side == Side.left && reaches(t, s)).firstOrNull;
  final right = sets.where((s) => counts(s) && s.side == Side.right && reaches(t, s)).firstOrNull;
  if (left == null || right == null) return null;
  return left.loggedAt.isAfter(right.loggedAt) ? left : right;
}

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
    bool counts(LoggedSet s) => s.loggedAt.isAfter(g.activatedAt!) && (t.passedUntil == null || s.loggedAt.isAfter(t.passedUntil!));
    final workouts = store.workouts.where((w) => w.commits.any((c) => c.exerciseId == t.exerciseId)).toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    if (t.reachedAt != null) {
      final w = workouts.where((w) => w.commits.any((c) => c.sets.any((s) => s.id == t.reachedById))).firstOrNull;
      final fact = w == null ? null : _reachIn(t, w, counts);
      if (fact != null && fact.id == t.reachedById) continue;
      t.reachedAt = null;
      t.reachedById = null;
      changed = true;
    }
    for (final w in workouts) {
      final fact = _reachIn(t, w, counts);
      if (fact != null) {
        t.reachedAt = fact.loggedAt;
        t.reachedById = fact.id;
        changed = true;
        break;
      }
    }
  }
  return changed;
}

List<Goal> owedPrompts() =>
    [for (final g in store.goals) if (g.state == GoalState.active && g.target?.reachedAt != null && !g.target!.kept) g];

/// A new goal from an ended one: its name, its target unreached and its alternates; its questions start unanswered.
Goal copyGoal(Goal g) {
  final copy = Goal(name: g.name, alternateIds: [...g.alternateIds], fromGoalId: g.id, target: g.target?.unreachedCopy());
  store.goals.add(copy);
  return copy;
}

void _leaveRoutines(Goal g) {
  for (final r in store.routines) {
    r.items.removeWhere((i) => i.goalId == g.id);
  }
}

void keepReach(Goal g, [String? whatGotYouThere]) {
  g.target!.kept = true;
  g.whatGotYouThere = whatGotYouThere == null || whatGotYouThere.trim().isEmpty ? null : whatGotYouThere.trim();
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
  if (t.value <= 0) return 'Its target has no value.';
  final ex = store.exercise(t.exerciseId);
  if (ex == null || ex.archived) return 'Its target sits on an archived exercise.';
  if (t.grades.isEmpty) return 'Its target names no grade.';
  if (ex.unilateral && t.side == null) return 'Its target names no side.';
  if (targetTakenBy(t.exerciseId, except: g) != null) return 'Another goal\'s target already sits on ${ex.name}.';
  return null;
}

/// The gap runs from the best point since the goal was made active to the target;
/// until a point arrives, from the last point before it.
({double? from, double? gap}) goalGap(Goal g) {
  final t = g.target;
  if (t == null) return (from: null, gap: null);
  // On both sides, the gap is the farther side's.
  final sides = switch (t.side) { TargetSide.left => [Side.left], TargetSide.right => [Side.right], TargetSide.both => Side.values, null => <Side?>[null] };
  ({double? from, double? gap}) result = (from: null, gap: null);
  for (final side in sides) {
    final line = exerciseLine(t.exerciseId, t.parameter, (s) => letsThrough(t, s), until: g.endedAt, side: side);
    if (line.isEmpty) return (from: null, gap: null);
    final since = g.activatedAt == null ? <Point>[] : line.where((p) => !p.date.isBefore(dayOf(g.activatedAt!))).toList();
    final from = since.isEmpty ? line.last.value : since.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final gap = t.value - from < 0 ? 0.0 : t.value - from;
    if (result.gap == null || gap > result.gap!) result = (from: from, gap: gap);
  }
  return result;
}

/// The draft or active goal whose target sits on this exercise, if any: an exercise is the target of at most one.
Goal? targetTakenBy(String exerciseId, {Goal? except}) => store.goals
    .where((g) => g != except && (g.state == GoalState.draft || g.state == GoalState.active) && g.target?.exerciseId == exerciseId)
    .firstOrNull;

// ---- Alternates (Spec/Features/Exercises.md) ----

/// Whether one exercise may be named as another's alternate: it shares a main mover and is tied to every gym the other is.
bool fitsAsAlternate(Exercise base, Exercise candidate) =>
    candidate.id != base.id && candidate.mainMovers.any(base.mainMovers.contains) && base.gymIds.every(candidate.gymIds.contains);

/// The active goal whose target sits on the exercise: while it is active, the exercise's alternates are the goal's.
Goal? alternatesFrom(Exercise e) => store.goals.where((g) => g.state == GoalState.active && g.target?.exerciseId == e.id).firstOrNull;

/// An exercise's alternates as they hold now: the goal's while it is an active goal's target, its own otherwise.
List<Exercise> alternatesOf(Exercise e) =>
    [for (final id in alternatesFrom(e)?.alternateIds ?? e.alternateIds) store.exercise(id)].nonNulls.toList();

// ---- Set limits (Spec/Features/Goals.md) ----

/// The limit of sets per workout on an exercise: the lowest of the active goals that name it, or null.
int? setLimitOn(String exerciseId) {
  int? lowest;
  for (final g in store.goals) {
    if (g.state != GoalState.active || !g.exerciseIds.contains(exerciseId)) continue;
    final l = g.limitOn(exerciseId);
    if (l != null && (lowest == null || l < lowest)) lowest = l;
  }
  return lowest;
}

/// The sets of a commit that count toward its limit: every grade but Warmup, on that side for a unilateral exercise.
int setsTowardLimit(Commit c, Side? side, {LoggedSet? except}) =>
    c.sets.where((s) => s != except && s.grade != Grade.warmup && (side == null || s.side == side)).length;

/// Whether a set of this grade, on this side, is refused by a limit.
bool refusedByLimit(Commit c, Exercise ex, Grade grade, Side? side, {LoggedSet? except}) {
  if (grade == Grade.warmup) return false;
  final limit = setLimitOn(ex.id);
  return limit != null && setsTowardLimit(c, ex.unilateral ? side : null, except: except) >= limit;
}

/// A unilateral set takes the side of the set before it in this commit; the first, the side the exercise's last
/// commit started on; an exercise never done, left.
Side startSide(Workout current, Commit commit) {
  final last = commit.sets.where((s) => s.side != null).lastOrNull;
  if (last != null) return last.side!;
  final earlier = store.workouts.where((w) => w.id != current.id).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  for (final w in earlier) {
    for (final c in w.commits) {
      if (c.exerciseId != commit.exerciseId) continue;
      final first = c.sets.where((s) => s.side != null).firstOrNull;
      if (first != null) return first.side!;
    }
  }
  return Side.left;
}

// ---- Routines (Spec/Features/Routines.md) ----

class OfferedGroup {
  OfferedGroup(this.goal, this.exercises, [this.alternates = const []]);
  final Goal? goal;
  final List<Exercise> exercises; // offered up front: the exercise, or the goal's target's exercise
  final List<Exercise> alternates; // a goal's alternates, offered only on demand
}

/// The routine's exercises tied to this gym, each offered once, at its first place in the order. A goal brings its
/// target's exercise; its alternates come behind it, on demand. Nothing tied to another gym is offered.
List<OfferedGroup> routineOffer(Routine r, String gymId) {
  final seen = <String>{};
  Exercise? resolve(String? id) {
    final e = store.exercise(id);
    if (e == null || e.archived || !e.availableAt(gymId) || !seen.add(e.id)) return null;
    return e;
  }

  final groups = <OfferedGroup>[];
  for (final item in r.items) {
    if (item.goalId != null) {
      final goal = store.goal(item.goalId);
      if (goal == null || goal.state != GoalState.active) continue;
      final target = resolve(goal.target?.exerciseId);
      groups.add(OfferedGroup(goal, [?target], [for (final id in goal.alternateIds) resolve(id)].nonNulls.toList()));
    } else {
      final e = resolve(item.exerciseId);
      if (e != null) groups.add(OfferedGroup(null, [e]));
    }
  }
  return groups;
}

/// Whether a goal may join a routine at this gym: its target's exercise is tied to it.
bool goalFitsGym(Goal g, String? gymId) {
  final e = store.exercise(g.target?.exerciseId);
  return e != null && gymId != null && e.availableAt(gymId);
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

// ---- Deleting an exercise ----

/// Why an exercise cannot be deleted, or null when it can. Only one with no sets can: history points at the rest.
String? cannotDelete(Exercise e) {
  if (store.workouts.any((w) => w.commits.any((c) => c.exerciseId == e.id && c.sets.isNotEmpty))) return 'It has sets. Archive it instead.';
  final target = store.goals.where((g) => g.target?.exerciseId == e.id).firstOrNull;
  if (target != null) return 'The target of ${target.name.isEmpty ? 'a goal' : target.name} sits on it.';
  final ended = store.goals.where((g) => g.ended && g.alternateIds.contains(e.id)).firstOrNull;
  if (ended != null) return '${ended.name.isEmpty ? 'An ended goal' : ended.name} names it, and an ended goal never changes.';
  return null;
}

/// Deletes an exercise with no sets, and takes it out of everything that names it.
void deleteExercise(Exercise e) {
  for (final w in store.workouts) {
    w.commits.removeWhere((c) => c.exerciseId == e.id);
  }
  for (final g in store.goals) {
    g.alternateIds.remove(e.id);
    g.hiddenExerciseIds.remove(e.id);
    g.setLimitsRemoveFor(e.id);
  }
  for (final r in store.routines) {
    r.items.removeWhere((i) => i.exerciseId == e.id);
  }
  for (final x in store.exercises) {
    x.alternateIds.remove(e.id);
  }
  store.exercises.remove(e);
}

// ---- Properties (Spec/Features/Exercises.md) ----

/// An exercise's property values, in the order the properties were made, as shown beside its name.
List<PropertyValue> valuesOf(Exercise e) => [
      for (final p in store.properties)
        ...store.propertyValues.where((v) => v.propertyId == p.id && e.propertyValueIds.contains(v.id)),
    ];

String nameWithValues(Exercise e) => [e.name, ...valuesOf(e).map((v) => v.name)].join(' · ');

/// Whether an exercise passes a filter: for each property the filter names, it holds one of the values on.
bool passesFilter(Exercise e, Set<String> valueIds) {
  final byProperty = <String, Set<String>>{};
  for (final id in valueIds) {
    final v = store.propertyValue(id);
    if (v != null) byProperty.putIfAbsent(v.propertyId, () => {}).add(id);
  }
  return byProperty.values.every((ids) => ids.any(e.propertyValueIds.contains));
}
