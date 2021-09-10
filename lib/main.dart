import 'package:bot_toast/bot_toast.dart';
import 'package:hx_to_dec/pages/home_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hx_to_dec/Utils/app_colors.dart';

List<CameraDescription>? cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(new MaterialApp(
      title: "Gohexana",
      theme: ThemeData().copyWith(
          primaryColor: AppColors.purple, accentColor: AppColors.purple),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: HomePage(cameras: cameras)));
}
