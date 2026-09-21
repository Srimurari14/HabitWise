import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/habit_widgets.dart';
import '../../../data/local/app_database.dart';
import '../../../providers.dart';
import '../domain/avatar_models.dart';
import 'avatar_character.dart';

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
      appBar: AppBar(title: const Text('Avatar')),
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
                      label: 'earned coins',
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
              child: AvatarCharacter(equipped: avatar.equipped, size: 175),
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
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            final repository = ref.read(gamificationRepositoryProvider);
            if (owned) {
              await repository.equip(item);
              return;
            }
            if (!store || lockedByMilestone) return;
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Unlock ${item.name}?'),
                content: Text(
                  '${item.price} earned coins will be used. Your current balance is $balance.',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Not now'),
                  ),
                  FilledButton(
                    onPressed: balance >= item.price
                        ? () => Navigator.pop(context, true)
                        : null,
                    child: const Text('Unlock'),
                  ),
                ],
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
                      : 'You do not have enough earned coins yet.',
                ),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              color: equipped
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: equipped
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(_icon(item.slot), size: 22),
                const SizedBox(height: 5),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  equipped
                      ? 'Wearing'
                      : owned
                      ? item.slot.label
                      : lockedByMilestone
                      ? '${item.milestone}-day milestone'
                      : '${item.price} coins',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
