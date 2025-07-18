import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class IPAInjectorService {
  /// يفك ملف IPA إلى مجلد مؤقت
  static Future<Directory> extractIPA(File ipaFile) async {
    final tempDir = await getTemporaryDirectory();
    final ipaBytes = ipaFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(ipaBytes);

    final ipaExtractedDir = Directory(p.join(tempDir.path, 'extracted_ipa'));
    if (ipaExtractedDir.existsSync()) {
      ipaExtractedDir.deleteSync(recursive: true);
    }
    ipaExtractedDir.createSync();

    for (final file in archive) {
      final filePath = p.join(ipaExtractedDir.path, file.name);
      if (file.isFile) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(filePath).createSync(recursive: true);
      }
    }

    return ipaExtractedDir;
  }
}