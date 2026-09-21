import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/core/utils/stats.dart';

void main() {
  group('descriptive statistics', () {
    test('mean, variance, Pearson, and Spearman match known values', () {
      expect(Stats.mean(<num>[1, 2, 3]), 2);
      expect(Stats.sampleVariance(<num>[1, 2, 3]), 1);
      expect(Stats.pearson(<num>[1, 2, 3], <num>[2, 4, 6]), closeTo(1, 1e-12));
      expect(
        Stats.spearman(<num>[1, 2, 3], <num>[6, 4, 2]),
        closeTo(-1, 1e-12),
      );
    });
  });

  group('inferential statistics', () {
    test('Welch t-test matches a known two-sided result', () {
      final result = Stats.welchTTest(<num>[1, 2, 3], <num>[5, 6, 7]);
      expect(result.statistic, closeTo(-4.898979, 1e-5));
      expect(result.degreesOfFreedom, closeTo(4, 1e-10));
      expect(result.pValue, closeTo(0.00805, 0.0002));
    });

    test('Mann–Whitney and chi-square match known directions', () {
      final mann = Stats.mannWhitneyU(<num>[1, 2, 3], <num>[4, 5, 6]);
      expect(mann.statistic, 0);
      expect(mann.pValue, lessThan(0.1));
      final chi = Stats.chiSquare2x2(a: 10, b: 20, c: 20, d: 10);
      expect(chi.statistic, closeTo(6.6667, 0.001));
      expect(chi.pValue, closeTo(0.00982, 0.001));
    });
  });

  group('regression', () {
    test('OLS recovers a linear intercept and slope', () {
      final result = Stats.ols(
        <List<num>>[
          <num>[1, 0],
          <num>[1, 1],
          <num>[1, 2],
          <num>[1, 3],
        ],
        <num>[1, 3, 5, 7],
      );
      expect(result.coefficients[0], closeTo(1, 1e-10));
      expect(result.coefficients[1], closeTo(2, 1e-10));
      expect(result.rSquared, closeTo(1, 1e-10));
    });

    test('logistic regression assigns a positive slope to rising outcomes', () {
      final result = Stats.logistic(
        <List<num>>[
          <num>[1, -2],
          <num>[1, -1],
          <num>[1, 0],
          <num>[1, 1],
          <num>[1, 2],
          <num>[1, 3],
        ],
        <int>[0, 0, 1, 0, 1, 1],
      );
      expect(result.coefficients[1], greaterThan(0));
      expect(result.iterations, inInclusiveRange(1, 40));
    });
  });
}
