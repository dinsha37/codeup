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
    required String levelName,
    required String achievements,
    String? logoPath, // Path to the CodeUp logo
    Uint8List? logoBytes, // Bytes of the CodeUp logo (from assets)
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();
    final titleFont = await PdfGoogleFonts.greatVibesRegular();
    final elegantFont = await PdfGoogleFonts.playfairDisplayRegular();
    final scriptFont = await PdfGoogleFonts.dancingScriptRegular();

    // Load the logo if path is provided
    pw.ImageProvider? logo;
    if (logoBytes != null) {
      logo = pw.MemoryImage(logoBytes);
    } else if (logoPath != null) {
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
              // Elegant gradient background
              pw.Positioned.fill(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      begin: pw.Alignment.topLeft,
                      end: pw.Alignment.bottomRight,
                      colors: [
                        PdfColors.white,
                        PdfColor.fromHex('#FAFBFB'),
                        PdfColor.fromHex('#F5F9F9'),
                        PdfColors.white,
                      ],
                      stops: [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Subtle decorative watermark
              pw.Center(
                child: pw.Transform.rotate(
                  angle: -0.3,
                  child: pw.Opacity(
                    opacity: 0.015,
                    child: pw.Text(
                      'CodeUp',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 200,
                        color: PdfColors.grey400,
                      ),
                    ),
                  ),
                ),
              ),

              // Main content with enhanced border design
              pw.Container(
                margin: const pw.EdgeInsets.all(20), // Reduced from 30
                decoration: pw.BoxDecoration(
                  // Outer border with gradient
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#2C5F5D'),
                    width: 4,
                  ),
                  borderRadius: pw.BorderRadius.circular(12),
                  boxShadow: [
                    pw.BoxShadow(
                      color: PdfColors.grey300,
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const PdfPoint(0, 3),
                    ),
                  ],
                ),
                child: pw.Container(
                  margin: const pw.EdgeInsets.all(5), // Reduced from 6
                  decoration: pw.BoxDecoration(
                    // Inner decorative border
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#5A9A97'),
                      width: 1.5,
                    ),
                    borderRadius: pw.BorderRadius.circular(10),
                    color: PdfColors.white,
                  ),
                  child: pw.Stack(
                    children: [
                      // Corner ornaments
                      ..._buildCornerOrnaments(),

                      // Main content
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(25), // Reduced from 40
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            // Logo section with enhanced styling
                            if (logo != null)
                              pw.Container(
                                height: 50, // Reduced from 70
                                child: pw.Image(logo, fit: pw.BoxFit.contain),
                              )
                            else
                              // Fallback if logo not available
                              pw.Container(
                                height: 50, // Reduced from 70
                                child: pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  children: [
                                    pw.Text(
                                      'CodeUp',
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: 28, // Reduced from 38
                                        color: PdfColor.fromHex('#2C5F5D'),
                                        letterSpacing: 3,
                                      ),
                                    ),
                                    pw.SizedBox(height: 2),
                                    pw.Text(
                                      '• Learn • Create • Innovate •',
                                      style: pw.TextStyle(
                                        font: font,
                                        fontSize: 8, // Reduced from 10
                                        color: PdfColors.grey600,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            pw.SizedBox(height: 10), // Reduced from 18
                            // Certificate title with flourish
                            pw.Column(
                              children: [
                                pw.Text(
                                  'Certificate of Completion',
                                  style: pw.TextStyle(
                                    font: elegantFont,
                                    fontSize: 30, // Reduced from 35
                                    color: PdfColor.fromHex('#2C5F5D'),
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                pw.SizedBox(height: 8), // Reduced from 12
                                _buildDecorativeLine(),
                              ],
                            ),

                            pw.SizedBox(height: 12), // Reduced from 24
                            // Two-line description section
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 40, // Reduced from 60
                                vertical: 8, // Reduced from 15
                              ),
                              decoration: pw.BoxDecoration(
                                gradient: pw.LinearGradient(
                                  colors: [
                                    PdfColors.white,
                                    PdfColor.fromHex('#F0F8F7'),
                                    PdfColors.white,
                                  ],
                                ),
                                borderRadius: pw.BorderRadius.circular(10),
                                border: pw.Border.all(
                                  color: PdfColor.fromHex('#B2DFDB'),
                                  width: 1,
                                ),
                              ),
                              child: pw.Column(
                                children: [
                                  pw.Text(
                                    'This certificate is proudly presented to',
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 12, // Reduced from 14
                                      color: PdfColors.grey700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    'in recognition of outstanding dedication and achievement',
                                    style: pw.TextStyle(
                                      font: font,
                                      fontSize: 11, // Reduced from 13
                                      color: PdfColors.grey600,
                                      fontStyle: pw.FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            pw.SizedBox(height: 10), // Reduced from 18
                            // Recipient name with elegant styling
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 20, // Reduced from 40
                              ),
                              child: pw.Column(
                                children: [
                                  pw.Text(
                                    recipientName,
                                    style: pw.TextStyle(
                                      font: titleFont,
                                      fontSize: 26, // Reduced from 58
                                      color: PdfColor.fromHex('#2C5F5D'),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  pw.SizedBox(height: 6), // Reduced from 10
                                  // Decorative underline
                                  pw.Container(
                                    width: 300, // Reduced from 400
                                    height: 1.5,
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
                                ],
                              ),
                            ),

                            pw.SizedBox(height: 10), // Reduced from 18
                            pw.Spacer(),
                            // For completing text
                            pw.Text(
                              'for successfully completing the comprehensive',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 12, // Reduced from 14
                                color: PdfColors.grey700,
                              ),
                            ),

                            pw.SizedBox(height: 8), // Reduced from 14
                            // Course name with enhanced styling

                            // Level badge with enhanced design
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 20, // Reduced from 28
                                vertical: 6, // Reduced from 10
                              ),
                              decoration: pw.BoxDecoration(
                                gradient: isMaster
                                    ? pw.LinearGradient(
                                        begin: pw.Alignment.topLeft,
                                        end: pw.Alignment.bottomRight,
                                        colors: [
                                          PdfColor.fromHex('#FFF9C4'),
                                          PdfColor.fromHex('#FFE082'),
                                          PdfColor.fromHex('#FFD54F'),
                                          PdfColor.fromHex('#FFE082'),
                                          PdfColor.fromHex('#FFF9C4'),
                                        ],
                                      )
                                    : pw.LinearGradient(
                                        begin: pw.Alignment.topLeft,
                                        end: pw.Alignment.bottomRight,
                                        colors: [
                                          PdfColor.fromHex('#E0F2F1'),
                                          PdfColor.fromHex('#B2DFDB'),
                                          PdfColor.fromHex('#80CBC4'),
                                          PdfColor.fromHex('#B2DFDB'),
                                          PdfColor.fromHex('#E0F2F1'),
                                        ],
                                      ),
                                borderRadius: pw.BorderRadius.circular(30),
                                border: pw.Border.all(
                                  color: isMaster
                                      ? PdfColor.fromHex('#FFA000')
                                      : PdfColor.fromHex('#2C5F5D'),
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  pw.BoxShadow(
                                    color: isMaster
                                        ? PdfColor.fromHex('#FFE082')
                                        : PdfColor.fromHex('#B2DFDB'),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: const PdfPoint(0, 2),
                                  ),
                                ],
                              ),
                              child: pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  if (isMaster) ...[
                                    pw.Text(
                                      '⭐',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                      ), // Reduced from 16
                                    ),
                                    pw.SizedBox(width: 8),
                                  ],
                                  pw.Text(
                                    '${levelName.toUpperCase()} LEVEL ACHIEVEMENT',
                                    style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: 12, // Reduced from 14
                                      color: isMaster
                                          ? PdfColor.fromHex('#E65100')
                                          : PdfColor.fromHex('#1A4644'),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  if (isMaster) ...[
                                    pw.SizedBox(width: 8),
                                    pw.Text(
                                      '⭐',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                      ), // Reduced from 16
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            pw.Spacer(),

                            // Signature and Date section - NOW BALANCED!
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 20, // Reduced from 40
                              ),
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  // Date section
                                  _buildInfoSection(
                                    'Date of Completion',
                                    date,
                                    font,
                                    fontBold,
                                  ),

                                  // Signature section
                                  _buildInfoSection(
                                    'Authorized Signature',
                                    'Director, CodeUp',
                                    font,
                                    fontBold,
                                  ),
                                ],
                              ),
                            ),

                            pw.SizedBox(height: 10),

                            // Certificate ID with enhanced styling
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#F5F9F9'),
                                borderRadius: pw.BorderRadius.circular(20),
                              ),
                              child: pw.Text(
                                'Certificate ID: CU-${date.replaceAll('/', '')}-${recipientName.split(' ').first.toUpperCase()}',
                                style: pw.TextStyle(
                                  font: font,
                                  fontSize: 8,
                                  color: PdfColors.grey600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
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

  // Helper method to build decorative line
  static pw.Widget _buildDecorativeLine() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Container(
          width: 40,
          height: 1.5,
          color: PdfColor.fromHex('#5A9A97'),
        ),
        pw.SizedBox(width: 10),
        pw.Container(
          width: 8,
          height: 8,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            gradient: pw.RadialGradient(
              colors: [
                PdfColor.fromHex('#2C5F5D'),
                PdfColor.fromHex('#5A9A97'),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Container(
          width: 120,
          height: 2,
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [
                PdfColor.fromHex('#5A9A97'),
                PdfColor.fromHex('#2C5F5D'),
                PdfColor.fromHex('#5A9A97'),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Container(
          width: 8,
          height: 8,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            gradient: pw.RadialGradient(
              colors: [
                PdfColor.fromHex('#2C5F5D'),
                PdfColor.fromHex('#5A9A97'),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Container(
          width: 40,
          height: 1.5,
          color: PdfColor.fromHex('#5A9A97'),
        ),
      ],
    );
  }

  // Helper method to build corner ornaments
  static List<pw.Widget> _buildCornerOrnaments() {
    return [
      // Top-left ornament
      pw.Positioned(top: 15, left: 15, child: _buildOrnament()),
      // Top-right ornament
      pw.Positioned(
        top: 15,
        right: 15,
        child: pw.Transform.rotate(
          angle: 1.5708, // 90 degrees
          child: _buildOrnament(),
        ),
      ),
      // Bottom-left ornament
      pw.Positioned(
        bottom: 15,
        left: 15,
        child: pw.Transform.rotate(
          angle: -1.5708, // -90 degrees
          child: _buildOrnament(),
        ),
      ),
      // Bottom-right ornament
      pw.Positioned(
        bottom: 15,
        right: 15,
        child: pw.Transform.rotate(
          angle: 3.14159, // 180 degrees
          child: _buildOrnament(),
        ),
      ),
    ];
  }

  // Helper method to create ornament design
  static pw.Widget _buildOrnament() {
    return pw.Container(
      width: 45,
      height: 45,
      child: pw.Stack(
        children: [
          // Horizontal line
          pw.Positioned(
            top: 0,
            left: 0,
            child: pw.Container(
              width: 35,
              height: 2,
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [
                    PdfColor.fromHex('#2C5F5D'),
                    PdfColor.fromHex('#5A9A97'),
                  ],
                ),
              ),
            ),
          ),
          // Vertical line
          pw.Positioned(
            top: 0,
            left: 0,
            child: pw.Container(
              width: 2,
              height: 35,
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  begin: pw.Alignment.topCenter,
                  end: pw.Alignment.bottomCenter,
                  colors: [
                    PdfColor.fromHex('#2C5F5D'),
                    PdfColor.fromHex('#5A9A97'),
                  ],
                ),
              ),
            ),
          ),
          // Corner dot
          pw.Positioned(
            top: 0,
            left: 0,
            child: pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: PdfColor.fromHex('#2C5F5D'),
              ),
            ),
          ),
          // Secondary corner dots
          pw.Positioned(
            top: 10,
            left: 10,
            child: pw.Container(
              width: 4,
              height: 4,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: PdfColor.fromHex('#5A9A97'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build info sections (date and signature) - RENAMED AND IMPROVED
  static pw.Widget _buildInfoSection(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      width: 190,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 160,
            height: 2,
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [
                  PdfColors.grey300,
                  PdfColor.fromHex('#2C5F5D'),
                  PdfColors.grey300,
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey600,
              letterSpacing: 0.3,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 12,
              color: PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }
}
