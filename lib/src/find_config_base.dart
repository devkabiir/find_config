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
/// Optionally specify [fs] to use
///
/// throws [Exception] when nothing found
File findConfigSync(
  String config, {
  bool includeCwd = true,
  List<String> includePaths = const <String>[],
  bool includeUserDir = false,
  FileSystem fs = const LocalFileSystem(),
}) {
  final userDir = fs
      .directory(
        p.normalize(Platform.environment.entries
            .firstWhere((variable) => variable.key
                .toLowerCase()
                .contains(RegExp(r'(userprofile)|(home)')))
            .value),
      )
      .path;

  final searchPaths = <String>[
    includeCwd ? fs.currentDirectory.path : '',
  ]
    ..addAll(includePaths)
    ..where((s) => s.isNotEmpty);

  /// loop through all the searchPaths
  for (var searchPath in searchPaths.map(p.normalize)) {
    var test = fs.file(p.join(searchPath, config));

    if (test.existsSync()) {
      return test;
    }

    final paths = searchPath.split(p.separator);
    var isFound = false;

    /// loop through all the parents for each path
    final length = paths.length;
    for (var j = 0; j < length; j++) {
      test = fs.file(p.join(p.joinAll(paths), config));

      if (test.existsSync()) {
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
    final test = fs.file(p.join(userDir, config));
    if (test.existsSync()) {
      return test;
    }
  }

  throw Exception('Config $config not found');
}
