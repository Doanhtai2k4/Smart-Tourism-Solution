import 'package:flutter/material.dart';
import '../../../shared/models/travel_db_model.dart';
import 'package:travel_app/features/packing/models/packing_model.dart';

class TripPackingSection extends StatelessWidget {
  final TravelDbModel trip;

  const TripPackingSection({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    if (trip.packingList == null || trip.packingList!.isEmpty) {
      return const Center(child: Text('Không có dữ liệu hành lý'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.5,
      ),
      itemCount: trip.packingList!.length,
      itemBuilder: (context, index) {
        final PackingCategory category = trip.packingList![index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(PackingCategory category) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  category.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${category.items.where((i) => i.isChecked).length}/${category.items.length}',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: category.items.length,
                itemBuilder: (context, index) {
                  final PackingItem item = category.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          item.isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 20,
                          color: item.isChecked ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                                  color: item.isChecked ? Colors.grey : Colors.black87,
                                ),
                              ),
                              if (item.reasoning != null && item.reasoning!.isNotEmpty)
                                Text(
                                  item.reasoning!,
                                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
