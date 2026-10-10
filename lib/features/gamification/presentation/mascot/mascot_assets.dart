import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
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
///
/// Images are read one at a time, on demand, and kept once read. Reading all
/// of them up front cost about twenty megabytes of memory and a second of
/// stutter the first time a mascot appeared, to draw a character that wears
/// four things in one colour.
abstract final class MascotAssets {
  static const _manifestPath = 'assets/config/mascot_v1.json';
  static const _defaultBody = 'body_violet';

  /// Every body colour the art ships. Only the worn one is ever read, except
  /// on the screens that show the whole range side by side.
  static const bodyColours = <String>[
    'body_violet',
    'body_sky',
    'body_mint',
    'body_sun',
    'body_ember',
    'body_blossom',
    'body_cloud',
    'body_ink',
  ];

  static final Map<String, ui.Image> _images = <String, ui.Image>{};

  /// One read per image, kept after it finishes so asking twice is free and
  /// two screens wanting the same coat share the one read.
  static final Map<String, Future<void>> _requests = <String, Future<void>>{};

  /// Keys whose file could not be read. Kept so a painter asking sixty times
  /// a second does not retry a missing file sixty times a second.
  static final Set<String> _missing = <String>{};
  static final Map<String, MascotPlacement> _items =
      <String, MascotPlacement>{};
  static MascotPlacement? _body;
  static double _frame = 1254;
  static Future<void>? _loading;
  static bool _ready = false;

  /// Counts up every time another image finishes being read, so anything
  /// drawing the mascot knows to draw itself again.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// True once the manifest is parsed. Images may still be arriving.
  static bool get ready => _ready;

  /// The master frame's size, which is the space placements are given in.
  static double get frame => _frame;

  static MascotPlacement? get bodyPlacement => _body;

  static MascotPlacement? placementOf(String itemId) => _items[itemId];

  /// The art for an item, or null while it is still being read. Asking for
  /// one that is not in memory starts reading it, so a caller can skip the
  /// layer on this frame and draw it on a later one.
  static ui.Image? layer(String itemId) =>
      _image('layer:$itemId', 'assets/mascot/layers/$itemId.png');

  static ui.Image? body(String colourId) =>
      _image('body:$colourId', 'assets/mascot/body/$colourId.png') ??
      _images['body:$_defaultBody'];

  static Future<void> ensureLoaded() => _loading ??= _load();

  /// Read what a screen is about to draw before it draws it, all at once
  /// rather than one after another, so the first frame is not half dressed.
  static Future<void> prewarm({
    Iterable<String> items = const <String>[],
    Iterable<String> bodies = const <String>[],
  }) async {
    await ensureLoaded();
    await Future.wait(<Future<void>>[
      for (final id in items)
        _read('layer:$id', 'assets/mascot/layers/$id.png'),
      for (final id in bodies) _read('body:$id', 'assets/mascot/body/$id.png'),
    ]);
  }

  static ui.Image? _image(String key, String asset) {
    final loaded = _images[key];
    if (loaded != null) return loaded;
    // Painters call this, so it must not await anything. Start the read and
    // let the revision counter bring whoever asked back for another look.
    if (_ready) _read(key, asset);
    return null;
  }

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
    }
    _ready = true;
    revision.value++;
  }

  static Future<void> _read(String key, String asset) {
    if (_images.containsKey(key) || _missing.contains(key)) {
      return Future<void>.value();
    }
    return _requests[key] ??= _decode(key, asset);
  }

  static Future<void> _decode(String key, String asset) async {
    try {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _images[key] = frame.image;
      revision.value++;
    } on Object {
      // A missing file means that item simply does not draw. It must never
      // take the screen down with it, and it must only be tried once.
      //
      // The clause is this wide on purpose: rootBundle reports a missing
      // asset as a FlutterError, which is an Error rather than an Exception,
      // so 'on Exception' would let it through and take the screen down.
      _missing.add(key);
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
