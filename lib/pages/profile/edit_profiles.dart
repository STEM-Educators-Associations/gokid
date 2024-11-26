import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokid/utils/showSnackbar.dart';
import 'package:gokid/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../../models/child_model.dart';
import '../../services/firebase_auth_methods.dart';
import '../../services/firebase_crud_methods.dart';
import '../../widgets/custom_textfield.dart';
import '../age_picker.dart';
import '../navigation_page.dart';

class EditProfiles extends StatefulWidget {
  static const String routeName = '/edit-profiles';

  final String name;
  final String surname;
  final String birthDate;
  final String photoId;
  final String id;
  final String docId;

  const EditProfiles({
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.id,
    required this.photoId,
    required this.docId,
    Key? key,
  }) : super(key: key);

  @override
  _EditProfilesState createState() => _EditProfilesState();
}

class _EditProfilesState extends State<EditProfiles> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  String? _updatedPhotoUrl;
  bool _isLoadingForImage = false;
  int _age = 5;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _surnameController.text = widget.surname;
    _birthDateController.text = widget.birthDate;
    _updatedPhotoUrl = widget.photoId;
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
              _birthDateController.text = _age.toString();
            });
          },
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoadingForImage = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final uploadedUrl = await _uploadImage(File(image.path));
        setState(() {
          _updatedPhotoUrl = uploadedUrl;
        });
      }
    } catch (e) {
      showSnackBar(context, 'Fotoğraf seçerken bir hata oluştu');
    } finally {
      setState(() {
        _isLoadingForImage = false;
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('child_photos')
          .child(fileName);

      firebase_storage.UploadTask uploadTask = ref.putFile(image);
      await uploadTask;

      return await ref.getDownloadURL();
    } catch (e) {
      showSnackBar(context, 'Fotoğraf yüklenirken bir hata oluştu');
      return null;
    }
  }

  void _updateProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = context.read<FirebaseAuthMethods>().user.uid;

      final updatedChild = ChildModel(
        childName: _nameController.text,
        childSurname: _surnameController.text,
        childDate: _birthDateController.text,
        childId: widget.id,
        childPhoto: _updatedPhotoUrl ?? widget.photoId,
        docId: widget.docId,
      );

      await context
          .read<FirebaseCrudMethods>()
          .updateChild(widget.docId, updatedChild);
      showSnackBar(context, 'Profil güncelleniyor...', isLoading: true);
      Navigator.pushNamedAndRemoveUntil(
          context, NavigationPage.routeName, (route) => false);
    } catch (e) {
      showSnackBar(context, 'Profil güncellenirken bir hata oluştu');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çocuk Profilini Düzenle'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _isLoadingForImage
                    ? const Center(child: CircularProgressIndicator())
                    : _updatedPhotoUrl != null
                        ? Image.network(
                            _updatedPhotoUrl!,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : const Placeholder(
                            fallbackHeight: 200,
                          ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Fotoğraf değiştirmek için görsele dokunun.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15.0),
              Text('Ad'),
              const Divider(),
              CustomTextField(
                controller: _nameController,
                hintText: widget.name,
                length: 10,
                hideChar: false,
              ),
              const SizedBox(height: 10.0),
              Text('Soyad'),
              const Divider(),
              CustomTextField(
                controller: _surnameController,
                hintText: widget.surname,
                length: 10,
                hideChar: false,
              ),
              const SizedBox(height: 10.0),
              Text('Yaş'),
              const Divider(),
              Container(
                child: GestureDetector(
                  onTap: _navigateToAgePicker,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      hideChar: false,
                      controller: _birthDateController,
                      hintText: 'Yaş',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      onTap: _updateProfile,
                      text: 'Kaydet',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
