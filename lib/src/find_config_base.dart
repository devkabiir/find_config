// find_config, Copyright (C) 2018 Dinesh Ahuja <dev@kabiir.me>.
// See the included LICENSE file for more info.

import 'dart:io' show Platform;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;

/// Syncronously searches for the given [config] in user's filesystem in
/// the following order of paths and returns the first found [File]
/// reference to [config]
/// 1. [includeCwd] default `true`, find in current directory and its parents
/// 2. [includePaths] find in paths in the listed order and their parents
///    - duplicate paths are *NOT* ignored
/// 3. [includeUserDir] finally search in User directory
///
/// [config] is matched against the basename of an entity
///
/// Optionally specify [fs] to use
///
/// Optionally specify [orElse] to use when nothing found, defaults to
/// throwing an [Exception]
///
/// throws [Exception] when nothing found
File findConfigSync(
  Pattern config, {
  bool includeCwd = true,
  List<String> includePaths = const <String>[],
  bool includeUserDir = false,
  FileSystem fs = const LocalFileSystem(),
  File orElse(Pattern config),
}) {
  final searchPaths = <String>[
    includeCwd ? fs.currentDirectory.path : '',
  ]
    ..addAll(includePaths)
    ..where((s) => s.isNotEmpty);

  /// loop through all the searchPaths
  for (var searchPath in searchPaths.map(p.normalize)) {
    File test;

    test = _findInDirectorySync(config, fs.directory(searchPath));

    if (test != null) {
      return test;
    }

    final paths = p.split(searchPath)..removeLast();
    var isFound = false;

    /// loop through all the parents for each path
    final length = paths.length;
    for (var j = 0; j < length; j++) {
      test =
          test = _findInDirectorySync(config, fs.directory(p.joinAll(paths)));

      if (test != null) {
        isFound = true;
        break;
      }

      /// go to parent directory
      paths.removeLast();
    }

    if (isFound) {
      return test;
    }
  }

  /// Search in the user directory
  if (includeUserDir) {
    final userDir = fs.directory(
      p.normalize(Platform.environment.entries.firstWhere((variable) {
        final name = variable.key.toLowerCase();
        return name == 'userprofile' || name == 'home';
      },
          orElse: () => throw Exception(
              'Could not locate user directory to search for $config')).value),
    );

    final test = _findInDirectorySync(config, userDir);

    if (test != null) {
      return test;
    }
  }

  return orElse?.call(config) ?? (throw Exception('Config $config not found'));
}

File _findInDirectorySync(Pattern config, Directory dir) {
  File test;

  if (config is String) {
    test = dir.childFile(config);
    if (test.existsSync()) {
      return test;
    }
  } else {
    if (!dir.existsSync()) {
      return null;
    }

    final list = dir.listSync(followLinks: true).whereType<File>();

    if (list.isNotEmpty) {
      test = list
          .firstWhere((file) => config.matchAsPrefix(file.basename) != null);
      if (test.existsSync()) {
        return test;
      }
    }
  }

  return null;
}
