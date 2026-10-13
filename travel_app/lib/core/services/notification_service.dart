import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/features/notifications/models/notification_model.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class FestivalEvent {
  final String id;
  final String nameVi;
  final String nameEn;
  final int month;
  final int day;
  final String messageVi;
  final String messageEn;
  final String type; // 'event' hoặc 'holiday'

  const FestivalEvent({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.month,
    required this.day,
    required this.messageVi,
    required this.messageEn,
    this.type = 'event',
  });
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Set<String> _sentWeatherNotifications = {};

  static const List<FestivalEvent> _vietnamFestivals = [
    FestivalEvent(
      id: 'phao_hoa_da_nang',
      nameVi: 'Lễ hội pháo hoa quốc tế Đà Nẵng 🎆',
      nameEn: 'Da Nang International Fireworks Festival 🎆',
      month: 6,
      day: 1,
      messageVi: 'Màn trình diễn pháo hoa quốc tế sắp thắp sáng bầu trời Đà Nẵng. Bạn đã sẵn sàng khám phá thành phố đáng sống này chưa?',
      messageEn: 'The International Fireworks Festival is about to light up Da Nang\'s sky. Are you ready to explore this beautiful coastal city?',
      type: 'event',
    ),
    FestivalEvent(
      id: 'den_long_hoi_an',
      nameVi: 'Lễ hội đèn lồng Hội An 🏮',
      nameEn: 'Hoi An Lantern Festival 🏮',
      month: 2,
      day: 14,
      messageVi: 'Phố cổ Hội An sắp lung linh sắc đèn lồng huyền ảo. Hãy lên lịch ghé thăm vùng đất di sản đầy lãng mạn này nhé!',
      messageEn: 'Hoi An Ancient Town is about to glow with magical lanterns. Plan a romantic trip to this heritage land!',
      type: 'event',
    ),
    FestivalEvent(
      id: 'festival_hoa_da_lat',
      nameVi: 'Festival Hoa Đà Lạt 🌸',
      nameEn: 'Da Lat Flower Festival 🌸',
      month: 12,
      day: 20,
      messageVi: 'Thành phố sương mù ngàn hoa sắp bước vào lễ hội lớn nhất năm. Lên kế hoạch vi vu Đà Lạt để tận hưởng không khí trong lành thôi!',
      messageEn: 'The city of eternal spring is entering its biggest flower festival. Plan a trip to Da Lat to enjoy the fresh cool air!',
      type: 'event',
    ),
    FestivalEvent(
      id: 'du_thuyen_nha_trang',
      nameVi: 'Festival Biển Nha Trang 🏖️',
      nameEn: 'Nha Trang Sea Festival 🏖️',
      month: 7,
      day: 15,
      messageVi: 'Nha Trang vẫy gọi với chuỗi sự kiện biển sôi động và bãi cát vàng lấp lánh. Đi trốn nóng thôi bạn ơi!',
      messageEn: 'Nha Trang calls with vibrant beach events and golden sands. Pack your bags and escape the summer heat!',
      type: 'event',
    ),
    FestivalEvent(
      id: 'chua_huong',
      nameVi: 'Lễ hội Chùa Hương ⛰️',
      nameEn: 'Huong Pagoda Festival ⛰️',
      month: 2,
      day: 15,
      messageVi: 'Hành trình trẩy hội Chùa Hương giữa non nước hữu tình đang đón chào bạn. Lên đường cầu chúc bình an cho gia đình thôi!',
      messageEn: 'The scenic pilgrimage of Huong Pagoda is welcoming you. Start your spiritual journey and wish for peace!',
      type: 'event',
    ),
    FestivalEvent(
      id: 'nghinh_ong',
      nameVi: 'Lễ hội Nghinh Ông 🐋',
      nameEn: 'Nghinh Ong Festival 🐋',
      month: 9,
      day: 27,
      messageVi: 'Lễ hội Nghinh Ông đậm nét văn hóa sông nước miền Nam sắp diễn ra. Cơ hội tuyệt vời để khám phá bản sắc miền biển Cần Giờ!',
      messageEn: 'Nghinh Ong Festival with rich Southern coastal culture is coming. A great chance to explore Can Gio\'s sea identity!',
      type: 'event',
    ),
    FestivalEvent(
      id: 'new_year',
      nameVi: 'Chúc Mừng Năm Mới! 🎉',
      nameEn: 'Happy New Year! 🎉',
      month: 1,
      day: 1,
      messageVi: 'TripHero chúc bạn một năm mới tràn ngập niềm vui, hạnh phúc và khám phá thêm nhiều vùng đất mới thú vị cùng những người thân yêu!',
      messageEn: 'TripHero wishes you a new year filled with joy, happiness, and exciting journeys to new lands with your loved ones!',
      type: 'holiday',
    ),
    FestivalEvent(
      id: 'lunar_new_year',
      nameVi: 'Chúc Mừng Năm Mới Âm Lịch! 🧧',
      nameEn: 'Happy Lunar New Year! 🧧',
      month: 1,
      day: 25,
      messageVi: 'Chúc bạn và gia đình năm mới an khang thịnh vượng, vạn sự như ý, tài lộc dồi dào và gặt hái thêm nhiều chuyến đi xuân ấm áp!',
      messageEn: 'Wishing you and your family prosperity, good health, peace, and many warm spring travels in this new lunar year!',
      type: 'holiday',
    ),
    FestivalEvent(
      id: 'womens_day',
      nameVi: 'Mừng Ngày Quốc Tế Phụ Nữ 8/3 💐',
      nameEn: 'Happy International Women\'s Day 8/3 💐',
      month: 3,
      day: 8,
      messageVi: 'Chúc một nửa thế giới xinh đẹp luôn ngập tràn niềm vui, hạnh phúc, xinh tươi rạng ngời và tự tin chinh phục những hành trình mơ ước!',
      messageEn: 'Wishing the beautiful half of the world love, happiness, brightness, and confidence to conquer all dream journeys!',
      type: 'holiday',
    ),
    FestivalEvent(
      id: 'reunification_day',
      nameVi: 'Mừng Ngày Giải Phóng Miền Nam 30/4 🇻🇳',
      nameEn: 'Happy Reunification Day 30/4 🇻🇳',
      month: 4,
      day: 30,
      messageVi: 'Chúc bạn và gia đình có một kỳ nghỉ lễ 30/4 thật ý nghĩa, đầm ấm, vui vẻ và có những chuyến đi thư giãn an toàn!',
      messageEn: 'Wishing you and your family a meaningful, warm, and happy April 30th holiday with safe and relaxing trips!',
      type: 'holiday',
    ),
    FestivalEvent(
      id: 'labor_day',
      nameVi: 'Mừng Ngày Quốc Tế Lao Động 1/5 🌟',
      nameEn: 'Happy International Workers\' Day 1/5 🌟',
      month: 5,
      day: 1,
      messageVi: 'Chúc mừng ngày 1/5! Hãy tự thưởng cho bản thân một chuyến đi xả hơi thật sảng khoái sau chuỗi ngày làm việc chăm chỉ nhé!',
      messageEn: 'Happy May Day! Treat yourself to a refreshing getaway and relax after all your hard work!',
      type: 'holiday',
    ),
    FestivalEvent(
      id: 'national_day',
      nameVi: 'Mừng Ngày Quốc Khánh 2/9 🇻🇳',
      nameEn: 'Happy National Day 2/9 🇻🇳',
      month: 9,
      day: 2,
      messageVi: 'Chúc bạn có một kỳ nghỉ lễ Quốc khánh ngập tràn niềm vui bên gia đình và tận hưởng những hành trình khám phá non sông tươi đẹp!',
      messageEn: 'Wishing you a joyful National Day holiday with your family and wonderful explorations across our beautiful country!',
      type: 'holiday',
    ),
    FestivalEvent(
      id: 'vietnam_womens_day',
      nameVi: 'Mừng Ngày Phụ Nữ Việt Nam 20/10 🌸',
      nameEn: 'Happy Vietnamese Women\'s Day 20/10 🌸',
      month: 10,
      day: 20,
      messageVi: 'Gửi những lời chúc ấm áp nhất đến những người phụ nữ tuyệt vời của TripHero. Chúc bạn luôn hạnh phúc và tràn đầy cảm hứng xê dịch!',
      messageEn: 'Sending warmest wishes to the amazing women of TripHero. May you stay happy and full of wanderlust inspiration!',
      type: 'holiday',
    ),
    FestivalEvent(
      id: 'christmas',
      nameVi: 'Giáng Sinh An Lành! 🎄',
      nameEn: 'Merry Christmas! 🎄',
      month: 12,
      day: 25,
      messageVi: 'Chúc bạn một mùa Giáng sinh ấm áp, an lành bên gia đình, bạn bè và đón nhận nhiều may mắn cho những hành trình cuối năm!',
      messageEn: 'Wishing you a warm and peaceful Christmas with family and friends, filled with luck for your year-end journeys!',
      type: 'holiday',
    ),
  ];

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? travelId,
  }) async {
    // Không gửi thông báo nếu chuyến đi đã hoàn thành (đã đi)
    if (travelId != null && travelId.isNotEmpty) {
      try {
        final doc = await _firestore.collection('trips').doc(travelId).get();
        if (doc.exists) {
          final tripData = doc.data();
          final status = tripData?['status'] as String? ?? 'planned';
          final isVisited = tripData?['isVisited'] as bool? ?? false;
          if (status == 'visited' || isVisited) {
            return; // Bỏ qua
          }
        }
      } catch (e) {
        // Swallowed
      }
    }

    final Map<String, dynamic> data = {
      'title': title,
      'body': body,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };
    if (travelId != null) {
      data['travelId'] = travelId;
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(data);
  }

  Future<void> checkAndTriggerWeatherNotification({
    required String userId,
    required String destination,
    required String alertMessage,
    required String travelId,
  }) async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final storageKey = 'notified_weather_${travelId}_$todayStr';
    
    // 1. Chặn trùng lặp tức thì trong bộ nhớ (Memory Cache) để tránh Race Condition
    if (_sentWeatherNotifications.contains(storageKey)) {
      return;
    }
    _sentWeatherNotifications.add(storageKey);

    // 2. Kiểm tra SharedPreferences để bền vững qua các lần khởi động
    final prefs = await SharedPreferences.getInstance();
    final hasBeenNotified = prefs.getBool(storageKey) ?? false;

    if (!hasBeenNotified) {
      await sendNotification(
        userId: userId,
        title: "Cảnh báo thời tiết tại $destination",
        body: alertMessage,
        type: 'weather',
        travelId: travelId,
      );
      await prefs.setBool(storageKey, true);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    if (querySnapshot.docs.isEmpty) return;

    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> sendGroupNotification({
    required List<String> memberIds,
    required String title,
    required String body,
    required String type,
    String? excludeUserId,
    String? travelId,
  }) async {
    // Không gửi thông báo nhóm nếu chuyến đi đã hoàn thành (đã đi)
    if (travelId != null && travelId.isNotEmpty) {
      try {
        final doc = await _firestore.collection('trips').doc(travelId).get();
        if (doc.exists) {
          final tripData = doc.data();
          final status = tripData?['status'] as String? ?? 'planned';
          final isVisited = tripData?['isVisited'] as bool? ?? false;
          if (status == 'visited' || isVisited) {
            return; // Bỏ qua
          }
        }
      } catch (e) {
        // Swallowed
      }
    }

    final batch = _firestore.batch();
    for (String uid in memberIds) {
      if (uid == excludeUserId) continue;
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc();
      final Map<String, dynamic> data = {
        'title': title,
        'body': body,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };
      if (travelId != null) {
        data['travelId'] = travelId;
      }
      batch.set(docRef, data);
    }
    await batch.commit();
  }

  Future<void> checkAndTriggerFestivalNotifications(String userId, {String languageCode = 'vi'}) async {
    final now = DateTime.now();
    final currentYear = now.year;
    final prefs = await SharedPreferences.getInstance();

    for (var festival in _vietnamFestivals) {
      final festivalDate = DateTime(currentYear, festival.month, festival.day);
      final difference = festivalDate.difference(now).inDays;

      // Với ngày lễ (holiday), ta báo trước 1 ngày hoặc đúng ngày.
      // Với sự kiện du lịch (event), ta báo trước 7 ngày để người dùng có thời gian lên kế hoạch.
      final int alertWindow = festival.type == 'holiday' ? 1 : 7;

      if (difference >= 0 && difference <= alertWindow) {
        final storageKey = 'notified_festival_${festival.id}_$currentYear';
        final hasBeenNotified = prefs.getBool(storageKey) ?? false;

        if (!hasBeenNotified) {
          final title = languageCode == 'vi' ? festival.nameVi : festival.nameEn;
          final body = languageCode == 'vi' ? festival.messageVi : festival.messageEn;

          await sendNotification(
            userId: userId,
            title: title,
            body: body,
            type: festival.type,
          );
          await prefs.setBool(storageKey, true);
        }
      }
    }
  }
}
