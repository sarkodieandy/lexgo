import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createPlatformHttpClient() {
  final ioClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 30)
    ..idleTimeout = const Duration(seconds: 30)
    ..userAgent = 'LexGo/1.0 (Windows; Flutter)';

  // In debug builds, accept all certificates to work around
  // Windows SChannel TLS negotiation issues with some servers.
  if (kDebugMode) {
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  }

  return IOClient(ioClient);
}

