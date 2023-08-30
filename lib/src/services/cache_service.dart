import 'package:path/path.dart';

import '../models/cache_version_model.dart';
import '../models/valid_version_model.dart';
import '../utils/helpers.dart';
import 'context.dart';
import 'git_tools.dart';

/// Service to interact with FVM Cache
class CacheService {
  CacheService._();

  /// Directory where local versions are cached

  /// Returns a [CacheVersion] from a [versionName]
  static Future<CacheVersion?> getByVersionName(String versionName) async {
    final versionDir = versionCacheDir(versionName);
    // Return null if version does not exist
    if (!await versionDir.exists()) return null;

    return CacheVersion(versionName);
  }

  /// Lists Installed Flutter SDK Version
  static Future<List<CacheVersion>> getAllVersions() async {
    // Returns empty array if directory does not exist
    if (!await ctx.cacheDir.exists()) return [];

    final versions = await ctx.cacheDir.list().toList();

    final cacheVersions = <CacheVersion>[];

    for (var version in versions) {
      if (isDirectory(version.path)) {
        final name = basename(version.path);
        final cacheVersion = await getByVersionName(name);

        if (cacheVersion != null) {
          cacheVersions.add(cacheVersion);
        }
      }
    }

    cacheVersions.sort((a, b) => a.compareTo(b));

    return cacheVersions.reversed.toList();
  }

  /// Removes a Version of Flutter SDK
  static Future<void> remove(CacheVersion version) async {
    if (await version.dir.exists()) {
      await version.dir.delete(recursive: true);
    }
  }

  // Verifies that the cache version name matches the flutter version
  static Future<bool> verifyVersionMatch(CacheVersion version) async {
    // If its a channel return true
    if (version.isChannel) return true;
    return version.sdkVersion == version.name;
  }

  /// Caches version a [validVersion] and returns [CacheVersion]
  static Future<void> cacheVersion(ValidVersion validVersion) async {
    await GitTools.cloneVersion(validVersion);
  }

  /// Checks if a [validVersion] is cached correctly, and cleans up if its not
  /// Returns the cache version if its valid
  static Future<CacheVersion?> getVersionCache(
    ValidVersion validVersion,
  ) async {
    return await CacheService.getByVersionName(
      validVersion.name,
    );
  }
}
