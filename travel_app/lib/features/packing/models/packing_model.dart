import 'dart:convert';

class PackingItem {
  String name;
  bool isChecked;
  String? reasoning;

  PackingItem({
    required this.name,
    this.isChecked = false,
    this.reasoning,
  });

  factory PackingItem.fromText(String text) {
    return PackingItem(name: text);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'isChecked': isChecked,
        if (reasoning != null) 'reasoning': reasoning,
      };
}

class PackingCategory {
  final String name;
  final List<PackingItem> items;

  PackingCategory({
    required this.name,
    required this.items,
  });

  factory PackingCategory.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<PackingItem> itemList = list.map((i) {
      if (i is Map<String, dynamic>) {
        return PackingItem(
          name: i['name'] ?? '',
          isChecked: i['isChecked'] ?? false,
          reasoning: i['reasoning'] as String?,
        );
      }
      return PackingItem.fromText(i.toString());
    }).toList();

    return PackingCategory(
      name: json['name'] as String? ?? 'Khác',
      items: itemList,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'items': items.map((i) => i.toJson()).toList(),
      };

  static List<PackingCategory> fromList(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((item) => PackingCategory.fromJson(item as Map<String, dynamic>)).toList();
  }
}

// Model wrapper cho response từ API
class PackingListResponse {
  final List<PackingCategory> categories;

  PackingListResponse({required this.categories});

  factory PackingListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['categories'] as List? ?? [];
    return PackingListResponse(
      categories: PackingCategory.fromList(list),
    );
  }
}
