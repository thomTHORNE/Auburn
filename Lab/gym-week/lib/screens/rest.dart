// Rest: every tracked muscle group in a list, and one group with its rhythm and steps set by hand.
// Behaviour: Spec/Features/Rest.md. Splits and cardio are left out of the prototype.
import 'package:flutter/material.dart';

import '../logic.dart';
import '../model.dart';
import '../ui.dart';

const _sources = ['Fixed steps', 'Your rhythm', 'Set by hand'];

class RestScreen extends StatelessWidget {
  const RestScreen({super.key});
  @override
  Widget build(BuildContext context) => Live((context) {
        final rest = readRest();
        final tracked = [for (final g in MuscleGroup.values) if (rest[g]!.tracked) rest[g]!];
        final onlySupporting = [for (final g in MuscleGroup.values) if (!rest[g]!.tracked && rest[g]!.lastSupporting != null) rest[g]!];
        return Screen(title: 'Rest', status: 'Kept for main moves · nothing is recommended', children: [
          if (tracked.isEmpty) const Para('No muscle group is tracked yet. Name each exercise\'s main movers under Exercises.', apart: true),
          for (final r in tracked)
            InkWell(
              onTap: () => push(context, MuscleScreen(group: r.group)),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lineSupporting, width: 2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  RestMeter(r),
                  Text(
                      [
                        _sources[r.source.index],
                        if (r.backAfter != null) 'back after ${r.backAfter} days',
                        if (r.lastSupporting != null) 'supported ${fmtDay(r.lastSupporting)}',
                      ].join(' · ').toUpperCase(),
                      style: ts(10, color: secondaryC)),
                ]),
              ),
            ),
          if (onlySupporting.isNotEmpty) ...[
            const Label('Only ever supporting · no rest kept'),
            for (final r in onlySupporting) Entry(r.group.label, glyph: '-', dim: true, trailing: 'last ${fmtDay(r.lastSupporting)}'),
          ],
        ]);
      });
}

class MuscleScreen extends StatelessWidget {
  const MuscleScreen({super.key, required this.group});
  final MuscleGroup group;
  @override
  Widget build(BuildContext context) => Live((context) {
        final r = readRest()[group]!;
        final hand = store.restSteps.where((s) => s.group == group).firstOrNull;
        final mains = store.exercises.where((e) => !e.archived && e.mainMovers.contains(group)).map((e) => e.name).toList();
        final supports = store.exercises.where((e) => !e.archived && e.supporting.contains(group)).map((e) => e.name).toList();
        return Screen(
          title: group.label,
          status: r.days == null ? 'Not yet trained' : '${r.days} days since ${fmtDay(r.lastMain)}',
          children: [
            RestMeter(r, showName: false),
            if (r.backAfter != null) Para('Back after ${r.backAfter} days.', apart: true),
            const Label('Supporting work'),
            Para(r.lastSupporting == null ? 'None recorded.' : 'Last worked as a supporting muscle ${fmtDay(r.lastSupporting)}. Shown, never counted.'),
            const Label('Steps'),
            Para('${_sources[r.source.index]} · Maybe from ${r.maybeFrom} · Should from ${r.shouldFrom} · Overdue from ${r.overdueFrom} days', apart: true),
            if (r.gaps.isNotEmpty) ...[
              const Label('Last gaps as a main mover, in days'),
              Para('${r.gaps.join(' · ')}${r.usualGap == null ? '   (rhythm from 3 gaps)' : '   usual gap, the middle: ${fmtKg(r.usualGap!)}'}', apart: true),
            ],
            const Label('Set by hand'),
            if (hand == null)
              KeyButton('Set its steps by hand', onTap: () {
                store.restSteps.add(RestSteps(group: group, maybeFrom: r.maybeFrom < 1 ? 1 : r.maybeFrom, shouldFrom: r.shouldFrom < 2 ? 2 : r.shouldFrom, overdueFrom: r.overdueFrom < 3 ? 3 : r.overdueFrom));
                store.save();
              })
            else ...[
              for (final (label, get, set, min, max) in [
                ('Maybe from', () => hand.maybeFrom, (int v) => hand.maybeFrom = v, 1, hand.shouldFrom - 1),
                ('Should from', () => hand.shouldFrom, (int v) => hand.shouldFrom = v, hand.maybeFrom + 1, hand.overdueFrom - 1),
                ('Overdue from', () => hand.overdueFrom, (int v) => hand.overdueFrom = v, hand.shouldFrom + 1, 99),
              ]) ...[
                Text(label.toUpperCase(), style: ts(10.5, color: secondaryC)),
                Stepper2(
                  text: '${get()} d',
                  onMinus: get() <= min ? null : () {
                    set(get() - 1);
                    store.save();
                  },
                  onPlus: get() >= max ? null : () {
                    set(get() + 1);
                    store.save();
                  },
                ),
                const SizedBox(height: 8),
              ],
              KeyButton('Hand back to its rhythm', onTap: () {
                store.restSteps.remove(hand);
                store.save();
              }),
            ],
            const Label('Main mover on'),
            Para(mains.isEmpty ? 'No exercise.' : mains.join(', ')),
            const Label('Supporting on'),
            Para(supports.isEmpty ? 'No exercise.' : supports.join(', ')),
          ],
        );
      });
}

class GymsScreen extends StatelessWidget {
  const GymsScreen({super.key});
  @override
  Widget build(BuildContext context) => Live((context) => Screen(
        title: 'Gyms',
        status: 'Home is a gym',
        bottom: KeyButton('New gym', onTap: () async {
          final name = await askText(context, 'New gym', hint: 'Name', required: true);
          if (name == null || name.isEmpty) return;
          store.gyms.add(Gym(name: name));
          store.save();
        }),
        children: [
          for (final g in store.gyms)
            Entry(g.name, dim: g.archived, trailing: g.archived ? 'Archived' : null, onTap: () async {
              final act = await pickOne<String>(context, g.name, ['Rename', g.archived ? 'Restore' : 'Archive'], (s) => s);
              if (act == null || !context.mounted) return;
              if (act == 'Rename') {
                final n = await askText(context, 'Rename gym', initial: g.name, required: true);
                if (n == null || n.isEmpty) return;
                g.name = n;
              } else {
                g.archived = !g.archived;
              }
              store.save();
            }),
        ],
      ));
}
