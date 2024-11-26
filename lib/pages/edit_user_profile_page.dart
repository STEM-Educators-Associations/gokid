import 'package:flutter/material.dart';
import 'package:gokid/models/user_model.dart';
import 'package:gokid/services/firebase_crud_methods.dart';
import 'package:gokid/utils/showSnackbar.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-user-profile';

  final UserModel userModel;

  const EditProfileScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.userModel.userName);
    _emailController = TextEditingController(text: widget.userModel.userMail);
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      bool isPasswordValid = await context.read<FirebaseCrudMethods>().verifyPassword(
        widget.userModel.userMail,
        _oldPasswordController.text,
      );

      if (!isPasswordValid) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Eski şifre yanlış.');
        return;
      }

      if (_newPasswordController.text != _confirmPasswordController.text) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Yeni şifreler eşleşmiyor.');
        return;
      }

      final updatedUser = UserModel(
        userId: widget.userModel.userId,
        userName: _userNameController.text,
        userMail: _emailController.text,
        userPassword: _newPasswordController.text.isEmpty ? widget.userModel.userPassword : _newPasswordController.text,
        isVerified: widget.userModel.isVerified,
        userToken: widget.userModel.userToken,
        isExceeded: widget.userModel.isExceeded,
        isRestricted: widget.userModel.isRestricted,
        storageUsed: widget.userModel.storageUsed,
        userDate: widget.userModel.userDate,
        isEditor: widget.userModel.isEditor,
        profileSetup: widget.userModel.profileSetup,
        otherDeviceToken: widget.userModel.otherDeviceToken,
        deviceInfo: widget.userModel.deviceInfo,
        otherDeviceInfo: widget.userModel.otherDeviceInfo,
      );

      bool success = await context.read<FirebaseCrudMethods>().updateUserProfile(updatedUser);

      setState(() {
        isLoading = false;
      });

      if (success) {
        showSnackBar(context, 'Profil başarıyla güncellendi.');
        Navigator.pop(context);
      } else {
        showSnackBar(context, 'Profil güncellenirken bir hata oluştu.');
      }
    }
  }

  Future<void> _confirmAccountDeletion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text('Bu işlem geri alınamaz. Hesabınızı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        isLoading = true;
      });

      await context.read<FirebaseCrudMethods>().createAccountDeletionRequest(widget.userModel);

      setState(() {
        isLoading = false;
      });

      showSnackBar(context, 'Hesap silme isteği gönderildi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _userNameController,
                  maxLength: 15,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kullanıcı adı boş olamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _oldPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Eski Şifre',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Eski şifre boş olamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _newPasswordController,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: 'Yeni Şifre',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != null && value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  maxLength: 15,
                  decoration: const InputDecoration(
                    labelText: 'Yeni Şifre (Tekrar)',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != null && value != _newPasswordController.text) {
                      return 'Şifreler eşleşmiyor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                  children: [
                    CustomButton(
                      onTap: _saveProfile,
                      text: 'Kaydet',
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      onTap: _confirmAccountDeletion,
                      text: 'Hesabı Silme Talebi',

                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
