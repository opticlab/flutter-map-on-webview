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

class WebViewFlutterPage extends StatefulWidget {
  const WebViewFlutterPage({super.key});

  @override
  State<WebViewFlutterPage> createState() => _WebViewFlutterPageState();
}

class _WebViewFlutterPageState extends State<WebViewFlutterPage> {
  late final WebViewController _controller;
  var _isLoading = false;
  var _started = -1;

  final _measure = Measure<int>();

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            _isLoading = true;
          });

          log(url);

          final messenger = ScaffoldMessenger.of(context);
          if (messenger.mounted) {
            messenger.clearSnackBars();
          }

          _started = DateTime.now().millisecondsSinceEpoch;
        },
        onPageFinished: (url) {
          setState(() {
            _isLoading = false;
          });

          log(url);

          if (_started == -1) return; // finished without starting

          final elapsed = DateTime.now().millisecondsSinceEpoch - _started;
          _measure.add(elapsed);

          final message =
              "Elapsed: $elapsed\nMedium: ${_measure.medium} (out of ${_measure.sampleSize})\nAverage: ${_measure.average}";
          final messenger = ScaffoldMessenger.of(context);
          if (messenger.mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(days: 1),
                showCloseIcon: true,
              ),
            );
          } else {
            log(message);
          }
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("webview_flutter"),
        actions: [
          IconButton(
            onPressed: () {
              _measure.clear();
              final messenger = ScaffoldMessenger.of(context);
              if (messenger.mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Measurements cleared"),
                  ),
                );
              }
            },
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            onPressed: _startTest,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }

  void _startTest() async {
    _started = -1;

    if (_isLoading) {
      _controller.runJavaScript('window.stop();');
    }
    _controller.clearCache();
    _controller.clearLocalStorage();
    _controller.loadRequest(_kSamplePageUrl);
  }
}

class FlutterInAppWebViewPage extends StatefulWidget {
  const FlutterInAppWebViewPage({super.key});

  @override
  State<FlutterInAppWebViewPage> createState() =>
      _FlutterInAppWebViewPageState();
}

class _FlutterInAppWebViewPageState extends State<FlutterInAppWebViewPage> {
  late InAppWebViewController _controller;
  final _measure = Measure<int>();
  var _started = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("flutter_inappwebview"),
        actions: [
          IconButton(
            onPressed: _startTest,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: InAppWebView(
        onWebViewCreated: (controller) => _controller = controller,
        onLoadStart: (controller, url) {
          _started = DateTime.now().millisecondsSinceEpoch;

          final messenger = ScaffoldMessenger.of(context);
          if (messenger.mounted) {
            messenger.clearSnackBars();
          }
        },
        onLoadStop: (controller, url) {
          if (_started == -1) return;

          final elapsed = DateTime.now().millisecondsSinceEpoch - _started;
          _measure.add(elapsed);

          final message =
              "Elapsed: $elapsed\nMedium: ${_measure.medium} (out of ${_measure.sampleSize})\nAverage: ${_measure.average}";
          final messenger = ScaffoldMessenger.of(context);
          if (messenger.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(days: 1),
                showCloseIcon: true,
              ),
            );
          } else {
            log(message);
          }
        },
      ),
    );
  }

  void _startTest() async {
    _started = -1;

    if (await _controller.isLoading()) {
      await _controller.stopLoading();
    }
    await _controller.clearCache();
    await _controller.webStorage.localStorage.clear();
    await _controller.loadUrl(urlRequest: URLRequest(url: _kSamplePageUrl));
  }
}

final _kSamplePageUrl = Uri.parse(
    "https://developers.google.com/maps/documentation/javascript/examples/polyline-simple");

class Measure<T extends num> {
  final List<T> _measurements = List.empty(growable: true);

  int get sampleSize => _measurements.length;

  void add(T value) {
    _measurements
      ..add(value)
      ..sort();
  }

  void clear() {
    _measurements.clear();
  }

  double get average {
    return _measurements.fold(0.0, (value, element) => value + element) /
        _measurements.length;
  }

  T get medium {
    return _measurements[(_measurements.length + 1) ~/ 2];
  }
}
