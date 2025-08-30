import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GoogleAdWidget extends StatelessWidget {
  final String adSlot;

  GoogleAdWidget({required this.adSlot}) {
    if (kIsWeb) {
      // Register a unique view for Flutter web
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory('ad-$adSlot', (int viewId) {
        final div =
            html.DivElement()
              ..style.width = '100%'
              ..style.height = '100%'
              ..innerHtml = '''
              <ins class="adsbygoogle"
                   style="display:block"
                   data-ad-client="ca-pub-XXXXXXXXXXXXXXX"
                   data-ad-slot="$adSlot"
                   data-ad-format="auto"
                   data-full-width-responsive="true"></ins>
              <script>
                (adsbygoogle = window.adsbygoogle || []).push({});
              </script>
            ''';
        return div;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return SizedBox();
    return SizedBox(
      width: 300,
      height: 250,
      child: HtmlElementView(viewType: 'ad-$adSlot'),
    );
  }
}
