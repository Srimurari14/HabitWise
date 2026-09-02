import 'dart:math' as math;

class TestResult {
  const TestResult({
    required this.statistic,
    required this.pValue,
    this.degreesOfFreedom,
  });

  final double statistic;
  final double pValue;
  final double? degreesOfFreedom;
}

class OlsResult {
  const OlsResult({
    required this.coefficients,
    required this.rSquared,
    required this.residualVariance,
  });

  final List<double> coefficients;
  final double rSquared;
  final double residualVariance;
}

class LogisticResult {
  const LogisticResult({required this.coefficients, required this.iterations});
  final List<double> coefficients;
  final int iterations;
}

abstract final class Stats {
  static double mean(Iterable<num> values) {
    final list = values.toList();
    if (list.isEmpty) return double.nan;
    return list.fold<double>(0, (sum, value) => sum + value) / list.length;
  }

  static double sampleVariance(Iterable<num> values) {
    final list = values.map((value) => value.toDouble()).toList();
    if (list.length < 2) return double.nan;
    final average = mean(list);
    return list.fold<double>(
          0,
          (sum, value) => sum + math.pow(value - average, 2),
        ) /
        (list.length - 1);
  }

  static double pearson(List<num> x, List<num> y) {
    _sameNonEmptyLength(x, y);
    final meanX = mean(x);
    final meanY = mean(y);
    var numerator = 0.0;
    var sumX = 0.0;
    var sumY = 0.0;
    for (var index = 0; index < x.length; index++) {
      final dx = x[index] - meanX;
      final dy = y[index] - meanY;
      numerator += dx * dy;
      sumX += dx * dx;
      sumY += dy * dy;
    }
    final denominator = math.sqrt(sumX * sumY);
    return denominator == 0 ? double.nan : numerator / denominator;
  }

  static double spearman(List<num> x, List<num> y) {
    _sameNonEmptyLength(x, y);
    return pearson(_averageRanks(x), _averageRanks(y));
  }

  static TestResult welchTTest(List<num> first, List<num> second) {
    if (first.length < 2 || second.length < 2) {
      throw ArgumentError(
        'Welch t-test requires at least two values per group.',
      );
    }
    final meanA = mean(first);
    final meanB = mean(second);
    final varianceA = sampleVariance(first);
    final varianceB = sampleVariance(second);
    final termA = varianceA / first.length;
    final termB = varianceB / second.length;
    final standardError = math.sqrt(termA + termB);
    final t = (meanA - meanB) / standardError;
    final degrees =
        math.pow(termA + termB, 2) /
        (math.pow(termA, 2) / (first.length - 1) +
            math.pow(termB, 2) / (second.length - 1));
    final p = 2 * (1 - _studentTCdf(t.abs(), degrees));
    return TestResult(
      statistic: t,
      pValue: p.clamp(0, 1),
      degreesOfFreedom: degrees,
    );
  }

  static TestResult mannWhitneyU(List<num> first, List<num> second) {
    if (first.isEmpty || second.isEmpty) {
      throw ArgumentError('Mann–Whitney U requires two non-empty groups.');
    }
    final combined = <({double value, int group})>[
      ...first.map((value) => (value: value.toDouble(), group: 0)),
      ...second.map((value) => (value: value.toDouble(), group: 1)),
    ]..sort((a, b) => a.value.compareTo(b.value));
    final values = combined.map((item) => item.value).toList();
    final ranks = _averageRanks(values);
    var rankSumFirst = 0.0;
    for (var index = 0; index < combined.length; index++) {
      if (combined[index].group == 0) rankSumFirst += ranks[index];
    }
    final n1 = first.length.toDouble();
    final n2 = second.length.toDouble();
    final u1 = rankSumFirst - n1 * (n1 + 1) / 2;
    final u2 = n1 * n2 - u1;
    final u = math.min(u1, u2);
    final tieCounts = <double, int>{};
    for (final value in values) {
      tieCounts[value] = (tieCounts[value] ?? 0) + 1;
    }
    final total = n1 + n2;
    final tieCorrection = tieCounts.values.fold<double>(
      0,
      (sum, count) => sum + (count * count * count - count),
    );
    final variance =
        n1 * n2 / 12 * ((total + 1) - tieCorrection / (total * (total - 1)));
    final z = variance == 0
        ? 0.0
        : (u - n1 * n2 / 2 + 0.5) / math.sqrt(variance);
    final p = 2 * (1 - _normalCdf(z.abs()));
    return TestResult(statistic: u, pValue: p.clamp(0, 1));
  }

