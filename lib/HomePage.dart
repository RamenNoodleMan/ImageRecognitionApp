import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:imagerecognition/main.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  bool isWorking = false;
  String result="";
  late CameraController cameraController;
  CameraImage? imgCamera;

  loadModel() async
  {
    await Tflite.loadModel(model: "assets/mobilenet_v1_1.0_224.tflite",
    labels: "assets/mobilenet_v1_1.0_224.txt"
    );
  }

  initCamera()
  {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value)
    {
      if(!mounted){
        return;
      }

      setState(() {
        cameraController.startImageStream((imagesFromStream) =>
        {
          if(!isWorking)
            {
            isWorking = true, 
              imgCamera = imagesFromStream,
              runModelOnStreamFrames(),
            
            }
        });
      });
    });
  }

  runModelOnStreamFrames() async
  {
  if(imgCamera != null)
    {
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: imgCamera!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
              imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
          );
      result ="";

      recognitions!.forEach((response)
      {
        result += response["label"]+ " " + (response["confidence"] as double).toStringAsFixed(2) + "\n\n";
      }
      );

      setState(() {
        result;
      });

      isWorking = false;
    }
  }
  
  @override
  void initState(){
    //TODO: implement iniState
    super.initState();

    loadModel();

  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:SafeArea(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image2.jpg")
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                        child: Container(
                            color: Colors.blueGrey,
                            height: 400,
                            width: 400,
                            child: Image.asset("assets/image1.jpg")
                        )
                    ),
                    Center(
                      child: TextButton(
                        onPressed: (){
                          initCamera();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 35),
                          height: 270,
                          width: 360,
                          child: Center(
                            child: imgCamera == null
                                ? Container(
                              height: 270,
                              width: 360,
                              child: const Icon(Icons.camera_front, color: Colors.blueAccent, size: 40),
                            )
                                : AspectRatio(
                              aspectRatio: cameraController.value.aspectRatio,
                              child: CameraPreview(cameraController),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 55.0),
                    child: SingleChildScrollView(
                      child: Text(
                        result,
                        style: const TextStyle(
                          backgroundColor: Colors.black,
                          fontSize: 30.0,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      )
                      ,
                    )
                  )
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
