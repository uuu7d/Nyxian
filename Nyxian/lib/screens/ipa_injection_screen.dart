import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/ipa_injector_service.dart';

class IPAInjectionScreen extends StatefulWidget {
  const IPAInjectionScreen({super.key});
  @override
  State<IPAInjectionScreen> createState() => _IPAInjectionScreenState();
}

class _IPAInjectionScreenState extends State<IPAInjectionScreen> {
  File? ipaFile;
  File? dylibFile;
  String status = 'لم تبدأ العملية بعد';

  Future<void> _startInjection() async {
    if (ipaFile == null || dylibFile == null) {
      setState(() => status = 'الرجاء اختيار الملفات');
      return;
    }

    setState(() => status = 'جاري التفكيك...');
    final extracted = await IPAInjectorService.extractIPA(ipaFile!);

    setState(() => status = 'جاري الحقن...');
    await IPAInjectorService.injectDylibIntoIPA(
        extractedIPA: extracted, dylibFile: dylibFile!);

    setState(() => status = 'جاري التجميع...');
    final output = await IPAInjectorService.repackIPA(extracted);

    setState(() => status = 'تم بنجاح! تم الحفظ في:\n${output.path}');
  }

  Future<void> _pickIPA() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['ipa']);
    if (result != null) setState(() => ipaFile = File(result.files.single.path!));
  }

  Future<void> _pickDylib() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['dylib']);
    if (result != null) setState(() => dylibFile = File(result.files.single.path!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خدمة حقن IPA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickIPA, child: const Text('اختر ملف IPA')),
            ElevatedButton(onPressed: _pickDylib, child: const Text('اختر ملف DYLIB')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _startInjection, child: const Text('ابدأ الحقن والتجميع')),
            const SizedBox(height: 16),
            Text(status, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
