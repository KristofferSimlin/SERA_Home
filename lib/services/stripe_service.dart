import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<void> presentPaymentSheet({
    required BuildContext context,
    String? email,
  }) async {
    final backend = dotenv.env['STRIPE_BACKEND_URL'] ?? '';
    if (backend.isEmpty) {
      throw 'STRIPE_BACKEND_URL saknas i .env (krävs för att hämta PaymentIntent).';
    }
    final uri = Uri.parse('$backend/payment-sheet');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (email != null && email.isNotEmpty) 'email': email,
      }),
    );
    if (res.statusCode >= 400) {
      throw 'Stripe backend fel ${res.statusCode}: ${res.body}';
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final clientSecret = data['paymentIntent'] as String?;
    final ephemeralKey = data['ephemeralKey'] as String?;
    final customerId = data['customer'] as String?;
    final publishable = data['publishableKey'] as String?;

    if (clientSecret == null ||
        ephemeralKey == null ||
        customerId == null ||
        publishable == null) {
      throw 'Stripe backend returnerade ofullständig payload.';
    }

    // Säkerställ att frontend har rätt publishable key (om backend skickar med).
    if (Stripe.publishableKey != publishable) {
      Stripe.publishableKey = publishable;
      await Stripe.instance.applySettings();
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'SERA',
        customerEphemeralKeySecret: ephemeralKey,
        customerId: customerId,
        applePay: const PaymentSheetApplePay(merchantCountryCode: 'SE'),
        googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'SE'),
        style: ThemeMode.dark,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }

  Future<void> startCheckoutSession({
    required BuildContext context,
    String? email,
    String? priceId,
  }) async {
    final backend = dotenv.env['STRIPE_BACKEND_URL'] ?? '';
    if (backend.isEmpty) {
      throw 'STRIPE_BACKEND_URL saknas i .env (krävs för att skapa Checkout Session).';
    }
    final resolvedPrice = priceId ?? dotenv.env['STRIPE_PRICE_ID'];
    if (resolvedPrice == null || resolvedPrice.isEmpty) {
      throw 'STRIPE_PRICE_ID saknas (ange i .env eller skicka in som argument).';
    }
    final successUrl =
        dotenv.env['STRIPE_SUCCESS_URL'] ?? 'https://sera.chat/success';
    final cancelUrl =
        dotenv.env['STRIPE_CANCEL_URL'] ?? 'https://sera.chat/cancel';

    final uri = Uri.parse('$backend/stripe');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'priceId': resolvedPrice,
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
        if (email != null && email.isNotEmpty) 'email': email,
      }),
    );
    if (res.statusCode >= 400) {
      throw 'Stripe backend fel ${res.statusCode}: ${res.body}';
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = (data['url'] ?? data['checkoutUrl'] ?? data['sessionUrl'])
        as String?;
    if (url == null || url.isEmpty) {
      throw 'Stripe backend returnerade ingen checkout-url.';
    }
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      throw 'Kunde inte öppna checkout-url: $url';
    }
  }
}
