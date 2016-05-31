// Copyright (c) 2016, Ravi Teja Gudapati. All rights reserved.

library pathCompleter.src;

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;

typedef Future<FileStatReturn> PathExistsFunctio(String aPath);

class FileStatReturn {
  final bool found;

  final FileStat stat;

  FileStatReturn(this.found, this.stat);

  const FileStatReturn.Invalid()
      : found = false,
        stat = null;
}

Future<FileStatReturn> getFileStat(String aPath, {Function aFunc}) async {
  if (aFunc == null) {
    FileStat bStat = await FileStat.stat(aPath);
    if (bStat.type == FileSystemEntityType.NOT_FOUND) {
      return const FileStatReturn.Invalid();
    }
    return new FileStatReturn(true, bStat);
  }

  if (aFunc is! PathExistsFunctio) {
    return const FileStatReturn.Invalid();
  }

  return await aFunc(aPath);
}

Future<List<String>> getAllChildren(String aPath,
    {bool aAddBase: false,
    bool aIncDirs: true,
    List<String> aExt: null}) async {
  Directory lDir = new Directory(aPath);
  Stream<FileSystemEntity> lRec = lDir.list(recursive: true);

  List<String> lRet = [];
  await for (FileSystemEntity lChild in lRec) {
    FileSystemEntityType bTyp = await FileSystemEntity.type(lChild.path);
    if (bTyp == FileSystemEntityType.NOT_FOUND) {
      continue;
    } else if (bTyp == FileSystemEntityType.FILE) {
      if (aExt != null) {
        //TODO can we handle multiple extensions like ".tar.gz"
        String bExt = path.extension(lChild.path);
        if (!aExt.any((String aItem) => aItem == bExt)) {
          continue;
        }
      }
    } else if (bTyp == FileSystemEntityType.DIRECTORY) {
      if (!aIncDirs) {
        continue;
      }
    } else if (bTyp == FileSystemEntityType.LINK) {
      //TODO
    }

    if (aAddBase) {
      lRet.add(lChild.path);
    } else {
      lRet.add(path.relative(lChild.path, from: aPath));
    }
  }

  return lRet;
}

Future<List<String>> complete(String aPath,
    {Function aFunc,
    bool aAddBase: false,
    bool aIncDirs: true,
    List<String> aExt: null}) async {
  //Normalize base path
  String lPath = path.normalize(aPath);

  //Is absolute path?
  if (!path.isAbsolute(lPath)) {
    return [];
  }

  FileStatReturn lStatRec = await getFileStat(lPath);

  //Check if the path exists
  if (lStatRec.found == false || lStatRec.stat == null) {
    return [];
  }

  FileStat lStat = lStatRec.stat;
  if (lStat.type == FileSystemEntityType.DIRECTORY) {
    List<String> bRet =
        await getAllChildren(aPath, aIncDirs: aIncDirs, aExt: aExt);
    if (aIncDirs) {
      if (aAddBase) {
        bRet.add(lPath);
      } else {
        bRet.add(path.relative(lPath, from: lPath));
      }
    }
    return bRet;
  } else if (lStat.type == FileSystemEntityType.FILE) {
    List<String> bRet = [];

    if (aExt != null) {
      //TODO can we handle multiple extensions like ".tar.gz"
      String bExt = path.extension(lPath);
      if (aExt.any((String aItem) => aItem == bExt)) {
        if (aAddBase) {
          bRet.add(lPath);
        } else {
          bRet.add(path.relative(lPath, from: lPath));
        }
      }
    }

    return bRet;
  } else if (lStat.type == FileSystemEntityType.LINK) {
    //TODO
    return [];
  }

  return [];
}

/// completePathOneBase a list of possible paths that complete given prefix and base directory
Future<List<String>> completeBase(String aBase, String aPrefix,
    {bool aAddBase: false,
    bool aIncDirs: true,
    List<String> aExt: null}) async {
  //Get lookup bath
  String lLook = path.join(aBase, aPrefix);

  //Find all the possible combinations
  //TODO add prefix
  return await complete(lLook,
      aAddBase: aAddBase, aIncDirs: aIncDirs, aExt: aExt);
}

/// Returns a list of possible paths that complete given prefix and base directory
Future<List<String>> completeBases(List<String> aBaseDirs, String aPrefix,
    {bool aAddBase: false,
    bool aIncDirs: true,
    List<String> aExt: null}) async {
  List<String> lRet = [];
  for (String cBase in aBaseDirs) {
    List<String> bPaths = await completeBase(cBase, aPrefix,
        aAddBase: aAddBase, aIncDirs: aIncDirs, aExt: aExt);
    lRet.addAll(bPaths);
  }

  return lRet;
}
