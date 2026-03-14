import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:new_version/screens/splash_screen.dart';

void main(){

  runApp(GetMaterialApp(
      debugShowCheckedModeBanner: false,

      home: const SplashScreen()));

}