import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photofilters/filters/image_filters.dart';
import 'package:photofilters/filters/subfilters.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/utils/convolution_kernels.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class ApplyAllFilters extends StatefulWidget {
  final File? imageFile;
  ApplyAllFilters({this.imageFile});
  @override
  _ApplyAllFiltersState createState() => new _ApplyAllFiltersState();
}

class _ApplyAllFiltersState extends State<ApplyAllFilters> {
  late String fileName;
  List<Filter> filters = presetFiltersList;
  final picker = ImagePicker();
  File? imageFile;
  imageLib.Image? finalImage;
  imageLib.Image? usedImage;
  String filterName = '';
  List<int> filteredImage = [];

  @override
  void initState() {
    super.initState();
    if (widget.imageFile != null) {
      imageFile = widget.imageFile;
      fileName = basename(imageFile!.path);
      var image = imageLib.decodeImage(imageFile!.readAsBytesSync());
      finalImage = imageLib.copyResize(image!, width: 600);
      filterName = 'sharpenKernel';
      customImageFilter.subFilters = [
        ConvolutionSubFilter.fromKernel(sharpenKernel)
      ];
      if (this.mounted) setState(() {});
    }
  }

  Future getImage(context) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = new File(pickedFile.path);
      fileName = basename(imageFile!.path);
      var image = imageLib.decodeImage(imageFile!.readAsBytesSync());
      finalImage = imageLib.copyResize(image!, width: 600);
      setState(() {});
      // Map imagefile = await Navigator.push(
      //   context,
      //   new MaterialPageRoute(
      //     builder: (context) => new PhotoFilterSelector(
      //       title: Text("Photo Filter Example"),
      //       image: image!,
      //       filters: presetFiltersList,
      //       filename: fileName,
      //       loader: Center(child: CircularProgressIndicator()),
      //       fit: BoxFit.contain,
      //     ),
      //   ),
      // );

      // if (imagefile != null && imagefile.containsKey('image_filtered')) {
      //   setState(() {
      //     imageFile = imagefile['image_filtered'];
      //   });
      //   print(imageFile!.path);
      // }
    }
  }

  var customImageFilter = ImageFilter(name: "Custom Image Filter");

  @override
  Widget build(BuildContext context) {
    if (finalImage != null) usedImage = finalImage!.clone();
    return Scaffold(
        appBar: AppBar(
          title: Text('Photo Filter Example'),
          actions: [
            if (filterName != '')
              IconButton(
                  onPressed: () async {
                    await WcFlutterShare.share(
                        sharePopupTitle: filterName,
                        subject: filterName,
                        text: 'filter name: $filterName',
                        fileName: 'share.png',
                        mimeType: 'image/png',
                        bytesOfFile: filteredImage);
                  },
                  icon: Icon(Icons.share))
          ],
        ),
        body: Center(
          child: Container(
              child: imageFile == null
                  ? Center(
                      child: Text('No image selected.'),
                    )
                  : FutureBuilder<List<int>>(
                      future: applyFilter(<String, dynamic>{
                        "filter": customImageFilter,
                        "image": usedImage,
                        "filename": imageFile!.path,
                      }),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<int>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return Center(child: CircularProgressIndicator());
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          case ConnectionState.done:
                            if (snapshot.hasError)
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));

                            return PhotoView(
                                imageProvider:
                                    MemoryImage(snapshot.data as dynamic));
                        }
                        // unreachable
                      },
                    )),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => getImage(context),
        //   tooltip: 'Pick Image',
        //   child: Icon(Icons.add_a_photo),
        // ),
        bottomNavigationBar: (imageFile != null)
            ? Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    InkWell(
                      child: Chip(label: Text('edgeDetectionHardKernel')),
                      onTap: () {
                        setState(() {
                          filterName = 'edgeDetectionHardKernel';
                          customImageFilter.subFilters = [
                            ConvolutionSubFilter.fromKernel(
                              edgeDetectionHardKernel,
                            )
                          ];
                        });
                      },
                    ),
                    InkWell(
                      child: Chip(label: Text('coloredEdgeDetectionKernel')),
                      onTap: () {
                        setState(() {
                          filterName = 'coloredEdgeDetectionKernel';
                          customImageFilter.subFilters = [
                            ConvolutionSubFilter.fromKernel(
                              coloredEdgeDetectionKernel,
                            )
                          ];
                        });
                      },
                    ),
                    InkWell(
                      child: Chip(label: Text('edgeDetectionMediumKernel')),
                      onTap: () {
                        filterName = 'edgeDetectionMediumKernel';
                        setState(() {
                          customImageFilter.subFilters = [
                            ConvolutionSubFilter.fromKernel(
                              edgeDetectionMediumKernel,
                            )
                          ];
                        });
                      },
                    ),
                    InkWell(
                      child: Chip(label: Text('embossKernel')),
                      onTap: () {
                        setState(() {
                          filterName = 'embossKernel';
                          customImageFilter.subFilters = [
                            ConvolutionSubFilter.fromKernel(
                              embossKernel,
                            )
                          ];
                        });
                      },
                    ),
                    InkWell(
                      child: Chip(label: Text('sharpenKernel')),
                      onTap: () {
                        setState(() {
                          filterName = 'sharpenKernel';
                          customImageFilter.subFilters = [
                            ConvolutionSubFilter.fromKernel(
                              sharpenKernel,
                            )
                          ];
                        });
                      },
                    ),
                  ],
                ),
              )
            : Container(
                height: 1,
              ));
  }

  Future<List<int>> applyFilter(Map<String, dynamic> params) async {
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
    filteredImage = _bytes;
    return _bytes;
  }
}
