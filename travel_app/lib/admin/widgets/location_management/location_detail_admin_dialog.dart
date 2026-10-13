import 'package:flutter/material.dart';
import '../../../shared/models/destination_model.dart';

class LocationDetailAdminDialog extends StatelessWidget {
  final DestinationModel location;

  const LocationDetailAdminDialog({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const Divider(height: 48),
              _buildStatsRow(),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildGeneralInfo()),
                  const SizedBox(width: 32),
                  Expanded(child: _buildAIContextInfo()),
                ],
              ),
              const SizedBox(height: 24),
              _buildDescription(),
              const SizedBox(height: 24),
              _buildTagsAndActivities(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (location.images.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              location.images.first,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image, size: 64, color: Colors.blue),
          ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      location.name,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildChip(location.category ?? 'Địa điểm', Colors.blue),
                  const SizedBox(width: 8),
                  _buildChip(location.province ?? 'Toàn quốc', Colors.orange),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location.address ?? location.displayLocation,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.star, location.averageRating.toString(), 'Đánh giá (${location.ratingCount})', Colors.amber),
          _buildStatItem(Icons.visibility, location.viewCount.toString(), 'Lượt xem', Colors.blue),
          _buildStatItem(Icons.favorite, location.favoriteCount.toString(), 'Yêu thích', Colors.red),
          _buildStatItem(Icons.trending_up, location.trendingScore.toString(), 'Xu hướng', Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildGeneralInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thông tin chung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDetailRow(Icons.attach_money, 'Giá vé', location.ticketPrice != null ? '${location.ticketPrice} VNĐ' : 'Miễn phí/Chưa cập nhật'),
        _buildDetailRow(Icons.timer, 'Thời gian ở lý tưởng', location.idealDuration != null ? '${location.idealDuration} ngày' : 'Chưa cập nhật'),
        _buildDetailRow(Icons.map, 'Tọa độ', '${location.latitude}, ${location.longitude}'),
      ],
    );
  }

  Widget _buildAIContextInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thông tin AI (Ngữ cảnh)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDetailRow(Icons.wb_sunny, 'Thời tiết/Mùa', location.weatherCondition ?? 'Chưa cập nhật'),
        _buildDetailRow(Icons.event, 'Sự kiện sắp tới', location.upcomingEvent ?? 'Chưa cập nhật'),
        _buildDetailRow(Icons.calendar_today, 'Thời điểm đẹp nhất', location.bestTimeToVisit.join(', ')),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mô tả chi tiết', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          location.description,
          style: const TextStyle(height: 1.6, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildTagsAndActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (location.topActivities.isNotEmpty) ...[
          const Text('Hoạt động nổi bật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: location.topActivities.map((a) => _buildChip(a, Colors.green)).toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (location.tags.isNotEmpty) ...[
          const Text('Thẻ / Đặc điểm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: location.tags.map((t) => _buildChip('#$t', Colors.purple)).toList(),
          ),
        ],
      ],
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
