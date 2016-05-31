// Copyright (c) 2016, Ravi Teja Gudapati. All rights reserved.

import 'package:pathCompleter/importMe.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void test_complete_() {
  group('Tests completePath normal operation', () {
    test('Depth1: No base, All extensions, ', () async {
      String lBaseDir = Directory.current.path;

      lBaseDir = path.join(lBaseDir, "test/fixtures/depth1");

      List<String> lSuggestions = await complete(lBaseDir);

      expect(lSuggestions, unorderedEquals(["apple.sucks", "hello.h", "ms.rotten", "nope.m", "world.h", "."]));
    });

    test('Depth1: No base, [.h, .c] extensions', () async {
      String lBaseDir = Directory.current.path;

      lBaseDir = path.join(lBaseDir, "test/fixtures/depth1");

      List<String> lSuggestions = await complete(lBaseDir, aExt: [".h", ".c"]);

      expect(lSuggestions, unorderedEquals(["hello.h", "world.h", "."]));
    });
  });
}

void main() {
  test_complete_();
}
