import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:hx_to_dec/Utils/app_loading.dart';
import 'package:hx_to_dec/models/code_model.dart';
import 'package:hx_to_dec/services/code_api_service.dart';
import 'package:hx_to_dec/services/images_service.dart';
import 'package:image/image.dart' as imageLib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hx_to_dec/Utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photofilters/filters/image_filters.dart';
import 'package:photofilters/filters/subfilters.dart';
import 'package:photofilters/utils/convolution_kernels.dart';

class ImageServices {
  static Future<File?> compressAndGetFile(
      String filePath, String targetPath) async {
    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: 50,
        rotate: 0,
      );
      return result;
    } catch (_) {
      BotToast.showText(text: 'Couldn\'t compress the image');
      return null;
    }
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filtered_${DateTime.now().second}');
  }

  static Future<File> saveFilteredImage(List<int> filteredImage) async {
    var imageFile = await _localFile;
    await imageFile.writeAsBytes(filteredImage);
    return imageFile;
  }

  static Future<List<int>?> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File? compressedImage = await ImageServices.compressAndGetFile(
          (pickedFile.path),
          '${pickedFile.path}${DateTime.now().second.toString()}.jpg');

      return await prepareForFilter(compressedImage ?? File(pickedFile.path));
    }
    return null;
  }

  static Future<List<int>> prepareForFilter(File? file) async {
    var customImageFilter = ImageFilter(name: "Custom Image Filter");
    var image = imageLib.decodeImage(file!.readAsBytesSync());
    imageLib.Image? usedImage = imageLib.copyResize(image!, width: 600);
    customImageFilter.subFilters = [
      ConvolutionSubFilter.fromKernel(sharpenKernel),
      // ConvolutionSubFilter.fromKernel(sharpenKernel),
    ];
    return await applyFilter(<String, dynamic>{
      "filter": customImageFilter,
      "image": usedImage,
      "filename": file.path,
    });
  }

  static Future<List<int>> applyFilter(Map<String, dynamic> params) async {
    ImageFilter? filter = params["filter"];
    imageLib.Image? image = params["image"];
    String? filename = params["filename"];
    List<int> _bytes = image!.getBytes();
    if (filter != null) {
      filter.apply(_bytes as dynamic, image.width, image.height);
    }
    imageLib.Image _image =
        imageLib.Image.fromBytes(image.width, image.height, _bytes);
    _bytes = imageLib.encodeNamedImage(_image, filename!)!;
    return _bytes;
  }
}
