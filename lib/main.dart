import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const VoiceApp());

class VoiceApp extends StatelessWidget {
  const VoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: IconButton(
            icon: const Icon(Icons.mic, size: 50),
            onPressed: _sendAudioToServer,
          ),
        ),
      ),
    );
  }

  Future<void> _sendAudioToServer() async {
    final record = AudioRecorder();
    final player = AudioPlayer();
    try {
      if (await record.hasPermission()) {
        await record.start();
        await Future.delayed(const Duration(seconds: 3));
        final path = await record.stop();

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://ВАШ_IP:8000/process'),
        );
        request.files.add(await http.MultipartFile.fromPath('audio', path!));
        var response = await request.send();

        if (response.statusCode == 200) {
          await player.play(UrlSource('http://ВАШ_IP:8000/response.mp3'));
        }
      }
    } catch (e) {
      debugPrint('Ошибка: $e');
    }
  }
}
