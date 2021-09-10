import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hx_to_dec/Utils/app_colors.dart';

showLoading() {
  BotToast.showCustomLoading(
      toastBuilder: (_) {
        return Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Platform.isAndroid
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow))
                : CupertinoActivityIndicator());
      },
      clickClose: true);
}

closeLoading() {
  BotToast.closeAllLoading();
}
