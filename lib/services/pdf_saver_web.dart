import 'dart:html';
import 'package:flutter/foundation.dart';

const _kBlobMimeType = 'application/pdf';

Future<String?> savePdfToDownloads(Uint8List bytes, String filename) async {
  if (!kIsWeb) {
    throw UnsupportedError('Web PDF saver used on non-web platform.');
  }

  final blob = Blob([bytes], _kBlobMimeType);
  final url = Url.createObjectUrlFromBlob(blob);
  final anchor = AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';

  document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  Url.revokeObjectUrl(url);

  return filename;
}