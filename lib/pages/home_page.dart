import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:hx_to_dec/Utils/app_loading.dart';
import 'package:hx_to_dec/models/code_model.dart';
import 'package:hx_to_dec/services/code_api_service.dart';
import 'package:hx_to_dec/services/images_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hx_to_dec/Utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'generate_code_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.cameras}) : super(key: key);
  final List<CameraDescription>? cameras;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController? controller;
  bool flashIsOn = false;
  var filteredImage = <int>[];

  @override
  void initState() {
    super.initState();
    controller =
        CameraController(widget.cameras![0], ResolutionPreset.veryHigh);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: filteredImage.isEmpty
                ? CameraPreview(controller!)
                : Container(
                    width: 900,
                    height: 600,
                    color: AppColors.purple,
                    child: PhotoView(
                        imageProvider: MemoryImage(filteredImage as dynamic)),
                  ),
          ),
          if (filteredImage.isEmpty)
            Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: (MediaQuery.of(context).size.width * 600) / 900,
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.yellow),
                      borderRadius: BorderRadius.circular(15)),
                ))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      GenerateCodePage(withCode: false, model: CodeModel())));
        },
        label: Row(
          children: [Text("Generate Code"), Icon(Icons.arrow_forward_ios)],
        ),
        backgroundColor: AppColors.yellow.withOpacity(0.5),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      bottomNavigationBar: Container(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () async {
                if (filteredImage.isEmpty) {
                  await controller!
                      .setFlashMode(flashIsOn ? FlashMode.off : FlashMode.torch)
                      .whenComplete(() => setState(() {
                            flashIsOn = !flashIsOn;
                          }));
                } else {
                  await startAllOver();
                }
              },
              child: Container(
                child: Icon(
                    filteredImage.isNotEmpty
                        ? Icons.settings_backup_restore_sharp
                        : flashIsOn
                            ? Icons.flash_on
                            : Icons.flash_off,
                    color: Colors.white),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.yellow.withOpacity(0.7)),
              ),
            ),
            if (filteredImage.isEmpty)
              GestureDetector(
                onTap: () async {
                  showLoading();
                  try {
                    XFile image = await controller!
                        .takePicture()
                        .timeout(Duration(seconds: 5));
                    await controller!.pausePreview();
                    // File? croppedImage =
                    //     await ImageServices.cropImage(image.path);
                    // File? compressedImage =
                    //     await ImageServices.compressAndGetFile(
                    //         (croppedImage!.path),
                    //         '${croppedImage.path}${DateTime.now().second.toString()}.jpg');
                    // filteredImage = await ImageServices.prepareForFilter(
                    //     compressedImage);
                    filteredImage = await ImageServices.doAll(image.path);
                    await controller!.resumePreview();
                    setState(() {});
                  } catch (_) {
                    await startAllOver();
                  }

                  closeLoading();
                },
                child: CircleAvatar(
                  child: Icon(Icons.camera_alt, color: AppColors.white),
                  backgroundColor: AppColors.yellow,
                  radius: 28,
                ),
              ),
            GestureDetector(
              onTap: () async {
                if (filteredImage.isEmpty) {
                  filteredImage = (await ImageServices.getImage())!;
                  // await controller!.pausePreview();
                  setState(() {});
                } else {
                  File file =
                      await ImageServices.saveFilteredImage(filteredImage);
                  var model = await CodeApi().readCode(file.path);
                  if (model != null) {
                    await startAllOver();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GenerateCodePage(
                                withCode: true, file: file, model: model)));
                  }
                  BotToast.showText(text: 'Error uploading the image');
                }
              },
              child: Container(
                child: Icon(filteredImage.isEmpty ? Icons.image : Icons.check,
                    color: Colors.white),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.yellow.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startAllOver() async {
    filteredImage = [];
    await controller!.dispose();
    controller =
        CameraController(widget.cameras![0], ResolutionPreset.veryHigh);
    await controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }
}
