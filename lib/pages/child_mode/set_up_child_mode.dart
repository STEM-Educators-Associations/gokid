import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokid/pages/check_token/check_token.dart';
import 'package:gokid/pages/help_center/help_center_home.dart';
import 'package:gokid/widgets/custom_button.dart';
import 'package:gokid/widgets/custom_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:url_launcher/url_launcher.dart';

import '../../models/child_model.dart';
import '../../services/firebase_auth_methods.dart';
import '../../services/firebase_crud_methods.dart';
import '../../utils/showSnackbar.dart';
import '../age_picker.dart';

class SetUpChildModePage extends StatefulWidget {
  static const String routeName = '/set-up-child-mode';

  SetUpChildModePage({Key? key}) : super(key: key);

  @override
  _SetUpChildModePageState createState() => _SetUpChildModePageState();
}

class _SetUpChildModePageState extends State<SetUpChildModePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  int _age = 5;

  String? _childPhoto;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _childPhoto = image.path;
      });
    }
  }
  void _navigateToAgePicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgePickerScreen(
          initialAge: _age,
          onAgeChanged: (age) {
            setState(() {
              _age = age;
              _ageController.text = _age.toString();
            });
          },
        ),
      ),
    );
  }

  Future<String> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('child_photos')
        .child(fileName);

    firebase_storage.UploadTask uploadTask = ref.putFile(image);
    await uploadTask;

    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çocuk Modu Kurulumu'),
        centerTitle: true,
      ),
      body:_isLoading ? Center(
        child: Container(
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  strokeWidth: 12,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              SizedBox(
                height: 100.0,
              ),
              Text(

                'Hesap kurulumu tamamlanırken\nlütfen biraz bekleyin...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
      ) : SingleChildScrollView(
        child:   Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.redAccent,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Bu bilgiler Özel Gereksinimli\nbirey adına doldurulmalıdır.',textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
              TextButton(onPressed: (){
                const url = 'https://gorsel-bag-info-web-app.web.app';
                launchUrl(Uri.parse(url));
              }, child: const Text('Daha fazla bilgi alın.')),

           const Divider(),

              const SizedBox(
                height: 30.0,
              ),
              GestureDetector(
                onTap: _pickImage,
                child: _childPhoto == null
                    ? Icon(
                        Icons.photo_camera_outlined,
                        size: 100,
                        color: Colors.purple[200],
                      )
                    : CircleAvatar(
                        radius: 100,
                        backgroundImage: FileImage(File(_childPhoto!)),
                      ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                'Fotoğraf eklemek için görsele dokunun.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 15.0,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Bazı bilgiler daha sonra\nana sayfada gözükecektir.',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: 300,
                child: CustomTextField(
                    controller: _nameController,
                    hintText: 'Ad',
                    length: 10,
                    hideChar: false),
              ),
              const SizedBox(
                height: 10.0,
              ),
              SizedBox(
                width: 300,
                child: CustomTextField(
                    controller: _surnameController,
                    hintText: 'Soyad',
                    length: 10,
                    hideChar: false),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 300,
                child:      Container(
                  child: GestureDetector(
                    onTap: _navigateToAgePicker,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        hideChar: false,
                        controller: _ageController,
                        hintText: 'Yaş',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              CustomButton(
                onTap: () async {
                  if (_nameController.text.isNotEmpty &&
                      _childPhoto != null && _ageController.text.isNotEmpty &&
                      !_isLoading) {
                    setState(() {
                      _isLoading = true;
                    });

                    String childName = _nameController.text;
                    String childSurname = _surnameController.text;
                    String childDate = _ageController.text;
                    String childPhotoUrl = await _uploadImage(File(_childPhoto!));

                    final childCollection = ChildModel(
                      childName: childName,
                      childPhoto: childPhotoUrl,
                      childId: '',
                      childDate: childDate,
                      childSurname: childSurname,
                      docId: ''
                    );

                    await context.read<FirebaseCrudMethods>().createChild(childCollection, user.uid);

                     setState(() {
                       _isLoading = false;
                     });

                    Navigator.pushNamed(context, CheckToken.routeName);
                  } else {
                    showSnackBar(context, 'Lütfen tüm alanları doldurun!');
                  }
                },
                text: _isLoading ? 'Yükleniyor...' : 'Kaydet ve Cihaz Kurulumuna Geç',
              ),

              // CustomButton(
              //     onTap: () async {
              //       showSnackBar(
              //           context, 'Bu hizmet geliştirme aşamasındadır.');
              //     },
              //     text: 'Başka Ekle'),
              const SizedBox(
                height: 30,
              ),
              TextButton(onPressed: () {
                Navigator.pushNamed(context, HelpCenterHome.routeName);
              }, child: const Text('Yardım Merkezi'))
            ],
          ),
        ),
      ),
    );
  }
}
