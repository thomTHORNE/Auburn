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
        shownGrades = shownGrades ?? {Grade.ideal};

  final String id;
  String name;
  LoadKind loadKind;
  double? barKg;
  double? stepKg;
  Set<MuscleGroup> mainMovers;
  Set<MuscleGroup> supporting;
  List<String> alternateIds;
  Set<String> gymIds;
  String observations;
  String settings;
  String form;
  Param shownParameter;
  Set<Grade> shownGrades;
  bool archived;

  bool availableAt(String gymId) => gymIds.isEmpty || gymIds.contains(gymId);

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'loadKind': loadKind.name, 'barKg': barKg, 'stepKg': stepKg,
        'mainMovers': [for (final m in mainMovers) m.name],
        'supporting': [for (final m in supporting) m.name],
        'alternateIds': alternateIds, 'gymIds': [...gymIds],
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
        observations: j['observations'] ?? '', settings: j['settings'] ?? '', form: j['form'] ?? '',
        shownParameter: _byName(Param.values, j['shownParameter']) ?? Param.load,
        shownGrades: {for (final n in _strings(j['shownGrades'])) _byName(Grade.values, n)!},
        archived: j['archived'] ?? false,
      );
}

/// A goal's target. The prototype keeps targets on exercises only; cardio is not imported.
class Target {
  Target({
    required this.exerciseId,
    this.parameter = Param.load,
    this.value = 0,
    Set<Grade>? grades,
    this.minLoadKg,
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
  DateTime? reachedAt;
  String? reachedById;
  bool kept;
  DateTime? passedUntil;

  Target unreachedCopy() =>
      Target(exerciseId: exerciseId, parameter: parameter, value: value, grades: {...grades}, minLoadKg: minLoadKg);

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId, 'parameter': parameter.name, 'value': value,
        'grades': [for (final g in grades) g.name], 'minLoadKg': minLoadKg,
        'reachedAt': reachedAt?.toIso8601String(), 'reachedById': reachedById, 'kept': kept,
        'passedUntil': passedUntil?.toIso8601String(),
      };

  static Target fromJson(Map<String, dynamic> j) => Target(
        exerciseId: j['exerciseId'],
        parameter: _byName(Param.values, j['parameter']) ?? Param.load,
        value: (j['value'] as num).toDouble(),
        grades: {for (final n in _strings(j['grades'])) _byName(Grade.values, n)!},
        minLoadKg: (j['minLoadKg'] as num?)?.toDouble(),
        reachedAt: _date(j['reachedAt']), reachedById: j['reachedById'], kept: j['kept'] ?? false,
        passedUntil: _date(j['passedUntil']),
      );
}

class Goal {
  Goal({
    String? id,
    this.name = '',
    this.explanation = '',
    Set<String>? exerciseIds,
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
        exerciseIds = exerciseIds ?? {},
        hiddenExerciseIds = hiddenExerciseIds ?? {},
        shownGrades = shownGrades ?? {Grade.ideal};

  final String id;
  String name;
  String explanation;
  Set<String> exerciseIds;
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

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'explanation': explanation, 'exerciseIds': [...exerciseIds],
        'state': state.name, 'activatedAt': activatedAt?.toIso8601String(), 'endedAt': endedAt?.toIso8601String(),
        'abandonedBecause': abandonedBecause, 'fromGoalId': fromGoalId, 'shownParameter': shownParameter?.name,
        'hiddenExerciseIds': [...hiddenExerciseIds],
        'shownGrades': [for (final g in shownGrades) g.name],
        'target': target?.toJson(),
      };

  static Goal fromJson(Map<String, dynamic> j) => Goal(
        id: j['id'], name: j['name'] ?? '', explanation: j['explanation'] ?? '',
        exerciseIds: _strings(j['exerciseIds']).toSet(),
        state: _byName(GoalState.values, j['state']) ?? GoalState.draft,
        activatedAt: _date(j['activatedAt']), endedAt: _date(j['endedAt']),
        abandonedBecause: j['abandonedBecause'], fromGoalId: j['fromGoalId'],
        shownParameter: _byName(Param.values, j['shownParameter']),
        hiddenExerciseIds: _strings(j['hiddenExerciseIds']).toSet(),
        shownGrades: {for (final n in _strings(j['shownGrades'])) _byName(Grade.values, n)!},
        target: j['target'] == null ? null : Target.fromJson(j['target']),
      );
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
  Routine({String? id, this.name = '', this.groupId, Set<String>? gymIds, List<RoutineItem>? items, this.archived = false})
      : id = id ?? newId(),
        gymIds = gymIds ?? {},
        items = items ?? [];
  final String id;
  String name;
  String? groupId;
  Set<String> gymIds;
  List<RoutineItem> items;
  bool archived;

  bool offeredAt(String gymId) => gymIds.isEmpty || gymIds.contains(gymId);

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'groupId': groupId, 'gymIds': [...gymIds],
        'items': [for (final i in items) i.toJson()], 'archived': archived,
      };
  static Routine fromJson(Map<String, dynamic> j) => Routine(
        id: j['id'], name: j['name'] ?? '', groupId: j['groupId'], gymIds: _strings(j['gymIds']).toSet(),
        items: [for (final i in (j['items'] as List? ?? [])) RoutineItem.fromJson(i)], archived: j['archived'] ?? false,
      );
}

class LoggedSet {
  LoggedSet({String? id, required this.loggedAt, required this.loadKg, this.platesPerSide, this.grade, this.test = false, this.reps})
      : id = id ?? newId();
  final String id;
  DateTime loggedAt;
  double loadKg;
  List<double>? platesPerSide;
  Grade? grade;
  bool test;
  int? reps;

