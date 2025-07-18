import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class IPAInjectorService {
  static Future<Directory> extractIPA(File ipaFile) async {
    final tempDir = await getTemporaryDirectory();
    final archive = ZipDecoder().decodeBytes(await ipaFile.readAsBytes());
    final extracted = Directory(p.join(tempDir.path, 'extracted_ipa'));
    if (extracted.existsSync()) extracted.deleteSync(recursive: true);
    extracted.createSync();

    for (final file in archive) {
      final filePath = p.join(extracted.path, file.name);
      if (file.isFile) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(filePath).createSync(recursive: true);
      }
    }

    return extracted;
  }

  static Future<void> injectDylibIntoIPA({
    required Directory extractedIPA,
    required File dylibFile,
  }) async {
    final payloadDir = Directory('${extractedIPA.path}/Payload');
    final appDirs = payloadDir.listSync().whereType<Directory>().toList();
    if (appDirs.isEmpty) throw Exception('App bundle not found.');
    final appDir = appDirs.first;
    final targetPath = p.join(appDir.path, p.basename(dylibFile.path));
    await dylibFile.copy(targetPath);
  }

  static Future<File> repackIPA(Directory extractedIPA) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = p.join(tempDir.path, 'output.ipa');
    final encoder = ZipFileEncoder();
    encoder.create(outputPath);

    void addDir(Directory dir, String basePath) {
      for (final entity in dir.listSync(recursive: true)) {
        final relative = p.relative(entity.path, from: basePath);
        if (entity is File) encoder.addFile(entity, relative);
      }
    }

    addDir(extractedIPA, extractedIPA.path);
    encoder.close();
    return File(outputPath);
  }
}
