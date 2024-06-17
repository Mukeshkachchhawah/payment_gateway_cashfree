/* import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CashFirePayment extends StatefulWidget {
  const CashFirePayment({super.key});

  @override
  State<CashFirePayment> createState() => CashFirePaymentState();
}

class CashFirePaymentState extends State<CashFirePayment> {
  var amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cashfree Phone Pay"),
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton(
                onPressed: payClick,
                child: const Text("Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void payClick() {
    FocusScope.of(context).requestFocus(FocusNode());
    final amount = amountController.text.trim();

    if (amount.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please Enter Amount")));
      return;
    }

    final orderId = Random().nextInt(1000).toString();
    final payableAmount = num.parse(amount);

    getAccessToken(payableAmount, orderId).then((tokenData) {
      if (tokenData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to get access token")));
        return;
      }

      final paymentData = {
        'stage': 'PROD',
        'orderAmount': amount,
        'orderId': orderId,
        'orderCurrency': 'INR',
        'customerName': 'test',
        'customerPhone': '7296826128',
        'customerEmail': 'test2@gmail.com', // Corrected email format
        'tokenData': tokenData,
        'appId': '66800004b8615ebd012c1fba70000866',
      };

// cashfree payment function
      CashfreePGSDK.doPayment(paymentData).then((value) {
        if (value != null) {
          if (value['txStatus'] == 'SUCCESS') {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Payment Success")));
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Payment Failed")));
          }
        }
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${error.toString()}")));
    });
  }

  Future<String> getAccessToken(num amount, String orderId) async {
    try {
      final uri = Uri.parse(
          "https://api.cashfree.com/api/v2/cftoken/order"); // Correct URI
      final headers = {
        'Content-Type': 'application/json',
        'x-client-id': "66800004b8615ebd012c1fba70000866", // app ids
        'x-client-secret':
            "cfsk_ma_prod_09423c61449b22ca2750debc94640c58_25da1987", // secret client id
      };
      final body = jsonEncode({
        "orderAmount": amount,
        "orderId": orderId,
        "orderCurrency": "INR",
      });

      print("Request Headers: $headers");

      print("Request Body: $body"); // Log the request body

      final res = await http.post(uri, headers: headers, body: body);

      print("Response Status Code: ${res.statusCode}"); // Log status code
      print("Response Body: ${res.body}"); // Log response body

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);
        if (jsonResponse['status'] == 'OK') {
          return jsonResponse['cftoken'];
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