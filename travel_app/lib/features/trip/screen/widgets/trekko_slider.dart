import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrekkoSlider extends StatefulWidget {
  final List<String> images;
  final String destination;
  final double height;

  const TrekkoSlider({
    super.key,
    required this.images,
    required this.destination,
    this.height = 300,
  });

  @override
  State<TrekkoSlider> createState() => _TrekkoSliderState();
}

class _TrekkoSliderState extends State<TrekkoSlider> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _autoScrollController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _autoScrollController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollController.forward().then((_) {
      if (mounted) {
        _autoScrollNext();
      }
    });
  }

  void _autoScrollNext() {
    if (mounted) {
      final itemSize = _getItemSize();
      if (itemSize <= 1) return;
      
      final nextPage = (_currentPage + 1) % itemSize;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      ).then((_) {
        if (mounted) {
          _autoScrollController.reset();
          _startAutoScroll();
        }
      });
    }
  }

  int _getItemSize() {
    final displayImages = widget.images.isEmpty ? [widget.destination] : widget.images;
    final isUrl = displayImages.isNotEmpty && displayImages[0].startsWith('http');
    final finalImages = (displayImages.length == 1 && !isUrl)
        ? [displayImages[0], "${displayImages[0]} view", "${displayImages[0]} city"]
        : displayImages;
    return finalImages.length > 5 ? 5 : finalImages.length;
  }

  String _formatImageUrl(String input, int index) {
    if (input.startsWith('http')) return input;
    return 'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?q=80&w=1000&auto=format&fit=crop';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayImages = widget.images.isEmpty ? [widget.destination] : widget.images;
    final isUrl = displayImages.isNotEmpty && displayImages[0].startsWith('http');
    final finalImages = (displayImages.length == 1 && !isUrl)
        ? [displayImages[0], "${displayImages[0]} view", "${displayImages[0]} city"]
        : displayImages;

    final int itemSize = finalImages.length > 5 ? 5 : finalImages.length;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: itemSize,
            itemBuilder: (context, index) => _buildImageItem(finalImages[index], index),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(80),
                    Colors.transparent,
                    Colors.black.withAlpha(180),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(String imageKeyword, int index) {
    return CachedNetworkImage(
      imageUrl: _formatImageUrl(imageKeyword, index),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey.shade400,
        highlightColor: Colors.grey.shade200,
        child: Container(color: Colors.grey.shade300),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.image_search, size: 48, color: Colors.grey),
      ),
    );
  }
}
