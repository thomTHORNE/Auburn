// The records, after Spec/Data Model.md, and the store that keeps them in one JSON file.
// Shortcuts: commits and sets live inside their workout, a routine's items inside the routine,
// a goal's target inside the goal. Activities, splits and settings are left out.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

enum MuscleGroup {
  chest, frontDelts, sideDelts, rearDelts, biceps, triceps, forearms,
  lats, upperBack, traps, lowerBack, abs, obliques,
  quads, hamstrings, glutes, calves, adductors, abductors, neck,
}

const _muscleLabels = [
  'Chest', 'Front delts', 'Side delts', 'Rear delts', 'Biceps', 'Triceps', 'Forearms',
  'Lats', 'Upper back', 'Traps', 'Lower back', 'Abs', 'Obliques',
  'Quads', 'Hamstrings', 'Glutes', 'Calves', 'Adductors', 'Abductors', 'Neck',
];

extension MuscleLabel on MuscleGroup {
  String get label => _muscleLabels[index];
}

enum LoadKind { plates, stack, dumbbells, bodyweight }

enum Grade { ideal, acceptable, light, yielding, warmup }

enum GoalState { draft, active, reached, abandoned }

enum Param { load, reps }

enum Side { left, right }

enum TargetSide { left, right, both }

int _seq = 0;
String newId() => '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

T? _byName<T extends Enum>(List<T> values, Object? name) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

DateTime? _date(Object? s) => s == null ? null : DateTime.parse(s as String);
List<String> _strings(Object? l) => [...?(l as List?)?.cast<String>()];

class Gym {
  Gym({String? id, required this.name, this.archived = false}) : id = id ?? newId();
  final String id;
  String name;
  bool archived;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'archived': archived};
  static Gym fromJson(Map<String, dynamic> j) => Gym(id: j['id'], name: j['name'], archived: j['archived'] ?? false);
}

class Exercise {
  Exercise({
    String? id,
    required this.name,
    this.loadKind = LoadKind.stack,
    this.barKg,
    this.stepKg,
    Set<MuscleGroup>? mainMovers,
    Set<MuscleGroup>? supporting,
    List<String>? alternateIds,
    Set<String>? gymIds,
    this.unilateral = false,
    Set<String>? propertyValueIds,
    this.observations = '',
    this.settings = '',
    this.form = '',
    this.shownParameter = Param.load,
    Set<Grade>? shownGrades,
    this.archived = false,
  })  : id = id ?? newId(),
        mainMovers = mainMovers ?? {},
        supporting = supporting ?? {},
        alternateIds = alternateIds ?? [],
        gymIds = gymIds ?? {},
        propertyValueIds = propertyValueIds ?? {},
        shownGrades = shownGrades ?? {Grade.ideal};

  final String id;
  String name;
  LoadKind loadKind;
  double? barKg;
  double? stepKg;
  Set<MuscleGroup> mainMovers;
  Set<MuscleGroup> supporting;
  List<String> alternateIds;
  Set<String> gymIds; // at least one
  bool unilateral;
  Set<String> propertyValueIds; // at most one value of each property
  String observations;
  String settings;
  String form;
  Param shownParameter;
  Set<Grade> shownGrades;
  bool archived;

