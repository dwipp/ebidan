import 'package:ebidan/common/utility/app_colors.dart';
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

  final List<_IntroSlideData> _slides = [
    _IntroSlideData(
      title: 'Lelah Lembur?',
      description:
          'Pasien sudah pulang, tapi laporan menumpuk?\nJangan biarkan waktu istirahatmu tersita.',
      background: 'assets/images/slide-1.png',
    ),
    _IntroSlideData(
      title: 'Solusi Cerdas',
      description:
          'eBidan mudahkan pencatatan & laporan langsung dari HP.\nLebih cepat, rapi, dan terintegrasi.',
      background: 'assets/images/slide-2.png',
    ),
    _IntroSlideData(
      title: 'Kerja Tenang',
      description:
          'Laporan beres tepat waktu.\nLebih banyak waktu berkualitas bersama keluarga.',
      background: 'assets/images/slide-3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(
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
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(slide.background, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0.0, 0.35, 0.7],
                colors: [
                  context.themeColors.surface,
                  const Color.fromARGB(200, 255, 255, 255),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  slide.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroSlideData {
  final String title;
  final String description;
  final String background;

  const _IntroSlideData({
    required this.title,
    required this.description,
    required this.background,
  });
}
