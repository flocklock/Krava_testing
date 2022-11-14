import 'dart:ffi';
import 'dart:io';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getLocalIpAddress() async {
  final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4, includeLinkLocal: true);

  try {
    // Try VPN connection first
    NetworkInterface vpnInterface =
        interfaces.firstWhere((element) => element.name == "tun0");
    return vpnInterface.addresses.first.address;
  } on StateError {
    // Try wlan connection next
    try {
      NetworkInterface interface = interfaces
          .firstWhere((element) => element.name.contains(RegExp("wlan0")));
      return interface.addresses.first.address;
    } catch (ex) {
      // Try any other connection next
      try {
        NetworkInterface interface = interfaces.firstWhere(
            (element) => !(element.name == "tun0" || element.name == "wlan0"));
        return interface.addresses.first.address;
      } catch (ex) {
        return "error";
      }
    }
  }
}

class SensorValue {
  int time = 0;
  double x = 0;
  double y = 0;
  double z = 0;
  String line = 'empty';
  String state = "NONE";

  SensorValue(this.time, this.x, this.y, this.z);
  SensorValue.FromString(String input, String state) {
    final items = input.split(',');
    this.time = int.parse(items[0]);
    this.x = double.parse(items[1]);
    this.y = double.parse(items[2]);
    this.z = double.parse(items[3]);
    this.line = input;
    this.state = state;
  }
}

Future<String> getFilePath() async {
  Directory? appDocumentsDirectory =
      //await getApplicationDocumentsDirectory(); // 1
      await getExternalStorageDirectory();
  String? appDocumentsPath = appDocumentsDirectory?.path; // 2
  String filePath = '$appDocumentsPath/data' +
      DateTime.now().hour.toString() +
      '_' +
      DateTime.now().minute.toString() +
      '_' +
      DateTime.now().second.toString(); // 3

  return filePath;
}

void saveFile(String str) async {
  File file = File(await getFilePath()); // 1
  file.writeAsString(str + '\n', mode: FileMode.append); // 2
}

void readFile() async {
  File file = File(await getFilePath()); // 1
  String fileContent = await file.readAsString(); // 2

  print('File Content: $fileContent');
}

class Controller extends GetxController {
  var num = 0.obs;
  change(var x) => num = x;
}
