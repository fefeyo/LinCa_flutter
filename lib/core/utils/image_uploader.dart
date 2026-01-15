import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

enum ImageQuality {
  icon,
  memory,
}

extension ImageQualityExtension on ImageQuality {
  int get quality {
    switch (this) {
      case ImageQuality.icon:
        return 75;
      case ImageQuality.memory:
        return 80;
    }
  }

  int get minWidth {
    switch (this) {
      case ImageQuality.icon:
        return 512;
      case ImageQuality.memory:
        return 1024;
    }
  }

  int get minHeight {
    switch (this) {
      case ImageQuality.icon:
        return 512;
      case ImageQuality.memory:
        return 1024;
    }
  }
}

Future<String?> pickCompressAndUploadImage({
  required String uid,
  required String uploadPath,
  required ImageQuality imageQuality,
}) async {
  try {
    // 画像を選択
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return null;
    }
    final File originalFile = File(pickedFile.path);
    // 2. 一時ディレクトリへ圧縮
    final Directory tempDir = await getTemporaryDirectory();
    final String targetPath = '${tempDir.path}/tmp.jpg';

    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalFile.path,
      targetPath,
      quality: imageQuality.quality,
      minWidth: imageQuality.minWidth,
      minHeight: imageQuality.minHeight,
    );

    if (compressedFile == null) throw Exception('Image compression failed');

    // 3. Firebase Storage にアップロード
    final Reference storageRef =
        FirebaseStorage.instance.ref().child(uploadPath);

    await storageRef.putFile(
      File(compressedFile.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    // 4. ダウンロードURLを取得
    final String downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error uploading image: $e');
    }
    return null;
  }
}
