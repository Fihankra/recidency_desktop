import 'dart:io';
import 'package:crypt/crypt.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AppUtils {
  static Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory
    // final Directory appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory appDocDirFolder =
        Directory('Public/$folderName/');

    if (await appDocDirFolder.exists()) {
      //if folder already exists return path
      return appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory appDocDirNewFolder =
          await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path;
    }
  }


  static String getId(){
    var id = const Uuid().v1();
    return id.hashCode.toString();
  }

  static String key = 'residency';
  static String hashPassword(String password) {
    var crypt = Crypt.sha256(password, salt: key);
    return crypt.toString();
  }

  static bool comparePassword(String password, String hash) {
    var crypt = Crypt(hash);
    return crypt.match(password);
  }
}
