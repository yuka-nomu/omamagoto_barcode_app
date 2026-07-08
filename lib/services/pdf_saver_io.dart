import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<String?> savePdfToDownloads(Uint8List bytes, String filename) async {
  Directory? dir;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    dir = await getDownloadsDirectory();
    if (dir == null) return null;
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  } else if (Platform.isAndroid) {
    dir = Directory('/storage/emulated/0/Download');
    if (!await dir.exists()) {
      dir = await getExternalStorageDirectory();
    }
  } else if (Platform.isIOS) {
    dir = await getApplicationDocumentsDirectory();
  }

  if (dir == null) return null;

  final targetDir = Directory(p.join(dir.path, 'Downloads'));
  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }

  final file = File(p.join(targetDir.path, filename));
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}