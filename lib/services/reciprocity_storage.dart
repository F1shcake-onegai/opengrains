import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReciprocityStorage {
  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/reciprocity_profiles.json');
  }

  static Future<List<Map<String, dynamic>>> loadProfiles() async {
    try {
      final file = await _file();
      if (!await file.exists()) return [];
      final json = await file.readAsString();
      final list = jsonDecode(json) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveProfiles(
      List<Map<String, dynamic>> profiles) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(profiles));
  }

  static Future<void> updateProfile(Map<String, dynamic> profile) async {
    final profiles = await loadProfiles();
    final idx = profiles.indexWhere((p) => p['id'] == profile['id']);
    if (idx >= 0) {
      profiles[idx] = profile;
    } else {
      profiles.add(profile);
    }
    await saveProfiles(profiles);
  }

  static Future<void> deleteProfile(String id) async {
    final profiles = await loadProfiles();
    profiles.removeWhere((p) => p['id'] == id);
    await saveProfiles(profiles);
  }

  /// Merge presets + custom profiles into a single list.
  static List<Map<String, dynamic>> allProfiles(
      List<Map<String, dynamic>> custom) {
    return [...presets, ...custom];
  }

  static const List<Map<String, dynamic>> presets = [
    // ── Ilford ──
    {
      'id': 'preset_ilford_hp5',
      'name': 'HP5+',
      'brand': 'Ilford',
      'exponent': 1.31,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_ilford_fp4',
      'name': 'FP4+',
      'brand': 'Ilford',
      'exponent': 1.26,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_ilford_delta100',
      'name': 'Delta 100',
      'brand': 'Ilford',
      'exponent': 1.26,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_ilford_delta400',
      'name': 'Delta 400',
      'brand': 'Ilford',
      'exponent': 1.41,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_ilford_delta3200',
      'name': 'Delta 3200',
      'brand': 'Ilford',
      'exponent': 1.33,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_ilford_panf',
      'name': 'Pan F+ 50',
      'brand': 'Ilford',
      'exponent': 1.33,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    // ── Kodak ──
    {
      'id': 'preset_kodak_trix',
      'name': 'Tri-X 400',
      'brand': 'Kodak',
      'exponent': 1.33,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_kodak_tmax100',
      'name': 'T-Max 100',
      'brand': 'Kodak',
      'exponent': 1.15,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_kodak_tmax400',
      'name': 'T-Max 400',
      'brand': 'Kodak',
      'exponent': 1.19,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_kodak_portra160',
      'name': 'Portra 160',
      'brand': 'Kodak',
      'exponent': 1.30,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_kodak_portra400',
      'name': 'Portra 400',
      'brand': 'Kodak',
      'exponent': 1.30,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_kodak_ektar100',
      'name': 'Ektar 100',
      'brand': 'Kodak',
      'exponent': 1.30,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_kodak_gold200',
      'name': 'Gold 200',
      'brand': 'Kodak',
      'exponent': 1.33,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_kodak_ektachrome100',
      'name': 'Ektachrome E100',
      'brand': 'Kodak',
      'exponent': 1.33,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    // ── Fuji ──
    {
      'id': 'preset_fuji_acros100ii',
      'name': 'Acros 100 II',
      'brand': 'Fuji',
      'exponent': 1.10,
      'thresholdSeconds': 120.0,
      'isPreset': true,
    },
    {
      'id': 'preset_fuji_c200',
      'name': 'C200',
      'brand': 'Fuji',
      'exponent': 1.30,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_fuji_superia400',
      'name': 'Superia 400',
      'brand': 'Fuji',
      'exponent': 1.30,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_fuji_provia100f',
      'name': 'Provia 100F',
      'brand': 'Fuji',
      'exponent': 1.25,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_fuji_velvia50',
      'name': 'Velvia 50',
      'brand': 'Fuji',
      'exponent': 1.35,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
    {
      'id': 'preset_fuji_velvia100',
      'name': 'Velvia 100',
      'brand': 'Fuji',
      'exponent': 1.30,
      'thresholdSeconds': 1.0,
      'isPreset': true,
    },
  ];
}