  bool availableAt(String gymId) => gymIds.contains(gymId);

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'loadKind': loadKind.name, 'barKg': barKg, 'stepKg': stepKg,
        'mainMovers': [for (final m in mainMovers) m.name],
        'supporting': [for (final m in supporting) m.name],
        'alternateIds': alternateIds, 'gymIds': [...gymIds],
        'unilateral': unilateral, 'propertyValueIds': [...propertyValueIds],
        'observations': observations, 'settings': settings, 'form': form,
        'shownParameter': shownParameter.name,
        'shownGrades': [for (final g in shownGrades) g.name],
        'archived': archived,
      };

  static Exercise fromJson(Map<String, dynamic> j) => Exercise(
        id: j['id'], name: j['name'],
        loadKind: _byName(LoadKind.values, j['loadKind']) ?? LoadKind.stack,
        barKg: (j['barKg'] as num?)?.toDouble(), stepKg: (j['stepKg'] as num?)?.toDouble(),
        mainMovers: {for (final n in _strings(j['mainMovers'])) _byName(MuscleGroup.values, n)!},
        supporting: {for (final n in _strings(j['supporting'])) _byName(MuscleGroup.values, n)!},
        alternateIds: _strings(j['alternateIds']), gymIds: _strings(j['gymIds']).toSet(),
        unilateral: j['unilateral'] ?? false, propertyValueIds: _strings(j['propertyValueIds']).toSet(),
        observations: j['observations'] ?? '', settings: j['settings'] ?? '', form: j['form'] ?? '',
        shownParameter: _byName(Param.values, j['shownParameter']) ?? Param.load,
        shownGrades: {for (final n in _strings(j['shownGrades'])) _byName(Grade.values, n)!},
        archived: j['archived'] ?? false,
      );
}

/// A property the user made, such as Form, and one of its values, such as Strict.
class Property {
  Property({String? id, required this.name}) : id = id ?? newId();
  final String id;
  String name;
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  static Property fromJson(Map<String, dynamic> j) => Property(id: j['id'], name: j['name']);
}

class PropertyValue {
  PropertyValue({String? id, required this.propertyId, required this.name}) : id = id ?? newId();
  final String id;
  final String propertyId;
  String name;
  Map<String, dynamic> toJson() => {'id': id, 'propertyId': propertyId, 'name': name};
  static PropertyValue fromJson(Map<String, dynamic> j) => PropertyValue(id: j['id'], propertyId: j['propertyId'], name: j['name']);
}

/// A limit of sets per workout on one exercise a goal names. From activation, every change is a new record; the latest holds.
class SetLimit {
  SetLimit({required this.exerciseId, required this.sets, required this.setAt});
  final String exerciseId;
  final int? sets; // null: the limit was removed
  final DateTime setAt;
  Map<String, dynamic> toJson() => {'exerciseId': exerciseId, 'sets': sets, 'setAt': setAt.toIso8601String()};
  static SetLimit fromJson(Map<String, dynamic> j) => SetLimit(exerciseId: j['exerciseId'], sets: j['sets'], setAt: DateTime.parse(j['setAt']));
}

/// A goal's target. The prototype keeps targets on exercises only; cardio is not imported.
class Target {
  Target({
    required this.exerciseId,
    this.parameter = Param.load,
    this.value = 0,
    Set<Grade>? grades,
    this.minLoadKg,
    this.side,
    this.reachedAt,
    this.reachedById,
    this.kept = false,
    this.passedUntil,
  }) : grades = grades ?? {Grade.ideal};

  String exerciseId;
  Param parameter;
  double value;
  Set<Grade> grades;
  double? minLoadKg;
  TargetSide? side; // set when its exercise is unilateral
  DateTime? reachedAt;
  String? reachedById;
  bool kept;
  DateTime? passedUntil;

  Target unreachedCopy() =>
      Target(exerciseId: exerciseId, parameter: parameter, value: value, grades: {...grades}, minLoadKg: minLoadKg, side: side);

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId, 'parameter': parameter.name, 'value': value,
        'grades': [for (final g in grades) g.name], 'minLoadKg': minLoadKg, 'side': side?.name,
        'reachedAt': reachedAt?.toIso8601String(), 'reachedById': reachedById, 'kept': kept,
        'passedUntil': passedUntil?.toIso8601String(),
      };

  static Target fromJson(Map<String, dynamic> j) => Target(
        exerciseId: j['exerciseId'],
        parameter: _byName(Param.values, j['parameter']) ?? Param.load,
        value: (j['value'] as num).toDouble(),
        grades: {for (final n in _strings(j['grades'])) _byName(Grade.values, n)!},
        minLoadKg: (j['minLoadKg'] as num?)?.toDouble(),
        side: _byName(TargetSide.values, j['side']),
        reachedAt: _date(j['reachedAt']), reachedById: j['reachedById'], kept: j['kept'] ?? false,
        passedUntil: _date(j['passedUntil']),
      );
}

