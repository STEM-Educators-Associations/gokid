import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokid/models/collection_model.dart';
import 'package:gokid/pages/select_image.dart';
import 'package:gokid/utils/showSnackbar.dart';
import 'package:gokid/widgets/custom_button.dart';
import 'package:gokid/widgets/custom_textfield.dart';

import '../services/firebase_auth_methods.dart';
import '../services/firebase_crud_methods.dart';

class CreateCollection extends StatefulWidget {
  static const String routeName = '/create-collection';

  const CreateCollection({Key? key}) : super(key: key);

  @override
  _CreateCollectionState createState() => _CreateCollectionState();
}

class _CreateCollectionState extends State<CreateCollection> {
  late TextEditingController _collectionNameController;
  IconData? _selectedIcon;
  MaterialColor? _selectedColor;
  int? _collectionIconCodePoint;
  String? _collectionIconFontFamily;
  int? _collectionColorValue;

  final List<IconData> _icons = [
    Icons.star,
    Icons.home,
    Icons.water_drop,
    Icons.toys,
    Icons.pets,
    Icons.attach_file,
    Icons.music_note,
    Icons.location_on,
    Icons.fastfood,
    Icons.back_hand,
    Icons.discount,
    Icons.shopping_cart,
    Icons.access_alarm,
    Icons.accessibility,
    Icons.tag_faces,
    Icons.class_,
    Icons.bookmark,
    Icons.card_giftcard,
    Icons.access_time_sharp,
    Icons.stop_circle
  ];

  final List<MaterialColor> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.cyan,
    Colors.brown,
    Colors.grey,
    Colors.purple,
    Colors.blueGrey
  ];

  @override
  void initState() {
    super.initState();
    _collectionNameController = TextEditingController();
  }

  @override
  void dispose() {
    _collectionNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;
    final userModel =
        context.read<FirebaseCrudMethods>().getUserFromFirebase(user.uid);
    final randomNum =
        context.read<FirebaseCrudMethods>().generateRandomNumber();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksiyon Oluştur'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Koleksiyon İsmi Oluşturun. ',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                length: 18,
                controller: _collectionNameController,
                hintText: "Örnek : Temel İhtiyaçlar ",
                hideChar: false,
              ),
              const SizedBox(height: 40),
              const Text('Koleksiyon İkonu Seçin'),
              const Divider(),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20.0,
                children: [
                  for (IconData icon in _icons)
                    IconButton(
                      icon: Icon(icon),
                      onPressed: () {
                        setState(() {
                          _selectedIcon = icon;
                          _collectionIconCodePoint = icon.codePoint;
                          _collectionIconFontFamily = icon.fontFamily;
                        });
                      },
                      color: _selectedIcon == icon ? Colors.blue : Colors.grey,
                    ),
                ],
              ),
              const SizedBox(height: 40),
              const Text('Koleksiyon Rengi Seçin'),
              const SizedBox(height: 10),
              const Text('Renkler, çocukların duygularını ifade etmelerine ve anlamalarını kolaylaştırarak iletişimlerini güçlendirir.',textAlign: TextAlign.center,style:
                TextStyle(color: Colors.grey)

                ,),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 40.0,
                children: [
                  for (MaterialColor color in _colors)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                          _collectionColorValue = color.value;
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: _selectedColor == color
                              ? Border.all(
                                  color: Colors.grey,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              CustomButton(
                onTap: () async {
                  if (_collectionNameController.text.isNotEmpty &&
                      _collectionIconFontFamily != null &&
                      _collectionColorValue != null) {
                    String collectionName = _collectionNameController.text;

                    final user_collection = CollectionModel(
                      userId: user.uid,
                      collectionId: randomNum,
                      collectionName: collectionName,
                      collectionIconCodePoint: _collectionIconCodePoint!,
                      collectionIconFontFamily: _collectionIconFontFamily!,
                      collectionColorValue: _collectionColorValue!,
                    );
                    await context
                        .read<FirebaseCrudMethods>()
                        .createCollectionForUser(user_collection);

                    Navigator.of(context).pop();
                    setState(() {
                      showSnackBar(context,
                          'Güncellemeler sürüyor...',isLoading: true);
                    });
                    setState(() {
                      showSnackBar(context,
                          'Lütfen sayfayı yenileyin.',);
                    });

                  } else {
                    showSnackBar(context, 'Lütfen tüm alanları doldurun!');
                  }
                },
                text: "Oluştur",
              ),
              const SizedBox(height: 10),
              CustomButton(
                onTap: () async {
                  if (_collectionNameController.text.isNotEmpty &&
                      _collectionIconFontFamily != null &&
                      _collectionColorValue != null) {
                    String collectionName = _collectionNameController.text;
                    final user_collection = CollectionModel(
                      userId: user.uid,
                      collectionId: '',
                      collectionName: collectionName,
                      collectionIconCodePoint: _collectionIconCodePoint!,
                      collectionIconFontFamily: _collectionIconFontFamily!,
                      collectionColorValue: _collectionColorValue!,
                    );
                    await context
                        .read<FirebaseCrudMethods>()
                        .createCollectionForUser(user_collection);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImagePickerPage(
                          collectionId: user_collection.collectionId!,
                        ),
                      ),
                    );
                  } else {
                    showSnackBar(context, 'Lütfen tüm alanları doldurun!');
                  }
                },
                text: "Oluştur ve Görsel Ekle",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
