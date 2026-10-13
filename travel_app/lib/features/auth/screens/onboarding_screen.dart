import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:travel_app/features/auth/provider/onboarding_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Lên kế hoạch thông minh",
      subtitle: "Để trí tuệ nhân tạo kiến tạo lịch trình hoàn hảo cho riêng bạn chỉ trong vài giây.",
      imageUrl: "https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&q=80&w=1000",
    ),
    OnboardingData(
      title: "Khám phá theo phong cách",
      subtitle: "Nhận những gợi ý điểm đến tinh tế, được cá nhân hóa hoàn toàn theo sở thích của bạn.",
      imageUrl: "https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&q=80&w=1000",
    ),
    OnboardingData(
      title: "Kết nối và Sẻ chia",
      subtitle: "Cùng bạn bè tạo nên những kỷ niệm đáng nhớ và chia sẻ hành trình tới cộng đồng.",
      imageUrl: "https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&q=80&w=1000",
    ),
    OnboardingData(
      title: "Chào mừng bạn đến với Trekko",
      subtitle: "", 
      imageUrl: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&q=80&w=1000",
    ),
  ];

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              if (index == 3) {
                return _BrandPage(data: _pages[index]);
              }
              return OnboardingPageWidget(data: _pages[index]);
            },
          ),

          // 2. Skip Button (Top Right)
          if (_currentPage < 3)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(
                  "Bỏ qua",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // 3. Navigation UI (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _currentPage < 3 
                    ? _buildBottomNav() 
                    : _buildFinalActions(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Row(
      key: const ValueKey('normal_nav'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Indicators
        SmoothPageIndicator(
          controller: _pageController,
          count: _pages.length,
          effect: ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: Colors.white,
            dotColor: Colors.white.withAlpha(100),
            expansionFactor: 4,
            spacing: 8,
          ),
        ),

        // Next Button
        GestureDetector(
          onTap: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            );
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalActions() {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      key: const ValueKey('final_nav'),
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _completeOnboarding,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 8,
            shadowColor: primaryColor.withAlpha(100),
          ),
          child: Text(
            "Bắt đầu ngay",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPageWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          data.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(color: Colors.black);
          },
          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.2, 0.9],
              colors: [
                Colors.transparent,
                Colors.black.withAlpha(230),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  data.title,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white.withAlpha(180),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandPage extends StatelessWidget {
  final OnboardingData data;

  const _BrandPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          data.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(color: Colors.grey[900]);
          },
          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
        ),
        Container(color: Colors.black.withAlpha(120)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withAlpha(50),
                          Colors.white.withAlpha(15),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(70)),
                    ),
                    child: const Icon(
                      Icons.terrain_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "TREKKO",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "TRÍ TUỆ DU LỊCH",
                style: GoogleFonts.poppins(
                  color: Colors.white.withAlpha(150),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String imageUrl;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}
