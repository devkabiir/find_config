// find_config, Copyright (C) 2018 Dinesh Ahuja <dev@kabiir.me>.
// See the included LICENSE file for more info.

import 'dart:io' show Platform;

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:find_config/find_config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('findConfigSync', () {
    MemoryFileSystem fs;

    setUp(() => fs = MemoryFileSystem());

    group('(cwd)', () {
      test('returns File reference when found', () {
        final pubspec = fs.file('pubspec.yaml')..createSync();
        final config =
            findConfigSync(pubspec.basename, fs: fs, includeCwd: true);

        expect(config, const TypeMatcher<File>());
        expect(config.path, pubspec.path);
      });

      test('throws exception when not found', () {
        expect(() => findConfigSync('pubspec', fs: fs, includeCwd: true),
            throwsException);
      });
    });

    group('(searchPath)', () {
      test('returns File reference when found', () {
        final pubspec = fs.file(p.join('lib', 'src', 'pubspec.yaml'))
          ..createSync();

        final config = findConfigSync(pubspec.basename,
            includePaths: [p.join('lib', 'src')], includeCwd: true, fs: fs);

        expect(config, const TypeMatcher<File>());

        expect(config.path, pubspec.path);
      });

      test('throws exception when not found', () {
        expect(
            () => findConfigSync('pubspec',
                includePaths: [p.join('lib', 'src')], fs: fs, includeCwd: true),
            throwsException);
      });
    });

    group('(user directory)', () {
      test('returns File reference when found', () {
        final testConfig = fs.file(p.join(
            Platform.environment.entries
                .firstWhere((variable) => variable.key
                    .toLowerCase()
                    .contains(RegExp(r'(userprofile)|(home)')))
                .value,
            'test.config'))
          ..createSync();

        final config =
            findConfigSync('test.config', includeUserDir: true, fs: fs);
        expect(config, const TypeMatcher<File>());

        expect(config.path, testConfig.path);
      });

      test('throws exception when not found', () {
        expect(
            () => findConfigSync('test.config.yaml',
                includeUserDir: true, fs: fs),
            throwsException);
      });
    });
  });

  group('findConfig', () {});
}
