import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoControlPage(),
    );
  }
}

class VideoControlPage extends StatefulWidget {
  @override
  _VideoControlPageState createState() => _VideoControlPageState();
}

class _VideoControlPageState extends State<VideoControlPage> {
  // Подключаемся к WebSocket серверу
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080'), // Адрес вашего WebSocket-сервера
  );

  void sendCommand(String command) {
    // Отправляем команду на сервер
    channel.sink.add(command);
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Controller'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                sendCommand('play');
              },
              child: Text('Play'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendCommand('pause');
              },
              child: Text('Pause'),
            ),
          ],
        ),
      ),
    );
  }
}
