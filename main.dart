import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

void main(List<String> args) async {
  ReceivePort receivePort = ReceivePort();

  final isolate2 = await Isolate.spawn(getAllUsers, receivePort.sendPort);
  final isolate1 = await Isolate.spawn(readFile, receivePort.sendPort);

  final results = await receivePort.take(2).toList();
  print(results);

  isolate1.kill();
  isolate2.kill();
}

Future<void> getAllUsers(SendPort sendPort) async {
  print("users");
  final httpClient = HttpClient();
  final request = await httpClient
      .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/users"));
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  sendPort.send(responseBody);
}

Future<void> readFile(SendPort sendPort) async {
  print("read file");
  final file = File("video.mp4");
  final readContents = await file.readAsString();
  sendPort.send(readContents);
}
