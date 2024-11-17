import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gokid/services/firebase_crud_methods.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';
import '../utils/showSnackbar.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth;

  FirebaseAuthMethods(this._auth);

  // FOR EVERY FUNCTION HERE
  // POP THE ROUTE USING: Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);

  // GET USER DATA
  // using null check operator since this method should be called only
  // when the user is logged in
  User get user => _auth.currentUser!;

  // STATE PERSISTENCE STREAM
  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();

  // OTHER WAYS (depends on use case):
  // Stream get authState => FirebaseAuth.instance.userChanges();
  // Stream get authState => FirebaseAuth.instance.idTokenChanges();
  // KNOW MORE ABOUT THEM HERE: https://firebase.flutter.dev/docs/auth/start#auth-state

  // EMAIL SIGN UP
  Future<void> signUpWithEmail({
    required String userName,
    required String email,
    required String date,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final token = await getToken();
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      String deviceDetails = 'Desteklenmeyen Platform';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceDetails = "${androidInfo.brand} ${androidInfo.device}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        deviceDetails = "${iosDeviceInfo.name} ${iosDeviceInfo.model}";
      }

      UserModel myUser = UserModel(
        userName: userName,
        userMail: email,
        userId: FirebaseAuth.instance.currentUser!.uid,
        userPassword: password,
        isExceeded: false,
        isVerified: false,
        isRestricted: false,
        isEditor: false,
        storageUsed: 0,
        userDate: date,
        profileSetup: false,
        userToken: token,
        otherDeviceToken: '',
        deviceInfo: deviceDetails,
        otherDeviceInfo: '',
      );

      if (!context.mounted) return;
      context.read<FirebaseCrudMethods>().createUser(myUser);

      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        if (!context.mounted) return;
        await sendEmailVerification(context);
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/wait-verification',
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      if (e.code == 'weak-password') {
        showSnackBar(context, 'Daha güçlü bir şifre oluşturun.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context, 'Bu e-posta adresi zaten kullanımda.');
      } else if (e.code == 'invalid-email') {
        showSnackBar(context, 'Geçersiz bir e-posta adresi girdiniz.');
      } else if (e.code == 'operation-not-allowed') {
        showSnackBar(context, 'Bu işlemin yapılmasına izin verilmiyor.');
      } else if (e.code == 'network-request-failed') {
        showSnackBar(context, 'İnternet bağlantısı başarısız.');
      } else {
        showSnackBar(context, e.message ?? 'Bilinmeyen bir hata oluştu.');
      }
      print(e.message);
    }
  }


  // EMAIL LOGIN
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    print('testt');
    final localToken = preferences.getString('utoken');
    print('testt2');

    if (!context.mounted) return;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        if (!context.mounted) return;
        await sendEmailVerification(context);
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/wait-verification',
              (route) => false,
        );
      } else {
        if (!context.mounted) return;
        context.read<FirebaseCrudMethods>().updateVerificationStatus(user!.uid, true);

        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/intro-screen-main',
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi girdiniz.';
          break;
        case 'user-disabled':
          errorMessage = 'Bu kullanıcı devre dışı bırakılmış.';
          break;
        case 'user-not-found':
          errorMessage = 'Bu e-posta ile kayıtlı bir kullanıcı bulunamadı.';
          break;
        case 'wrong-password':
          errorMessage = 'Yanlış şifre girdiniz.';
          break;
        case 'too-many-requests':
          errorMessage = 'Çok fazla başarısız deneme yapıldı, lütfen daha sonra tekrar deneyin.';
          break;
        default:
          errorMessage = 'Giriş işlemi sırasında bir hata oluştu.';
      }

      showSnackBar(context, errorMessage);
    }
  }


  // EMAIL VERIFICATION
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, 'E-Posta doğrulama bağlantısı gönderildi.');

    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }


//GOOGLE SIGN IN
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          String email = user.email!;
          String userName = user.displayName!;
          String userId = user.uid;
          String userPassword = 'signed-in-with-google-no-password';
          bool isExceeded = false;
          bool isVerified = true;
          bool isRestricted = false;
          int storageUsed = 0;
          DateTime userDate = DateTime.now();
          final tokenForGoogleSignIn = await getToken();

          final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
          final doc = await userRef.get();

          if (!doc.exists) {
            UserModel myUser = UserModel(
              userName: userName,
              userMail: email,
              userId: userId,
              userPassword: userPassword,
              isExceeded: isExceeded,
              isVerified: isVerified,
              isRestricted: isRestricted,
              storageUsed: storageUsed,
              userDate: userDate.toString(),
              profileSetup: false,
              userToken: tokenForGoogleSignIn,
              isEditor: false,
              otherDeviceToken: '',
              deviceInfo: '',
              otherDeviceInfo: '',
            );

            if (!context.mounted) return;
            context.read<FirebaseCrudMethods>().createUser(myUser);
          }

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/intro-screen-main',
                (route) => false,
          );
        }
      } else {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Google hesabı ile giriş yapmaktan vazgeçtiniz.',
        );
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }


// APPLE SIGN IN
  Future<void> signInWithApple(BuildContext context) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null || appleCredential.authorizationCode == null) {
        throw FirebaseAuthException(
          code: 'ERROR_INVALID_CREDENTIAL',
          message: 'Apple kimlik bilgileri alınamadı. Lütfen tekrar deneyin.',
        );
      }

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      User? user = userCredential.user;

      if (user != null) {
        String email = user.email ?? 'no-email@example.com';
        String userName = user.displayName ?? appleCredential.givenName ?? 'Unknown';
        String userId = user.uid;
        String userPassword = 'signed-in-with-apple-no-password';
        bool isExceeded = false;
        bool isVerified = user.emailVerified;
        bool isRestricted = false;
        int storageUsed = 0;
        DateTime userDate = DateTime.now();
        final tokenForAppleSignIn = await getToken();

        final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
        final doc = await userRef.get();

        if (!doc.exists) {
          UserModel myUser = UserModel(
            userName: userName,
            userMail: email,
            userId: userId,
            userPassword: userPassword,
            isExceeded: isExceeded,
            isVerified: isVerified,
            isRestricted: isRestricted,
            storageUsed: storageUsed,
            userDate: userDate.toString(),
            profileSetup: false,
            userToken: tokenForAppleSignIn,
            isEditor: false,
            otherDeviceToken: '',
            deviceInfo: '',
            otherDeviceInfo: '',
          );

          if (!context.mounted) return;

          context.read<FirebaseCrudMethods>().createUser(myUser);
        }

        if (!context.mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/intro-screen-main',
              (route) => false,
        );
      } else {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Apple Kimliği ile giriş yapmaktan vazgeçtiniz.',
        );
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      showSnackBar(context, e.message!);
    } catch (e) {
      print("Error during Apple Sign-In: $e");
      showSnackBar(context, e.toString());
    }
  }


  Future<String?> getToken() async {
    try {
      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      final token = await _firebaseMessaging.getToken();
      print("User messaging token: $token");
      return token;
    } catch (e) {
      print('Error getting user messaging token: $e');
    }
    return null;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
}
