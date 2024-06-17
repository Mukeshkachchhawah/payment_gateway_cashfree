import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardlistener.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardwidget.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfcard.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfcardpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfnetbanking.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfnetbankingpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupi.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupipayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfupi/cfupiutils.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  final String oderToken;
  String orderId;
  PaymentPage({Key? key, required this.oderToken, required this.orderId})
      : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  var cfPaymentGatewayService = CFPaymentGatewayService();

  // CFCardWidget? cfCardWidget;

  @override
  void initState() {
    super.initState();
    // paymentSessionId = widget.oderToken;
    cfPaymentGatewayService.setCallback(verifyPayment, onError);

    final GlobalKey<CFCardWidgetState> myWidgetKey =
        GlobalKey<CFCardWidgetState>();

    CFUPIUtils().getUPIApps().then((value) {
      print("value");
      print(value);
      for (var i = 0; i < (value?.length ?? 0); i++) {
        var a = value?[i]["id"] as String ?? "";
        if (a.contains("cashfree")) {
          selectedId = value?[i]["id"];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashfree payment'),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(onPressed: pay, child: const Text("Pay")),
          ],
        ),
      ),
    );
  }

  void verifyPayment(String orderId) {
    print("Verify Payment");
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    print(errorResponse.getMessage());
    print("Error while making payment $orderId");
  }

  void cardListener(CFCardListener cardListener) {
    print("Card Listener triggered");
    print(cardListener.getNumberOfCharacters());
    print(cardListener.getType());
    print(cardListener.getMetaData());
  }

  // String orderId = "order_3242VhWIOoHkighuJbdpuhWdXE9Bsghjd";
  // String paymentSessionId = "";
  void receivedEvent(String event_name, Map<dynamic, dynamic> meta_data) {
    print(event_name);
    print(meta_data);
  }

  // String orderId = "order_18482TC1GWfnEYW3gheFhy4mArfynXh";
  // String paymentSessionId = "session_gMej8P4gvNUKLbd3fGWVw7Njg5fj3KK4We0HjCg6Tkzy5yZ8mkghdv7vKels1CJ8fBz9_aVpSoU8n5rqufVQrexzhLW0g0dzgdiTJwmrkZYn";

  // String orderId = "order_18482OupTxSofcClBAlgqyYxUVceHo8";
  // String paymentSessionId = "session_oeYlKCusKyW5pND4Swzn1rE2-gwnoM8MOC2nck9RjIiUQwXcPLWB3U1xHaaItb-uA9H1k6Fwziq9O63DWcfYGy_3B7rl1nDFo3MMeVqiYrBr";

  CFEnvironment environment = CFEnvironment.PRODUCTION;
  String selectedId = "";

  upiCollectPay() async {
    try {
      var session = createSession();
      var upi = CFUPIBuilder()
          .setChannel(CFUPIChannel.COLLECT)
          .setUPIID("suhasg6@ybl")
          .build();
      var upiPayment =
          CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
      cfPaymentGatewayService.doPayment(upiPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  netbankingPay() async {
    try {
      var session = createSession();
      var netbanking =
          CFNetbankingBuilder().setChannel("link").setBankCode(3003).build();
      var netbankingPayment = CFNetbankingPaymentBuilder()
          .setSession(session!)
          .setNetbanking(netbanking)
          .build();
      cfPaymentGatewayService.doPayment(netbankingPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  upiIntentPay() async {
    // try {
    //   cfPaymentGatewayService.setCallback(verifyPayment, onError);
    //   var session = createSession();
    //   var upi = CFUPIBuilder()
    //       .setChannel(CFUPIChannel.INTENT)
    //       .setUPIID(selectedId)
    //       .build();
    //   var upiPayment =
    //       CFUPIPaymentBuilder().setSession(session!).setUPI(upi).build();
    //   cfPaymentGatewayService.doPayment(upiPayment);
    // } on CFException catch (e) {
    //   print(e.message);
    // }
  }

  cardPay() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
      var session = createSession();
      var card = CFCardBuilder()
          .setInstrumentId("db178aff-b8cf-420e-b0ba-7af89f0d2263")
          .setCardCVV("123")
          .build();
      var cardPayment = CFCardPaymentBuilder()
          .setSession(session!)
          .setCard(card)
          .savePaymentMethod(true)
          .build();
      cfPaymentGatewayService.doPayment(cardPayment);
    } on CFException catch (e) {
      print(e.message);
    }
  }

  pay() async {
    try {
      var session = createSession();
      List<CFPaymentModes> components = <CFPaymentModes>[];
      components.add(CFPaymentModes.UPI);
      var paymentComponent =
          CFPaymentComponentBuilder().setComponents(components).build();

      var theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#FF0000")
          .setPrimaryFont("Menlo")
          .setSecondaryFont("Futura")
          .build();

      var cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(session!)
          .setPaymentComponent(paymentComponent)
          .setTheme(theme)
          .build();

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } on CFException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      print(e.message);
    }
  }

  CFSession? createSession() {
    print('widget.orderId =-- ${widget.orderId}');
    try {
      var oid = widget.orderId;
      var spi = widget.oderToken;
      var session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(oid)
          .setPaymentSessionId(spi)
          .build();
      return session;
    } on CFException catch (e) {
      print(e.message);
    }
    return null;
  }

  newPay() async {
    cfPaymentGatewayService = CFPaymentGatewayService();
    cfPaymentGatewayService.setCallback((p0) async {
      print(p0);
    }, (p0, p1) async {
      print(p0);
      print(p1);
    });
    webCheckout();
  }

  webCheckout() async {
    try {
      var session = createSession();
      var theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#ff00ff")
          .setNavigationBarTextColor("#ffffff")
          .build();
      var cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session!)
          .setTheme(theme)
          .build();
      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      print(e.message);
    }
  }
}
