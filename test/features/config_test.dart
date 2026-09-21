import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/features/craving_flow/domain/config_loader.dart';
import 'package:habitwise/features/craving_flow/domain/craving_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled craving tree is complete and internally valid', () async {
    final config = await ConfigLoader(rootBundle).load();
    expect(config.version, 2);
    expect(config.subtriggers.length, greaterThanOrEqualTo(26));
    expect(config.interventions.length, greaterThanOrEqualTo(20));
    for (final category in TriggerCategory.values) {
      expect(config.forCategory(category), isNotEmpty);
    }
    expect(
      config.subtriggers.any((item) => item.id == 'medication_rebound'),
      isTrue,
    );
    expect(config.interventions['permission-to-eat']!.nonLearnable, isTrue);
    for (final subtrigger in config.subtriggers) {
      expect(
        subtrigger.interventionIds.first,
        isNot('intentional-enjoyment'),
        reason: '${subtrigger.id} must not default to intentional consumption',
      );
      final primary = config.interventions[subtrigger.interventionIds.first]!;
      expect(primary.minutes, inInclusiveRange(5, 15));
      expect(primary.tags, contains('resist'));
    }
  });
}
