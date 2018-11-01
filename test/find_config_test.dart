// find_config, Copyright (C) 2018 Dinesh Ahuja <dev@kabiir.me>.
// See the included LICENSE file for more info.

import 'dart:io';

import 'package:find_config/find_config.dart';
import 'package:test/test.dart';

void main() {
  group('find config from cwd', () {
    test('returns File reference when found', () {
      expect(findConfig('pubspec.yaml'), const TypeMatcher<File>());
    });

    test('throws exception when not found', () {
      expect(() => findConfig('pubspec'), throwsException);
    });
  });

  group('find config from searchPath', () {
    final searchPath =
        '${Directory.current.path}${seperator}lib${seperator}src';

    test('returns File reference when found', () {
      expect(
          findConfig(
            'pubspec.yaml',
            includePaths: [searchPath],
            includeCwd: false,
          ),
          const TypeMatcher<File>());
    });

    test('throws exception when not found', () {
      expect(
          () => findConfig(
                'pubspec',
                includePaths: [searchPath],
                includeCwd: false,
              ),
          throwsException);
    });
  });

  group('find config from user directory', () {
    final testConfig = File(
        '${env['userprofile'] ?? env['home'] ?? env['Home'] ?? env['HOME']}${seperator}test.config');

    setUp(testConfig.createSync);
    tearDown(testConfig.deleteSync);

    test('returns File reference when found', () {
      expect(findConfig('test.config', includeUserDir: true),
          const TypeMatcher<File>());
    });

    test('throws exception when not found', () {
      expect(() => findConfig('test.config.yaml', includeUserDir: true),
          throwsException);
    });
  });
}
