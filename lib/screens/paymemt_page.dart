import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  var cfPaymentGatewayService = CFPaymentGatewayService();
  var amountController = TextEditingController();

  String cf_order_id = '';

  @override
  void initState() {
    super.initState();
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashfree payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee_outlined),
                hintText: "Enter Amount",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: pay, child: const Text("Pay")),
          ],
        ),
      ),
    );
  }

  void verifyPayment(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful")),
    );
    print("Payment Successful");
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${errorResponse.getMessage()}")),
    );
    print(errorResponse.getMessage());
    print("Error while making payment $orderId");
  }

  CFEnvironment environment = CFEnvironment.SANDBOX; // testing  mode
  // CFEnvironment environment = CFEnvironment.PRODUCTION; // production mode
  String selectedId = "";

  pay() async {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please Enter Amount")));
      return;
    }

    final payableAmount = num.parse(amountText);
    final orderId = Random().nextInt(1000).toString();

    try {
      var sessionId = await getAccessToken(payableAmount, orderId);
      if (sessionId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to get access token")));
        print("Session id ${sessionId}");
        return;
      }

      /// Testing ke liye getAccessTokenPro ki jagah par getAccessToken kar lena

      var session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(orderId)
          .setPaymentSessionId(sessionId)
          .build();

      List<CFPaymentModes> components = <CFPaymentModes>[
        CFPaymentModes.UPI,
        CFPaymentModes.CARD,
        CFPaymentModes.NETBANKING,
        CFPaymentModes.WALLET,
        CFPaymentModes.EMI,
        CFPaymentModes.PAYLATER,
      ];
      components.add(CFPaymentModes.UPI);
      var paymentComponent =
          CFPaymentComponentBuilder().setComponents(components).build();

      var theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#FF0000")
          .setPrimaryFont("Menlo")
          .setSecondaryFont("Futura")
          .build();

      var cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(session)
          .setPaymentComponent(paymentComponent)
          .setTheme(theme)
          .build();

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } on CFException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      print("------------>> ${e.message}");
    }
  }

  // test mode

  Future<String> getAccessToken(num amount, String orderId) async {
//     Production -> https://api.cashfree.com/pg/orders
// Sandbox -> https://sandbox.cashfree.com/pg/orders
    try {
      final uri =
          Uri.parse("https://sandbox.cashfree.com/pg/orders"); // Correct URI
      final headers = {
        'Content-Type': 'application/json',
        'x-client-id': "TEST1021250856bb0392d3bff379012680521201", // app ids
        //CF10212508CPM763IMML80HLA01EA0
        'x-api-version': '2023-08-01',
        'x-client-secret':
            "cfsk_ma_test_71238110f8ebb6a9c8ee711560da0f42_7255766c", // secret client id
      };
      final body = jsonEncode({
        "order_amount": amount,
        "order_currency": "INR",
        'order_id': orderId,
        "customer_details": {
          "customer_id": "USER123",
          "customer_name": "joe",
          "customer_email": "joe.s@cashfree.com",
          "customer_phone": "+919876543210"
        },
        "order_meta": {
          "return_url": "https://b8af79f41056.eu.ngrok.io?order_id=$orderId",
        }
      });

      print("Request Headers: $headers");

      print("Request Body: $body"); // Log the request body

      final res = await http.post(uri, headers: headers, body: body);

      print("Response Status Code: ${res.statusCode}"); // Log status code
      print("Response Body: ${res.body}"); // Log response body

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);
        if (jsonResponse['order_status'] == 'ACTIVE') {
          cf_order_id = jsonResponse['cf_order_id'];
          return jsonResponse['payment_session_id'];
        } else {
          print("Error response: ${jsonResponse.toString()}");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Error: ${jsonResponse['message'] ?? 'Unknown error'}")));
        }
      } else {
        print("HTTP error: ${res.statusCode}, ${res.reasonPhrase}");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("HTTP Error: ${res.statusCode}, ${res.reasonPhrase}")));
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Exception: ${e.toString()}")));
    }

    return '';
  }

  /// production mode
  Future<String> getAccessTokenPro(num amount, String orderId) async {
    try {
      final uri = Uri.parse("https://api.cashfree.com/pg/orders");
      final headers = {
        'Content-Type': 'application/json',
        'x-client-id': "66800004b8615ebd012c1fba70000866",
        'x-api-version': '2023-08-01',
        'x-client-secret':
            "cfsk_ma_prod_09423c61449b22ca2750debc94640c58_25da1987",
      };
      final body = jsonEncode({
        "order_amount": amount,
        "order_currency": "INR",
        'order_id': orderId,
        "customer_details": {
          "customer_id": "USER123",
          "customer_name": "joe",
          "customer_email": "joe.s@cashfree.com",
          "customer_phone": "+919876543210"
        },
        "order_meta": {
          "return_url": "https://b8af79f41056.eu.ngrok.io?order_id=$orderId",
        }
      });

      final res = await http.post(uri, headers: headers, body: body);

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);
        if (jsonResponse['order_status'] == 'ACTIVE') {
          return jsonResponse['payment_session_id'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Error: ${jsonResponse['message'] ?? 'Unknown error'}")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("HTTP Error: ${res.statusCode}, ${res.reasonPhrase}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Exception: ${e.toString()}")));
    }

    return '';
  }
}
