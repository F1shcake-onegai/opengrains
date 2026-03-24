import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

enum MeteringMode { centerWeighted, matrix, average, point }
enum CalculatedParam { aperture, shutterSpeed, iso }
enum ExposureStep { full, half, third, quarter }

class ExposureStepSettings {
  static const String _key = 'exposure_step';
  static const ExposureStep defaultStep = ExposureStep.third;

  static Future<ExposureStep> load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_key);
    if (idx == null || idx < 0 || idx >= ExposureStep.values.length) {
      return defaultStep;
    }
    return ExposureStep.values[idx];
  }

  static Future<void> save(ExposureStep step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, step.index);
  }

  static String label(ExposureStep step) {
    switch (step) {
      case ExposureStep.full:
        return '1';
      case ExposureStep.half:
        return '1/2';
      case ExposureStep.third:
        return '1/3';
      case ExposureStep.quarter:
        return '1/4';
    }
  }
}

class LightMeterConstants {
  // ───── Full-stop values ─────
  static const List<double> _aperturesFull = [
    1.0, 1.4, 2.0, 2.8, 4.0, 5.6, 8.0, 11.0, 16.0, 22.0, 32.0,
  ];
  static const List<double> _aperturesHalf = [
    1.0, 1.2, 1.4, 1.7, 2.0, 2.4, 2.8, 3.3, 4.0, 4.8, 5.6, 6.7, 8.0, 9.5, 11.0, 13.0, 16.0, 19.0, 22.0, 27.0, 32.0,
  ];
  static const List<double> _aperturesThird = [
    1.0, 1.1, 1.2, 1.4, 1.6, 1.8, 2.0, 2.2, 2.5, 2.8, 3.2, 3.5, 4.0, 4.5, 5.0, 5.6, 6.3, 7.1, 8.0, 9.0, 10.0, 11.0, 13.0, 14.0, 16.0, 18.0, 20.0, 22.0, 25.0, 29.0, 32.0,
  ];
  static const List<double> _aperturesQuarter = [
    1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.7, 1.8, 2.0, 2.1, 2.4, 2.5, 2.8, 3.0, 3.4, 3.6, 4.0, 4.2, 4.8, 5.0, 5.6, 6.0, 6.7, 7.1, 8.0, 8.5, 9.5, 10.0, 11.0, 12.0, 13.0, 14.0, 16.0, 17.0, 19.0, 21.0, 22.0, 24.0, 27.0, 30.0, 32.0,
  ];

  static const List<double> _shuttersFull = [
    30, 15, 8, 4, 2, 1,
    1 / 2, 1 / 4, 1 / 8, 1 / 15, 1 / 30, 1 / 60,
    1 / 125, 1 / 250, 1 / 500, 1 / 1000, 1 / 2000, 1 / 4000, 1 / 8000,
  ];
  static const List<double> _shuttersHalf = [
    30, 20, 15, 10, 8, 6, 4, 3, 2, 1.5, 1,
    1 / 1.5, 1 / 2, 1 / 3, 1 / 4, 1 / 6, 1 / 8, 1 / 10, 1 / 15, 1 / 20, 1 / 30, 1 / 45, 1 / 60, 1 / 90, 1 / 125, 1 / 180, 1 / 250, 1 / 350, 1 / 500, 1 / 750, 1 / 1000, 1 / 1500, 1 / 2000, 1 / 3000, 1 / 4000, 1 / 6000, 1 / 8000,
  ];
  static const List<double> _shuttersThird = [
    30, 25, 20, 15, 13, 10, 8, 6, 5, 4, 3.2, 2.5, 2, 1.6, 1.3, 1,
    1 / 1.3, 1 / 1.6, 1 / 2, 1 / 2.5, 1 / 3, 1 / 4, 1 / 5, 1 / 6, 1 / 8, 1 / 10, 1 / 13, 1 / 15, 1 / 20, 1 / 25, 1 / 30, 1 / 40, 1 / 50, 1 / 60, 1 / 80, 1 / 100, 1 / 125, 1 / 160, 1 / 200, 1 / 250, 1 / 320, 1 / 400, 1 / 500, 1 / 640, 1 / 800, 1 / 1000, 1 / 1250, 1 / 1600, 1 / 2000, 1 / 2500, 1 / 3200, 1 / 4000, 1 / 5000, 1 / 6400, 1 / 8000,
  ];
  static const List<double> _shuttersQuarter = [
    30, 25, 22, 20, 15, 13, 11, 10, 8, 7, 6, 5, 4, 3.5, 3, 2.5, 2, 1.7, 1.5, 1.3, 1,
    1 / 1.3, 1 / 1.5, 1 / 1.7, 1 / 2, 1 / 2.5, 1 / 3, 1 / 3.5, 1 / 4, 1 / 5, 1 / 6, 1 / 7, 1 / 8, 1 / 10, 1 / 11, 1 / 13, 1 / 15, 1 / 18, 1 / 20, 1 / 23, 1 / 30, 1 / 35, 1 / 40, 1 / 45, 1 / 60, 1 / 70, 1 / 80, 1 / 90, 1 / 125, 1 / 140, 1 / 160, 1 / 180, 1 / 250, 1 / 280, 1 / 320, 1 / 350, 1 / 500, 1 / 570, 1 / 640, 1 / 750, 1 / 1000, 1 / 1100, 1 / 1250, 1 / 1500, 1 / 2000, 1 / 2300, 1 / 2500, 1 / 3000, 1 / 4000, 1 / 4500, 1 / 5000, 1 / 6000, 1 / 8000,
  ];

