import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeWebView(),
    );
  }
}

class SafeWebView extends StatefulWidget {
  const SafeWebView({super.key});

  @override
  State<SafeWebView> createState() => _SafeWebViewState();
}

class _SafeWebViewState extends State<SafeWebView> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://www.valeoservice.fr"),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                allowsBackForwardNavigationGestures: true,
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url.toString();
                // ✅ On autorise uniquement confosmart.fr
                if (url.startsWith("https://www.valeoservice.fr")) {
                  return NavigationActionPolicy.ALLOW;
                }
                // ❌ On bloque tout le reste
                return NavigationActionPolicy.CANCEL;
              },
              onProgressChanged: (controller, progress) {
                setState(() => _progress = progress / 100);
              },
            ),
            if (_progress < 1)
              LinearProgressIndicator(
                value: _progress,
                minHeight: 3,
                color: Colors.blueAccent,
              ),
          ],
        ),
      ),
    );
  }
}