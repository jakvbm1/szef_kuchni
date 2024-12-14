import 'dart:io';

import 'package:pdf/widgets.dart';
import 'package:szef_kuchni_v2/services/save_and_open_pdf.dart';

class SimplePdfApi {
  static Future<File> generateSimpleTextPdf(String text, String text2) async {
    final pdf = Document();

    pdf.addPage(
      Page(
        build: (_) => Center(
          child: Column(
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 48),
              ),
              Text(
                text2,
                style: const TextStyle(fontSize: 48),
              ),
            ],
          ),
        ),
      ),
    );
    
    return SaveAndOpenPdf.savePdf(
      name: 'simple_pdf.pdf',
      pdf: pdf,
    );
  }
}
