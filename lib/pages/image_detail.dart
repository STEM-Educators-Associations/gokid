import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gokid/models/image_model.dart';
import 'package:gokid/pages/help_center/help_center_home.dart';
import 'package:gokid/pages/navigation_page.dart';
import 'package:gokid/services/firebase_crud_methods.dart';
import 'package:gokid/utils/showSnackbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class ImageEditPage extends StatefulWidget {
  final ImageModel image;

  const ImageEditPage({Key? key, required this.image}) : super(key: key);

  @override
  _ImageEditPageState createState() => _ImageEditPageState();
}

class _ImageEditPageState extends State<ImageEditPage> {
  final FlutterTts flutterTts = FlutterTts();
  TextEditingController nameController = TextEditingController();
  bool isCheckboxEnabled = false;
  String? language;
  double? pitch;
  double? volume;
  double? rate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    nameController.text = widget.image.imageName;
    isCheckboxEnabled = widget.image.isEnabled;
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görseli Düzenleyin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/help-center');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.deepPurple,
                    width: 5.0,
                  ),
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.image.imageURL,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Text(
                      'Görsel ID',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      widget.image.imageId.substring(0,4),
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic,color: Colors.grey),
                      textAlign: TextAlign.start,
                    ),
                  ],),
                ),
              ),

              const SizedBox(height: 8.0),
              TextField(
                controller: nameController,
                maxLength: 20,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () async {
                      Vibration.vibrate(duration: 500);
                      _speak(widget.image.imageName);
                    },
                  ),
                ),
              ),
              Card(
                child: CheckboxListTile(
                  title: Row(
                    children: [
                      Icon(Icons.face),
                      SizedBox(
                        width: 10.0,
                      ),
                      const Text('Çocuk Profiline Eklensin'),
                    ],
                  ),
                  value: isCheckboxEnabled,
                  onChanged: (newValue) {
                    setState(() {
                      isCheckboxEnabled = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              if (isLoading)
                const CircularProgressIndicator(),
              if (!isLoading)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });

                        if (widget.image.isEnabled != true) {
                          await context
                              .read<FirebaseCrudMethods>()
                              .uploadImageAndUpdateChildCollection(
                                  widget.image.userId,
                                  widget.image.imageURL,
                                  widget.image.imageName,
                                  isCheckboxEnabled);
                        }

                        if (widget.image.isEnabled != isCheckboxEnabled) {
                          await context
                              .read<FirebaseCrudMethods>()
                              .updateImageIsEnabled(
                                  widget.image.userId,
                                  widget.image.imageName,
                                  isCheckboxEnabled);

                          await context
                              .read<FirebaseCrudMethods>()
                              .updateImageStatus(
                                  widget.image.userId,
                                  widget.image.imageId,
                                  widget.image.collectionId,
                                  isCheckboxEnabled);
                        }

                        if(nameController.text!= widget.image.imageName){
                          await context
                              .read<FirebaseCrudMethods>()
                              .updateImageName(
                              widget.image.userId,
                              widget.image.imageId,
                              nameController.text);


                          await context
                              .read<FirebaseCrudMethods>()
                              .updateImageName2(
                              widget.image.userId,
                              widget.image.imageId,
                              widget.image.collectionId,
                              nameController.text);
                        }

                        setState(() {
                          showSnackBar(context, 'Güncellemeler sürüyor...',
                              isLoading: true);
                        });

                        setState(() {
                          showSnackBar(context, 'İşlem başarılı.');
                        });
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pushNamedAndRemoveUntil(context, NavigationPage.routeName, (route)=>false);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save,
                            color: Colors.deepPurple,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          const Text('Kaydet'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        bool confirm = await _confirmDelete();
                        if (confirm) {
                          await _deleteImage();
                          showSnackBar(context, 'İşleniyor...',isLoading: true);
                          Navigator.pushNamedAndRemoveUntil(context, NavigationPage.routeName, (route)=>false);



                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          const Text(
                            'Görseli Sil',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              SizedBox(
                height: 30,
              ),
              Divider(),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, HelpCenterHome.routeName);
                  },
                  child: Text('Yardım Merkezi')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateImageDetails() async {
    await context.read<FirebaseCrudMethods>().updateImageName(
          widget.image.userId,
          widget.image.imageId,
          nameController.text,
        );

    await context.read<FirebaseCrudMethods>().updateImageIsEnabled(
          widget.image.userId,
          widget.image.imageName,
          widget.image.isEnabled,
        );

    await context.read<FirebaseCrudMethods>().updateImageStatus(
          widget.image.userId,
          widget.image.imageId,
          widget.image.collectionId,
          widget.image.isEnabled,
        );

    showSnackBar(context, 'Değişiklikler başarıyla kaydedildi.');
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Görsel silinsin mi?'),
              content: const Text(
                  'Bu görsel kalıcı olarak silinecektir. Bu işlem geri alınamaz.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Görseli Sil'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _deleteImage() async {
    await context.read<FirebaseCrudMethods>().deleteImageFromCollection(
          widget.image.userId,
          widget.image.collectionId,
          widget.image.imageId,
        );

    await context.read<FirebaseCrudMethods>().deletePictureFromChild(
          widget.image.userId,
          widget.image.imageURL,
        );

    showSnackBar(context, 'Görsel başarıyla silindi.');
  }
}
