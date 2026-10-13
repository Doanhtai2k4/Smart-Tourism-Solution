import 'package:flutter/material.dart';
import '../../../shared/models/travel_db_model.dart';
import 'package:intl/intl.dart';

class TripInfoSection extends StatelessWidget {
  final TravelDbModel trip;

  const TripInfoSection({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildDetailsCard(dateFormat),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildMembersCard(),
              ),
            ],
          ),
          if (trip.overview != null && trip.overview!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildOverviewCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (trip.images.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              trip.images.first,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.map, size: 48, color: Colors.blue),
          ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.destination,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildChip(trip.tripType.name.toUpperCase(), Colors.orange),
                  const SizedBox(width: 8),
                  _buildChip(trip.status.name.toUpperCase(), Colors.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chi tiết chuyến đi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            _buildInfoRow(Icons.calendar_today, 'Thời gian', 
                '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)} (${trip.totalDays} ngày)'),
            _buildInfoRow(Icons.people, 'Số người', '${trip.totalPeople} người'),
            _buildInfoRow(Icons.account_balance_wallet, 'Ngân sách', trip.budget ?? 'Chưa xác định'),
            _buildInfoRow(Icons.speed, 'Tốc độ đi', trip.pace ?? 'Vừa phải'),
            _buildInfoRow(Icons.restaurant, 'Sở thích ăn uống', trip.foodPreference ?? 'Đa dạng'),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thành viên', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: trip.ownerPhoto != null ? NetworkImage(trip.ownerPhoto!) : null,
                child: trip.ownerPhoto == null ? const Icon(Icons.person) : null,
              ),
              title: Text(trip.ownerName ?? 'Chủ phòng'),
              subtitle: const Text('Người tạo'),
            ),
            if (trip.memberIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('${trip.memberIds.length} thành viên tham gia', style: const TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tổng quan lịch trình', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            Text(trip.overview!, style: const TextStyle(height: 1.6, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    // Logic "Tàng hình nếu rỗng"
    if (value.trim().isEmpty || value == 'Chưa xác định') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