  static TestResult chiSquare2x2({
    required int a,
    required int b,
    required int c,
    required int d,
  }) {
    if (<int>[a, b, c, d].any((value) => value < 0)) {
      throw ArgumentError('Counts cannot be negative.');
    }
    final total = (a + b + c + d).toDouble();
    if (total == 0) {
      throw ArgumentError('At least one observation is required.');
    }
    final numerator = total * math.pow(a * d - b * c, 2);
    final denominator = (a + b) * (c + d) * (a + c) * (b + d).toDouble();
    final chiSquare = denominator == 0 ? 0.0 : numerator / denominator;
    final p = _erfc(math.sqrt(chiSquare / 2));
    return TestResult(
      statistic: chiSquare,
      pValue: p.clamp(0, 1),
      degreesOfFreedom: 1,
    );
  }

  /// Ordinary least squares. Each row in [predictors] must include an
  /// intercept column if one is desired.
  static OlsResult ols(List<List<num>> predictors, List<num> outcomes) {
    if (predictors.isEmpty || predictors.length != outcomes.length) {
      throw ArgumentError(
        'Predictors and outcomes must have equal non-zero rows.',
      );
    }
    final columns = predictors.first.length;
    if (columns == 0 || predictors.any((row) => row.length != columns)) {
      throw ArgumentError('Predictor rows must have equal non-zero width.');
    }
    final x = predictors
        .map((row) => row.map((value) => value.toDouble()).toList())
        .toList();
    final y = outcomes.map((value) => value.toDouble()).toList();
    final xt = _transpose(x);
    final xtx = _multiply(xt, x);
    final inverse = _inverse(xtx);
    final xty = _multiplyVector(xt, y);
    final coefficients = _multiplyVector(inverse, xty);
    final predicted = _multiplyVector(x, coefficients);
    final averageY = mean(y);
    var residualSum = 0.0;
    var totalSum = 0.0;
    for (var index = 0; index < y.length; index++) {
      residualSum += math.pow(y[index] - predicted[index], 2);
      totalSum += math.pow(y[index] - averageY, 2);
    }
    return OlsResult(
      coefficients: coefficients,
      rSquared: totalSum == 0 ? 1 : 1 - residualSum / totalSum,
      residualVariance: residualSum / math.max(1, y.length - columns),
    );
  }

