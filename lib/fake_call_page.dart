import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class FakeCallPage extends StatefulWidget {
  const FakeCallPage({super.key});

  @override
  State<FakeCallPage> createState() => _FakeCallPageState();
}

class _FakeCallPageState extends State<FakeCallPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _callAnswered = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _playRingtone();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _playRingtone() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('ringtone.mp3'));
  }

  Future<void> _stopRingtone() async {
    await _audioPlayer.stop();
  }

  Future<void> _speakFakeVoice() async {
    await _flutterTts.speak("Hey! Just calling to check on you. Are you okay?");
  }

  void _answerCall() {
    setState(() => _callAnswered = true);
    _stopRingtone();
    _speakFakeVoice();
  }

  void _endCall() {
    _flutterTts.stop();
    Navigator.pop(context);
  }

  void _declineCall() {
    _stopRingtone();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _stopRingtone();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/avatar.png', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Baby Dukie",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _callAnswered ? "Call in progress..." : "Incoming call...",
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _callAnswered
                    ? _buildEndCallButton()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: Icons.call_end,
                      color: Colors.red,
                      label: "Decline",
                      onTap: _declineCall,
                    ),
                    _buildActionButton(
                      icon: Icons.call,
                      color: Colors.green,
                      label: "Answer",
                      onTap: _answerCall,
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEndCallButton() {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: _endCall,
          backgroundColor: Colors.red,
          child: const Icon(Icons.call_end, size: 28, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text("End Call", style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: onTap,
          backgroundColor: color,
          child: Icon(icon, size: 28, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
