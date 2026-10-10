import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Where something sits inside the master render's frame.
class MascotPlacement {
  const MascotPlacement({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  factory MascotPlacement.fromJson(Map<String, Object?> json) =>
      MascotPlacement(
        left: (json['left']! as num).toDouble(),
        top: (json['top']! as num).toDouble(),
        width: (json['width']! as num).toDouble(),
        height: (json['height']! as num).toDouble(),
      );

  final double left;
  final double top;
  final double width;
  final double height;
}

/// The mascot's images and where each one belongs.
///
/// Every item was generated as an edit of one master render, so each layer
/// already knows its place in that render's frame. Nothing is anchored by
/// hand, which is what kept the old hats and coats sliding around.
abstract final class MascotAssets {
  static const _manifestPath = 'assets/config/mascot_v1.json';
  static const _defaultBody = 'body_violet';

  static final Map<String, ui.Image> _images = <String, ui.Image>{};
  static final Map<String, MascotPlacement> _items =
      <String, MascotPlacement>{};
  static MascotPlacement? _body;
  static double _frame = 1254;
  static Future<void>? _loading;
  static bool _ready = false;

  static bool get ready => _ready;

  /// The master frame's size, which is the space placements are given in.
  static double get frame => _frame;

  static MascotPlacement? get bodyPlacement => _body;

  static MascotPlacement? placementOf(String itemId) => _items[itemId];

  static ui.Image? layer(String itemId) => _images['layer:$itemId'];

  static ui.Image? body(String colourId) =>
      _images['body:$colourId'] ?? _images['body:$_defaultBody'];

  static Future<void> ensureLoaded() => _loading ??= _load();

  static Future<void> _load() async {
    final raw = await rootBundle.loadString(_manifestPath);
    final manifest = jsonDecode(raw) as Map<String, Object?>;
    _frame = (manifest['frame']! as num).toDouble();
    _body = MascotPlacement.fromJson(
      (manifest['body']! as Map<Object?, Object?>).cast<String, Object?>(),
    );
    final items = (manifest['items']! as Map<Object?, Object?>)
        .cast<String, Object?>();
    for (final entry in items.entries) {
      _items[entry.key] = MascotPlacement.fromJson(
        (entry.value! as Map<Object?, Object?>).cast<String, Object?>(),
      );
      await _decode(
        'layer:${entry.key}',
        'assets/mascot/layers/${entry.key}.png',
      );
    }
    for (final colour in <String>[
      'body_violet',
      'body_sky',
      'body_mint',
      'body_sun',
      'body_ember',
      'body_blossom',
      'body_cloud',
      'body_ink',
    ]) {
      await _decode('body:$colour', 'assets/mascot/body/$colour.png');
    }
    _ready = true;
  }

  static Future<void> _decode(String key, String asset) async {
    try {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _images[key] = frame.image;
    } on Exception {
      // A missing file means that item simply does not draw. It must never
      // take the screen down with it.
    }
  }
}

/// Items that were drawn as one whole outfit, and the slots they draw for you.
///
/// The explorer gear is a beanie, a coat and trainers from a single render.
/// Swapping any one of them would cut the others off mid-leg, so wearing it
/// hides those slots rather than drawing both.
const mascotCovers = <String, List<String>>{
  'outfit_urban_explorer': <String>['hat', 'shoes', 'scarf', 'back'],
};

/// Painting order, back to front. The face is a layer like anything else
/// because the body underneath it is blank.
const mascotLayerOrder = <String>[
  'back',
  'expression',
  'top',
  'shoes',
  'scarf',
  'glasses',
  'hat',
  'pet',
];
