import 'dart:convert';
import 'dart:io';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AppUtils {
  static Future<(bool, String?)> endCodeimage({required File image}) async {
    try {
      ImageFile input = ImageFile(
        filePath: image.path,
        rawBytes: image.readAsBytesSync(),
      );
      //if size is less than 500kb then return
      if (input.sizeInBytes < 500000) {
        var data = base64Encode(input.rawBytes);
        return Future.value((true, data));
      }
      Configuration config = const Configuration(
        outputType: ImageOutputType.webpThenJpg,
        useJpgPngNativeCompressor: false,
        // set quality between 0-100
        quality: 10,
      );
      final param = ImageFileConfiguration(input: input, config: config);
      final output = await compressor.compress(param);
      var data = base64Encode(output.rawBytes);
      return Future.value((true, data));
    } catch (_) {
      return Future.value((false, null));
    }
  }



  static String getId() {
    var id = const Uuid().v1();
    return id.hashCode.toString();
  }


}
