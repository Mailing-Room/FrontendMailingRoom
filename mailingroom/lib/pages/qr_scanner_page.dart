// lib/pages/qr_scanner_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanComplete = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isScanComplete) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() {
        _isScanComplete = true;
      });
      final String code = barcodes.first.rawValue!;
      // Tampilkan dialog hasil scan
      _showScanResult(code);
    }
  }

  void _showScanResult(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Hasil Scan', style: GoogleFonts.poppins()),
        content: Text('Data ditemukan: $code', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () {
              // Kembali ke halaman scanner dan reset
              Navigator.pop(context);
              setState(() {
                _isScanComplete = false;
              });
            },
            child: const Text('Scan Lagi'),
          ),
          ElevatedButton(
            onPressed: () {
              // Tutup dialog DAN kembali ke halaman sebelumnya (KurirDashboard)
              // Bawa data hasil scan
              Navigator.pop(context); 
              Navigator.pop(context, code);
            },
            child: const Text('Gunakan Data Ini'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code Surat'),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Tampilan Kamera
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),

          // Overlay (Area Scan)
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Teks Bantuan
          Positioned(
            bottom: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Arahkan kamera ke QR Code',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}