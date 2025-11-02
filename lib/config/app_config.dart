class AppConfig {
  // True for local development, false for remote server
  static const bool useLocal = true;
  static const String localHost = 'http://10.0.2.2:8000';
  static const String remoteHost = 'http://10.1.53.58:8000';

  static String get baseHost => useLocal ? localHost : remoteHost;
  static String get apiBase => '$baseHost/api/v1';

  static String imageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseHost$path';
  }
}
