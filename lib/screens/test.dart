/* import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'paymemt_page.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                final orderId = Random().nextInt(1000).toString();
                // final orderId = "order_18482TC1GWfnEYW3gheFhy4mArfynXh";
                getAccessToken(123, orderId).then(
                  (value) {
                    if (value.isEmpty) {
                      return;
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            oderToken: value,
                            orderId: orderId,
                          ),
                        ));
                  },
                );
              },
              child: Text("Test Payment mode")),

          // production mode
          TextButton(
              onPressed: () {
                final orderId = Random().nextInt(1000).toString();
                // final orderId = "order_18482TC1GWfnEYW3gheFhy4mArfynXh";
                getAccessTokenPro(1, orderId).then(
                  (value) {
                    if (value.isEmpty) {
                      return;
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            oderToken: value,
                            orderId: orderId,
                          ),
                        ));
                  },
                );
              },
              child: Text("Production Payment Mode"))
        ],
      ),
    );
  }

  String cf_order_id = '';

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




// production mode
  Future<String> getAccessTokenPro(num amount, String orderId) async {
//     Production -> https://api.cashfree.com/pg/orders
// Sandbox -> https://sandbox.cashfree.com/pg/orders
    try {
      final uri =
          Uri.parse("https://api.cashfree.com/pg/orders"); // Correct URI
      final headers = {
        'Content-Type': 'application/json',
        'x-client-id': "66800004b8615ebd012c1fba70000866", // app ids
        //CF10212508CPM763IMML80HLA01EA0
        'x-api-version': '2023-08-01',
        'x-client-secret':
            "cfsk_ma_prod_09423c61449b22ca2750debc94640c58_25da1987", // secret client id
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



}
 */