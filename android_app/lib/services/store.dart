import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/application.dart';

class Store {
  static late Box b;
  static bool _ready = false;

  // Initialize local database
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    b = await Hive.openBox('careerai');
    _ready = true;
  }

  // Check database initialization
  static bool get isInitialized => _ready && Hive.isBoxOpen('careerai');

  // Saved resume
  static String get resume {
    if (!isInitialized) return '';

    final value = b.get('resume', defaultValue: '');

    return value is String ? value : '';
  }

  static Future<void> saveResume(String value) async {
    if (!isInitialized) {
      throw Exception('Local storage is not initialized.');
    }

    await b.put('resume', value);
  }

  // Internal backend configuration
  static String get url {
    if (!isInitialized) return 'http://10.0.2.2:8000';

    final value = b.get(
      'backend',
      defaultValue: 'http://10.0.2.2:8000',
    );

    return value is String ? value : 'http://10.0.2.2:8000';
  }

  static Future<void> saveUrl(String value) async {
    if (!isInitialized) {
      throw Exception('Local storage is not initialized.');
    }

    await b.put('backend', value);
  }

  // Application tracker
  static List<JobApplication> get jobs {
    if (!isInitialized) return [];

    final data = b.get(
      'jobs',
      defaultValue: [],
    );

    if (data is! List) return [];

    return data
        .whereType()
        .map((item) {
          try {
            return JobApplication.fromMap(
              Map<String, dynamic>.from(item),
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<JobApplication>()
        .toList();
  }

  static Future<void> saveJobs(
    List<JobApplication> applications,
  ) async {
    if (!isInitialized) {
      throw Exception('Local storage is not initialized.');
    }

    final data = applications
        .map((application) => application.toMap())
        .toList();

    await b.put('jobs', data);
  }

  // Recent activity history
  static List<String> get history {
    if (!isInitialized) return [];

    final data = b.get(
      'history',
      defaultValue: [],
    );

    if (data is! List) return [];

    return data.whereType<String>().toList();
  }

  static Future<void> log(String activity) async {
    if (!isInitialized) {
      throw Exception('Local storage is not initialized.');
    }

    final entries = history;

    entries.insert(0, activity);

    // Keep only the latest 50 activities
    if (entries.length > 50) {
      entries.removeRange(50, entries.length);
    }

    await b.put('history', entries);
  }

  // Clear recent activity
  static Future<void> clearHistory() async {
    if (!isInitialized) {
      throw Exception('Local storage is not initialized.');
    }

    await b.put('history', <String>[]);
  }
}