import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'mascot_character.dart';

/// A scratch screen for looking at the mascot. Not linked from anywhere in the
/// app and not wired to the shop or the coin system. It exists so the design
/// can be reviewed before anything replaces the current character.
class MascotLabScreen extends StatefulWidget {
  const MascotLabScreen({super.key});

  @override
  State<MascotLabScreen> createState() => _MascotLabScreenState();
}

class _MascotLabScreenState extends State<MascotLabScreen>
    with SingleTickerProviderStateMixin {
  static const _colours = <String, String>{
    'body_violet': 'Violet',
    'body_sky': 'Sky',
    'body_blossom': 'Blossom',
    'body_mint': 'Mint',
    'body_sun': 'Sun',
    'body_ember': 'Ember',
    'body_cloud': 'Cloud',
    'body_ink': 'Ink',
  };
  static const _faces = <String, String>{
    'face_happy': 'Happy',
    'face_excited': 'Excited',
    'face_focused': 'Focused',
    'face_surprised': 'Surprised',
    'face_sad': 'Sad',
  };

  late final Ticker _ticker;

  /// Pinch and drag the preview. Showing somebody how a collar sits needs a
  /// closer look than a 220 pixel blob allows.
  final _zoom = TransformationController();
  Duration _last = Duration.zero;
  double _clock = 0;
  double _fps = 0;
  String _colour = 'body_violet';
  String _face = 'face_happy';
  String? _hat;
  String? _outfit;
  String? _shoes;
  String? _glasses;
  String? _back;
  String? _scarf;
  MascotPose _pose = MascotPose.idle;
  double _lean = 0;
  bool _reducedMotion = false;
  bool _highContrast = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onFrame)..start();
  }

  double get _scale => _zoom.value.getMaxScaleOnAxis();

  @override
  void dispose() {
    _zoom.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _onFrame(Duration elapsed) {
    final frame = elapsed - _last;
    _last = elapsed;
    final seconds = frame.inMicroseconds / 1000000;
    if (seconds <= 0) return;
    setState(() {
      _clock += seconds;
      final instant = 1 / seconds;
      _fps = _fps < 1 ? instant : _fps * 0.9 + instant * 0.1;
    });
  }

  double get _phase {
    final speed = switch (_pose) {
      MascotPose.run => 2.0,
      MascotPose.celebrate => 1.4,
      MascotPose.hit || MascotPose.land => 0.8,
      _ => 0.55,
    };
    return (_clock * speed) % 1;
  }

  Widget _picker(
    String label,
    List<String> options,
    String? selected,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label),
          Wrap(
            spacing: 8,
            children: <Widget>[
              ChoiceChip(
                label: const Text('none'),
                selected: selected == null,
                onSelected: (_) => onChanged(null),
              ),
              for (final option in options)
                ChoiceChip(
                  label: Text(option.split('_').skip(1).join(' ')),
                  selected: selected == option,
                  onSelected: (_) => onChanged(option),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final equipped = <String, String>{
      'baseColor': _colour,
      'expression': _face,
      'hat': ?_hat,
      'top': ?_outfit,
      'shoes': ?_shoes,
      'glasses': ?_glasses,
      'back': ?_back,
      'scarf': ?_scarf,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Mascot lab')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xFF2B1B46), Color(0xFF6B4C96)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 236,
                      child: InteractiveViewer(
                        transformationController: _zoom,
                        minScale: 1,
                        maxScale: 6,
                        // Room to drag a zoomed blob around, rather than
                        // clamping it to its own edges.
                        boundaryMargin: const EdgeInsets.all(240),
                        clipBehavior: Clip.hardEdge,
                        onInteractionEnd: (_) => setState(() {}),
                        child: Center(
                          child: MascotCharacter(
                            equipped: equipped,
                            size: 220,
                            pose: _pose,
                            phase: _phase,
                            lean: _lean,
                            reducedMotion: _reducedMotion,
                            highContrast: _highContrast,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for (final size in <double>[120, 72, 44])
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: MascotCharacter(
                              equipped: equipped,
                              size: size,
                              pose: _pose,
                              phase: _phase,
                              lean: _lean,
                              reducedMotion: _reducedMotion,
                              highContrast: _highContrast,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${_fps.round()} fps   ${_scale.toStringAsFixed(1)}x',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (_scale > 1.01)
                          TextButton(
                            onPressed: () => setState(
                              () => _zoom.value = Matrix4.identity(),
                            ),
                            child: const Text('Reset zoom'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              children: <Widget>[
                const Text('Pose'),
                Wrap(
                  spacing: 8,
                  children: MascotPose.values
                      .map(
                        (pose) => ChoiceChip(
                          label: Text(pose.name),
                          selected: _pose == pose,
                          onSelected: (_) => setState(() => _pose = pose),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                const Text('Body'),
                Wrap(
                  spacing: 8,
                  children: _colours.entries
                      .map(
                        (entry) => ChoiceChip(
                          label: Text(entry.value),
                          selected: _colour == entry.key,
                          onSelected: (_) =>
                              setState(() => _colour = entry.key),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                const Text('Face'),
                Wrap(
                  spacing: 8,
                  children: _faces.entries
                      .map(
                        (entry) => ChoiceChip(
                          label: Text(entry.value),
                          selected: _face == entry.key,
                          onSelected: (_) => setState(() => _face = entry.key),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                _picker(
                  'Hat',
                  const <String>[
                    'hat_beanie',
                    'hat_cap',
                    'hat_bucket',
                    'hat_party',
                    'hat_headphones',
                    'hat_cosy_knit',
                    'hat_aurora_circlet',
                  ],
                  _hat,
                  (value) => setState(() => _hat = value),
                ),
                _picker(
                  'Outfit',
                  const <String>[
                    'outfit_hoodie_blue',
                    'outfit_cosy_sweater',
                    'outfit_aurora_cloak',
                    'outfit_urban_explorer',
                  ],
                  _outfit,
                  (value) => setState(() => _outfit = value),
                ),
                _picker(
                  'Shoes',
                  const <String>[
                    'shoes_sneaker_red',
                    'shoes_cosy_boots',
                    'shoes_aurora_boots',
                  ],
                  _shoes,
                  (value) => setState(() => _shoes = value),
                ),
                _picker(
                  'Glasses',
                  const <String>['glasses_sun', 'glasses_round'],
                  _glasses,
                  (value) => setState(() => _glasses = value),
                ),
                _picker(
                  'Back',
                  const <String>['back_cape', 'back_backpack'],
                  _back,
                  (value) => setState(() => _back = value),
                ),
                _picker(
                  'Scarf',
                  const <String>[
                    'scarf_red',
                    'scarf_navy',
                    'scarf_aurora_collar',
                  ],
                  _scarf,
                  (value) => setState(() => _scarf = value),
                ),
                const SizedBox(height: 14),
                Text('Lean ${_lean.toStringAsFixed(1)}'),
                Slider(
                  value: _lean,
                  min: -1,
                  max: 1,
                  divisions: 20,
                  onChanged: (value) => setState(() => _lean = value),
                ),
                SwitchListTile(
                  title: const Text('Reduced motion'),
                  value: _reducedMotion,
                  onChanged: (value) => setState(() => _reducedMotion = value),
                ),
                SwitchListTile(
                  title: const Text('High contrast'),
                  value: _highContrast,
                  onChanged: (value) => setState(() => _highContrast = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
