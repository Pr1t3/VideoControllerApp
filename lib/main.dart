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
      home: IPInputPage(),
    );
  }
}

// Экран для ввода IP-адреса
class IPInputPage extends StatefulWidget {
  @override
  _IPInputPageState createState() => _IPInputPageState();
}

class _IPInputPageState extends State<IPInputPage> {
  TextEditingController _ipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Введите IP-адрес'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'IP-адрес WebSocket-сервера',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Переходим к следующей странице и передаем IP-адрес
                String ipAddress = _ipController.text.trim();
                if (ipAddress.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoControlPage(ipAddress: ipAddress),
                    ),
                  );
                } else {
                  // Показать ошибку если поле пустое
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Введите корректный IP-адрес')),
                  );
                }
              },
              child: Text('Подключиться'),
            ),
          ],
        ),
      ),
    );
  }
}

// Основной экран управления видео
class VideoControlPage extends StatefulWidget {
  final String ipAddress;

  VideoControlPage({required this.ipAddress});

  @override
  _VideoControlPageState createState() => _VideoControlPageState();
}

class _VideoControlPageState extends State<VideoControlPage> {
  WebSocketChannel? channel;
  TextEditingController _linkController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Подключаемся к WebSocket серверу по введенному IP-адресу
    connectToServer(widget.ipAddress);
  }

  void connectToServer(String ipAddress) {
    try {
      final uri = 'ws://$ipAddress:8080';
      channel = WebSocketChannel.connect(
        Uri.parse(uri),
      );
      print('Подключение к WebSocket серверу по адресу $uri');
    } catch (e) {
      print('Ошибка подключения к WebSocket: $e');
    }
  }

  void sendCommand(String command) {
    if (channel != null) {
      // Отправляем команду на сервер
      channel!.sink.add(command);
    } else {
      print('Ошибка: канал WebSocket не подключен');
    }
  }

  void sendLink() {
    String link = _linkController.text.trim();
    if (link.isNotEmpty && Uri.tryParse(link)?.hasAbsolutePath == true) {
      sendCommand('openLink:$link');  // Отправляем команду открытия ссылки через WebSocket
    } else {
      print('Ошибка: неверный формат ссылки');
    }
  }

  @override
  void dispose() {
    channel?.sink.close(status.goingAway);
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
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,  // Центрируем кнопки по горизонтали
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    sendCommand('left10');
                  },
                  child: Text('Left 10 sec'),
                ),
                SizedBox(width: 20),  // Отступ между кнопками
                ElevatedButton(
                  onPressed: () {
                    sendCommand('right10');
                  },
                  child: Text('Right 10 sec'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendCommand('toggleFullscreen');
              },
              child: Text('Toggle Fullscreen'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                labelText: 'Введите ссылку для перехода',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendLink,
              child: Text('Перейти по ссылке'),
            ),
          ],
        ),
      ),
    );
  }
}

