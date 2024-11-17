class BlogModel {
  String id;
  String userName;
  String title;
  String subtitle;
  String sources;
  String image;
  int likes;
  bool banned;
  bool isEditor;
  int readingTime;
  String userId;
  DateTime createdAt;
  List<dynamic> likedBy;




  BlogModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sources,
    required this.image,
    required this.likes,
    required this.banned,
    required this.readingTime,
    required this.userName,
    required this.userId,
    required this.likedBy,
    required this.isEditor,
    required this.createdAt,
  });
}
