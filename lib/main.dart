import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return WebViewFlutterPage();
                      },
                    ),
                  );
                },
                child: const Text("webview_flutter"),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const FlutterInAppWebViewPage();
                      },
                    ),
                  );
                },
                child: const Text("flutter_inappwebview"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebViewFlutterPage extends StatelessWidget {
  final _controller = WebViewController();

  WebViewFlutterPage({super.key}) {
    _controller
      ..clearLocalStorage()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    var started = 0;

    _controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            started = DateTime.now().millisecondsSinceEpoch;
          },
          onPageFinished: (url) {
            final elapsed = DateTime.now().millisecondsSinceEpoch - started;
            final message = "Elapsed: $elapsed";
            final messenger = ScaffoldMessenger.of(context);
            if (messenger.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            } else {
              log(message);
            }
          },
        ),
      )
      ..loadRequest(_kSamplePageUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text("webview_flutter"),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

class FlutterInAppWebViewPage extends StatelessWidget {
  const FlutterInAppWebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    var started = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("flutter_inappwebview"),
      ),
      body: InAppWebView(
        onWebViewCreated: (controller) {
          controller.webStorage.localStorage.clear();
          controller.webStorage.sessionStorage.clear();
          controller.loadUrl(urlRequest: URLRequest(url: _kSamplePageUrl));
        },
        onLoadStart: (controller, url) {
          started = DateTime.now().millisecondsSinceEpoch;
        },
        onLoadStop: (controller, url) {
          final elapsed = DateTime.now().millisecondsSinceEpoch - started;
          final message = "Elapsed: $elapsed";
          final messenger = ScaffoldMessenger.of(context);
          if (messenger.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
              ),
            );
          } else {
            log(message);
          }
        },
      ),
    );
  }
}

final _kSamplePageUrl = Uri.parse(
    "https://developers.google.com/maps/documentation/javascript/examples/polyline-simple");
