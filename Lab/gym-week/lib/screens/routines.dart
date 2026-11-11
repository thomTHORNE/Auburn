// Routines and routine groups: the list, and creating or editing one. Behaviour: Spec/Features/Routines.md.
import 'package:flutter/material.dart';

import '../logic.dart';
import '../model.dart';
import '../ui.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});
  @override
  Widget build(BuildContext context) => Live((context) {
        final active = store.routines.where((r) => !r.archived).toList();
        final archived = store.routines.where((r) => r.archived).toList();
        bool grouped(Routine r) => store.routineGroups.any((g) => g.id == r.groupId);
        Widget row(Routine r) => Entry(r.name.isEmpty ? 'Unnamed' : r.name,
            sub: '${r.items.length} in it${r.gymIds.isEmpty ? '' : ' · ${r.gymIds.map((id) => store.gym(id)?.name ?? '?').join(', ')}'}',
            dim: r.archived,
            onTap: () => push(context, RoutineScreen(routineId: r.id)));
        return Screen(
          title: 'Routines',
          status: '${active.length} routines',
          bottom: KeyButton('New routine', onTap: () async {
            final name = await askText(context, 'New routine', hint: 'Name', required: true);
            if (name == null || name.isEmpty) return;
            final r = Routine(name: name);
            store.routines.add(r);
            store.save();
            if (context.mounted) push(context, RoutineScreen(routineId: r.id));
          }),
          children: [
            if (store.routines.isEmpty) const Para('No routines yet. A routine is a workout prepared in advance: exercises and goals, in order.'),
            for (final g in store.routineGroups)
              if (active.any((r) => r.groupId == g.id)) ...[Label(g.name), for (final r in active.where((r) => r.groupId == g.id)) row(r)],
            if (active.any((r) => !grouped(r))) ...[
              if (active.any(grouped)) const Label('Standalone'),
              for (final r in active.where((r) => !grouped(r))) row(r),
            ],
            if (archived.isNotEmpty) ...[const Label('Archived'), for (final r in archived) row(r)],
          ],
        );
      });
}

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key, required this.routineId});
  final String routineId;
  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  late final name = TextEditingController(text: store.routine(widget.routineId)?.name ?? '');

  bool _exerciseFits(Routine r, Exercise e) => r.gymIds.isEmpty || r.gymIds.any(e.availableAt);

  Future<void> _group(Routine r) async {
    const none = '— Standalone';
    const fresh = '+ New group';
    final pick = await pickOne<String>(context, 'Routine group', [none, ...store.routineGroups.map((g) => g.name), fresh], (s) => s);
    if (pick == null || !mounted) return;
    if (pick == none) {
      r.groupId = null;
    } else if (pick == fresh) {
      final n = await askText(context, 'New routine group', hint: 'Such as Push, Pull, Legs', required: true);
      if (n == null || n.isEmpty) return;
      final g = RoutineGroup(name: n);
      store.routineGroups.add(g);
      r.groupId = g.id;
    } else {
      r.groupId = store.routineGroups.firstWhere((g) => g.name == pick).id;
    }
    // A group with no routines left is deleted outright.
    store.routineGroups.removeWhere((g) => !store.routines.any((x) => x.groupId == g.id));
    store.save();
  }

  @override
  Widget build(BuildContext context) => Live((context) {
        final r = store.routine(widget.routineId);
        if (r == null) return const Screen(title: 'Routine', children: [Para('Gone.')]);
        final group = store.routineGroups.where((g) => g.id == r.groupId).firstOrNull;
        return Screen(title: 'Routine', status: r.archived ? 'Archived' : 'Exercises and goals, in order', children: [
          const Label('Name'),
          Field(controller: name, onChanged: (v) {
            r.name = v.trim();
            store.save();
          }),
          const Label('Routine group'),
          Entry(group?.name ?? 'Standalone', trailing: 'Change', onTap: () => _group(r)),
          const Label('Gyms · none ticked: offered everywhere'),
          Choice<Gym>(options: store.gyms.where((g) => !g.archived).toList(), label: (g) => g.name, isOn: (g) => r.gymIds.contains(g.id), onTap: (g) {
            r.gymIds.contains(g.id) ? r.gymIds.remove(g.id) : r.gymIds.add(g.id);
            store.save();
          }),
          const Label('In it, in order'),
          if (r.items.isEmpty) const Para('Nothing yet.'),
          for (final (i, item) in r.items.indexed) _item(r, i, item),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: KeyButton('Add exercise', size: 11, onTap: () async {
              final options = store.exercises.where((e) => !e.archived && _exerciseFits(r, e) && !r.items.any((i) => i.exerciseId == e.id)).toList()
                ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              final pick = await pickOne<Exercise>(context, 'Add an exercise', options, (e) => e.name);
              if (pick == null) return;
              r.items.add(RoutineItem(exerciseId: pick.id));
              store.save();
            })),
            const SizedBox(width: 8),
            Expanded(child: KeyButton('Add goal', size: 11, onTap: () async {
              final options = store.goals.where((g) => g.state == GoalState.active && goalFitsGyms(g, r.gymIds) && !r.items.any((i) => i.goalId == g.id)).toList();
              final pick = await pickOne<Goal>(context, 'Add an active goal', options, (g) => g.name, sub: (g) => '${g.exerciseIds.length} exercises');
              if (pick == null) return;
              r.items.add(RoutineItem(goalId: pick.id));
              store.save();
            })),
          ]),
          const SizedBox(height: 28),
          KeyButton(r.archived ? 'Restore' : 'Archive', onTap: () {
            r.archived = !r.archived;
            store.save();
          }),
        ]);
      });

  Widget _item(Routine r, int i, RoutineItem item) {
    final goal = store.goal(item.goalId);
    final ex = store.exercise(item.exerciseId);
    final label = goal != null ? 'Goal · ${goal.name}' : (ex?.name ?? '?');
    final notes = <String>[
      if (goal != null) [for (final id in goal.exerciseIds) store.exercise(id)?.name].nonNulls.join(', '),
      if (goal != null && !goalFitsGyms(goal, r.gymIds)) 'not provable at this routine\'s gyms',
      if (ex != null && ex.archived) 'archived',
      if (ex != null && !_exerciseFits(r, ex)) 'not at this routine\'s gyms',
    ];
    void move(int by) {
      final j = i + by;
      if (j < 0 || j >= r.items.length) return;
      r.items.insert(j, r.items.removeAt(i));
      store.save();
    }

    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lineSupporting, width: 2))),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 30, child: Text('${i + 1}.', style: ts(12, color: secondaryC, spacing: 0))),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(), style: ts(13.5, color: goal != null ? cyanWhite : primaryC, spacing: 1.5)),
            if (notes.isNotEmpty) Text(notes.join(' · ').toUpperCase(), style: ts(10.5, color: secondaryC)),
          ]),
        ),
        SizedBox(width: 44, child: KeyButton('Up', size: 11, onTap: i == 0 ? null : () => move(-1))),
        const SizedBox(width: 4),
        SizedBox(width: 44, child: KeyButton('Dn', size: 11, onTap: i == r.items.length - 1 ? null : () => move(1))),
        const SizedBox(width: 4),
        SizedBox(width: 44, child: KeyButton('X', size: 11, onTap: () {
          r.items.removeAt(i);
          store.save();
        })),
      ]),
    );
  }
}
