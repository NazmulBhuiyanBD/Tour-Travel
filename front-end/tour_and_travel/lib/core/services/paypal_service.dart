import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:tour_and_travel/core/.env/config.dart';
import 'package:get/get.dart';

class PaypalService {
  static Future<bool> processPayment({
    required double amount,
    required String transactionId,
    String productName = "Booking",
  }) async {
    Completer<bool> completer = Completer<bool>();

    // Note: PayPal sandbox typically uses USD. Amount conversion can be handled here if needed.
    Get.to(() => PaypalCheckoutView(
      sandboxMode: true,
      clientId: PaypalConfig.clientId,
      secretKey: PaypalConfig.secretKey,
      transactions: [
        {
          "amount": {
            "total": amount.toStringAsFixed(2),
            "currency": "USD", 
            "details": {
              "subtotal": amount.toStringAsFixed(2),
              "shipping": '0',
              "shipping_discount": 0
            }
          },
          "description": "Payment for $productName (TXN: $transactionId)",
          "item_list": {
            "items": [
              {
                "name": productName,
                "quantity": 1,
                "price": amount.toStringAsFixed(2),
                "currency": "USD"
              }
            ],
          }
        }
      ],
      note: "Contact us for any questions on your order.",
      onSuccess: (Map params) async {
        Get.back(); // close the paypal webview
        completer.complete(true);
      },
      onError: (error) {
        Get.back();
        Get.snackbar("Error", "PayPal Error: ${error.toString()}");
        completer.complete(false);
      },
      onCancel: () {
        Get.back();
        Get.snackbar("Cancelled", "PayPal Payment Cancelled");
        completer.complete(false);
      },
    ));

    return completer.future;
  }
}
