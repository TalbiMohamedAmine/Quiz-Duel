// Web implementation for URL manipulation
import 'dart:js_interop';
import 'package:web/web.dart' as web;

void clearUrlParams() {
  web.window.history.replaceState(null, '', 'https://quizzly-36c08.web.app/');
}
