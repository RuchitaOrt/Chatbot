import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _filePath;
  bool _isInited = false;

  Future<void> init() async {
    if (_isInited) return;

    await Permission.microphone.request();
    await _recorder.openRecorder();
    _isInited = true;
  }

  void dispose() {
    _recorder.closeRecorder();
  }

  Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    print("Recording to $_filePath");

    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.aacMP4, // Produces .m4a
      sampleRate: 44100,
    );
  }

  Future<String?> stopRecording() async {
    await _recorder.stopRecorder();
    return _filePath;
  }
}
