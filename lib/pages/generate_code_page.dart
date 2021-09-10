import 'dart:io';
import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:hx_to_dec/Utils/api_routes.dart';
import 'package:hx_to_dec/Utils/app_colors.dart';
import 'package:hx_to_dec/Utils/app_loading.dart';
import 'package:hx_to_dec/models/code_model.dart';
import 'package:flutter/material.dart';
import 'package:hx_to_dec/services/code_api_service.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

// ignore: must_be_immutable
class GenerateCodePage extends StatefulWidget {
  final File? file;
  late CodeModel? model;
  final bool withCode;
  GenerateCodePage({this.file, required this.model, this.withCode = false});

  @override
  _GenerateCodePageState createState() => _GenerateCodePageState();
}

class _GenerateCodePageState extends State<GenerateCodePage> {
  late TextEditingController controllerWidth;
  late TextEditingController controllerHeight;

  @override
  void initState() {
    controllerWidth =
        TextEditingController(text: isNotNullOrEmpty(widget.model!.x0));
    controllerHeight =
        TextEditingController(text: isNotNullOrEmpty(widget.model!.y0));
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    closeLoading();
    return Scaffold(
        backgroundColor: AppColors.purple,
        appBar: AppBar(
          title: Text(widget.withCode ? "Generated Code" : 'Generate Code'),
          elevation: 0,
          actions: [
            if (widget.file != null)
              IconButton(
                  onPressed: () async {
                    final bytes = await widget.file!.readAsBytes();
                    await WcFlutterShare.share(
                        sharePopupTitle: "Image from Gohexana",
                        subject: "Image from Gohexana",
                        text: widget.model!.toRawJson(),
                        fileName: 'Gohexana.png',
                        mimeType: 'image/png',
                        bytesOfFile: bytes.buffer.asUint8List());
                  },
                  icon: Icon(Icons.share)),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: false,
            children: [
              //image
              if (widget.file != null || widget.model!.image != null)
                Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: widget.model!.image != null
                        ? Image.network('$baseUrl${widget.model!.image}')
                        : Image.file(widget.file!)),
              Column(
                children: _buildDecSection(),
              )
            ],
          ),
        ),
        floatingActionButton: (widget.file == null)
            ? FloatingActionButton.extended(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    BotToast.showText(
                        text:
                            "Width and Height values must be between 300 and 1920",
                        contentColor: AppColors.yellow);
                  } else {
                    widget.model!.x0 = int.parse(controllerWidth.text);
                    widget.model!.y0 = int.parse(controllerHeight.text);
                    widget.model = await CodeApi().generateCode(widget.model!);
                    setState(() {});
                  }
                },
                label: Text("Generate Code"),
                backgroundColor: AppColors.yellow,
              )
            : Container());
  }

  List<Widget> _buildDecSection() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Divider(color: AppColors.yellow),
            Container(
              color: AppColors.purple,
              padding: EdgeInsets.all(8),
              child: Text(
                'Decimal',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.yellow),
              ),
            )
          ],
        ),
      ),
      Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(flex: 1, child: Container()),
          _buildTextField(controllerWidth, 'Width',
              onlyNumbers: true,
              validator: (String? e) => (e!.isEmpty ||
                      int.tryParse(e)! < 300 ||
                      int.tryParse(e)! > 1920)
                  ? "300 ~ 1920"
                  : null),
          Flexible(flex: 1, child: Container()),
          _buildTextField(controllerHeight, 'Height',
              onlyNumbers: true,
              validator: (String? e) =>
                  (e!.isEmpty || int.tryParse(e)! < 300) ? "300 ~ 1920" : null),
          Flexible(flex: 1, child: Container()),
        ],
      ),
      SizedBox(height: 20),
      Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.standardization)),
              'Standardization',
              onlyNumbers: true,
              onChanged: (e) =>
                  widget.model!.standardization = int.tryParse(e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.sector)),
              'Sector',
              onlyNumbers: true,
              onChanged: (e) => widget.model!.sector = int.tryParse(e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.timeStump)),
              'TimeStamp',
              onlyNumbers: true,
              onChanged: (e) => widget.model!.timeStump = int.tryParse(e)),
          Flexible(flex: 1, child: Container()),
        ],
      ),
      SizedBox(height: 20),
      Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.section)),
              'Section',
              onlyNumbers: true,
              onChanged: (e) => widget.model!.section = int.tryParse(e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(text: isNotNullOrEmpty(widget.model!.item)),
              'Item',
              onlyNumbers: true,
              onChanged: (e) => widget.model!.item = int.tryParse(e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.quality)),
              'Quality',
              onlyNumbers: true,
              onChanged: (e) => widget.model!.quality = int.tryParse(e)),
          Flexible(flex: 1, child: Container()),
        ],
      ),
      SizedBox(height: 20),
      Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(text: isNotNullOrEmpty(widget.model!.unit)),
              'Unit',
              onlyNumbers: true,
              onChanged: (e) => widget.model!.unit = int.tryParse(e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.validty)),
              'Validty',
              onlyNumbers: true,
              onChanged: (e) => widget.model!.validty = int.tryParse(e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.entity)),
              'Entity',
              onlyNumbers: true,
              onChanged: (e) => widget.model!.entity = int.tryParse(e)),
          Flexible(flex: 1, child: Container()),
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Divider(color: AppColors.yellow),
            Container(
              color: AppColors.purple,
              padding: EdgeInsets.all(8),
              child: Text(
                'Hexa',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.yellow),
              ),
            )
          ],
        ),
      ),
      Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.standardizationHx)),
              'Standardization',
              onChanged: (e) => widget.model!.standardizationHx = (e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.sectorHx)),
              'Sector',
              onChanged: (e) => widget.model!.sectorHx = (e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.timeStumpHx)),
              'TimeStamp',
              onChanged: (e) => widget.model!.timeStumpHx = (e)),
          Flexible(flex: 1, child: Container()),
        ],
      ),
      SizedBox(height: 20),
      Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.sectionHx)),
              'Section',
              onChanged: (e) => widget.model!.sectionHx = (e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.itemHx)),
              'Item',
              onChanged: (e) => widget.model!.itemHx = (e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.qualityHx)),
              'Quality',
              onChanged: (e) => widget.model!.qualityHx = (e)),
          Flexible(flex: 1, child: Container()),
        ],
      ),
      SizedBox(height: 20),
      Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.unitHx)),
              'Unit',
              onChanged: (e) => widget.model!.unitHx = (e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.validtyHx)),
              'Validty',
              onChanged: (e) => widget.model!.validtyHx = (e)),
          Flexible(flex: 1, child: Container()),
          _buildTextField(
              TextEditingController(
                  text: isNotNullOrEmpty(widget.model!.entityHx)),
              'Entity',
              onChanged: (e) => widget.model!.entityHx = (e)),
          Flexible(flex: 1, child: Container()),
        ],
      ),
      SizedBox(height: 30)
    ];
  }

  Widget _buildTextField(TextEditingController? controller, String label,
      {bool onlyNumbers = false, validator, Function(String)? onChanged}) {
    return Flexible(
      flex: 9,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: onlyNumbers ? TextInputType.number : TextInputType.text,
        cursorColor: Colors.white60,
        style: TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                borderSide: BorderSide(width: 1.0)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.yellow)),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent)),
            contentPadding: EdgeInsets.all(10.0),
            labelText: label,
            errorStyle: TextStyle(fontSize: 10),
            labelStyle: TextStyle(color: Colors.white70, fontSize: 13)),
      ),
    );
  }

  String isNotNullOrEmpty(t) =>
      (t == null || t == 0 || t == '') ? '0' : t.toString();
}
