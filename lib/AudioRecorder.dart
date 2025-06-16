/*
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  String? _filePath;

  Future<void> init() async {
    _recorder = FlutterSoundRecorder();

    // Request permissions
    await Permission.microphone.request();
    await Permission.storage.request();

    await _recorder!.openRecorder();
  }

  Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp3';
    print('MP3 Location: '+_filePath!);

    // Set sample rate to 48000 Hz and encode to MP3
    await _recorder!.startRecorder(
      toFile: _filePath,
      codec: Codec.mp3,
      sampleRate: 48000,
    );
  }

  Future<String?> stopRecording() async {
    await _recorder!.stopRecorder();
    return _filePath;
  }

  Future<void> dispose() async {
    await _recorder!.closeRecorder();
    _recorder = null;
  }
}*/
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  String? _filePath;

  Future<void> init() async {
    _recorder = FlutterSoundRecorder();

    // Request permissions
    await Permission.microphone.request();
    await Permission.storage.request();

    await _recorder!.openRecorder();
  }

/*
  Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp3';

    try {
      // First try MP3 at 48kHz
      await _recorder!.startRecorder(
        toFile: _filePath,
        codec: Codec.mp3,
        sampleRate: 48000,
      );
    } catch (e) {
      print('MP3 at 48kHz not supported, trying AAC at 48kHz');

      _filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
        sampleRate: 48000,
      );
    }
  }

  Future<String?> stopRecording() async {
    await _recorder!.stopRecorder();
    return _filePath;
  }
*/

  Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final tempPath = '${directory.path}/temp_recording.aac';
    _filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp3';

    // Record in AAC (widely supported)
    await _recorder!.startRecorder(
      toFile: tempPath,
      codec: Codec.aacADTS,
      sampleRate: 48000,
    );
  }

  Future<String?> stopRecording() async {
    final tempPath = await _recorder!.stopRecorder();

    // Convert to MP3 using FFmpeg
    final flutterFFmpeg = FFmpegKit();
    // await flutterFFmpeg.execute('-i $tempPath -ar 48000 -acodec libmp3lame $_filePath');

    // Delete temporary file
    File(tempPath!).delete();

    return _filePath;
  }


  Future<void> dispose() async {
    await _recorder?.closeRecorder();
    _recorder = null;
  }



  // // Check if MP3 at 48kHz is supported
  // Future<bool> isMp3At48kSupported() async {
  //   return await _recorder!.isEncoderSupported(Codec.mp3, sampleRate: 48000);
  // }
}