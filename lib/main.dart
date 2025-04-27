import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double base = 90;
  double shoulder = 90;
  double elbow = 90;
  double gripper = 90;

  Timer? _debounce;
  final String esp32Url = 'http://192.168.4.1'; // Ganti dengan IP ESP32-mu

  void _onSliderChange() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      sendServoPositions(
        base: base,
        shoulder: shoulder,
        elbow: elbow,
        gripper: gripper,
      );
    });
  }

  Future<void> sendServoPositions({
    required double base,
    required double shoulder,
    required double elbow,
    required double gripper,
  }) async {
    final uri = Uri.parse(
      'http://192.168.4.1/servo?base=$base&shoulder=$shoulder&elbow=$elbow&gripper=$gripper',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print('✅ Servo update success: ${response.body}');
      } else {
        print('❌ Failed with status: ${response}');
      }
    } catch (e) {
      print('⚠️ Error during request: $e');
    }
  }

  Widget buildSlider(
      String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toInt()}°', style: TextStyle(fontSize: 16)),
        Slider(
          min: 0,
          max: 180,
          divisions: 180,
          value: value,
          onChanged: (val) {
            onChanged(val);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kontrol Robot Arm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildSlider('Base', base, (val) {
              setState(() => base = val);
              _onSliderChange();
            }),
            buildSlider('Shoulder', shoulder, (val) {
              setState(() => shoulder = val);
              _onSliderChange();
            }),
            buildSlider('Elbow', elbow, (val) {
              setState(() => elbow = val);
              _onSliderChange();
            }),
            buildSlider('Gripper', gripper, (val) {
              setState(() => gripper = val);
              _onSliderChange();
            }),
          ],
        ),
      ),
    );
  }
}
