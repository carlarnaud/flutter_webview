import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init gestion fenêtre Windows
  await windowManager.ensureInitialized();
  WindowOptions opts = const WindowOptions(
    fullScreen: true,                 // plein écran
    titleBarStyle: TitleBarStyle.hidden, // pas de barre de titre
    alwaysOnTop: true,                // reste au-dessus
  );
  await windowManager.waitUntilReadyToShow(opts, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true); // bloque la fermeture (Alt+F4)
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Optionnel : cache le curseur
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

class _SafeWebViewState extends State<SafeWebView> with WindowListener {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    // Optionnel : verrouiller l’orientation (inutile sur Windows)
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // 🔒 Intercepte la fermeture (Alt+F4, X…)
  @override
  void onWindowClose() async {
    // On ignore la fermeture tant que preventClose = true
    // (tu peux afficher un PIN/shortcut secret ici au besoin)
    // Ex: await windowManager.setPreventClose(false); // pour autoriser plus tard
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: (event) {
        // 🧱 On “avale” quelques touches (ça n’empêchera pas Alt+Tab/Win)
        if (event is RawKeyDownEvent) {
          // Empêche ESC/F11 (certains screens sortent du plein écran)
          if (event.logicalKey == LogicalKeyboardKey.escape ||
              event.logicalKey == LogicalKeyboardKey.f11) {
            // ne rien faire
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://www.valeoservice.fr"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  allowsBackForwardNavigationGestures: false,
                  // 🚫 Pas de menu clic droit
                  supportZoom: false,
                ),
                contextMenu: ContextMenu( // vide => pas de menu
                  settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: true),
                ),
                shouldOverrideUrlLoading: (controller, action) async {
                  final url = action.request.url.toString();
                  if (url.startsWith("https://www.valeoservice.fr")) {
                    return NavigationActionPolicy.ALLOW;
                  }
                  return NavigationActionPolicy.CANCEL;
                },
                onProgressChanged: (controller, progress) {
                  setState(() => _progress = progress / 100);
                },
              ),
              if (_progress < 1)
                const LinearProgressIndicator(minHeight: 3),
            ],
          ),
        ),
      ),
    );
  }
}