class Goal {
  Goal({
    String? id,
    this.name = '',
    List<String>? alternateIds,
    this.why = '',
    this.reachedMeans = '',
    this.hardestExpected = '',
    this.whatGotYouThere,
    List<SetLimit>? setLimits,
    this.state = GoalState.draft,
    this.activatedAt,
    this.endedAt,
    this.abandonedBecause,
    this.fromGoalId,
    this.shownParameter,
    Set<String>? hiddenExerciseIds,
    Set<Grade>? shownGrades,
    this.target,
  })  : id = id ?? newId(),
        alternateIds = alternateIds ?? [],
        setLimits = setLimits ?? [],
        hiddenExerciseIds = hiddenExerciseIds ?? {},
        shownGrades = shownGrades ?? {Grade.ideal};

  final String id;
  String name;
  List<String> alternateIds; // ordered; the target's exercise is the target's
  String why; // the start answers, empty when unanswered
  String reachedMeans;
  String hardestExpected;
  String? whatGotYouThere; // reached only
  List<SetLimit> setLimits;
  GoalState state;
  DateTime? activatedAt;
  DateTime? endedAt;
  String? abandonedBecause;
  String? fromGoalId;
  Param? shownParameter;
  Set<String> hiddenExerciseIds;
  Set<Grade> shownGrades;
  Target? target;

  bool get ended => state == GoalState.reached || state == GoalState.abandoned;

  /// The target's exercise, then the alternates.
  List<String> get exerciseIds => [if (target != null) target!.exerciseId, ...alternateIds.where((id) => id != target?.exerciseId)];

  /// The limit that holds on one of its exercises now, or null.
  int? limitOn(String exerciseId) => setLimits.where((l) => l.exerciseId == exerciseId).lastOrNull?.sets;

  void setLimitsRemoveFor(String exerciseId) => setLimits.removeWhere((l) => l.exerciseId == exerciseId);

  /// Sets a limit. In a draft it replaces the earlier one; from activation every change is kept with its date.
  void setLimit(String exerciseId, int? sets) {
    if (state == GoalState.draft) setLimits.removeWhere((l) => l.exerciseId == exerciseId);
    if (limitOn(exerciseId) == sets && state != GoalState.draft) return;
    if (sets == null && state == GoalState.draft) return;
    setLimits.add(SetLimit(exerciseId: exerciseId, sets: sets, setAt: DateTime.now()));
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'alternateIds': alternateIds,
        'why': why, 'reachedMeans': reachedMeans, 'hardestExpected': hardestExpected, 'whatGotYouThere': whatGotYouThere,
        'setLimits': [for (final l in setLimits) l.toJson()],
        'state': state.name, 'activatedAt': activatedAt?.toIso8601String(), 'endedAt': endedAt?.toIso8601String(),
        'abandonedBecause': abandonedBecause, 'fromGoalId': fromGoalId, 'shownParameter': shownParameter?.name,
        'hiddenExerciseIds': [...hiddenExerciseIds],
        'shownGrades': [for (final g in shownGrades) g.name],
        'target': target?.toJson(),
      };

