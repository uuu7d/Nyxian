import 'package:flutter/material.dart';

class TerminalInjectionView extends StatefulWidget {
  const TerminalInjectionView({super.key});

  @override
  State<TerminalInjectionView> createState() => _TerminalInjectionViewState();
}

class _TerminalInjectionViewState extends State<TerminalInjectionView> {
  String _terminalOutput = "🔥 Nyxian IPA Injector Ready...\n";
  bool _isProcessing = false;

  void _startInjectionProcess() async {
    setState(() {
      _isProcessing = true;
      _terminalOutput += "\n📦 Step 1: Selecting IPA...";
    });

    // محاكاة اختيار وتفكيك وحقن وتجميع الملف
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _terminalOutput += "\n🔍 Step 2: Extracting executable and @rpath...";
    });

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _terminalOutput += "\n🧬 Step 3: Injecting dylib...";
    });

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _terminalOutput += "\n📦 Step 4: Rebuilding IPA...";
    });

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _terminalOutput += "\n✅ Injection Complete! IPA saved to Files.";
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IPA Injection Tool')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Text(
                    _terminalOutput,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text("Start Injection"),
              onPressed: _isProcessing ? null : _startInjectionProcess,
            ),
          ],
        ),
      ),
    );
  }
}