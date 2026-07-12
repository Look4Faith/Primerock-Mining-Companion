import 'package:url_launcher/url_launcher.dart';

import '../core/errors/app_failure.dart';

class ContactLauncher {
  static Future<void> phone(String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(' ', ''));
    await _launch(uri);
  }

  static Future<void> email(String email, {String subject = 'Primerock enquiry'}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject},
    );
    await _launch(uri);
  }

  static Future<void> whatsapp(String number, {String message = 'Hello Primerock Solutions'}) async {
    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse(
      'https://wa.me/${cleaned.replaceFirst('+', '')}?text=${Uri.encodeComponent(message)}',
    );
    await _launch(uri);
  }

  static Future<void> openMaps(String query) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    await _launch(uri);
  }

  static Future<void> _launch(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) throw AppFailure('Could not open $uri');
  }
}
