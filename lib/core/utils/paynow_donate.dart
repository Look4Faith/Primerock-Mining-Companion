import 'dart:convert';

import '../constants/app_constants.dart';

/// Builds a Paynow Advanced Payment Request (custom button) URL.
/// Uses only the public Integration ID — never the Integration Key.
class PaynowDonate {
  PaynowDonate._();

  /// Unlocked amount so the donor can change it on Paynow (typical for donations).
  static String url({double? amountUsd}) {
    final override = AppConstants.paynowDonateUrlOverride.trim();
    if (override.isNotEmpty) return override;

    final parts = <String>[
      'id=${AppConstants.paynowIntegrationId}',
      if (amountUsd != null && amountUsd > 0)
        'amount=${amountUsd.toStringAsFixed(2)}',
      'l=0',
    ];
    final args = parts.join('&');
    // Paynow: Base64-encode the argument string, then URL-encode for the query.
    final b64 = base64Encode(utf8.encode(args));
    final q = Uri.encodeComponent(b64);
    return 'https://www.paynow.co.zw/payment/billpaymentlink/?q=$q';
  }
}
