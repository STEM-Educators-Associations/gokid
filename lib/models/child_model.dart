
class ChildModel {
  String childId;
  String childName;
  String childSurname;
  String childPhoto;
  String childDate;
  String docId;

  ChildModel({
    required this.childName,
    required this.childSurname,
    required this.childPhoto,
    required this.childId,
    required this.childDate,
    required this.docId
  });

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'childName': childName,
      'child': childSurname,
      'childPhoto': childPhoto,
      'childDate': childDate,
      'docId':docId,
    };
  }
}
