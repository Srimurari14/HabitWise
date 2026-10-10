import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/habit_widgets.dart';
import '../../../data/local/app_database.dart';
import '../../../providers.dart';
import '../domain/avatar_models.dart';
import 'mascot/mascot_assets.dart';
import 'mascot/mascot_character.dart';

class AvatarScreen extends ConsumerWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ready = ref.watch(gamificationReadyProvider);
    final catalog = ref.watch(cosmeticCatalogProvider).value;
    final avatar = ref.watch(avatarProvider).value ?? const AvatarProfileData();
    final ownedRows =
        ref.watch(ownedCosmeticsProvider).value ?? const <OwnedCosmetic>[];
    final outfits =
        ref.watch(outfitPresetsProvider).value ?? const <OutfitPreset>[];
    final streak = ref.watch(streakProvider).value;
    final balance = ref.watch(coinBalanceProvider);
    final activeDays = ref.watch(weeklyActivityProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar'),
        actions: <Widget>[
          IconButton(
            tooltip: 'How coins are earned',
            onPressed: () => _showCoinGuide(context),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: ready.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Could not open your avatar: $error')),
        data: (_) => PageFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _AvatarHero(avatar: avatar),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.brightness_5_rounded,
                      value: '$balance',
                      label: 'coins left',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.calendar_view_week_rounded,
                      value: '$activeDays/7',
                      label: 'active this week',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.local_fire_department_outlined,
                      value: '${streak?.currentStreak ?? 0}',
                      label: 'momentum days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Coins are earned through check-ins, using plans, and short game sessions. There are no purchases, ads, loot boxes, or paid currency.',
              ),
              const SizedBox(height: 26),
              FilledButton.icon(
                onPressed: () => context.push(
                  '/signal-shift',
                  extra: SignalShiftLaunch.practice(
                    mode: avatar.preferences.reducedMotion
                        ? GameMode.reducedMotion
                        : avatar.preferences.calmMode
                        ? GameMode.calm
                        : GameMode.standard,
                  ),
                ),
                icon: const Icon(Icons.sports_esports_rounded),
                label: const Text('Practice Signal Shift'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => context.push(
                  '/focus-stack',
                  extra: SignalShiftLaunch.practice(
                    kind: GameKind.focusStack,
                    mode: avatar.preferences.reducedMotion
                        ? GameMode.reducedMotion
                        : avatar.preferences.calmMode
                        ? GameMode.calm
                        : GameMode.standard,
                  ),
                ),
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Practice Focus Stack'),
              ),
              const SizedBox(height: 10),
              // Temporary. Remove once the mascot is approved or dropped.
              TextButton.icon(
                onPressed: () => context.push('/mascot-lab'),
                icon: const Icon(Icons.science_outlined),
                label: const Text('Mascot lab (work in progress)'),
              ),
              TextButton.icon(
                onPressed: () => context.push('/signal-lab'),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Signal Shift look (work in progress)'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Practice anytime. During a craving, HabitWise recommends the game only when your answers suggest a short attention shift could fit.',
              ),
              const SizedBox(height: 28),
              const SectionHeader('Locker'),
              const SizedBox(height: 6),
              const Text('Tap any owned item to wear it immediately.'),
              const SizedBox(height: 12),
              if (catalog != null)
                _CosmeticGrid(
                  items: catalog.items
                      .where(
                        (item) =>
                            ownedRows.any((owned) => owned.itemId == item.id),
                      )
                      .toList(),
                  avatar: avatar,
                  ownedIds: ownedRows.map((row) => row.itemId).toSet(),
                  balance: balance,
                  store: false,
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _saveOutfit(context, ref),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save this outfit'),
              ),
              if (outfits.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                const Text('Saved outfits'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: outfits
                      .map(
                        (outfit) => ActionChip(
                          avatar: const Icon(Icons.checkroom_rounded),
                          label: Text(outfit.name),
                          onPressed: () => ref
                              .read(gamificationRepositoryProvider)
                              .wearOutfit(outfit),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 30),
              const SectionHeader('Earned-item shop'),
              const SizedBox(height: 6),
              const Text(
                'Choose what to unlock. Milestone items cannot be bought; they unlock through momentum days.',
              ),
              const SizedBox(height: 12),
              if (catalog != null)
                _CosmeticGrid(
                  items: catalog.items.where((item) => !item.starter).toList(),
                  avatar: avatar,
                  ownedIds: ownedRows.map((row) => row.itemId).toSet(),
                  balance: balance,
                  store: true,
                ),
              const SizedBox(height: 30),
              const SectionHeader('Game comfort settings'),
              const SizedBox(height: 8),
              _PreferenceSwitches(avatar: avatar),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveOutfit(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save outfit'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Outfit name'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    await ref.read(gamificationRepositoryProvider).saveOutfit(name);
  }
}

class _AvatarHero extends StatelessWidget {
  const _AvatarHero({required this.avatar});
  final AvatarProfileData avatar;

  @override
  Widget build(BuildContext context) {
    return HabitCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    const Color(0xFF7557A8),
                    Theme.of(context).colorScheme.secondaryContainer,
                    const Color(0xFFFFB29F),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 28,
              top: 32,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 34,
                color: Color(0xFFBCEFF1),
              ),
            ),
            const Positioned(
              right: 34,
              top: 70,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 46,
                color: Color(0xFFFFE39A),
              ),
            ),
            Positioned(
              bottom: 10,
              child: MascotCharacter(equipped: avatar.equipped, size: 175),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: Text(
                avatar.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return HabitCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, textAlign: TextAlign.center, maxLines: 2),
        ],
      ),
    );
  }
}

