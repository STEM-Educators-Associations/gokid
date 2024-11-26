import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gokid/utils/showSnackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../formatter/input_formatter.dart';
import '../../services/firebase_auth_methods.dart';
import '../../services/firebase_crud_methods.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class CreateBlogPage extends StatefulWidget {
  static const String routeName = '/create-blog';

  const CreateBlogPage({Key? key}) : super(key: key);

  @override
  _CreateBlogPageState createState() => _CreateBlogPageState();
}

class _CreateBlogPageState extends State<CreateBlogPage> {
  File? _image;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _sourcesController = TextEditingController();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FocusNode _focusNode = FocusNode();



  Future<File?> _compressImage(File imageFile) async {
    final String targetPath =
    imageFile.path.replaceAll('.jpg', '_compressed.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      targetPath,
      quality: 20,
      minWidth: 1000,
      minHeight: 1000,
    );
    print('Görsel başarıyla sıkıştırıldı!');

    return File(result!.path);
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (_sourcesController.text.isEmpty) {
          _sourcesController.text = '#';
          _sourcesController.selection = TextSelection.fromPosition(
            TextPosition(offset: _sourcesController.text.length),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _sourcesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;
    final userModel =
    context.read<FirebaseCrudMethods>().getUserFromFirebase(user.uid);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Oluştur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bugün aklınızdan ne geçiyor?',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Image.asset(
              'assets/images/ic/write_blog_ic.png',
              height: 300,
            ),
            const Text(
              'Deneyimleriniz, tavsiyeleriniz, önerileriniz ve aktarmak istediklerinizi yazın.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),
            CustomTextField(
              controller: _titleController,
              hintText: 'Eşsiz Bir Başlık Seçin',
              length: 65,
              hideChar: false,
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _subtitleController,
              maxLines: 13,
              maxLength: 3000,
              decoration: InputDecoration(
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
                hintText:
                'Düşüncelerinizi Burada Detaylandırın \n\nEn fazla 3000 karakter',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Konuyla ilgili bir görsel ekleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            _image == null
                ? GestureDetector(
              onTap: _pickImage,
              child: Image.asset(
                'assets/images/ic/select_image_ic.png',
                height: 200,
              ),
            )
                : GestureDetector(
              onTap: _pickImage,
              child: Image.file(
                _image!,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const Text(
              'Seçmek için tıklatın.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(),
            const SizedBox(height: 12.0),
            const Text(
              'Etiketler',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12.0),
          TextField(
            controller: _sourcesController,
            obscureText: false,
            maxLength: 40,
            focusNode: _focusNode,
            inputFormatters: [
              HashTagFormatter(),
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.deepPurple,
                  width: 2.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: const Color(0xffF5F6FA),
              hintText: ' #sağlık  #eğitim', // Placeholder text
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              counterText: '',
            ),
          ),

            const SizedBox(height: 10.0),
            const Text(
              'Etiketler gönderinizin daha fazla öne çıkmasını sağlar.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30.0),


            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'Topluluk kurallarını ihlal eden içerik paylaşmadığımı onaylıyorum.',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Yazınız editörler tarafından onaylandıktan sonra yayınlanır. Genelde bu çok uzun sürmez. Onay durumunu profil ayarlarından takip edebilirsiniz. ',
              style: TextStyle(color: Colors.grey,),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15.0),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Topluluk Kurallarımız'),
                  content: SingleChildScrollView(
                    child: Text(
                        'Sayın Kullanıcımız, bu platform özel gereksinimli bireylerin aileleri için güvenli ve destekleyici bir alan sunmaktadır. Lütfen içerik paylaşırken aşağıdaki kurallara dikkat ediniz:\n\n'
                            '1. Saygı ve Hassasiyet Gösterin: Paylaşılan içerik, özel gereksinimli bireyler ve ailelerinin hassasiyetlerini gözetmeli, onur kırıcı veya incitici olmamalıdır.\n'
                            '2. Destekleyici Olun: Bilgi, tecrübe ve fikirlerinizi paylaşırken diğer kullanıcıların yaşam durumlarına empatiyle yaklaşın. Eleştirilerinizi yapıcı ve destekleyici bir şekilde dile getirin.\n'
                            '3. Spam ve Alakasız İçerik Paylaşmayın: Platformun amacına uygun olmayan içeriklerden ve reklamlardan kaçının. Her paylaşımın, topluluğa katkı sağladığından emin olun.\n'
                            '4. Gizliliğe Özen Gösterin: Özel gereksinimli bireyler ve ailelerine ait kişisel bilgileri izinsiz paylaşmayın. Gizlilik en önemli önceliklerden biridir.\n\n'
                            'Bu kurallara uymayan kullanıcıların yazıları editörler tarafından onaylanmaz.\n\n\n\n'
                            'İlginiz için teşekkür ederiz.'

                    ),
                  ),

                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Tamam'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Daha Fazla Bilgi'),
          ),

          const SizedBox(height: 15.0),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
              onTap: () {
                if (_agreeToTerms) {
                  _createBlog();


                } else {

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Uyarı'),
                      content: Text('Blog oluşturabilmek için lütfen kullanım şartlarını kabul edin.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Tamam'),
                        ),
                      ],
                    ),
                  );
                }
              },
              text: 'Blog Oluştur',
            )
            ,

            const SizedBox(height: 30.0),


          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File? compressedImage = await _compressImage(File(image.path));
      setState(() {
        _image = compressedImage;
      });
    }
  }

  Future<void> _createBlog() async {
    setState(() {
      _isLoading = true;
    });

    String title = _titleController.text.trim();
    String subtitle = _subtitleController.text.trim();
    String sources = _sourcesController.text.trim();
    DateTime createdAt = DateTime.now();
    final user = context.read<FirebaseAuthMethods>().user;

    if (title.isNotEmpty && subtitle.isNotEmpty && sources.isNotEmpty && _image!=null ) {
      try {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        DocumentSnapshot userDoc =
        await firestore.collection('Users').doc(user.uid).get();
        String userName = userDoc.get('userName') ?? 'Kullanıcı ismi boş';
        bool isEditor = userDoc.get('isEditor') ?? false;

        if (_image != null) {
          Reference ref = _storage.ref().child(
              'blog_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await ref.putFile(_image!);
          String imageUrl = await ref.getDownloadURL();

          await firestore.collection('Blogs').add({
            'createdAt': createdAt,
            'userId': user.uid,
            'userName': userName,
            'title': title,
            'subtitle': subtitle,
            'sources': sources,
            'image': imageUrl,
            'likes': 0,
            'banned': true,
            'likedBy': [],
            'readingTime': 0,
            'isEditor': isEditor,

          });
        } else {
          await firestore.collection('Blogs').add({
            'createdAt': createdAt,
            'user_id': user.uid,
            'user_name': userName,
            'title': title,
            'subtitle': subtitle,
            'sources': sources,
            'image': '',
            'likes': 0,
            'banned': true,
            'liked_by': [],
            'reading_time': 0,
            'is_editor': isEditor,
          });
        }
        await firestore.collection('BlogStatus').add({
          'userId': user.uid,
          'userName': userName,
          'userMail': user.email,
          'requestedAt': FieldValue.serverTimestamp(),
          'reason': 'Blog creating request',
        });

        Navigator.of(context).pop();
        showSnackBar(context, 'İşleniyor...', isLoading: true);
        showSnackBar(context, 'Blog başarıyla oluşturuldu.\nOnay durumunu profilinizden\ntakip edebilirsiniz.');

        _titleController.clear();
        _subtitleController.clear();
        _sourcesController.clear();
        setState(() {
          _image = null;
          _isLoading = false;
          _agreeToTerms = false;


        });
      } catch (e) {
        showSnackBar(context, 'Blog oluşturulurken bir hata oluştu.');
        print(e);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      showSnackBar(context, 'Lütfen tüm alanları doldurun.');

      setState(() {
        _isLoading = false;
      });
    }
  }

}

