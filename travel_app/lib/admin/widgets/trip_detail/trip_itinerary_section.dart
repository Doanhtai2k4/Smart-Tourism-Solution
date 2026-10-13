import 'package:flutter/material.dart';
import '../../../shared/models/travel_db_model.dart';
import '../../../features/addtrip/models/travel_gemini_response.dart';
import 'package:intl/intl.dart';

class TripItinerarySection extends StatelessWidget {
  final TravelDbModel trip;

  const TripItinerarySection({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    if (trip.dailyPlan.isEmpty) {
      return const Center(child: Text('Không có dữ liệu lịch trình'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: trip.dailyPlan.length,
      itemBuilder: (context, index) {
        final dayPlan = trip.dailyPlan[index];
        return _buildDayCard(dayPlan);
      },
    );
  }

  Widget _buildDayCard(DayPlan dayPlan) {
    final dateFormat = DateFormat('EEEE, dd/MM', 'vi');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ngày ${dayPlan.day}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                dateFormat.format(dayPlan.date),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ...dayPlan.activities.map((Activity activity) => _buildActivityTile(activity)).toList(),
        const Divider(height: 48),
      ],
    );
  }

  Widget _buildActivityTile(Activity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16, left: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activity.time,
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.description,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (activity.reasoning != null && activity.reasoning!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activity.reasoning!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
