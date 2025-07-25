import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

Future<CroppedFile?> cropImage(File imageFile) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    uiSettings: [IOSUiSettings(title: 'Cropper')],
  );
  if (croppedFile != null) {
    // 使用裁剪后的图片，例如显示或上传等操作
    print(croppedFile.path); // 输出裁剪后的图片路径
  } else {
    print('Cancel Image Cropping.'); // 用户取消了裁剪操作
  }
  return croppedFile;
}

class FileImageEx extends FileImage {
  int fileSize = 0;

  FileImageEx(File file, {double scale = 1.0}) : super(file, scale: scale) {
    fileSize = file.lengthSync(); // 记录文件大小
    }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FileImageEx &&
            super == other &&
            fileSize == other.fileSize); // 增加文件大小比对
  }
}

  ImageProvider? dynamicGetImageProvider(String path1)
  {
    try {
      return FileImageEx(File(path1));
    } catch (e) {
      return null;
    }
  }

  ImageProvider dynamicGetImageProviderWithDefault(String path1, String path2)
  {
    try {
      return FileImageEx(File(path1));
    } catch (e) {
      return AssetImage('assets/images/$path2');
    }
  }