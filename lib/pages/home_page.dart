import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gokid/models/collection_model.dart';
import 'package:gokid/pages/child_mode/set_up_child_mode.dart';
import 'package:gokid/pages/collections_detail.dart';
import 'package:gokid/pages/navigation_page.dart';
import 'package:gokid/pages/profile/edit_profiles.dart';
import 'package:gokid/pages/settings/settings_main_page.dart';
import 'package:gokid/services/firebase_crud_methods.dart';
import 'package:gokid/services/firebase_auth_methods.dart';
import 'package:gokid/utils/showOtpDialog.dart';
import 'package:gokid/utils/showSnackbar.dart';
import 'package:gokid/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../models/child_model.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";
  bool show_button = true;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;



  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hazır Koleksiyonlar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 300,
                  child: Image.asset('assets/images/ic/upload_photo_ic.png',
                      height: 300),
                ),

                const Text('Daha önce içerik üreticisi tarafından hazırlanmış hazır Koleksiyon şablonlarını indirebilirsiniz.\n\nHazır Koleksiyonlar uygulamanın nasıl çalıştığını anlamanıza yardımcı olur.\n\nŞablonlar indirilecektir.\nOnaylıyor musunuz?'),
                SizedBox(height: 20.0,),


              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Evet'),
              onPressed: () async {
                final userId = context.read<FirebaseAuthMethods>().user.uid;
               if(await checkIfTemplateCollectionsExist(userId)) {
_showLoadingDialog3(context);
               }else {

                 await createTemplateCollectionsForUser(userId);
                 _showLoadingDialog(context);

                 await Future.delayed(Duration(seconds: 5));
                 setState(() {


                   Navigator.pushNamedAndRemoveUntil(
                     context,
                     '/navigation',
                         (route) => false,
                   );
                 });

                 showSnackBar(context, 'Şablonlar başarıyla indirildi.');
                 _showLoadingDialog2(context);
               }

              },
            ),
          ],
        );
      },
    );
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }
  void _showDownloadCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İndirme Tamamlandı'),
          content: const Text('Şablonlar başarıyla indirildi.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void downloadTemplates(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();

      _showDownloadCompleteDialog(context);
    });
  }
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });

    if (_connectionStatus.contains(ConnectivityResult.none)) {
      showSnackBar(context, 'Ağa bağlanırken bir sorun oluştu ://\nLütfen bağlantınızı kontrol edin ve yeniden deneyin.');
     // _showNoInternetDialog(context);
    }

    print('Connectivity changed: $_connectionStatus');
  }


  void _showLoadingDialog2(BuildContext context) {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tebrikler !'),
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    const Icon(Icons.file_download_done,color: Colors.green,size: 100,),
                    const SizedBox(height: 20),
                    const Text("Şimdi koleksiyonlarınıza görsel ekleyin."),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(onPressed: (){Navigator.pop(context);}, child: Text('Tamam'))

              ],
            ),
          ),
        );
      },
    );


  }
  void _showLoadingDialog3(BuildContext context) {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('İşlem Başarısız'),
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
               Icon(Icons.cancel_rounded,size: 150,color: Colors.red,),
                    SizedBox(height: 20,),
                    const Text("Hazır Koleksiyonlar zaten indirilmiş.\n\nBunun yerine kendi Koleksiyonlarınızı oluşturun."),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(onPressed: (){Navigator.pop(context);}, child: Text('Tamam'))

              ],
            ),
          ),
        );
      },
    );


  }

  void _showLoadingDialog(BuildContext context) {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 20),
                    const Text("İndiriliyor...\nBu uzun sürmeyecek.\nLütfen bekleyin."),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(onPressed: (){Navigator.pop(context);}, child: Text('İptal'))

              ],
            ),
          ),
        );
      },
    );


  }

  Future<bool> checkIfTemplateCollectionsExist(String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference userCollections = firestore
          .collection('Users')
          .doc(userId)
          .collection('collections');

      List<String> templateNames = ['Oyuncaklar', 'Yiyecekler', 'Favoriler', 'Kıyafetler'];

      QuerySnapshot querySnapshot = await userCollections
          .where('collectionName', whereIn: templateNames)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }



  Future<void> createTemplateCollectionsForUser(String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference userCollections = firestore
          .collection('Users')
          .doc(userId)
          .collection('collections');

      List<CollectionModel> templateCollections = [
        CollectionModel(
          userId: userId,
          collectionName: 'Oyuncaklar',
          collectionIconFontFamily: 'MaterialIcons',
          collectionIconCodePoint: 0xf455,
          collectionColorValue: 0xFFEF5350,
        ),
        CollectionModel(
          userId: userId,
          collectionName: 'Yiyecekler',
          collectionIconFontFamily: 'MaterialIcons',
          collectionIconCodePoint: 0xf049,
          collectionColorValue: 0xFF66BB6A,
        ),
        CollectionModel(
          userId: userId,
          collectionName: 'Favoriler',
          collectionIconFontFamily: 'MaterialIcons',
          collectionIconCodePoint: 0xe25b,
          collectionColorValue: 0xFFFFA726,
        ),
        CollectionModel(
          userId: userId,
          collectionName: 'Kıyafetler',
          collectionIconFontFamily: 'MaterialIcons',
          collectionIconCodePoint: 0xef4c,
          collectionColorValue: 0xFFAB47BC,
        ),

      ];


      for (var collectionModel in templateCollections) {
        DocumentReference docRef = await userCollections.add({
          'collectionName': collectionModel.collectionName,
          'collectionIconFontFamily': collectionModel.collectionIconFontFamily,
          'collectionColorValue': collectionModel.collectionColorValue,
          'collectionIconCodePoint': collectionModel.collectionIconCodePoint,
        });

        collectionModel.collectionId = docRef.id;


        await docRef.set(collectionModel.toMap());
      }
    } catch (e) {
    }
  }
  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bağlantı Sorunu :('),
          content: const Text(
              'Bilgilerimiz kaybolmuş! 🐾 Lütfen bağlantınızı kontrol edin ve bilgileri tekrar bize getirin.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tekrar Dene'),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, NavigationPage.routeName, (route) => false);
              },
            ),
          ],

        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<FirebaseAuthMethods>().user.uid;
    final crud = context.read<FirebaseCrudMethods>();
    final childModel = crud.getChildrenByUserId(userId);
    final anyChild =
        context.read<FirebaseCrudMethods>().getChildrenByUserId(userId);

    final isReallyVerified =
        context.read<FirebaseCrudMethods>().getVerificationStatus(userId);

    return Scaffold(
      floatingActionButton: Visibility(
        visible: show_button,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
          SizedBox(
          height: 50,
          child: FloatingActionButton.extended(
            heroTag: 12,
            onPressed: () {

              _showConfirmationDialog(context);
            },
            icon: const Icon(Icons.folder_copy),
            label: const Text(
              'Şablonlar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),



            SizedBox(height: 15.0,),

            SizedBox(
              height: 70,
              child: FloatingActionButton.extended(
                heroTag: 12,
                onPressed: () {
                  Navigator.pushNamed(context, '/create-collection');
                },
                icon: const Icon(Icons.collections),
                label: const Text(
                  'Koleksiyon\nOluştur',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<bool?>(
              future: isReallyVerified,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    '',
                    style: TextStyle(fontSize: 10),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (snapshot.data != null && snapshot.data == true) {
                    return SizedBox(
                      height: 0,
                    );
                  } else {
                    return Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              'Doğrulanmamış Hesap',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        CustomButton(
                          text: 'Hesabını Doğrula',
                          onTap: () async {
                            context
                                .read<FirebaseAuthMethods>()
                                .signOut(context);
                            context
                                .read<FirebaseAuthMethods>()
                                .sendEmailVerification(context);
                            showSnackBar(context,
                                'Lütfen hesabınızı doğruladıktan sonra tekrar giriş yapın.');
                          },
                        )
                      ],
                    );
                  }
                }
              },
            ),
            FutureBuilder<List<ChildModel?>>(
              future: anyChild,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    '',
                    style: TextStyle(fontSize: 10),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8,left: 8,top: 2,bottom: 2),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.done_outline_rounded,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              'Hesap kurulumları tamamlandı.',
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              'Çocuk Profili kurulumu tamamlanmadı.',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        CustomButton(
                          text: 'Profil Kurulumunu Tamamla',
                          onTap: () {
                            Navigator.pushNamed(
                                context, SetUpChildModePage.routeName);
                          },
                        )
                      ],
                    );
                  }
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        filled: true,
                        fillColor: const Color(0xffF5F6FA),
                        hintText: 'Koleksiyon Ara',
                      ),
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
            ),
            Expanded(
              flex: 15,
              child: FutureBuilder<List<CollectionModel>>(
                future: crud.getCollectionsByUserId(userId),
                builder: (BuildContext context,
                    AsyncSnapshot<List<CollectionModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: CircularProgressIndicator(
                              strokeWidth: 7,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            'Koleksiyonlar Yükleniyor...',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                          'Bir şeyler ters gitti :( \nLütfen daha sonra tekrar deneyin.'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(
                          height: 250,
                          child: Image.asset(
                            'assets/images/ic/add_image_ic.png',
                            height: 250,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        const Text(
                          "Henüz Koleksiyon Oluşturmadınız",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        const Text(
                          "Görsel eklemek için önce bir Koleksiyon oluşturun.",
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  } else {
                    List<CollectionModel> filteredCollections =
                        snapshot.data!.where((collection) {
                      return collection.collectionName
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                    }).toList();

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 1.0,
                        crossAxisSpacing: 1.0,
                      ),
                      itemCount: filteredCollections.length,
                      itemBuilder: (BuildContext context, int index) {
                        CollectionModel collection = filteredCollections[index];
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onTap: () async {
                              String userId = collection.userId;
                              String collectionId = collection.collectionId!;

                              DocumentReference docRef = FirebaseFirestore
                                  .instance
                                  .collection('Users')
                                  .doc(userId)
                                  .collection('collections')
                                  .doc(collectionId);

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CollectionsDetailPage(
                                    collectionName: collection.collectionName,
                                    collectionIconCodePoint:
                                        collection.collectionIconCodePoint,
                                    collectionIconFontFamily:
                                        collection.collectionIconFontFamily,
                                    collectionColorValue:
                                        collection.collectionColorValue,
                                    docRefId: docRef.id,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color:
                                  Color(collection.collectionColorValue ?? 0),
                              elevation: 4,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      PopupMenuButton(
                                        icon: const Icon(
                                          Icons.more_horiz_rounded,
                                          color: Colors.white,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'delete') {
                                            showNormalAlertDialog(
                                                context: context,
                                                title:
                                                    'Koleksiyon silinsin mi ?',
                                                content:
                                                    'Bu koleksiyonu tamamen silmeden önce içindeki görselleri silmelisiniz. Bu işlem geri alınamaz.',
                                                confirmButtonText: 'Sil',
                                                onPressed: () async {
                                                  if (await crud
                                                      .checkCollectionIsEmpty(
                                                          collection.userId,
                                                          collection
                                                              .collectionId!)) {
                                                    crud.deleteCollectionForUser(
                                                        userId,
                                                        collection
                                                            .collectionId!);
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      showSnackBar(context,
                                                          'İşleniyor...',
                                                          isLoading: true);
                                                    });
                                                  } else {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      showSnackBar(context,
                                                          'Koleksiyon boş olmadığından silinemiyor.\nLütfen ${collection.collectionName} koleksiyonundaki\ntüm görselleri silin\nve yeniden deneyin. ');
                                                    });
                                                  }
                                                });
                                          } else if (value == "more-settings") {
                                            Navigator.pushNamed(context,
                                                SettingsMainPage.routeName);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.redAccent,
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  'Koleksiyonu Sil',
                                                  style: TextStyle(
                                                      color: Colors.redAccent),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'more-settings',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.settings_rounded,
                                                  color: Colors.deepPurple,
                                                ),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  'Daha fazla Ayar',
                                                  style: TextStyle(
                                                      color: Colors.deepPurple),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        IconData(
                                          collection.collectionIconCodePoint,
                                          fontFamily: collection
                                              .collectionIconFontFamily,
                                        ),
                                        color: Colors.white,
                                        size: 70.0,
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            collection.collectionName,
                                            style:
                                                const TextStyle(fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Expanded(
              flex: 6,
              child: FutureBuilder<List<ChildModel>>(
                future: childModel,
                builder: (BuildContext context,
                    AsyncSnapshot<List<ChildModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Bilgiler Yükleniyor...',
                            style: TextStyle(fontSize: 20),
                          )
                        ]);
                  } else {
                    if (snapshot.hasData) {
                      List<ChildModel> children = snapshot.data!.toList();
                      return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 1.0,
                          ),
                          itemCount: children.length,
                          itemBuilder: (BuildContext context, int index) {
                            ChildModel child = children[index];

                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: 5.0, left: 5.0),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    right: 10, left: 10, bottom: 5, top: 5),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.only(
                                                right: 15,
                                                left: 15,
                                                top: 0,
                                                bottom: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            height: 28,
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.face,
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  'Çocuk Profili',
                                                ),
                                              ],
                                            )),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              right: 15,
                                              left: 15,
                                              top: 0,
                                              bottom: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  child.childPhoto,
                                                ),
                                                radius: 28,
                                              ),
                                              SizedBox(
                                                width: 15.0,
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    child.childName,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '${child.childDate} Yaşında',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.grey,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        SizedBox(
                                          child: SizedBox(
                                            height: 25,
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProfiles(
                                                        name: child.childName,
                                                        surname:
                                                            child.childSurname,
                                                        birthDate:
                                                            child.childDate,
                                                        id: child.childId,
                                                        photoId:
                                                            child.childPhoto,
                                                        docId: child.docId,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit),
                                                    SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text('Profili Düzenle')
                                                  ],
                                                )),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2.0,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    } else {
                      return const Text('Bilgiler Yüklenemedi');
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
