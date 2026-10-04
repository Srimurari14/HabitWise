import 'dart:convert';

enum CosmeticSlot {
  baseColor('Skin tone'),
  hair('Hair'),
  eyes('Eyes'),
  expression('Expression'),
  top('Top'),
  bottom('Bottom'),
  shoes('Shoes'),
  scarf('Scarf'),
  glasses('Glasses'),
  hat('Hat'),
  back('Back'),
  trail('Trail'),
  celebration('Celebration'),
  background('Background');

  const CosmeticSlot(this.label);
  final String label;

  /// Accessories can be taken off. Clothing, colour and expression cannot, so
  /// the avatar is never left undressed.
  bool get canBeRemoved => const <CosmeticSlot>{
    CosmeticSlot.scarf,
    CosmeticSlot.glasses,
    CosmeticSlot.hat,
    CosmeticSlot.back,
    CosmeticSlot.trail,
    CosmeticSlot.celebration,
  }.contains(this);
}

enum CosmeticRarity { starter, common, bright, milestone }

enum GameMode { standard, calm, reducedMotion }

enum GameSource { recommended, practice }

enum GameHelpfulness { helpful, somewhat, notHelpful }

class CosmeticItem {
  const CosmeticItem({
    required this.id,
    required this.name,
    required this.slot,
    required this.rarity,
    required this.price,
    required this.style,
    this.starter = false,
    this.milestone,
  });

  factory CosmeticItem.fromJson(Map<String, Object?> json) => CosmeticItem(
    id: json['id']! as String,
    name: json['name']! as String,
    slot: CosmeticSlot.values.byName(json['slot']! as String),
    rarity: CosmeticRarity.values.byName(json['rarity']! as String),
    price: json['price']! as int,
    style: json['style']! as String,
    starter: json['starter'] as bool? ?? false,
    milestone: json['milestone'] as int?,
  );

  final String id;
  final String name;
  final CosmeticSlot slot;
  final CosmeticRarity rarity;
  final int price;
  final String style;
  final bool starter;
  final int? milestone;
}

class CosmeticCatalog {
  const CosmeticCatalog(this.items);

  factory CosmeticCatalog.decode(String source) {
    final json = jsonDecode(source) as Map<String, Object?>;
    return CosmeticCatalog(
      (json['items']! as List<Object?>)
          .whereType<Map<Object?, Object?>>()
          .map(
            (item) => CosmeticItem.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false),
    );
  }

  final List<CosmeticItem> items;

  CosmeticItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}

class GamePreferences {
  const GamePreferences({
    this.reducedMotion = false,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.highContrast = false,
    this.oneHanded = false,
    this.calmMode = false,
    this.recommendationsEnabled = true,
  });

  factory GamePreferences.fromJson(Map<String, Object?> json) =>
      GamePreferences(
        reducedMotion: json['reducedMotion'] as bool? ?? false,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        highContrast: json['highContrast'] as bool? ?? false,
        oneHanded: json['oneHanded'] as bool? ?? false,
        calmMode: json['calmMode'] as bool? ?? false,
        recommendationsEnabled: json['recommendationsEnabled'] as bool? ?? true,
      );

  final bool reducedMotion;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool highContrast;
  final bool oneHanded;
  final bool calmMode;
  final bool recommendationsEnabled;

  GamePreferences copyWith({
    bool? reducedMotion,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? highContrast,
    bool? oneHanded,
    bool? calmMode,
    bool? recommendationsEnabled,
  }) => GamePreferences(
    reducedMotion: reducedMotion ?? this.reducedMotion,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    highContrast: highContrast ?? this.highContrast,
    oneHanded: oneHanded ?? this.oneHanded,
    calmMode: calmMode ?? this.calmMode,
    recommendationsEnabled:
        recommendationsEnabled ?? this.recommendationsEnabled,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'reducedMotion': reducedMotion,
    'soundEnabled': soundEnabled,
    'hapticsEnabled': hapticsEnabled,
    'highContrast': highContrast,
    'oneHanded': oneHanded,
    'calmMode': calmMode,
    'recommendationsEnabled': recommendationsEnabled,
  };
}

class AvatarProfileData {
  const AvatarProfileData({
    this.name = 'Spark',
    this.equipped = const <String, String>{
      'baseColor': 'skin_honey',
      'eyes': 'eyes_kind',
      'expression': 'expression_ready',
    },
    this.preferences = const GamePreferences(),
  });

  factory AvatarProfileData.fromJson(Map<String, Object?> json) {
    final equipped = json['equipped'] as Map<Object?, Object?>? ?? const {};
    final preferences =
        json['preferences'] as Map<Object?, Object?>? ?? const {};
    return AvatarProfileData(
      name: json['name'] as String? ?? 'Spark',
      equipped: equipped.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      preferences: GamePreferences.fromJson(
        preferences.map((key, value) => MapEntry(key.toString(), value)),
      ),
    );
  }

  factory AvatarProfileData.decode(String value) => AvatarProfileData.fromJson(
    (jsonDecode(value) as Map<Object?, Object?>).map(
      (key, value) => MapEntry(key.toString(), value),
    ),
  );

  final String name;
  final Map<String, String> equipped;
  final GamePreferences preferences;

  AvatarProfileData copyWith({
    String? name,
    Map<String, String>? equipped,
    GamePreferences? preferences,
  }) => AvatarProfileData(
    name: name ?? this.name,
    equipped: equipped ?? this.equipped,
    preferences: preferences ?? this.preferences,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'equipped': equipped,
    'preferences': preferences.toJson(),
  };

  String encode() => jsonEncode(toJson());
}

class AvatarProgress {
  const AvatarProgress({
    required this.coins,
    required this.currentStreak,
    required this.bestStreak,
    required this.activeDaysThisWeek,
  });

  final int coins;
  final int currentStreak;
  final int bestStreak;
  final int activeDaysThisWeek;
}

class GameRecommendation {
  const GameRecommendation({
    required this.reason,
    required this.durationMinutes,
    required this.mode,
    required this.safetyNote,
  });

  final String reason;
  final int durationMinutes;
  final GameMode mode;
  final String safetyNote;
}

class SignalShiftLaunch {
  const SignalShiftLaunch({
    required this.source,
    required this.durationMinutes,
    required this.mode,
    this.cravingSessionId,
    this.category,
    this.subtriggerId,
    this.intensityBefore,
    this.reason,
  });

  const SignalShiftLaunch.practice({
    this.durationMinutes = 3,
    this.mode = GameMode.standard,
  }) : source = GameSource.practice,
       cravingSessionId = null,
       category = null,
       subtriggerId = null,
       intensityBefore = null,
       reason = null;

  final GameSource source;
  final int durationMinutes;
  final GameMode mode;
  final String? cravingSessionId;
  final String? category;
  final String? subtriggerId;
  final int? intensityBefore;
  final String? reason;
}

class SignalShiftResult {
  const SignalShiftResult({
    required this.sessionId,
    required this.score,
    required this.coinsEarned,
    required this.completed,
    this.intensityAfter,
    this.helpfulness,
  });

  final String sessionId;
  final int score;
  final int coinsEarned;
  final bool completed;
  final int? intensityAfter;
  final GameHelpfulness? helpfulness;
}
