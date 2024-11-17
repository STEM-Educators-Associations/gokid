import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gokid/models/image_model.dart';
import 'package:gokid/pages/select_image.dart';
import 'package:gokid/services/firebase_crud_methods.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../services/firebase_auth_methods.dart';
import 'image_detail.dart';

class CollectionsDetailPage extends StatefulWidget {
  final String collectionName;
  final int collectionIconCodePoint;
  final String collectionIconFontFamily;
  final int collectionColorValue;
  final String docRefId;
  static String routeName = '/collections-detail';



  const CollectionsDetailPage({
    Key? key,
    required this.collectionName,
    required this.collectionIconCodePoint,
    required this.collectionIconFontFamily,
    required this.collectionColorValue,
    required this.docRefId,
  }) : super(key: key);

  @override
  State<CollectionsDetailPage> createState() => _CollectionsDetailPageState();
}

class _CollectionsDetailPageState extends State<CollectionsDetailPage> {
  final FlutterTts flutterTts = FlutterTts();
  TextEditingController nameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String searchText = "";
  String? language;
  double? pitch;
  double? volume;
  double? rate;
  @override
  void initState() {
    super.initState();
    _loadSettings(); }


  Future<void> _speak(String text) async {
    try {
      await flutterTts.getDefaultEngine;
      await flutterTts.setLanguage(language ?? 'tr-TR');
      await flutterTts.setPitch(pitch ?? 1.0);
      await flutterTts.setVolume(volume ?? 1.0);
      await flutterTts.setSpeechRate(rate ?? 0.5);
      await flutterTts.speak(text);
    } catch (e) {
      print("Text-to-Speech hatası: $e");
    }
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      language = prefs.getString('selectedLanguage') ?? 'tr-TR';
      pitch = prefs.getDouble('pitch') ?? 1.0;
      volume = prefs.getDouble('volume') ?? 1.0;
      rate = prefs.getDouble('rate') ?? 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    final getPictures = context
        .read<FirebaseCrudMethods>()
        .getPicturesFromCollections(user.uid, widget.docRefId);

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.collectionName} Koleksiyonu"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: const Color(0xffF5F6FA),
                hintText: 'Görseli İsmiyle Aratın',
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),
        ),

      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    ImagePickerPage(collectionId: widget.docRefId)),
          );
        },
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Görsel Ekle'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder<List<ImageModel>>(
          future: getPictures,
          builder:
              (BuildContext context, AsyncSnapshot<List<ImageModel>> snapshot) {
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
                  'Görseller Yükleniyor...',
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
          );
            } else {
              if (snapshot.hasData) {
                List<ImageModel> filteredImages = snapshot.data!.where((image) {
                  return image.imageName.toLowerCase().contains(searchText);
                }).toList();

                if (filteredImages.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Image.asset('assets/images/bg/cat_bg.png', height: 300),
                      const SizedBox(height: 10.0),
                      const Text(
                        "Henüz Görsel Eklemediniz.",
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                } else {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                    ),
                    itemCount: filteredImages.length,
                    itemBuilder: (BuildContext context, int index) {
                      ImageModel image = filteredImages[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>  ImageEditPage(image: image),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Image.network(
                              image.imageURL,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              } else {
                return const Text(
                    'Bir şeyler ters gitti :( \nLütfen daha sonra tekrar deneyin.');
              }
            }
          },
        ),
      ),
    );
  }





}
