// Web implementation: try to use current hostname via 'window.location.host'
// Avoid importing dart:html directly to keep analyzer clean.
// We rely on const self-hosted default.
String get defaultPlatformBaseUrl => 'http://localhost:3000';