  static Goal fromJson(Map<String, dynamic> j) {
    final target = j['target'] == null ? null : Target.fromJson(j['target']);
    // Before 0.4 a goal named its exercises in one set, with an explanation; the target's exercise was among them.
    final alternates = j.containsKey('alternateIds') ? _strings(j['alternateIds']) : [for (final id in _strings(j['exerciseIds'])) if (id != target?.exerciseId) id];
    return Goal(
        id: j['id'], name: j['name'] ?? '',
        alternateIds: alternates,
        why: j['why'] ?? j['explanation'] ?? '', reachedMeans: j['reachedMeans'] ?? '', hardestExpected: j['hardestExpected'] ?? '',
        whatGotYouThere: j['whatGotYouThere'],
        setLimits: [for (final l in (j['setLimits'] as List? ?? [])) SetLimit.fromJson(l)],
        state: _byName(GoalState.values, j['state']) ?? GoalState.draft,
        activatedAt: _date(j['activatedAt']), endedAt: _date(j['endedAt']),
        abandonedBecause: j['abandonedBecause'], fromGoalId: j['fromGoalId'],
        shownParameter: _byName(Param.values, j['shownParameter']),
        hiddenExerciseIds: _strings(j['hiddenExerciseIds']).toSet(),
        shownGrades: {for (final n in _strings(j['shownGrades'])) _byName(Grade.values, n)!},
        target: target,
      );
  }
}

class RoutineGroup {
  RoutineGroup({String? id, required this.name}) : id = id ?? newId();
  final String id;
  String name;
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  static RoutineGroup fromJson(Map<String, dynamic> j) => RoutineGroup(id: j['id'], name: j['name']);
}

/// One exercise or goal in a routine. Its place in the routine's list is its position.
class RoutineItem {
  RoutineItem({this.exerciseId, this.goalId});
  String? exerciseId;
  String? goalId;
  Map<String, dynamic> toJson() => {'exerciseId': exerciseId, 'goalId': goalId};
  static RoutineItem fromJson(Map<String, dynamic> j) => RoutineItem(exerciseId: j['exerciseId'], goalId: j['goalId']);
}

class Routine {
  Routine({String? id, this.name = '', this.groupId, this.gymId, List<RoutineItem>? items, this.archived = false, this.oldGymIds = const []})
      : id = id ?? newId(),
        items = items ?? [];
  final String id;
  String name;
  String? groupId;
  String? gymId; // one gym; empty only until migrated
  final List<String> oldGymIds; // before 0.4: a routine tied to several gyms, or none
  List<RoutineItem> items;
  bool archived;

  bool offeredAt(String gymId) => this.gymId == gymId;

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'groupId': groupId, 'gymId': gymId,
        'items': [for (final i in items) i.toJson()], 'archived': archived,
      };
  static Routine fromJson(Map<String, dynamic> j) => Routine(
        id: j['id'], name: j['name'] ?? '', groupId: j['groupId'], gymId: j['gymId'], oldGymIds: _strings(j['gymIds']),
        items: [for (final i in (j['items'] as List? ?? [])) RoutineItem.fromJson(i)], archived: j['archived'] ?? false,
      );
}

class LoggedSet {
  LoggedSet({String? id, required this.loggedAt, required this.loadKg, this.platesPerSide, this.grade, this.test = false, this.reps, this.side})
      : id = id ?? newId();
  final String id;
  DateTime loggedAt;
  double loadKg;
  List<double>? platesPerSide;
  Grade? grade;
  bool test;
  int? reps;
  Side? side; // unilateral exercises; null on sets from before it was marked, and on imported sets

  Map<String, dynamic> toJson() => {
        'id': id, 'loggedAt': loggedAt.toIso8601String(), 'loadKg': loadKg, 'platesPerSide': platesPerSide,
        'grade': grade?.name, 'test': test, 'reps': reps, 'side': side?.name,
      };
  static LoggedSet fromJson(Map<String, dynamic> j) => LoggedSet(
        id: j['id'], loggedAt: DateTime.parse(j['loggedAt']), loadKg: (j['loadKg'] as num).toDouble(),
        platesPerSide: (j['platesPerSide'] as List?)?.map((e) => (e as num).toDouble()).toList(),
        grade: _byName(Grade.values, j['grade']), test: j['test'] ?? false, reps: j['reps'],
        side: _byName(Side.values, j['side']),
      );
}

