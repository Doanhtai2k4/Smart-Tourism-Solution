import 'package:flutter/material.dart';
import '../../../shared/models/travel_db_model.dart';
import '../../services/admin_service.dart';
import 'trip_info_section.dart';
import 'trip_itinerary_section.dart';
import 'trip_packing_section.dart';

class AdminTripDetailView extends StatefulWidget {
  final String tripId;

  const AdminTripDetailView({super.key, required this.tripId});

  @override
  State<AdminTripDetailView> createState() => _AdminTripDetailViewState();
}

class _AdminTripDetailViewState extends State<AdminTripDetailView> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.85,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: FutureBuilder(
          future: _adminService.getTripById(widget.tripId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Không tìm thấy thông tin chuyến đi'));
            }

            final trip = TravelDbModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);

            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  _buildAppBar(context, trip),
                  const TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(icon: Icon(Icons.info_outline), text: 'Thông tin chung'),
                      Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Lịch trình chi tiết'),
                      Tab(icon: Icon(Icons.backpack_outlined), text: 'Hành lý chuẩn bị'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        TripInfoSection(trip: trip),
                        TripItinerarySection(trip: trip),
                        TripPackingSection(trip: trip),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TravelDbModel trip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.blue.withValues(alpha: 0.05),
      child: Row(
        children: [
          const Icon(Icons.flight_takeoff, color: Colors.blue, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chi tiết chuyến đi',
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                Text(
                  trip.destination,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
