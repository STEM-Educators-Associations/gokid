import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalMethods {
  Future<void> saveDeviceInfo(String info) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString('mode', info);
    } catch (e) {
      print('Error saving device info: $e');
    }
  }

  Future<String?> getDeviceInfo() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final result = preferences.getString('mode');
      if (result == 'child_mode') {
        return 'child_mode';
      } else if (result == 'parent_mode') {
        return 'parent_mode';
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving device info: $e');
      return null;
    }
  }

  Future<void> saveTokenToLocalStorage(String userId) async {
    try {
      final utoken = await getUserToken(userId);
      if (utoken != null) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('utoken', utoken);
      } else {
        print('Error saving device token: token is empty !!!!');
      }
    } catch (e) {
      print('Error saving device token: $e');
    }
  }

  Future<void> compareTokens() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

    } catch (e) {
      print('Error comparing tokens: $e');
    }
  }

  Future<String?> getUserToken(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['userToken'] as String?;
      } else {
        print('User document does not exist or has no data');
        return null;
      }
    } catch (e) {
      print('Error getting user token: $e');
      return null;
    }
  }
}
