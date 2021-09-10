// import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hx_to_dec/Utils/app_colors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/filters/image_filters.dart';
import 'package:photofilters/filters/subfilters.dart';
import 'package:photofilters/utils/convolution_kernels.dart';

class ImageServices {
  static Future<File?> compressAndGetFile(
      String filePath, String targetPath) async {
    try {
      print("before: " + await _getFileSize(filePath));
      var result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: 95,
        rotate: 0,
      );
      print("after: " + await _getFileSize(targetPath));
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

  static Future<File> saveFileImage(File file) async {
    final path = await _localPath;
    var imageFile = File('$path/cropped_${DateTime.now().second}.jpg');
    await imageFile.writeAsBytes(file.readAsBytesSync());
    return imageFile;
  }

  static Future<List<int>?> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return await doAll(pickedFile.path);
      // File? compressedImage = await ImageServices.compressAndGetFile(
      //     (pickedFile.path),
      //     '${pickedFile.path}${DateTime.now().second.toString()}.jpg');

      // return await prepareForFilter(compressedImage ?? File(pickedFile.path));
    }
    return [];
  }

  static Future<List<int>> doAll(String path) async {
    File? croppedImage = await ImageServices.cropImage(path);
    File? compressedImage = await ImageServices.compressAndGetFile(
        (croppedImage!.path),
        '${croppedImage.path}${DateTime.now().second.toString()}.jpg');

    return await ImageServices.prepareForFilter(compressedImage);
  }

  static Future<List<int>> prepareForFilter(File? file) async {
    var customImageFilter = ImageFilter(name: "Custom Image Filter");
    var image = imageLib.decodeImage(file!.readAsBytesSync());
    imageLib.Image? usedImage =
        imageLib.copyResize(image!, width: 900, height: 600);
    customImageFilter.subFilters = [
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

  static _getFileSize(String filepath) async {
    int decimals = 2;
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  static Future<File?> cropImage(String filePath) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: filePath,
        maxWidth: 900,
        maxHeight: 600,
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio16x9
          // CropAspectRatioPreset.square,
          // CropAspectRatioPreset.ratio3x2,
          // CropAspectRatioPreset.original,
          // CropAspectRatioPreset.ratio4x3,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop the code border',
            toolbarColor: AppColors.purple,
            toolbarWidgetColor: AppColors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    return await saveFileImage(croppedFile!);
  }
}