  /// Binary logistic regression fitted with iteratively reweighted least
  /// squares. Predictor rows must include an intercept when desired.
  static LogisticResult logistic(
    List<List<num>> predictors,
    List<int> outcomes, {
    int maxIterations = 40,
    double tolerance = 1e-7,
  }) {
    if (outcomes.any((value) => value != 0 && value != 1)) {
      throw ArgumentError('Logistic outcomes must be 0 or 1.');
    }
    if (predictors.isEmpty || predictors.length != outcomes.length) {
      throw ArgumentError(
        'Predictors and outcomes must have equal non-zero rows.',
      );
    }
    final x = predictors
        .map((row) => row.map((value) => value.toDouble()).toList())
        .toList();
    final columns = x.first.length;
    var beta = List<double>.filled(columns, 0);
    var iterations = 0;
    for (var iteration = 0; iteration < maxIterations; iteration++) {
      iterations = iteration + 1;
      final eta = _multiplyVector(x, beta);
      final probabilities = eta
          .map((value) => 1 / (1 + math.exp(-value.clamp(-30, 30))))
          .toList();
      final weights = probabilities
          .map((value) => math.max(1e-8, value * (1 - value)))
          .toList();
      final z = List<double>.generate(
        outcomes.length,
        (index) =>
            eta[index] +
            (outcomes[index] - probabilities[index]) / weights[index],
      );
      final xtwx = List<List<double>>.generate(
        columns,
        (row) => List<double>.generate(
          columns,
          (column) => List<double>.generate(
            x.length,
            (index) => x[index][row] * weights[index] * x[index][column],
          ).fold(0, (sum, value) => sum + value),
        ),
      );
      final xtwz = List<double>.generate(
        columns,
        (column) => List<double>.generate(
          x.length,
          (index) => x[index][column] * weights[index] * z[index],
        ).fold(0, (sum, value) => sum + value),
      );
      final next = _multiplyVector(_inverse(xtwx), xtwz);
      final change = List<double>.generate(
        columns,
        (index) => (next[index] - beta[index]).abs(),
      ).reduce(math.max);
      beta = next;
      if (change < tolerance) break;
    }
    return LogisticResult(coefficients: beta, iterations: iterations);
  }

  static void _sameNonEmptyLength(List<num> x, List<num> y) {
    if (x.isEmpty || x.length != y.length) {
      throw ArgumentError('Lists must be non-empty and have equal length.');
    }
  }

  static List<double> _averageRanks(List<num> values) {
    final indexed = List<({int index, double value})>.generate(
      values.length,
      (index) => (index: index, value: values[index].toDouble()),
    )..sort((a, b) => a.value.compareTo(b.value));
    final output = List<double>.filled(values.length, 0);
    var start = 0;
    while (start < indexed.length) {
      var end = start + 1;
      while (end < indexed.length &&
          indexed[end].value == indexed[start].value) {
        end++;
      }
      final averageRank = (start + 1 + end) / 2;
      for (var index = start; index < end; index++) {
        output[indexed[index].index] = averageRank;
      }
      start = end;
    }
    return output;
  }

  static double _normalCdf(double value) =>
      0.5 * (1 + _erf(value / math.sqrt2));

