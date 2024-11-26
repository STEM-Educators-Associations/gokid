import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  String userId;
  String collectionId;
  String imageId;
  String imageName;
  String imageURL;
  bool isEnabled;

  ImageModel({
    required this.isEnabled,
    required this.collectionId,
    required this.imageId,
    required this.imageName,
    required this.userId,
    required this.imageURL,
  });

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      isEnabled: map['isEnabled'],
      imageId: map['imageId'],
      imageURL: map['imageURL'],
      userId: map['userId'],
      imageName: map['imageName'],
      collectionId: map['collectionId'],
    );
  }


  factory ImageModel.fromFirestore(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return ImageModel(
      collectionId: snapshot.reference.parent.id ?? '',
      isEnabled: data['isEnabled'] ?? false,
      userId: data['userId'] ?? '',
      imageId: snapshot.id,
      imageName: data['imageName'] ?? '',
      imageURL: data['imageURL'] ?? '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'collectionId': collectionId,
      'isEnabled': isEnabled,
      'userId': userId,
      'imageId': imageId,
      'imageName': imageName,
      'imageURL': imageURL,
    };
  }
}