/// One exercise committed to one workout. Its place in the workout's list is its position.
class Commit {
  Commit({String? id, required this.exerciseId, List<LoggedSet>? sets})
      : id = id ?? newId(),
        sets = sets ?? [];
  final String id;
  String exerciseId;
  List<LoggedSet> sets;
  Map<String, dynamic> toJson() => {'id': id, 'exerciseId': exerciseId, 'sets': [for (final s in sets) s.toJson()]};
  static Commit fromJson(Map<String, dynamic> j) =>
      Commit(id: j['id'], exerciseId: j['exerciseId'], sets: [for (final s in (j['sets'] as List? ?? [])) LoggedSet.fromJson(s)]);
}

class Workout {
  Workout({String? id, required this.gymId, this.routineId, required this.startedAt, this.endedAt, this.imported = false, List<Commit>? commits})
      : id = id ?? newId(),
        commits = commits ?? [];
  final String id;
  String gymId;
  String? routineId;
  DateTime startedAt;
  DateTime? endedAt;
  bool imported;
  List<Commit> commits;

  Map<String, dynamic> toJson() => {
        'id': id, 'gymId': gymId, 'routineId': routineId, 'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(), 'imported': imported, 'commits': [for (final c in commits) c.toJson()],
      };
  static Workout fromJson(Map<String, dynamic> j) => Workout(
        id: j['id'], gymId: j['gymId'], routineId: j['routineId'], startedAt: DateTime.parse(j['startedAt']),
        endedAt: _date(j['endedAt']), imported: j['imported'] ?? false,
        commits: [for (final c in (j['commits'] as List? ?? [])) Commit.fromJson(c)],
      );
}

/// Rest steps set by hand for one muscle group. Absent: its steps follow its rhythm.
class RestSteps {
  RestSteps({required this.group, required this.maybeFrom, required this.shouldFrom, required this.overdueFrom});
  final MuscleGroup group;
  int maybeFrom;
  int shouldFrom;
  int overdueFrom;
  Map<String, dynamic> toJson() => {'group': group.name, 'maybeFrom': maybeFrom, 'shouldFrom': shouldFrom, 'overdueFrom': overdueFrom};
  static RestSteps fromJson(Map<String, dynamic> j) => RestSteps(
      group: _byName(MuscleGroup.values, j['group'])!, maybeFrom: j['maybeFrom'], shouldFrom: j['shouldFrom'], overdueFrom: j['overdueFrom']);
}

class Store extends ChangeNotifier {
  List<Gym> gyms = [];
  List<Exercise> exercises = [];
  List<Goal> goals = [];
  List<RoutineGroup> routineGroups = [];
  List<Routine> routines = [];
  List<Workout> workouts = [];
  List<RestSteps> restSteps = [];
  List<Property> properties = [];
  List<PropertyValue> propertyValues = [];
  File? _file;

  Exercise? exercise(String? id) => exercises.where((e) => e.id == id).firstOrNull;
  Gym? gym(String? id) => gyms.where((g) => g.id == id).firstOrNull;
  Goal? goal(String? id) => goals.where((g) => g.id == id).firstOrNull;
  Routine? routine(String? id) => routines.where((r) => r.id == id).firstOrNull;
  Workout? get current => workouts.where((w) => w.endedAt == null).firstOrNull;
  PropertyValue? propertyValue(String? id) => propertyValues.where((v) => v.id == id).firstOrNull;
  Property? property(String? id) => properties.where((p) => p.id == id).firstOrNull;

