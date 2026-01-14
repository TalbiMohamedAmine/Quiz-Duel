// URL service for cross-platform URL manipulation
// Uses conditional imports to handle web vs native platforms

export 'url_service_stub.dart' if (dart.library.html) 'url_service_web.dart';
