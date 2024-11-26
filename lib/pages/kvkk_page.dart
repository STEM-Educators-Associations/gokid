import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class KVKKPage extends StatelessWidget {
  static const  String routeName = '/kvkk-page';

  const KVKKPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: SfPdfViewer.network(
                'https://firebasestorage.googleapis.com/v0/b/gokid-67cae.appspot.com/o/kvkk.pdf?alt=media&token=ca451b3e-fc64-404d-850e-4f08aa8ba047')));
  }
}
