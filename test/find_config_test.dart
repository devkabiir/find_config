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

    setUp(() => fs = MemoryFileSystem(
        style: Platform.isWindows
            ? FileSystemStyle.windows
            : FileSystemStyle.posix));

    group('(cwd)', () {
      test('returns File reference when found', () {
        final pubspec = fs.file('pubspec.yaml')..createSync(recursive: true);
        final config =
            findConfigSync(pubspec.basename, fs: fs, includeCwd: true);

        expect(config, const TypeMatcher<File>());
        expect(config.absolute.path, pubspec.absolute.path);
      });

      test('returns File reference when found (pattern)', () {
        final pubspec = fs.file('pubspec.yaml')..createSync(recursive: true);
        final config =
            findConfigSync(RegExp(r'.*spec'), fs: fs, includeCwd: true);

        expect(config, const TypeMatcher<File>());
        expect(config.absolute.path, pubspec.absolute.path);
      });

      test('throws exception when not found', () {
        expect(() => findConfigSync('pubspec', fs: fs, includeCwd: true),
            throwsException);
      });
    });

    group('(searchPath)', () {
      test('returns File reference when found', () {
        final pubspec = fs.file(p.join('lib', 'src', 'pubspec.yaml'))
          ..createSync(recursive: true);

        final config = findConfigSync(pubspec.basename,
            includePaths: [p.join('lib', 'src')], includeCwd: true, fs: fs);

        expect(config, const TypeMatcher<File>());

        expect(config.absolute.path, pubspec.absolute.path);
      });

      test('returns File reference when found (pattern)', () {
        final pubspec = fs.file(p.join('lib', 'src', 'pubspec.yaml'))
          ..createSync(recursive: true);

        final config = findConfigSync(RegExp(r'.*spec'),
            includePaths: [p.join('lib', 'src')], includeCwd: true, fs: fs);

        expect(config, const TypeMatcher<File>());

        expect(config.absolute.path, pubspec.absolute.path);
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
            Platform.environment.entries.firstWhere((variable) {
              final name = variable.key.toLowerCase();
              return name == 'userprofile' || name == 'home';
            }).value,
            'test.config'))
          ..createSync(recursive: true);

        final config =
            findConfigSync('test.config', includeUserDir: true, fs: fs);
        expect(config, const TypeMatcher<File>());

        expect(config.path, testConfig.path);
      });

      test('returns File reference when found (pattern)', () {
        final testConfig = fs.file(p.join(
            Platform.environment.entries.firstWhere((variable) {
              final name = variable.key.toLowerCase();
              return name == 'userprofile' || name == 'home';
            }).value,
            'test.config'))
          ..createSync(recursive: true);

        final config =
            findConfigSync(RegExp(r'.*config'), includeUserDir: true, fs: fs);
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

    group('(orElse)', () {
      test('returns File reference when found', () {
        final pubspec = fs.file(p.join('does', 'not', 'match', 'pattern.yaml'))
          ..createSync(recursive: true);
        final config = findConfigSync(RegExp(r'.*spec'),
            fs: fs, includeCwd: true, orElse: (_) => pubspec);

        expect(config, const TypeMatcher<File>());
        expect(config.absolute.path, pubspec.absolute.path);
      });

      test('throws exception when not found', () {
        expect(
            () => findConfigSync('pubspec',
                fs: fs,
                includeCwd: true,
                orElse: (_) =>
                    throw const FileSystemException('Custom Message')),
            throwsA(const FileSystemException('Custom Message')));
      });
    });
  });

  group('findConfig', () {});
}
