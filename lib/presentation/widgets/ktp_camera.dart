import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:ktp_extractor/ktp_extractor.dart';

class KtpCameraScreen extends StatefulWidget {
  final Function(KtpModel ktp) onCaptured;

  const KtpCameraScreen({super.key, required this.onCaptured});

  @override
  State<KtpCameraScreen> createState() => _KtpCameraScreenState();
}

class _KtpCameraScreenState extends State<KtpCameraScreen> {
  CameraController? _controller;
  bool _isReady = false;
  KtpModel? _ktpResult;
  bool _showResult = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    await _controller!.setFocusMode(FocusMode.auto);

    setState(() => _isReady = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),

          if (_showResult && _ktpResult != null)
            _ResultOverlay(
              data: _ktpResult!,
              onConfirm: () {
                widget.onCaptured(_ktpResult!);
                Navigator.pop(context);
              },
              onRetry: () {
                setState(() {
                  _showResult = false;
                  _ktpResult = null;
                });
              },
            )
          else ...[
            // Overlay frame KTP
            _KtpOverlay(),

            // Tombol shutter
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: _capture,
                  child: const Icon(Icons.camera_alt, color: Colors.black),
                ),
              ),
            ),
          ],
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'Memproses KTP...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _capture() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final picture = await _controller!.takePicture();
      final file = File(picture.path);

      File? croppedImage = await KtpExtractor.cropImageForKtp(file);
      File imageToProcess = croppedImage ?? file;

      final ktpData = await KtpExtractor.extractKtp(imageToProcess);

      setState(() {
        _ktpResult = ktpData;
        _showResult = true;
      });
    } catch (e) {
      debugPrint('KTP scan error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memproses KTP')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}

class _KtpOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth * 0.9;
        final height = width / 1.6;

        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(color: Colors.black),
                  Center(
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  final KtpModel data;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  const _ResultOverlay({
    required this.data,
    required this.onConfirm,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _row('NIK', data.nik),
            _row('Nama', data.name),
            _row('Alamat', data.address),
            _row('Tanggal Lahir', data.birthDay),
            _row('Agama', data.religion),
            _row('Pekerjaan', data.occupation),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Button(
                    isSubmitting: false,
                    onPressed: onRetry,
                    label: 'Ulangi',
                    icon: Icons.camera_alt_outlined,
                    secondaryButton: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button(
                    isSubmitting: false,
                    onPressed: onConfirm,
                    label: 'Gunakan Data',
                    icon: Icons.add_card_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
