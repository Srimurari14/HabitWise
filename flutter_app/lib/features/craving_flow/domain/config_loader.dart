import 'package:flutter/services.dart';

import 'craving_models.dart';

class ConfigLoader {
  const ConfigLoader(this.bundle);

  final AssetBundle bundle;

  Future<CravingConfig> load() async {
    final values = await Future.wait(<Future<String>>[
      bundle.loadString('assets/config/tree_v1.json'),
      bundle.loadString('assets/config/interventions_v1.json'),
    ]);
    return CravingConfig.fromJson(
      treeJson: values[0],
      interventionsJson: values[1],
    );
  }
}
