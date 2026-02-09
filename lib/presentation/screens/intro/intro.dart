import 'package:ebidan/common/utility/user_preferences.dart';
import 'package:ebidan/configs/auth_gate.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_IntroSlideData> _slides = const [
    _IntroSlideData(
      title: 'Masalah',
      description:
          'Pasien sudah pulang.\nBidan masih lembur.\nLaporan menumpuk, waktu keluarga terpotong.',
      icon: Icons.warning_amber_rounded,
    ),
    _IntroSlideData(
      title: 'Solusi',
      description:
          'eBidan bantu pencatatan, laporan, dan administrasi\nlangsung dari HP.\nCepat. Rapi. Terintegrasi.',
      icon: Icons.lightbulb_outline,
    ),
    _IntroSlideData(
      title: 'Hasil',
      description:
          'Laporan beres tepat waktu.\nBidan pulang lebih cepat.\nWaktu untuk keluarga kembali.',
      icon: Icons.check_circle_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _IntroSlide(slide: slide);
                },
              ),
            ),
            _buildIndicator(),
            const SizedBox(height: 16),
            _buildButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentIndex == index ? Colors.blue : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final isLast = _currentIndex == _slides.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: Button(
          onPressed: () {
            if (isLast) {
              // TODO: arahkan ke login / home
              UserPreferences().setBool(UserPrefs.intro, true);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (route) => false,
              );
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
          label: isLast ? 'Login' : 'Lanjut',
          isSubmitting: false,
        ),
      ),
    );
  }
}

class _IntroSlide extends StatelessWidget {
  final _IntroSlideData slide;

  const _IntroSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(slide.icon, size: 96, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            slide.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _IntroSlideData {
  final String title;
  final String description;
  final IconData icon;

  const _IntroSlideData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
