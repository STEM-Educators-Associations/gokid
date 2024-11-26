import 'dart:convert';
import 'package:http/http.dart' as http;

class NotifUtils {
  void sendNotification(String? token, String title, String body) async {
    String url =
        'https://us-central1-gokid-67cae.cloudfunctions.net/sendNotification';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> notification = {
      'token': token,
      'title': title,
      'body': body,
    };

    if (token == null) {
      print('Error: Notification token is null.');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(notification),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
