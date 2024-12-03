import 'package:flutter/material.dart';
import 'package:imagerecognition/HomePage.dart';
import 'package:camera/camera.dart';
import 'my_splash_page.dart';

List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Image Recognition App',


      home: HomePage(),
    );
  }
}


