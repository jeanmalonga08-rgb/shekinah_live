import 'package:url_launcher/url_launcher.dart';

abstract final class ContactLauncher {
  static Future<void> openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> openPhone(String phoneE164) async {
    final uri = Uri(scheme: 'tel', path: phoneE164);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> openWhatsApp(
    String phoneWithoutPlus, {
    String? message,
  }) async {
    final buffer = StringBuffer('https://wa.me/$phoneWithoutPlus');
    if (message != null && message.isNotEmpty) {
      buffer.write('?text=${Uri.encodeComponent(message)}');
    }
    final uri = Uri.parse(buffer.toString());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
