// find_config, Copyright (C) 2018 Dinesh Ahuja <dev@kabiir.me>.
// See the included LICENSE file for more info.

import 'package:find_config/find_config.dart';

void main() {
  final pubspec = findConfig('pubspec.yaml');

  print(pubspec.readAsStringSync());
}
