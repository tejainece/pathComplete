// Copyright (c) 2016, Ravi Teja Gudapati. All rights reserved.

import 'package:pathCompleter/importMe.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

String getFixturesDir() {
  return Directory.current.path;
}

main() async {
  String lBaseDir = getFixturesDir();

  lBaseDir = path.join(lBaseDir, "../", "test", "fixtures", "depth1");

  print("Looking at path -> ${lBaseDir}");

  List<String> lSuggestions = await complete(lBaseDir);

  print("Path completer suggestions: ");

  for(String aSug in lSuggestions) {
    print(aSug);
  }
}
