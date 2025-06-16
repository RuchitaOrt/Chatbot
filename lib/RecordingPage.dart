import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AudioRecorder.dart';

class RecordingPage extends StatefulWidget {
  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _recorder.init();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      _recordedFilePath = await _recorder.stopRecording();
      setState(() {
        _isRecording = false;
      });
    } else {
      await _recorder.startRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Recorder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              onPressed: _toggleRecording,
              iconSize: 48,
              color: _isRecording ? Colors.red : Colors.blue,
            ),
            SizedBox(height: 20),
            Text(_isRecording ? 'Recording...' : 'Tap to record'),
            if (_recordedFilePath != null) ...[
              SizedBox(height: 20),
              Text('Recording saved to:'),
              Text(_recordedFilePath!),
            ],
          ],
        ),
      ),
    );
  }
}