  static const List<int> _isosFull = [
    50, 100, 200, 400, 800, 1600, 3200, 6400, 12800,
  ];
  static const List<int> _isosHalf = [
    50, 64, 100, 125, 200, 250, 400, 500, 800, 1000, 1600, 2000, 3200, 4000, 6400, 8000, 12800,
  ];
  static const List<int> _isosThird = [
    50, 64, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500, 3200, 4000, 5000, 6400, 8000, 10000, 12800,
  ];
  static const List<int> _isosQuarter = [
    50, 56, 64, 72, 100, 110, 125, 140, 200, 220, 250, 280, 400, 450, 500, 570, 800, 900, 1000, 1100, 1600, 1800, 2000, 2300, 3200, 3600, 4000, 4500, 6400, 7200, 8000, 9000, 12800,
  ];

  static List<double> apertureStops([ExposureStep step = ExposureStep.third]) {
    switch (step) {
      case ExposureStep.full:
        return _aperturesFull;
      case ExposureStep.half:
        return _aperturesHalf;
      case ExposureStep.third:
        return _aperturesThird;
      case ExposureStep.quarter:
        return _aperturesQuarter;
    }
  }

  static List<double> shutterSpeeds([ExposureStep step = ExposureStep.third]) {
    switch (step) {
      case ExposureStep.full:
        return _shuttersFull;
      case ExposureStep.half:
        return _shuttersHalf;
      case ExposureStep.third:
        return _shuttersThird;
      case ExposureStep.quarter:
        return _shuttersQuarter;
    }
  }

  static List<int> isoValues([ExposureStep step = ExposureStep.third]) {
    switch (step) {
      case ExposureStep.full:
        return _isosFull;
      case ExposureStep.half:
        return _isosHalf;
      case ExposureStep.third:
        return _isosThird;
      case ExposureStep.quarter:
        return _isosQuarter;
    }
  }

  /// Format aperture for display: f/2.8
  static String formatAperture(double f) {
    if (f == f.roundToDouble() && f >= 1) return 'f/${f.toInt()}';
    return 'f/$f';
  }

  /// Format shutter speed for display: 1/125 or 2"
  static String formatShutter(double seconds) {
    if (seconds >= 1) {
      return seconds == seconds.roundToDouble()
          ? '${seconds.toInt()}"'
          : '${seconds.toStringAsFixed(1)}"';
    }
    final denom = (1.0 / seconds).round();
    return '1/$denom';
  }

  /// Format ISO for display
  static String formatISO(int iso) => '$iso';

  // ───── EV Math ─────

  /// EV₁₀₀ = log2(N² / t)
  static double computeEV100(double aperture, double shutterSeconds) {
    return math.log(aperture * aperture / shutterSeconds) / math.ln2;
  }

  /// Convert scene EV to EV₁₀₀ given ISO
  static double evToEV100(double ev, int iso) {
    return ev - (math.log(iso / 100.0) / math.ln2);
  }

  /// Solve shutter speed: t = N² / 2^EV₁₀₀
  static double solveShutter(double ev, double aperture, int iso) {
    final ev100 = evToEV100(ev, iso);
    return (aperture * aperture) / math.pow(2, ev100);
  }

  /// Solve aperture: N = sqrt(t × 2^EV₁₀₀)
  static double solveAperture(double ev, double shutterSeconds, int iso) {
    final ev100 = evToEV100(ev, iso);
    return math.sqrt(shutterSeconds * math.pow(2, ev100));
  }

  /// Solve ISO: ISO = 100 × N² / (t × 2^EV)
  static int solveISO(double ev, double aperture, double shutterSeconds) {
    return (100.0 * aperture * aperture /
            (shutterSeconds * math.pow(2, ev)))
        .round()
        .clamp(1, 999999);
  }

  /// Find nearest index in a list (compares in log2 space)
  static int nearestStopIndex(List<double> values, double target) {
    if (target <= 0) return 0;
    double bestDiff = double.infinity;
    int bestIdx = 0;
    final logTarget = math.log(target);
    for (int i = 0; i < values.length; i++) {
      final diff = (math.log(values[i]) - logTarget).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  /// Find nearest ISO index (linear comparison)
  static int nearestISOIndex(List<int> values, int target) {
    double bestDiff = double.infinity;
    int bestIdx = 0;
    for (int i = 0; i < values.length; i++) {
      final diff = (values[i] - target).abs().toDouble();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIdx = i;
      }
    }
    return bestIdx;
  }
}
