// find_config, Copyright (C) 2018 Dinesh Ahuja <dev@kabiir.me>.
// See the included LICENSE file for more info.

import 'dart:io';

/// shorthand for `Platform.environment`
Map<String, String> get env => Platform.environment;

/// shorthand for `Platform.pathSeparator`
String get seperator => Platform.pathSeparator;

/// Syncronously searches for the given [config] in user's filesystem in
/// the following order of paths and returns the first found [File]
/// reference to [config]
/// 1. [includeCwd] default `true`, find in current directory and its parents
/// 2. [includePaths] find in paths in the listed order and their parents
///    - duplicate paths are *NOT* ignored
/// 3. [includeUserDir] finally search in User directory
///
/// throws [Exception] when nothing found
File findConfig(
  String config, {
  bool includeCwd = true,
  List<String> includePaths = const <String>[],
  bool includeUserDir = false,
}) {
  final userDir = Directory(
    env['userprofile'] ?? env['home'] ?? env['Home'] ?? env['HOME'],
  ).path;

  final searchPaths = <String>[
    includeCwd ? Directory.current.path : '',
  ]
    ..addAll(includePaths)
    ..where((s) => s.isNotEmpty);

  // loop through all the searchPaths
  for (var searchPath in searchPaths) {
    final paths = searchPath.split(seperator);
    var isFound = false;
    File test;

    // loop through all the parents for each path
    final length = paths.length;
    for (var j = 0; j < length; j++) {
      test = File('${paths.join(seperator)}$seperator$config');

      if (test.existsSync()) {
        isFound = true;
        break;
      }

      // go to parent directory
      paths.removeLast();
    }

    if (isFound) {
      return test;
    }
  }

  // Search in the user directory
  if (includeUserDir) {
    final test = File('$userDir$seperator$config');
    if (test.existsSync()) {
      return test;
    }
  }

  throw Exception('Config $config not found');
}
