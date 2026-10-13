void main() {
  String formatImageUrl(String input, int index) {
    String keyword = input.isEmpty ? "travel" : input;
    if (keyword.startsWith('http')) return keyword;
    final encoded = Uri.encodeComponent("$keyword travel");
    return "https://source.unsplash.com/800x600/?$encoded&sig=${keyword.hashCode + index}";
  }

  print("Test 1 (Hồ Hoàn Kiếm, index 0):");
  print(formatImageUrl("Hồ Hoàn Kiếm", 0));

  print("\nTest 2 (Đà Lạt, index 1):");
  print(formatImageUrl("Đà Lạt", 1));

  print("\nTest 3 (Phu Quoc, index 2):");
  print(formatImageUrl("Phu Quoc", 2));

  print("\nTest 4 (Empty keyword, index 3):");
  print(formatImageUrl("", 3));
  
  print("\nTest 5 (Direct URL, index 4):");
  print(formatImageUrl("https://example.com/image.png", 4));
}
