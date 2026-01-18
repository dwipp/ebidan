import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

/// ================= MODEL =================
class KtpModel {
  final String nik;
  final String nama;
  final String tanggalLahir;
  final String golonganDarah;
  final String alamat;
  final String agama;
  final String pekerjaan;

  KtpModel({
    required this.nik,
    required this.nama,
    required this.tanggalLahir,
    required this.golonganDarah,
    required this.alamat,
    required this.agama,
    required this.pekerjaan,
  });
}

/// ================= WIDGET =================
class KtpCameraScanner extends StatefulWidget {
  final Function(KtpModel) onResult;
  const KtpCameraScanner({super.key, required this.onResult});

  @override
  State<KtpCameraScanner> createState() => _KtpCameraScannerState();
}

class _KtpCameraScannerState extends State<KtpCameraScanner> {
  CameraController? _controller;
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  bool _isProcessing = false;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initCamera() async {
    if (!await Permission.camera.request().isGranted) return;

    final cameras = await availableCameras();
    final cam = cameras.firstWhere(
      (e) => e.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    await _controller!.setFlashMode(FlashMode.off);

    _controller!.startImageStream(_processFrame);
    setState(() {});
  }

  /// ================= FRAME PROCESS =================
  Future<void> _processFrame(CameraImage image) async {
    if (!_isScanning || _isProcessing) return;

    _isProcessing = true;

    // === BLUR DETECTION (variance threshold) ===
    if (_isBlur(image)) {
      _isProcessing = false;
      return;
    }

    await _controller!.stopImageStream();
    final file = await _controller!.takePicture();
    final inputImage = InputImage.fromFile(File(file.path));
    final text = await _recognizer.processImage(inputImage);

    final result = _parseKtp(text.text.toUpperCase());

    if (result.nik.length == 16) {
      _onKtpDetected(result);
    } else {
      _controller!.startImageStream(_processFrame);
      _isProcessing = false;
    }

    _isProcessing = false;
  }

  Future<void> _onKtpDetected(KtpModel ktp) async {
    if (!_isScanning) return;
    _isScanning = false;

    // 1. STOP STREAM
    // await _controller?.stopImageStream();

    // 2. DISPOSE CAMERA
    await _controller?.dispose();

    // 3. DISPOSE ML KIT
    await _recognizer.close();

    // 4. RETURN DATA
    widget.onResult(ktp);
    // Navigator.pop(context);
  }

  /// ================= BLUR DETECTION =================
  bool _isBlur(CameraImage img) {
    final plane = img.planes.first.bytes;
    double mean = plane.reduce((a, b) => a + b) / plane.length;
    double variance =
        plane.map((e) => pow(e - mean, 2)).reduce((a, b) => a + b) /
        plane.length;

    return variance < 500; // threshold praktis mobile
  }

  /// ================= PARSER =================
  KtpModel _parseKtp(String text) {
    final lines = text.split('\n');
    bool grabAlamat = false;
    List<String> alamat = [];

    String nik = '', nama = '', ttl = '', agama = '', pekerjaan = '', gol = '';

    for (final l in lines) {
      final line = l.trim();

      if (RegExp(r'\d{16}').hasMatch(line)) {
        nik = RegExp(r'\d{16}').firstMatch(line)!.group(0)!;
      }

      if (line.contains("NAMA")) {
        nama = line.split(':').last.trim();
      }

      if (line.contains("LAHIR")) {
        final m = RegExp(r'\d{2}-\d{2}-\d{4}').firstMatch(line);
        if (m != null) ttl = m.group(0)!;
      }

      if (line.contains("ALAMAT")) {
        grabAlamat = true;
        continue;
      }

      if (grabAlamat &&
          (line.contains("AGAMA") ||
              line.contains("PEKERJAAN") ||
              line.contains("STATUS"))) {
        grabAlamat = false;
      }

      if (grabAlamat && line.isNotEmpty) alamat.add(line);

      if (line.contains("AGAMA")) {
        agama = line.split(':').last.trim();
      }

      if (line.contains("PEKERJAAN")) {
        pekerjaan = line.split(':').last.trim();
      }

      if (line.contains("GOL. DARAH")) {
        gol = line.split(':').last.trim();
      }
    }

    return KtpModel(
      nik: nik,
      nama: nama,
      tanggalLahir: ttl,
      golonganDarah: gol,
      alamat: alamat.join(' '),
      agama: agama,
      pekerjaan: pekerjaan,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _recognizer.close();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),

          // === OVERLAY FRAME ===
          Center(
            child: AspectRatio(
              aspectRatio: 85 / 54,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Posisikan KTP di dalam frame",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
