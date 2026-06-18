import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  static Future<void> openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      throw Exception('URL tidak valid');
    }

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      throw Exception('Link tidak dapat dibuka');
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