  Future<void> load() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/gym-week.json');
    if (await _file!.exists()) {
      read(jsonDecode(await _file!.readAsString()));
    } else {
      await _importHistory();
    }
    _endStale();
    notifyListeners();
  }

  void read(Map<String, dynamic> j) {
    gyms = [for (final x in j['gyms'] ?? []) Gym.fromJson(x)];
    exercises = [for (final x in j['exercises'] ?? []) Exercise.fromJson(x)];
    goals = [for (final x in j['goals'] ?? []) Goal.fromJson(x)];
    routineGroups = [for (final x in j['routineGroups'] ?? []) RoutineGroup.fromJson(x)];
    routines = [for (final x in j['routines'] ?? []) Routine.fromJson(x)];
    workouts = [for (final x in j['workouts'] ?? []) Workout.fromJson(x)];
    restSteps = [for (final x in j['restSteps'] ?? []) RestSteps.fromJson(x)];
    properties = [for (final x in j['properties'] ?? []) Property.fromJson(x)];
    propertyValues = [for (final x in j['propertyValues'] ?? []) PropertyValue.fromJson(x)];
    migrate();
  }

  /// Brings records from before 0.4 under its rules: every exercise and every routine is tied to a gym.
  void migrate() {
    final live = gyms.where((g) => !g.archived).toList();
    for (final e in exercises) {
      if (e.gymIds.isNotEmpty) continue;
      // An exercise tied to no gym was offered everywhere: it is tied to the gyms it was done at, or every gym.
      final done = {for (final w in workouts) if (w.commits.any((c) => c.exerciseId == e.id)) w.gymId};
      e.gymIds = done.isNotEmpty ? done : {for (final g in live) g.id};
    }
    for (final r in routines) {
      if (r.gymId != null && gym(r.gymId) != null) continue;
      final started = workouts.where((w) => w.routineId == r.id).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      r.gymId = r.oldGymIds.where((id) => gym(id) != null).firstOrNull ?? started.firstOrNull?.gymId ?? live.firstOrNull?.id;
    }
  }

  Map<String, dynamic> toJson() => {
        'gyms': gyms, 'exercises': exercises, 'goals': goals, 'routineGroups': routineGroups,
        'routines': routines, 'workouts': workouts, 'restSteps': restSteps,
        'properties': properties, 'propertyValues': propertyValues,
      };

  /// Every change goes through here: it is written to the phone at once, so nothing logged is lost.
  void save() {
    notifyListeners();
    _file?.writeAsStringSync(jsonEncode(this), flush: true);
  }

  /// The Notion history, when the build carries assets/history.json (tool/convert_notion.py writes it).
  Future<void> _importHistory() async {
    String raw;
    try {
      raw = await rootBundle.loadString('assets/history.json');
    } catch (_) {
      return;
    }
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final gymByName = <String, Gym>{};
    for (final n in j['gyms']) {
      gymByName[n] = Gym(name: n);
    }
    gyms = gymByName.values.toList();
    final exByName = <String, Exercise>{};
    for (final e in j['exercises']) {
      exByName[e['name']] = Exercise(
        name: e['name'],
        loadKind: _byName(LoadKind.values, e['loadKind'])!,
        barKg: (e['barKg'] as num?)?.toDouble(),
        stepKg: (e['stepKg'] as num?)?.toDouble(),
        observations: e['observations'], settings: e['settings'], form: e['form'],
      );
    }
    exercises = exByName.values.toList();
    workouts = [
      for (final w in j['workouts'])
        Workout(
          gymId: gymByName[w['gym']]!.id,
          startedAt: DateTime.parse(w['startedAt']),
          endedAt: DateTime.parse(w['endedAt']),
          imported: true,
          commits: [
            for (final c in w['commits'])
              Commit(exerciseId: exByName[c['exercise']]!.id, sets: [
                for (final s in c['sets'])
                  LoggedSet(
                    loggedAt: DateTime.parse(s['loggedAt']),
                    loadKg: (s['loadKg'] as num).toDouble(),
                    grade: _byName(Grade.values, s['grade']),
                    test: s['test'] ?? false,
                    reps: s['reps'],
                  ),
              ]),
          ],
        ),
    ];
    migrate();
    save();
  }

  /// A workout still open on a later day ends at its last set's time, or at its start if it has none.
  void _endStale() {
    final w = current;
    if (w == null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!w.startedAt.isBefore(today)) return;
    final times = [for (final c in w.commits) for (final s in c.sets) s.loggedAt]..sort();
    if (w.commits.isEmpty) {
      workouts.remove(w);
    } else {
      w.endedAt = times.isEmpty ? w.startedAt : times.last;
    }
    save();
  }
}

final store = Store();
