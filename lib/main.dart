import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:krava/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'buttons.dart';
import 'chart.dart';
import 'utils.dart';
import 'Test.dart';

final mqtt = MQTT();
void main() async {
  final Controller tag = Get.put(Controller());
  runApp(const MyApp());
  //test();
  //await mqtt.connect();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Krava testing',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Krava testing'),
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
  int _counter = 0;
  final Future<String> _getLocalIpAddress = getLocalIpAddress();
  final Future<bool> _connect = mqtt.connect();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<String>(
                future: _getLocalIpAddress,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  String? ip;
                  if (snapshot.hasData) {
                    ip = snapshot.data;
                  } else {
                    ip = "No IP found";
                  }
                  return Text(ip ?? "error");
                }),
            FutureBuilder<bool>(
                future: _connect,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  bool status;
                  if (snapshot.hasData) {
                    status = snapshot.data ?? false;
                  } else {
                    status = false;
                  }
                  return Icon(status ? Icons.done : Icons.cancel);
                }),
            DataChart(),
            Container(
              height: 100,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class DataChart extends StatefulWidget {
  final Controller c = Get.find();

  final DateTime initTime = DateTime.now();

  List<String> options = [
    'none',
    'lies',
    'grazes',
    'ruminates',
    'stands',
    'walks',
    'runs',
    'other',
  ];

  DataChart({super.key});

  @override
  State<DataChart> createState() => _DataChartState();
}

class _DataChartState extends State<DataChart> {
  List<SensorValue> data = [];
  int messNumber = 0;
  double windowLen = 200;

  @override
  void initState() {
    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    mqtt.client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
      setState(() {
        messNumber++;
        data.add(
            SensorValue.FromString(pt, widget.options[widget.c.num.value]));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(messNumber.toString()),
        Container(
          height: 250,
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(18),
              ),
              color: Colors.black),
          child: Chart(
              data.length > windowLen
                  ? data.sublist(
                      data.length - windowLen.toInt(), data.length - 1)
                  : data,
              widget.initTime),
        ),
        Slider(
          value: windowLen,
          min: 10,
          max: 2010,
          divisions: 50,
          label: windowLen.round().toString(),
          onChanged: (double value) {
            setState(() {
              windowLen = value;
            });
          },
        ),
        IconButton(
            onPressed: () async {
              String filepath = await getFilePath();
              final newData = data.map((e) => '${e.state},${e.line}');
              saveFile(newData.fold<String>(
                  '', (previousValue, element) => previousValue + element));
              data.clear();
            },
            icon: Icon(Icons.save)),
        Buttons(),
        Text(widget.c.num.value.toString()),
      ],
    );
  }
}
