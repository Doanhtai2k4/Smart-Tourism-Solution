import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FlightLoadingView extends StatefulWidget {
  const FlightLoadingView({super.key});

  @override
  State<FlightLoadingView> createState() => _FlightLoadingViewState();
}

class _FlightLoadingViewState extends State<FlightLoadingView> {
  int _messageIndex = 0;
  late Timer _timer;

  final List<String> _loadingMessages = [
    "Đang nạp nhiên liệu cho máy bay...",
    "Đang kiểm tra hộ chiếu cho bạn...",
    "Đang xin visa từ TripHero AI...",
    "Đang hỏi thăm dân bản địa các quán ăn ngon...",
    "Đang xếp hành lý vào khoang...",
    "Máy bay đang lăn bánh ra đường băng...",
    "Sắp cất cánh rồi! Đang đóng gói lịch trình...",
  ];

  @override
  void initState() {
    super.initState();
    // Cứ 2.5 giây đổi câu thông báo một lần
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white, // Hoặc context.colors.background
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Hoạt họa máy bay (Sử dụng link mạng để bạn test nhanh)
          Lottie.asset(
            'assets/json/PassportTravel.json',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 20),

          // 2. Dòng chữ trạng thái với hiệu ứng mờ ảo
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _loadingMessages[_messageIndex],
              key: ValueKey<int>(_messageIndex),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 3. Thanh tiến trình nhỏ tinh tế ở dưới
          SizedBox(
            width: 150,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              minHeight: 2,
            ),
          ),
        ],
      ),
    );
  }
}