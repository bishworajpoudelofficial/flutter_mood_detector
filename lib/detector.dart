import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class PersonMood extends StatefulWidget {
  const PersonMood({Key? key}) : super(key: key);

  @override
  _PersonMoodState createState() => _PersonMoodState();
}

class _PersonMoodState extends State<PersonMood> {
  String pathOfImage = "";
  String moodImagePath = "";
  String moodDetail = "";
  bool isVisible = false;

  FaceDetector detector = GoogleMlKit.vision.faceDetector(
    const FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
    ),
  );

  @override
  void dispose() {
    super.dispose();
    detector.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Machine Learning Mood Detector"),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                const SizedBox(
                height: 20,
              ),
              Image.asset(
                "assets/mood.png",
                height: 100,
                width: 100,
              ),
              const SizedBox(
                height: 50,
              ),
              Visibility(
                visible: isVisible,
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset(
                    moodImagePath,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Visibility(
                visible: isVisible,
                child: Text(
                  "Person Mood is $moodDetail",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () async {
                    pickImage();
                    Future.delayed(const Duration(seconds: 7), () {
                      extractData(pathOfImage);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                        color: Colors.green,
                    ),
                  
                    height: 50,
                    child: const Center(
                      child: Text(
                        "Choose Picture",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      pathOfImage = image!.path;
    });
  }

  void extractData(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    List<Face> faces = await detector.processImage(inputImage);

    if (faces.isNotEmpty && faces[0].smilingProbability != null) {
      double? prob = faces[0].smilingProbability;

      if (prob! > 0.8) {
        setState(() {
          moodDetail = "Happy";
          moodImagePath = "assets/happy.png";
        });
      } else if (prob > 0.3 && prob < 0.8) {
        setState(() {
          moodDetail = "Normal";
          moodImagePath = "assets/meh.png";
        });
      } else if (prob > 0.06152385 && prob < 0.3) {
        setState(() {
          moodDetail = "Sad";
          moodImagePath = "assets/sad.png";
        });
      } else {
        setState(() {
          moodDetail = "Angry";
          moodImagePath = "assets/angry.png";
        });
      }
      setState(() {
        isVisible = true;
      });
    }
  }
}
