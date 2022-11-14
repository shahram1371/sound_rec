import 'package:flutter/material.dart';
import 'package:tflite_audio/tflite_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _sound = "Press the button to start";
  bool _recording = false;
  late Stream<Map<dynamic, dynamic>> result;
  int inferenceTime = 0;
  bool ckeckValue = true;

  ///
  String text = '';
  late stt.SpeechToText _speechToText;
  // var _localeId = 'en-US';
  // var _localeId = 'fa-IR';
  String lang = 'en';
  bool _isListening = false;
  double confidence = 1.0;
  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    TfliteAudio.loadModel(
      inputType: 'rawAudio',
      model: 'assets/soundclassifier_with_metadata.tflite',
      label: 'assets/labels.txt',
      outputRawScores: false,
      numThreads: 1,
      isAsset: true,
    );

    _recorder();
  }

  Future<void> _listen() async {
    // if (!_isListening) {
    final bool hasSpeech = await _speechToText.initialize(
        // onStatus: (status) => log('onStatus$status'),
        // onError: (errorNotification) => log('onError$errorNotification'),
        );

    if (hasSpeech) {
      String localeId = Locale.fromSubtags(languageCode: lang).languageCode;
      setState(() => _isListening = true);
      _speechToText.listen(
        localeId: localeId,
        onResult: (result) => setState(() {
          text = result.recognizedWords;
          // _recorder();
          print('text is $text');
          // _speechToText.stop();
          // _recorder();
        }),
      );
    } else {
      setState(() => _isListening = true);
      _speechToText.stop();
      _recorder();
    }
    setState(() {
      _isListening = false;
    });
    await Future.delayed(const Duration(seconds: 3)).then((value) {
      _speechToText.stop();
      _recorder();
      setState(() {
        _isListening = true;
      });
    });
  }

  void _recorder() {
    String recognition = "";
    // if (!_recording) {
    setState(() => _recording = true);
    result = TfliteAudio.startAudioRecognition(
        detectionThreshold: 0.5,
        sampleRate: 44100,
        bufferSize: 22016,
        numOfInferences: 2);

    result.listen((event) {
      recognition = event["recognitionResult"];
    }).onDone(() {
      setState(() {
        _recording = false;
        _sound = recognition.split(" ")[1];
        print(_sound);
        _listen();
        // if (_sound == 'Hello') {

        // }
      });
      // _recorder();
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "What's this sound?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              Column(
                children: [
                  MaterialButton(
                    onPressed: _recorder,
                    color: !_isListening ? Colors.green : Colors.pink,
                    textColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(25),
                    child: const Icon(Icons.mic, size: 60),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  !_isListening ? const Text('please speak') : Container()
                ],
              ),
              Text(
                text,
                style: Theme.of(context).textTheme.headline5,
              ),
              ListView(
                shrinkWrap: true,
                children: [
                  TextButton(
                    onPressed: () {
                      lang = 'en';
                      setState(() {
                        ckeckValue = true;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'English',
                          style: TextStyle(color: Colors.white),
                        ),
                        Checkbox(value: ckeckValue, onChanged: (value) {}),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      lang = 'fa';
                      setState(() {
                        ckeckValue = false;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Persian',
                          style: TextStyle(color: Colors.white),
                        ),
                        Checkbox(value: !ckeckValue, onChanged: (value) {}),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}



///due to train
// import 'package:flutter/material.dart';
// import 'package:tflite_audio/tflite_audio.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData.dark(),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   MyHomePageState createState() => MyHomePageState();
// }

// class MyHomePageState extends State<MyHomePage> {
//   String _sound = "Press the button to start";
//   bool _recording = false;
//   late Stream<Map<dynamic, dynamic>> result;
//   int inferenceTime = 0;
//   @override
//   void initState() {
//     super.initState();
//     TfliteAudio.loadModel(
//       inputType: 'rawAudio',
//       model: 'assets/soundclassifier_with_metadata.tflite',
//       label: 'assets/labels.txt',
//       outputRawScores: false,
//       numThreads: 1,
//       isAsset: true,
//     );
//     _recorder();
//   }

//   void _recorder() {
//     String recognition = "";
//     // if (!_recording) {
//     setState(() => _recording = true);
//     result = TfliteAudio.startAudioRecognition(
//         detectionThreshold: 0.5,
//         sampleRate: 44100,
//         bufferSize: 22016,
//         numOfInferences: 2);

//     result.listen((event) {
//       recognition = event["recognitionResult"];
//     }).onDone(() {
//       setState(() {
//         _recording = false;
//         _sound = recognition.split(" ")[1];
//         print(_sound);
//         // if (_sound == 'Hello') {

//         // }
//       });
//       _recorder();
//     });
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/background.jpg"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 child: const Text(
//                   "What's this sound?",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 60,
//                     fontWeight: FontWeight.w200,
//                   ),
//                 ),
//               ),
//               MaterialButton(
//                 onPressed: _recorder,
//                 color: _recording ? Colors.grey : Colors.pink,
//                 textColor: Colors.white,
//                 shape: const CircleBorder(),
//                 padding: const EdgeInsets.all(25),
//                 child: const Icon(Icons.mic, size: 60),
//               ),
//               Text(
//                 _sound,
//                 style: Theme.of(context).textTheme.headline5,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