Future<void> _showCoinGuide(BuildContext context) {
  const rows = <(String, String)>[
    ('Finishing a check-in follow-up', '2 coins'),
    ('Completing the plan you were given', '6 coins'),
    ('Moving past or redirecting a craving', '8 coins'),
    ('Reaching 3 or 7 momentum days', '15 coins'),
    ('Reaching 14 or 30 momentum days', '30 coins'),
    ('Signal Shift during a craving, if you finish it', '3 to 10 coins'),
    ('Signal Shift practice, if you finish it', 'up to 3 coins'),
  ];
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'How coins are earned',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 14),
            for (final row in rows) ...<Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: Text(row.$1)),
                  const SizedBox(width: 12),
                  Text(
                    row.$2,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Divider(height: 18),
            ],
            const Text(
              'Games can earn at most 30 coins a day. Practice pays less than a '
              'recommended session, and a short run may earn nothing at all.',
            ),
            const SizedBox(height: 10),
            const Text(
              'Hunger, glucose and eating-concern check-ins never earn coins. '
              'Food is never something you have to earn.',
            ),
          ],
        ),
      ),
    ),
  );
}

class _PreviewFigure extends StatelessWidget {
  const _PreviewFigure({required this.label, required this.equipped});

  final String label;
  final Map<String, String> equipped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        children: <Widget>[
          MascotCharacter(equipped: equipped, size: 110),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: style),
          Text(
            value,
            style: strong
                ? style?.copyWith(fontWeight: FontWeight.w700)
                : style,
          ),
        ],
      ),
    );
  }
}

