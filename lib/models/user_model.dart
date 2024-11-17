import 'package:gokid/models/collection_model.dart';

class UserModel {
  String userName;
  String userId;
  String userMail;
  String userPassword;
  String? userToken;
  String? otherDeviceToken;
  bool isVerified;
  bool isRestricted;
  bool isExceeded;
  bool profileSetup;
  bool isEditor;
  int storageUsed;
  String userDate;
  String deviceInfo;
  String otherDeviceInfo;

  //List<ChildModel> children;

  UserModel(
      {required this.userName,
      required this.userId,
      required this.userMail,
      required this.userPassword,
      required this.userToken,
      required this.isExceeded,
      required this.isRestricted,
      required this.isVerified,
      required this.storageUsed,
      required this.userDate,
      required this.isEditor,
      required this.profileSetup,
      required this.otherDeviceToken,
      required this.deviceInfo,
      required this.otherDeviceInfo});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName: json['user_name'],
      userId: json['user_id'],
      userMail: json['user_mail'],
      isEditor: json['is_editor'],
      userToken: json['user_token'],
      otherDeviceToken: json['other_device_token'],
      userPassword: json['user_password'],
      isExceeded: json['is_exceeded'],
      isRestricted: json['is_restricted'],
      isVerified: json['is_verified'],
      storageUsed: json['storage_used'],
      userDate: json['user_date'],
      profileSetup: json['profile_setup'],
      deviceInfo: json['device_info'],
      otherDeviceInfo: json['other_device_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'user_id': userId,
      'user_mail': userMail,
      'user_password': userPassword,
      'is_exceeded': isExceeded,
      'user_token': userToken,
      'other_device_token': otherDeviceToken,
      'is_restricted': isRestricted,
      'is_verified': isVerified,
      'storage_used': storageUsed,
      'profile_setup': profileSetup,
      'device_info': deviceInfo,
      'is_editor': isEditor,
      'other_device_info': otherDeviceInfo,
    };
  }

  UserModel copyWith({
    String? userName,
    String? userId,
    String? userMail,
    String? userPassword,
    String? userToken,
    String? otherDeviceToken,
    String? deviceInfo,
    String? otherDeviceInfo,
    bool? isVerified,
    bool? isRestricted,
    bool? isEditor,
    bool? isExceeded,
    int? storageUsed,
    List<CollectionModel>? collections,
    String? userDate,
    bool? profileSetup,
  }) {
    return UserModel(
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      userMail: userMail ?? this.userMail,
      userPassword: userPassword ?? this.userPassword,
      isEditor: isEditor ?? this.isEditor,
      userToken: userToken ?? this.userToken,
      otherDeviceToken: otherDeviceToken ?? this.otherDeviceToken,
      isExceeded: isExceeded ?? this.isExceeded,
      isRestricted: isRestricted ?? this.isRestricted,
      isVerified: isVerified ?? this.isVerified,
      storageUsed: storageUsed ?? this.storageUsed,
      userDate: userDate ?? this.userDate,
      profileSetup: profileSetup ?? this.profileSetup,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      otherDeviceInfo: otherDeviceInfo ?? this.otherDeviceInfo,
    );
  }
}