  // Abramowitz and Stegun 7.1.26, adequate for UI-level inference.
  static double _erf(double value) {
    const p = 0.3275911;
    const a1 = 0.254829592;
    const a2 = -0.284496736;
    const a3 = 1.421413741;
    const a4 = -1.453152027;
    const a5 = 1.061405429;
    final sign = value < 0 ? -1.0 : 1.0;
    final x = value.abs();
    final t = 1 / (1 + p * x);
    final polynomial = (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t;
    return sign * (1 - polynomial * math.exp(-x * x));
  }

  static double _erfc(double value) => 1 - _erf(value);

  static double _studentTCdf(double t, double degrees) {
    if (t == 0) return 0.5;
    final x = degrees / (degrees + t * t);
    final beta = _regularizedIncompleteBeta(x, degrees / 2, 0.5);
    return 1 - 0.5 * beta;
  }

  static double _regularizedIncompleteBeta(double x, double a, double b) {
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    final logBeta =
        _logGamma(a + b) -
        _logGamma(a) -
        _logGamma(b) +
        a * math.log(x) +
        b * math.log(1 - x);
    final front = math.exp(logBeta);
    if (x < (a + 1) / (a + b + 2)) {
      return front * _betaFraction(x, a, b) / a;
    }
    return 1 - front * _betaFraction(1 - x, b, a) / b;
  }

  static double _betaFraction(double x, double a, double b) {
    const maxIterations = 200;
    const epsilon = 3e-12;
    const tiny = 1e-30;
    final qab = a + b;
    final qap = a + 1;
    final qam = a - 1;
    var c = 1.0;
    var d = 1 - qab * x / qap;
    if (d.abs() < tiny) d = tiny;
    d = 1 / d;
    var h = d;
    for (var m = 1; m <= maxIterations; m++) {
      final m2 = 2 * m;
      var aa = m * (b - m) * x / ((qam + m2) * (a + m2));
      d = 1 + aa * d;
      if (d.abs() < tiny) d = tiny;
      c = 1 + aa / c;
      if (c.abs() < tiny) c = tiny;
      d = 1 / d;
      h *= d * c;
      aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2));
      d = 1 + aa * d;
      if (d.abs() < tiny) d = tiny;
      c = 1 + aa / c;
      if (c.abs() < tiny) c = tiny;
      d = 1 / d;
      final delta = d * c;
      h *= delta;
      if ((delta - 1).abs() < epsilon) break;
    }
    return h;
  }

  static double _logGamma(double value) {
    const coefficients = <double>[
      676.5203681218851,
      -1259.1392167224028,
      771.3234287776531,
      -176.6150291621406,
      12.507343278686905,
      -0.13857109526572012,
      9.984369578019571e-6,
      1.5056327351493116e-7,
    ];
    if (value < 0.5) {
      return math.log(math.pi) -
          math.log(math.sin(math.pi * value)) -
          _logGamma(1 - value);
    }
    var x = 0.9999999999998099;
    final z = value - 1;
    for (var index = 0; index < coefficients.length; index++) {
      x += coefficients[index] / (z + index + 1);
    }
    final t = z + coefficients.length - 0.5;
    return 0.5 * math.log(2 * math.pi) +
        (z + 0.5) * math.log(t) -
        t +
        math.log(x);
  }

  static List<List<double>> _transpose(List<List<double>> matrix) {
    return List<List<double>>.generate(
      matrix.first.length,
      (column) =>
          List<double>.generate(matrix.length, (row) => matrix[row][column]),
    );
  }

  static List<List<double>> _multiply(
    List<List<double>> first,
    List<List<double>> second,
  ) {
    final transposed = _transpose(second);
    return first
        .map(
          (row) => transposed
              .map(
                (column) => List<double>.generate(
                  row.length,
                  (index) => row[index] * column[index],
                ).fold<double>(0, (sum, value) => sum + value),
              )
              .toList(),
        )
        .toList();
  }

  static List<double> _multiplyVector(
    List<List<double>> matrix,
    List<double> vector,
  ) {
    return matrix
        .map(
          (row) => List<double>.generate(
            row.length,
            (index) => row[index] * vector[index],
          ).fold<double>(0, (sum, value) => sum + value),
        )
        .toList();
  }

  static List<List<double>> _inverse(List<List<double>> matrix) {
    final n = matrix.length;
    if (n == 0 || matrix.any((row) => row.length != n)) {
      throw ArgumentError('Matrix must be non-empty and square.');
    }
    final augmented = List<List<double>>.generate(
      n,
      (row) => <double>[
        ...matrix[row],
        ...List<double>.generate(n, (column) => row == column ? 1 : 0),
      ],
    );
    for (var column = 0; column < n; column++) {
      var pivot = column;
      for (var row = column + 1; row < n; row++) {
        if (augmented[row][column].abs() > augmented[pivot][column].abs()) {
          pivot = row;
        }
      }
      if (augmented[pivot][column].abs() < 1e-12) {
        throw StateError('Predictor matrix is singular.');
      }
      final temporary = augmented[column];
      augmented[column] = augmented[pivot];
      augmented[pivot] = temporary;
      final scale = augmented[column][column];
      for (var item = 0; item < n * 2; item++) {
        augmented[column][item] /= scale;
      }
      for (var row = 0; row < n; row++) {
        if (row == column) continue;
        final factor = augmented[row][column];
        for (var item = 0; item < n * 2; item++) {
          augmented[row][item] -= factor * augmented[column][item];
        }
      }
    }
    return augmented.map((row) => row.sublist(n)).toList();
  }
}