class _CosmeticGrid extends ConsumerWidget {
  const _CosmeticGrid({
    required this.items,
    required this.avatar,
    required this.ownedIds,
    required this.balance,
    required this.store,
  });
  final List<CosmeticItem> items;
  final AvatarProfileData avatar;
  final Set<String> ownedIds;
  final int balance;
  final bool store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.55,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final owned = ownedIds.contains(item.id);
        final equipped = avatar.equipped[item.slot.name] == item.id;
        final lockedByMilestone = item.milestone != null && !owned;
        final affordable =
            !owned && store && !lockedByMilestone && balance >= item.price;
        final outOfReach = !owned && !affordable;
        final scheme = Theme.of(context).colorScheme;
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            final repository = ref.read(gamificationRepositoryProvider);
            final messenger = ScaffoldMessenger.of(context);
            if (owned) {
              final action = await showModalBottomSheet<String>(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                builder: (context) => SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      4,
                      20,
                      20 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          equipped
                              ? 'You are wearing this ${item.slot.label.toLowerCase()}'
                              : '${item.slot.label} you own',
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: _PreviewFigure(
                            label: equipped ? 'Wearing now' : 'How it looks',
                            equipped: <String, String>{
                              ...avatar.equipped,
                              item.slot.name: item.id,
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (!equipped)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => Navigator.pop(context, 'wear'),
                              child: const Text('Wear this'),
                            ),
                          )
                        else if (item.slot.canBeRemoved)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => Navigator.pop(context, 'remove'),
                              child: const Text('Take it off'),
                            ),
                          )
                        else
                          Text(
                            '${item.slot.label} cannot be left empty. Pick a different one to change it.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, 'close'),
                            child: const Text('Close'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              if (action == 'wear') {
                await repository.equip(item);
              } else if (action == 'remove') {
                await repository.unequip(item.slot);
              }
              return;
            }
            if (lockedByMilestone) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Unlocks at ${item.milestone} momentum days. It cannot be bought with coins.',
                  ),
                ),
              );
              return;
            }
            if (!store) return;
            if (balance < item.price) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'You need ${item.price - balance} more coins for ${item.name}.',
                  ),
                ),
              );
              return;
            }
            final confirmed = await showModalBottomSheet<bool>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (context) => SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    4,
                    20,
                    20 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text('${item.slot.label} for your avatar'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _PreviewFigure(
                            label: 'Now',
                            equipped: avatar.equipped,
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          _PreviewFigure(
                            label: 'With ${item.name}',
                            equipped: <String, String>{
                              ...avatar.equipped,
                              item.slot.name: item.id,
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _CostRow(label: 'Cost', value: '${item.price} coins'),
                      _CostRow(label: 'You have', value: '$balance coins'),
                      _CostRow(
                        label: 'Left afterwards',
                        value: '${balance - item.price} coins',
                        strong: true,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Unlock'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Not now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (confirmed != true) return;
            final purchased = await repository.purchase(item);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  purchased
                      ? '${item.name} is now in your locker.'
                      : 'You do not have enough coins yet.',
                ),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              color: equipped
                  ? scheme.primaryContainer
                  : affordable
                  ? scheme.secondaryContainer
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: equipped
                    ? scheme.primary
                    : affordable
                    ? scheme.primary.withValues(alpha: 0.6)
                    : scheme.outlineVariant,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Opacity(
              opacity: outOfReach ? 0.55 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // The item itself, not a generic slot icon. Being able
                      // to see what you are saving for is the whole point of
                      // showing a locked item at all.
                      _ItemThumb(itemId: item.id, slot: item.slot),
                      const Spacer(),
                      if (!owned)
                        Icon(
                          lockedByMilestone
                              ? Icons.lock_clock_rounded
                              : Icons.lock_outline_rounded,
                          size: 18,
                          color: affordable
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      if (equipped)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: scheme.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    equipped
                        ? (item.slot.canBeRemoved
                              ? 'Wearing. Tap to remove'
                              : 'Wearing')
                        : owned
                        ? item.slot.label
                        : lockedByMilestone
                        ? '${item.milestone}-day milestone'
                        : affordable
                        ? '${item.price} coins'
                        : '${item.price} coins, ${item.price - balance} to go',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static IconData _icon(CosmeticSlot slot) => switch (slot) {
    CosmeticSlot.glasses => Icons.visibility_outlined,
    CosmeticSlot.hat || CosmeticSlot.hair => Icons.face_retouching_natural,
    CosmeticSlot.shoes => Icons.directions_run_rounded,
    CosmeticSlot.trail => Icons.auto_awesome_rounded,
    CosmeticSlot.background => Icons.wallpaper_rounded,
    CosmeticSlot.back => Icons.flight_rounded,
    _ => Icons.checkroom_rounded,
  };
}

class _PreferenceSwitches extends ConsumerWidget {
  const _PreferenceSwitches({required this.avatar});
  final AvatarProfileData avatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = avatar.preferences;
    Future<void> save(GamePreferences updated) =>
        ref.read(gamificationRepositoryProvider).updatePreferences(updated);
    return HabitCard(
      child: Column(
        children: <Widget>[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reduced motion'),
            subtitle: const Text('Slower movement and no screen shake.'),
            value: preferences.reducedMotion,
            onChanged: (value) =>
                save(preferences.copyWith(reducedMotion: value)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Calm mode'),
            subtitle: const Text('Predictable pace and softer contrast.'),
            value: preferences.calmMode,
            onChanged: (value) => save(preferences.copyWith(calmMode: value)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('One-handed controls'),
            subtitle: const Text('Large on-screen lane buttons.'),
            value: preferences.oneHanded,
            onChanged: (value) => save(preferences.copyWith(oneHanded: value)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Plan recommendations'),
            subtitle: const Text(
              'Allow the plan to suggest Signal Shift when it fits your answers.',
            ),
            value: preferences.recommendationsEnabled,
            onChanged: (value) =>
                save(preferences.copyWith(recommendationsEnabled: value)),
          ),
        ],
      ),
    );
  }
}

/// A small picture of a cosmetic, taken from the same layer art the mascot
/// wears.
///
/// The art is decoded once into a shared cache, which is usually still empty
/// on the frame this tile first builds. Without waiting for it, every tile
/// falls back to its slot icon and never recovers, which is why the locker
/// was a wall of coat hangers.
class _ItemThumb extends StatefulWidget {
  const _ItemThumb({required this.itemId, required this.slot});

  final String itemId;
  final CosmeticSlot slot;

  @override
  State<_ItemThumb> createState() => _ItemThumbState();
}

class _ItemThumbState extends State<_ItemThumb> {
  @override
  void initState() {
    super.initState();
    if (!MascotAssets.ready) {
      MascotAssets.ensureLoaded().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // body() falls back to the default colour for anything it does not know,
    // so it is only asked about ids that really are body colours.
    final image =
        MascotAssets.layer(widget.itemId) ??
        (widget.itemId.startsWith('body_')
            ? MascotAssets.body(widget.itemId)
            : null);
    if (image == null) {
      return Icon(_CosmeticGrid._icon(widget.slot), size: 34);
    }
    return SizedBox(
      height: 38,
      width: 38,
      child: RawImage(image: image, fit: BoxFit.contain),
    );
  }
}
