import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../models/image_model.dart';
import '../services/firebase_auth_methods.dart';
import '../utils/showSnackbar.dart';
import '../widgets/custom_button.dart';

class ImagePickerPage extends StatefulWidget {
  final String collectionId;
  static String routeName = '/select-image';

  const ImagePickerPage({Key? key, required this.collectionId})
      : super(key: key);

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  File? _image;
  bool show_loading = false;
  bool show_warning = true;
  bool c_okey = true;
  bool _uploading = false;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File compressedImage = await _compressImage(File(image.path));
      setState(() {
        _image = compressedImage;
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      File compressedPhoto = await _compressImage(File(photo.path));
      setState(() {
        _image = compressedPhoto;
      });
    }
  }

  Future<File> _compressImage(File imageFile) async {
    final String targetPath =
        imageFile.path.replaceAll('.jpg', '_compressed.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      targetPath,
      quality: 20,
      minWidth: 1000,
      minHeight: 1000,
    );
    print('görsel başarıyla sıkıştırıldı!');

    return File(result!.path);
  }

  Future<void> _showNameDialog(BuildContext context) async {
    String imageName = '';
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Görsele bir isim verin.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                  'Bu daha sonra seslendirmede kullanılacaktır.',style: TextStyle(color: Colors.purple),),
              TextField(
                maxLength: 20,
                onChanged: (value) {
                  imageName = value.trim();
                },
                decoration:
                    const InputDecoration(hintText: 'Bu nedir? Örnek : Suluk'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, imageName);
                final user = context.read<FirebaseAuthMethods>().user;
                await uploadImageAndUpdateCollection(
                    user.uid, widget.collectionId, imageName, _image!);

              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadImageAndUpdateCollection(String userId,
      String collectionId, String fileName, File imageFile) async {
    try {
      if (imageFile == null) return;

      final String imageName = fileName.isNotEmpty
          ? fileName
          : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final Reference ref =
          FirebaseStorage.instance.ref().child('compressed_images/$imageName');
      final UploadTask uploadTask = ref.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        final String downloadUrl = await ref.getDownloadURL();

        final ImageModel newImage = ImageModel(
          isEnabled: false,
          userId: userId,
          imageId: '',
          imageName: imageName,
          imageURL: downloadUrl,
          collectionId: collectionId,
        );

        final userDocRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('collections')
            .doc(collectionId);

        final picturesCollection = userDocRef.collection('pictures');
        DocumentReference imageDocRef =
            await picturesCollection.add(newImage.toMap());

        await imageDocRef.update({'imageId': imageDocRef.id});
      });
    } catch (e) {
      showSnackBar(context,
          'Hata oluştu: $e');
      print('Hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görsel Seç ve Yükle'),
        actions: [
          Visibility(
            visible: show_loading,
            child: const SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/help-center');
            },
            icon: const Icon(
              Icons.help,
              color: Colors.black26,
            ),
          )
        ],
      ),
      body: _uploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.deepPurpleAccent,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text('Görsel Yükleniyor...')
                ],
              ),
            )
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Visibility(
                            visible: c_okey,
                            child: Image.asset(
                              'assets/images/ic/select_photo_ic.png',
                              height: 350,
                            )),
                        Visibility(
                          visible: show_warning,
                          child: const ListTile(
                            leading: Icon(
                              Icons.info,
                              color: Colors.grey,
                            ),
                            title: Text(
                              'Görselin net ve diğer objelerden arınmış olduğundan emin olun.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: show_warning,
                          child: const ListTile(
                            leading: Icon(
                              Icons.info,
                              color: Colors.grey,
                            ),
                            title: Text(
                              'Yüklediğiniz görsel daha sonra koleksiyonunuzda gözükecektir.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: show_warning,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                show_warning = false;
                              });
                            },
                            child: const Text('Anlıyorum'),
                          ),
                        ),
                        Visibility(visible: show_warning, child: const Divider()),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (_image != null)
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                              width: 1000,
                              child: Image.file(_image!),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 40),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  'Bu görsel yüklemek için uygundur.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    Visibility(
                      visible: c_okey,
                      child: CustomButton(
                        onTap: () async {
                          await _pickImage();
                          setState(() {
                            c_okey = false;
                          });
                        },
                        text: 'Galeriden Seçin',
                      ),
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Visibility(
                        visible: c_okey,
                        child: const Text(
                          'veya',
                          style: TextStyle(color: Colors.grey),
                        )),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Visibility(
                      visible: c_okey,
                      child: CustomButton(
                        onTap: () {
                          _takePhoto();
                          setState(() {
                            c_okey = false;
                          });
                        },
                        text: 'Bir Fotoğraf Çekin',
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Visibility(
                      visible: _image != null,
                      child: CustomButton(
                        onTap: () async {
                          await _showNameDialog(context);
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/navigation', (route) => false);
                          showSnackBar(context, 'İşleniyor...',isLoading: true);

                        },
                        text: 'Görseli Yükle',
                      ),
                    ),
                    SizedBox(height: 50,)
                  ],
                ),
              ),
            ),
    );
  }
}
