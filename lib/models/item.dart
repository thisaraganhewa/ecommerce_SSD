class Item {
  final String imageUrl;
  final String itemName;
  final String itemAmount;
  final String itemId;
  final int quantity;

  // Constructor with named parameters for easier readability
  Item(String id, String string, param2, param3, int i, {
    required this.itemId,
    required this.itemAmount,
    required this.itemName,
    required this.imageUrl,
    required this.quantity,
  });

  // Convert Item object to Map
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemAmount': itemAmount,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
}
