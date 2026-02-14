import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';

class CertificateGenerator {
  static Future<Uint8List> generateCertificate({
    required String recipientName,
    required String courseName,
    required String date,
    required bool isMaster,
    required String achievements,
    String? logoPath, // Path to the CodeUp logo
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();
    final titleFont = await PdfGoogleFonts.greatVibesRegular();
    final elegantFont = await PdfGoogleFonts.playfairDisplayRegular();

    // Load the logo if path is provided
    pw.ImageProvider? logo;
    if (logoPath != null) {
      try {
        final logoFile = File(logoPath);
        if (await logoFile.exists()) {
          final logoBytes = await logoFile.readAsBytes();
          logo = pw.MemoryImage(logoBytes);
        }
      } catch (e) {
        // If logo fails to load, continue without it
        print('Failed to load logo: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Clean white background
              pw.Positioned.fill(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      begin: pw.Alignment.topLeft,
                      end: pw.Alignment.bottomRight,
                      colors: [
                        PdfColors.white,
                        PdfColors.grey50,
                        PdfColors.white,
                      ],
                    ),
                  ),
                ),
              ),

              // Subtle CodeUp watermark
              pw.Center(
                child: pw.Transform.rotate(
                  angle: -0.3,
                  child: pw.Opacity(
                    opacity: 0.02,
                    child: pw.Text(
                      'CodeUp',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 180,
                        color: PdfColors.grey400,
                      ),
                    ),
                  ),
                ),
              ),

              // Main content with border
              pw.Container(
                margin: const pw.EdgeInsets.all(35),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#2C5F5D'),
                    width: 3,
                  ),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Container(
                  margin: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#5A9A97'),
                      width: 1,
                    ),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Logo section
                      if (logo != null)
                        pw.Container(
                          height: 80,
                          child: pw.Image(logo, fit: pw.BoxFit.contain),
                        )
                      else
                        // Fallback if logo not available
                        pw.Container(
                          height: 80,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'CodeUp',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 36,
                                  color: PdfColors.black,
                                  letterSpacing: 2,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'Learn Create Innovate',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 11,
                                  color: PdfColors.black,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                      pw.SizedBox(height: 25),

                      // Certificate title
                      pw.Text(
                        'Certificate of Completion',
                        style: pw.TextStyle(
                          font: elegantFont,
                          fontSize: 42,
                          color: PdfColors.black,
                          letterSpacing: 2,
                        ),
                      ),

                      pw.SizedBox(height: 10),

                      // Decorative line
                      pw.Container(
                        width: 250,
                        height: 2,
                        decoration: pw.BoxDecoration(
                          gradient: pw.LinearGradient(
                            colors: [
                              PdfColors.white,
                              PdfColor.fromHex('#5A9A97'),
                              PdfColor.fromHex('#2C5F5D'),
                              PdfColor.fromHex('#5A9A97'),
                              PdfColors.white,
                            ],
                          ),
                        ),
                      ),

                      pw.SizedBox(height: 35),

                      // Presented to
                      pw.Text(
                        'This is presented to',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 16,
                          color: PdfColors.black,
                        ),
                      ),

                      pw.SizedBox(height: 20),

                      // Recipient name
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 40),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              recipientName,
                              style: pw.TextStyle(
                                font: titleFont,
                                fontSize: 56,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Container(
                              width: 350,
                              height: 1.5,
                              color: PdfColors.black,
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 20),

                      // For completing
                      pw.Text(
                        'for successfully completing the',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 16,
                          color: PdfColors.black,
                        ),
                      ),

                      pw.SizedBox(height: 18),

                      // Course name
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 12,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F0F8F7'),
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(
                            color: PdfColor.fromHex('#5A9A97'),
                            width: 1.5,
                          ),
                        ),
                        child: pw.Text(
                          courseName,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 26,
                            color: PdfColors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      // Master level badge
                      if (isMaster) ...[
                        pw.SizedBox(height: 18),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 10,
                          ),
                          decoration: pw.BoxDecoration(
                            gradient: pw.LinearGradient(
                              colors: [
                                PdfColor.fromHex('#FFE082'),
                                PdfColor.fromHex('#FFD54F'),
                                PdfColor.fromHex('#FFE082'),
                              ],
                            ),
                            borderRadius: pw.BorderRadius.circular(25),
                            border: pw.Border.all(
                              color: PdfColor.fromHex('#FFA000'),
                              width: 2,
                            ),
                          ),
                          child: pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text('⭐', style: pw.TextStyle(fontSize: 16)),
                              pw.SizedBox(width: 8),
                              pw.Text(
                                'MASTER LEVEL ACHIEVEMENT',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 14,
                                  color: PdfColor.fromHex('#E65100'),
                                  letterSpacing: 1,
                                ),
                              ),
                              pw.SizedBox(width: 8),
                              pw.Text('⭐', style: pw.TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ],

                      pw.SizedBox(height: 18),

                      // Achievements
                      pw.Container(
                        width: 550,
                        child: pw.Text(
                          achievements,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 13,
                            color: PdfColors.black,
                            lineSpacing: 3,
                          ),
                        ),
                      ),

                      pw.Spacer(),

                      // Signature section
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          // Date
                          pw.Container(
                            width: 180,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Container(
                                  height: 1.5,
                                  color: PdfColors.black,
                                ),
                                pw.SizedBox(height: 6),
                                pw.Text(
                                  'Date',
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 10,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  date,
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 12,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Official seal
                          pw.Column(
                            children: [
                              pw.Container(
                                width: 70,
                                height: 70,
                                decoration: pw.BoxDecoration(
                                  shape: pw.BoxShape.circle,
                                  border: pw.Border.all(
                                    color: PdfColor.fromHex('#2C5F5D'),
                                    width: 3,
                                  ),
                                  gradient: pw.RadialGradient(
                                    colors: [
                                      PdfColors.white,
                                      PdfColor.fromHex('#E0F2F1'),
                                      PdfColor.fromHex('#B2DFDB'),
                                    ],
                                  ),
                                ),
                                child: pw.Center(
                                  child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    children: [
                                      pw.Text(
                                        'CodeUp',
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 12,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Container(
                                        width: 35,
                                        height: 1,
                                        color: PdfColors.black,
                                      ),
                                      pw.SizedBox(height: 2),
                                      pw.Text(
                                        'OFFICIAL',
                                        style: pw.TextStyle(
                                          font: font,
                                          fontSize: 7,
                                          color: PdfColors.black,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'Official Seal',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 9,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),

                          // Signature
                          pw.Container(
                            width: 180,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Container(
                                  height: 1.5,
                                  color: PdfColors.black,
                                ),
                                pw.SizedBox(height: 6),
                                pw.Text(
                                  'Authorized Signature',
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 10,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  'Director, CodeUp',
                                  style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 11,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 15),

                      // Certificate ID
                      pw.Text(
                        'Certificate ID: CU-${date.replaceAll('/', '')}-${recipientName.split(' ').first.toUpperCase()}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 8,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
