import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/blog_model.dart';
import '../models/child_model.dart';
import '../models/collection_model.dart';
import '../models/image_model.dart';
import '../models/user_model.dart';

class FirebaseCrudMethods {
  final FirebaseFirestore _firestore;

  FirebaseCrudMethods(this._firestore);

  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
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

  Future<bool?> getProfileSetupStatus(String userId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('Users').doc(userId).get();
      if (documentSnapshot.exists) {
        bool? setupStatus = documentSnapshot.get('profileSetup');
        return setupStatus;
      } else {
        print('Kullanıcı bulunamadı -> getProfileSetupStatus');
        return null;
      }
    } catch (e) {
      print('Veri alınırken hata oluştu: $e  -> getProfileSetupStatus');
      return null;
    }
  }

  Future<bool?> getVerificationStatus(String userId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('Users').doc(userId).get();
      if (documentSnapshot.exists) {
        bool? nowIsVerified = documentSnapshot.get('isVerified');
        return nowIsVerified;
      } else {
        print('Kullanıcı bulunamadı -> getProfileSetupStatus');
        return null;
      }
    } catch (e) {
      print('Veri alınırken hata oluştu: $e  -> getProfileSetupStatus');
      return null;
    }
  }

  Future<void> updateOtherDeviceToken(String userId, String? token) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'otherDeviceToken': token,
      });
      print('other device token güncellendi ! ');
    } catch (e) {
      print('other device token güncellenemedi !!!!: $e');
    }
  }

  Future<void> updateUserTokenn(String userId, String? token) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'userToken': token,
      });
      print('user token güncellendi ! ');
    } catch (e) {
      print('user token güncellenemedi !!!!: $e');
    }
  }

  Future<bool?> getOtherDeviceTokenForMenu(String userId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('Users').doc(userId).get();
      if (documentSnapshot.exists) {
        String? otherDeviceToken = documentSnapshot.get('otherDeviceToken');
        if (otherDeviceToken != null) {
          return otherDeviceToken.isNotEmpty;
        } else {
          print(
              'other device token alınamadı null geldi !! -> getOtherDeviceToken');
          return null;
        }
      } else {
        print('other device token alınamadı ');
        return null;
      }
    } catch (e) {
      print('other device token alınamadı: $e  ');
      return null;
    }
  }

  Future<void> updateDeviceInfo(String userId, String deviceInfo) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? currentInfo = userData['deviceInfo'] as String?;

        if (currentInfo != deviceInfo) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .update({'deviceInfo': deviceInfo});
          print('User device info updated successfully (local one !!)');
        } else {
          print('New device is the same as the current device');
        }
      } else {
        print('User document does not exist or has no data');
      }
    } catch (e) {
      print('Error updating user token: $e');
    }
  }

  Future<void> updateOtherDeviceInfo(
      String userId, String otherDeviceInfo) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? currentInfo = userData['otherDeviceInfo'] as String?;

        if (currentInfo != otherDeviceInfo) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .update({'otherDeviceInfo': otherDeviceInfo});
          print('other device info updated successfully (local one !!)');
        } else {
          print('New other device is the same as the current device');
        }
      } else {
        print('User document does not exist or has no data');
      }
    } catch (e) {
      print('Error updating user token: $e');
    }
  }

  Future<void> updateUserToken(String userId, String localToken) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? currentToken = userData['userToken'] as String?;

        if (currentToken != localToken) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .update({'otherDeviceToken': localToken});
          print('User token updated successfully (local one !!)');
        } else {
          print(
              'New token is the same as the current token ( same with local one !!)');
        }
      } else {
        print('User document does not exist or has no data');
      }
    } catch (e) {
      print('Error updating user token: $e');
    }
  }

  Future<String?> getOtherDeviceToken(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['otherDeviceToken'] as String?;
      } else {
        print('User document does not exist or has no data');
        return null;
      }
    } catch (e) {
      print('Error getting user token: $e');
      return null;
    }
  }

  Future<void> createUser(UserModel my_user) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('Users').doc(my_user.userId).set({
        'userName': my_user.userName,
        'userId': my_user.userId,
        'userMail': my_user.userMail,
        'userPassword': my_user.userPassword,
        'isVerified': my_user.isVerified,
        'isRestricted': false,
        'isExceeded': false,
        'storageUsed': 0,
        'userDate': my_user.userDate,
        'isEditor': false,
        'profileSetup': false,
        'userToken': my_user.userToken,
        'otherDeviceToken': my_user.otherDeviceToken,
        'deviceInfo': my_user.deviceInfo,
        'otherDeviceInfo': my_user.otherDeviceInfo
      });
    } catch (e) {
      print('Kullanıcı oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<bool> checkTokenValidity(String userId) async {
    final currentDeviceToken = getDeviceToken();
    final dbToken = getUserToken(userId);

    if (currentDeviceToken != dbToken) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> verifyPassword(String email, String password) async {
    try {
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);
      User? user = FirebaseAuth.instance.currentUser;

      UserCredential authResult =
          await user!.reauthenticateWithCredential(credential);
      return authResult.user != null;
    } catch (e) {
      print('Şifre doğrulama hatası: $e');
      return false;
    }
  }

  Future<bool> updateUserProfile(UserModel user) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Map<String, dynamic> updatedData = {
        'userName': user.userName,
        'userDate': user.userDate,
        'userPassword': user.userPassword
      };

      await firestore.collection('Users').doc(user.userId).update(updatedData);

      print('Kullanıcı başarıyla güncellendi.');
      return true;
    } catch (e) {
      print('Kullanıcı güncellenirken bir hata oluştu: $e');
      return false;
    }
  }

  Future<UserModel?> getUserFromFirebase(String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await firestore.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data()!;

        UserModel user = UserModel(
          userName: userData['userName'],
          userId: userData['userId'],
          userMail: userData['userMail'],
          userPassword: userData['userPassword'],
          isVerified: userData['isVerified'],
          isRestricted: userData['isRestricted'],
          isEditor: userData['isEditor'],
          isExceeded: userData['isExceeded'],
          storageUsed: userData['storageUsed'],
          userDate: userData['userDate'],
          profileSetup: userData['profileSetup'],
          userToken: userData['userToken'],
          otherDeviceToken: userData['otherDeviceToken'],
          deviceInfo: userData['deviceInfo'],
          otherDeviceInfo: userData['otherDeviceInfo'],
        );

        return user;
      } else {
        print('Belirtilen kullanıcı bulunamadı.');
        return null;
      }
    } catch (e) {
      print('Kullanıcı alınırken bir hata oluştu: $e');
      return null;
    }
  }

  Future<void> updateVerificationStatus(String userId, bool status) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('Users').doc(userId).update({
        'isVerified': status,
      });

      print('Kullanıcı hesap doğrulama bilgisi başarıyla güncellendi.');
    } catch (e) {
      print(
          'Kullanıcı hesap doğrulama bilgisi güncellenirken bir hata oluştu: $e');
    }
  }

  Future<void> uploadImageAndUpdateChildCollection(
      String userId, String imageUrl, String imageName, bool newValue) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot querySnapshot = await firestore
          .collection('Children')
          .where('childId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Belirtilen userId ile eşleşen çocuk bulunamadı.');
        return;
      }

      DocumentSnapshot childDoc = querySnapshot.docs.first;
      final childDocRef = childDoc.reference;

      QuerySnapshot existingImageSnapshot = await childDocRef
          .collection('pictures')
          .where('imageURL', isEqualTo: imageUrl)
          .get();

      if (existingImageSnapshot.docs.isNotEmpty) {
        print('Aynı görsel zaten mevcut.');
        return;
      }

      final ImageModel newImage = ImageModel(
        isEnabled: newValue,
        userId: userId,
        imageId: '',
        imageName: imageName,
        imageURL: imageUrl,
        collectionId: childDoc.id,
      );

      DocumentReference imageDocRef =
          await childDocRef.collection('pictures').add(newImage.toMap());

      await imageDocRef.update({'imageId': imageDocRef.id});

      print('Resim başarıyla yüklendi ve koleksiyona eklendi.');
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  Future<void> updateImageIsEnabled(
      String userId, String imageName, bool newValue) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot querySnapshot = await firestore
          .collection('Children')
          .where('childId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Belirtilen userId ile eşleşen çocuk bulunamadı.');
        return;
      }

      DocumentSnapshot childDoc = querySnapshot.docs.first;

      final childDocRef = childDoc.reference;

      QuerySnapshot pictureSnapshot = await childDocRef
          .collection('pictures')
          .where('imageName', isEqualTo: imageName)
          .get();

      if (pictureSnapshot.docs.isEmpty) {
        print('Belirtilen imageName ile eşleşen resim bulunamadı.');
        return;
      }

      DocumentSnapshot imageDoc = pictureSnapshot.docs.first;
      await imageDoc.reference.update({'isEnabled': newValue});

      print('Resmin isEnabled durumu başarıyla güncellendi.');
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  Future<void> updateImageStatus(String userId, String pictureId,
      String collectionId, bool newStatus) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference pictureDoc = firestore
          .collection('Users')
          .doc(userId)
          .collection('collections')
          .doc(collectionId)
          .collection('pictures')
          .doc(pictureId);

      DocumentSnapshot pictureSnapshot = await pictureDoc.get();
      print(newStatus);

      if (pictureSnapshot.exists) {
        bool currentStatus = pictureSnapshot.get('isEnabled') as bool;
        newStatus = !currentStatus;

        await pictureDoc.update({
          'isEnabled': newStatus,
        });

        print('Picture status successfully updated to $newStatus.');

        CollectionReference childrenCollection =
            firestore.collection('Users').doc(userId).collection('children');

        QuerySnapshot childrenSnapshot = await childrenCollection.get();

        for (QueryDocumentSnapshot child in childrenSnapshot.docs) {
          DocumentReference childPictureDoc =
              child.reference.collection('pictures').doc(pictureId);

          DocumentSnapshot childPictureSnapshot = await childPictureDoc.get();

          if (childPictureSnapshot.exists) {
            await childPictureDoc.update({
              'isEnabled': newStatus,
            });
            print('Picture status in child collection updated to $newStatus.');
          }
        }
      } else {
        print('Picture with ID $pictureId does not exist.');
      }
    } catch (e) {
      print('An error occurred while updating picture status: $e');
    }
  }




  Future<void> createCollectionForUser(CollectionModel collectionModel) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference userCollections = firestore
          .collection('Users')
          .doc(collectionModel.userId)
          .collection('collections');

      DocumentReference docRef = await userCollections.add({
        'collectionName': collectionModel.collectionName,
        'collectionIconFontFamily': collectionModel.collectionIconFontFamily,
        'collectionColorValue': collectionModel.collectionColorValue,
        'collectionIconCodePoint': collectionModel.collectionIconCodePoint,
      });

      collectionModel.collectionId = docRef.id;

      await docRef.set(collectionModel.toMap());
    } catch (e) {
      print('Kullanıcı oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<void> updateChild(String docId, ChildModel updatedChild) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference children = firestore.collection('Children');

      DocumentReference docRef = children.doc(docId);

      await docRef.update({
        'childName': updatedChild.childName,
        'childPhoto': updatedChild.childPhoto,
        'childDate': updatedChild.childDate,
        'childSurname': updatedChild.childSurname,
      });

      print('Çocuk verileri başarıyla güncellendi!');
    } catch (e) {
      print('Çocuk verileri güncellenirken bir hata oluştu: $e');
    }
  }

  Future<void> createChild(ChildModel myChild, String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference children = firestore.collection('Children');

      DocumentReference docRef = children.doc();

      String docId = docRef.id;

      await docRef.set({
        'docId': docId,
        'childId': userId,
        'childName': myChild.childName,
        'childPhoto': myChild.childPhoto,
        'childDate': myChild.childDate,
        'childSurname': myChild.childSurname
      });

      myChild.childId = docId;
    } catch (e) {
      print('Çocuk Modu oluşturulurken bir hata oluştu: $e');
    }
  }

  Future<String?> getDeviceToken() async {
    if (Platform.isAndroid) {
      final String? token = await FirebaseMessaging.instance.getToken();
      return token;
    }
    return null;
  }

  Future<void> addPicturesToChildCollection(
      String collectionId, String userId, List<ImageModel> pictures) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference picturesCollection = firestore
          .collection('Children')
          .doc(collectionId)
          .collection('pictures');

      for (var picture in pictures) {
        await picturesCollection.add(picture.toMap());
      }
    } catch (e) {
      print('Görseller eklenirken bir hata oluştu: $e');
    }
  }

  Future<List<CollectionModel>> getCollectionsByUserId(String userId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot querySnapshot = await firestore
          .collection('Users')
          .doc(userId)
          .collection('collections')
          .get();
      List<CollectionModel> collections = querySnapshot.docs.map((doc) {
        return CollectionModel(
          userId: userId,
          collectionId: doc['collectionId'],
          collectionName: doc['collectionName'],
          collectionIconFontFamily: doc['collectionIconFontFamily'],
          collectionColorValue: doc['collectionColorValue'],
          collectionIconCodePoint: doc['collectionIconCodePoint'],
        );
      }).toList();
      return collections;
    } catch (e) {
      print('Koleksiyonlar alınırken hata oluştu: $e');
      return [];
    }
  }

  Future<List<ChildModel>> getChildrenByUserId(String userId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot querySnapshot = await firestore
          .collection('Children')
          .where('childId', isEqualTo: userId)
          .get();

      List<ChildModel> children = querySnapshot.docs.map((doc) {
        return ChildModel(
          childName: doc['childName'],
          childPhoto: doc['childPhoto'],
          childId: doc['childId'],
          childSurname: doc['childSurname'],
          childDate: doc['childDate'],
          docId: doc['docId'],
        );
      }).toList();
      return children;
    } catch (e) {
      print('Çocuk profilleri alınırken bir hata oldu: $e');
      return [];
    }
  }

  Future<void> deleteCollectionForUser(
      String userId, String collectionId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference collectionRef = firestore
          .collection('Users')
          .doc(userId)
          .collection('collections')
          .doc(collectionId);

      await collectionRef.delete();

      print('Koleksiyon başarıyla silindi.');
    } catch (e) {
      print('Koleksiyon silinirken bir hata oluştu: $e');
    }
  }


  Future<bool> checkCollectionIsEmpty(String userId, String collectionId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      CollectionReference collectionRef = firestore
          .collection('Users')
          .doc(userId)
          .collection('collections')
          .doc(collectionId)
          .collection('pictures');

      QuerySnapshot querySnapshot = await collectionRef.limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        print('Koleksiyon boş.');
        return true;
      } else {
        print('Koleksiyon boş değil.');
        return false;
      }
    } catch (e) {
      print('Koleksiyon kontrol edilirken bir hata oluştu: $e');
      return false;
    }
  }


  Future<void> updateImageName2(String userId, String imageId,
      String collectionId, String newName) async {
    try {
      DocumentReference documentReference = _firestore
          .collection('Users')
          .doc(userId)
          .collection('collections')
          .doc(collectionId)
          .collection('pictures')
          .doc(imageId);

      await documentReference.update({
        'imageName': newName,
      });

      print('görsel ismi Users koleksiyonu için güncellendi.');
    } catch (e) {
      print('görsel ismi güncellenirken bir hata oluştu > Users koleksiyonu: $e');
    }
  }

  Future<void> updateImageName(
      String userId, String imageId, String newImageName) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot querySnapshot = await firestore
          .collection('Children')
          .where('childId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Belirtilen userId ile eşleşen çocuk bulunamadı.');
        return;
      }

      DocumentSnapshot childDoc = querySnapshot.docs.first;

      final childDocRef = childDoc.reference;

      final picturesCollection = childDocRef.collection('pictures');

      QuerySnapshot imageQuerySnapshot =
          await picturesCollection.where('userId', isEqualTo: userId).get();

      if (imageQuerySnapshot.docs.isEmpty) {
        print('Belirtilen imageId ile eşleşen resim bulunamadı.');
        return;
      }

      DocumentSnapshot imageDoc = imageQuerySnapshot.docs.first;

      await imageDoc.reference.update({'imageName': newImageName});

      print('görsel ismi Children koleksiyonu için güncellendi.');
    } catch (e) {
      print('görsel ismi güncellenemedi > Children koleksiyonu: $e');
    }
  }

  Future<void> deleteImageFromCollection(
      String userId, String collectionId, String imageId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference imageRef = firestore
          .collection('Users')
          .doc(userId)
          .collection('collections')
          .doc(collectionId)
          .collection('pictures')
          .doc(imageId);

      await imageRef.delete();
      print('Koleksiyon içindeki bir görsel başarıyla silindi.');
    } catch (e) {
      print('Koleksiyon içindeki bir görsel silinirken bir hata oluştu: $e');
    }
  }

  Future<void> createAccountDeletionRequest(UserModel user) async {
    try {
      await _firestore.collection('Feedback').add({
        'userId': user.userId,
        'userName': user.userName,
        'userMail': user.userMail,
        'requestedAt': FieldValue.serverTimestamp(),
        'reason': 'Account deletion request',
      });

      print('Hesap silme isteği başarıyla gönderildi.');
    } catch (e) {
      print('Hesap silme isteği gönderilemedi: $e');
      rethrow;
    }
  }



  Future<void> deletePictureFromChild(String userId, String imageUrl) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot querySnapshot = await firestore
          .collection('Children')
          .where('childId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Belirtilen userId ile eşleşen çocuk bulunamadı.');
        return;
      }

      DocumentSnapshot childDoc = querySnapshot.docs.first;
      final childDocRef = childDoc.reference;

      QuerySnapshot picturesSnapshot = await childDocRef
          .collection('pictures')
          .where('userId', isEqualTo: userId)
          .get();

      if (picturesSnapshot.docs.isEmpty) {
        print('Belirtilen URL ile eşleşen resim bulunamadı.');
        return;
      }

      DocumentSnapshot pictureDoc = picturesSnapshot.docs.first;
      await pictureDoc.reference.delete();

      print('Resim başarıyla silindi.');
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  Future<List<ImageModel>> getPicturesFromCollections(
      String userId, String documentId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('Users')
          .doc(userId)
          .collection('collections')
          .doc(documentId)
          .collection('pictures')
          .get();

      List<ImageModel> images = querySnapshot.docs.map((doc) {
        return ImageModel(
          isEnabled: doc['isEnabled'],
          imageId: doc['imageId'],
          imageURL: doc['imageURL'],
          userId: doc['userId'],
          imageName: doc['imageName'],
          collectionId: doc['collectionId'],
        );
      }).toList();

      return images;
    } catch (e) {
      print('Hata oluştu: $e');
      return [];
    }
  }

  Future<List<ImageModel>> getPicturesFromChildrenCollections(
      String childId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot childSnapshot = await firestore
          .collection('Children')
          .where('childId', isEqualTo: childId)
          .get();

      if (childSnapshot.docs.isEmpty) {
        print('Belirtilen kimlik bilgisi ile eşleşen çocuk bulunamadı.');
        return [];
      }

      List<ImageModel> images = [];

      for (var childDoc in childSnapshot.docs) {
        QuerySnapshot pictureSnapshot =
            await childDoc.reference.collection('pictures').get();
        for (var pictureDoc in pictureSnapshot.docs) {
          images.add(
              ImageModel.fromMap(pictureDoc.data() as Map<String, dynamic>));
        }
      }

      return images;
    } catch (e) {
      print('Hata oluştu: $e');
      return [];
    }
  }

  Future<List<ImageModel>> getImagesFromFirebase(
      String userId, String collectionId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference picturesCollection = firestore
          .collection('Users')
          .doc(userId)
          .collection('collections')
          .doc(collectionId)
          .collection('pictures');

      QuerySnapshot querySnapshot = await picturesCollection.get();

      List<ImageModel> images = querySnapshot.docs.map((doc) {
        return ImageModel(
          isEnabled: doc['isEnabled'],
          userId: userId,
          imageId: doc.id,
          imageName: doc['imageName'],
          imageURL: doc['imageURL'],
          collectionId: doc['collectionId'],
        );
      }).toList();

      return images;
    } catch (e) {
      print('görseller alınırken bir hata oluştu: $e');
      return [];
    }
  }

  Future<List<BlogModel>> getBlogsFromFirebaseForUser(String userId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('Blogs')
          .where('userId', isEqualTo: userId)
          .get();

      List<BlogModel> blogs = querySnapshot.docs.map((doc) {
        return BlogModel(
          createdAt: (doc['createdAt'] as Timestamp).toDate(),
          id: doc.id,
          title: doc['title'] ?? '',
          subtitle: doc['subtitle'] ?? '',
          sources: doc['sources'] ?? '',
          image: doc['image'] ?? '',
          likes: doc['likes'] ?? 0,
          banned: doc['banned'] ?? false,
          readingTime: doc['readingTime'] ?? 0,
          userName: doc['userName'] ?? '',
          userId: doc['userId'] ?? '',
          likedBy: doc['likedBy'] ?? [],
          isEditor: doc['isEditor'] ?? '',
        );
      }).toList();
      return blogs;
    } catch (e) {
      print('Bloglar alınırken bir hata oluştu : $e');
      return [];
    }
  }

  Future<List<BlogModel>> getBlogsFromFirebase() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await firestore.collection('Blogs').get();

      List<BlogModel> blogs = querySnapshot.docs.map((doc) {
        return BlogModel(
          createdAt: (doc['createdAt'] as Timestamp).toDate(),
          id: doc.id,
          title: doc['title'] ?? '',
          subtitle: doc['subtitle'] ?? '',
          sources: doc['sources'] ?? '',
          image: doc['image'] ?? '',
          likes: doc['likes'] ?? 0,
          banned: doc['banned'] ?? false,
          readingTime: doc['readingTime'] ?? 0,
          userName: doc['userName'] ?? '',
          userId: doc['userId'] ?? '',
          likedBy: doc['likedBy'] ?? [],
          isEditor: doc['isEditor'] ?? '',
        );
      }).toList();
      return blogs;
    } catch (e) {
      print('Bloglar alınırken bir hata oluştu : $e');
      return [];
    }
  }

  Future<void> createBlogInFirebase(BlogModel blog) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference docRef = firestore.collection('Blogs').doc(blog.userId);

      await docRef.set({
        'createdAt': blog.createdAt,
        'title': blog.title,
        'subtitle': blog.subtitle,
        'sources': blog.sources,
        'image': blog.image,
        'likes': blog.likes,
        'banned': blog.banned,
        'readingTime': blog.readingTime,
        'userName': blog.userName,
        'userId': blog.userId,
        'likedBy': blog.likedBy,
        'isEditor': false
      });

      print('Blog başarıyla oluşturuldu.');
    } catch (e) {
      print('Blog oluşturulurken bir hata oluştu : $e');
    }
  }

  String generateRandomNumber() {
    Random random = Random();

    int randomNumber = random.nextInt(90000) + 10000;

    return randomNumber.toString();
  }
}