  Map<String, dynamic> toJson() => {
        'id': id, 'loggedAt': loggedAt.toIso8601String(), 'loadKg': loadKg, 'platesPerSide': platesPerSide,
        'grade': grade?.name, 'test': test, 'reps': reps,
      };
  static LoggedSet fromJson(Map<String, dynamic> j) => LoggedSet(
        id: j['id'], loggedAt: DateTime.parse(j['loggedAt']), loadKg: (j['loadKg'] as num).toDouble(),
        platesPerSide: (j['platesPerSide'] as List?)?.map((e) => (e as num).toDouble()).toList(),
        grade: _byName(Grade.values, j['grade']), test: j['test'] ?? false, reps: j['reps'],
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
  File? _file;

  Exercise? exercise(String? id) => exercises.where((e) => e.id == id).firstOrNull;
  Gym? gym(String? id) => gyms.where((g) => g.id == id).firstOrNull;
  Goal? goal(String? id) => goals.where((g) => g.id == id).firstOrNull;
  Routine? routine(String? id) => routines.where((r) => r.id == id).firstOrNull;
  Workout? get current => workouts.where((w) => w.endedAt == null).firstOrNull;

  Future<void> load() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/gym-week.json');
    if (await _file!.exists()) {
      _read(jsonDecode(await _file!.readAsString()));
    } else {
      await _importHistory();
    }
    _endStale();
    notifyListeners();
  }

  void _read(Map<String, dynamic> j) {
    gyms = [for (final x in j['gyms'] ?? []) Gym.fromJson(x)];
    exercises = [for (final x in j['exercises'] ?? []) Exercise.fromJson(x)];
    goals = [for (final x in j['goals'] ?? []) Goal.fromJson(x)];
    routineGroups = [for (final x in j['routineGroups'] ?? []) RoutineGroup.fromJson(x)];
    routines = [for (final x in j['routines'] ?? []) Routine.fromJson(x)];
    workouts = [for (final x in j['workouts'] ?? []) Workout.fromJson(x)];
    restSteps = [for (final x in j['restSteps'] ?? []) RestSteps.fromJson(x)];
  }

  Map<String, dynamic> toJson() => {
        'gyms': gyms, 'exercises': exercises, 'goals': goals, 'routineGroups': routineGroups,
        'routines': routines, 'workouts': workouts, 'restSteps': restSteps,
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
