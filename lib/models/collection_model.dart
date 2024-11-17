class CollectionModel {
  String userId;
  String? collectionId;
  String collectionName;
  int collectionIconCodePoint;
  String collectionIconFontFamily;
  int collectionColorValue;

  CollectionModel({
    required this.userId,
    this.collectionId,
    required this.collectionName,
    required this.collectionIconCodePoint,
    required this.collectionIconFontFamily,
    required this.collectionColorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'collectionIconCodePoint': collectionIconCodePoint,
      'collectionIconFontFamily': collectionIconFontFamily,
      'collectionColorValue': collectionColorValue,
    };
  }
}
