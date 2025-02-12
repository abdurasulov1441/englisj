import 'package:shared_preferences/shared_preferences.dart';

import 'cache/cache.dart';
import 'cache/prefs_cache.dart';

Future<void> initializeCache() async {
  cache = PrefsCache(await SharedPreferences.getInstance());
}

late final Cache cache;
