import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gokid/widgets/custom_button.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/showSnackbar.dart';

class BlogPageDetail extends StatefulWidget {
  static String routeName = '/blog-page-detail';
  final String title;
  final String subString;
  final String userName;
  final String createdAt;
  final String profilePicture;
  final String sources;
  final bool isEditor;
  final int likes;
  final String blogId;

  const BlogPageDetail({
    super.key,
    required this.likes,
    required this.title,
    required this.subString,
    required this.userName,
    required this.profilePicture,
    required this.sources,
    required this.isEditor,
    required this.createdAt,
    required this.blogId,
  });

  @override
  _BlogPageDetailState createState() => _BlogPageDetailState();
}

class _BlogPageDetailState extends State<BlogPageDetail> {
  late int _likes;
  bool _isLiked = false;
  bool isLiked = false;
  bool isDisliked = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _likes = widget.likes;
    _checkIfLiked();
  }



  void _handleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        isDisliked = false;
      }
      showSnackBar(context, 'Geri bildiriminiz için teşekkürler.');
    });
  }

  void _handleDislike() {
    setState(() {
      isDisliked = !isDisliked;
      if (isDisliked) {
        isLiked = false;
      }
      showSnackBar(context, 'Geri bildiriminiz için teşekkürler.');
    });
  }
  int _calculateReadingTime(String text) {
    int wordsPerMinute = 250;
    List<String> words = text.split(' ');
    int numOfWords = words.length;

    int minutes = (numOfWords / wordsPerMinute).ceil();

    return minutes;
  }

  void _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('Blogs')
        .doc(widget.blogId)
        .get();
    if (doc.exists && doc['likedBy'].contains(user?.uid)) {
      setState(() {
        _isLiked = true;
      });
    }
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
    FirebaseFirestore.instance.collection('Blogs').doc(widget.blogId);

    final doc = await docRef.get();

    if (doc.exists) {
      List likedBy = List.from(doc['likedBy']);
      if (_isLiked) {
        likedBy.remove(user.uid);
        setState(() {
          _likes--;
          _isLiked = false;
        });
      } else {
        likedBy.add(user.uid);
        setState(() {
          _likes++;
          _isLiked = true;
        });
      }
      await docRef.update({
        'likedBy': likedBy,
        'likes': _likes,
      });
    }
  }

  Future<void> _takeScreenshot() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      final Uint8List? imageBytes = await _screenshotController.capture();

      if (imageBytes != null) {


      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Depolama izni kalıcı olarak reddedildi. Lütfen ayarlardan izni aktif hale getirin.'),
          action: SnackBarAction(
            label: 'Ayarlara Git',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Depolama izni verilmedi.')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    int readingTime = _calculateReadingTime(widget.subString);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Ayrıntısı'),
        centerTitle: true,
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Center(
                          child: ProfilePicture(
                            name: widget.userName,
                            radius: 25,
                            fontsize: 25,
                            tooltip: true,
                          ),
                        ),
                        const SizedBox(width: 16),

                        Center(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.userName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 10.0,),
                                  if (widget.isEditor)
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: Colors.blue,
                                    ),
                                ],
                              ),
                              Text(
                                "${widget.createdAt} yayınlandı.",
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                  'Tahmini okuma Süresi : $readingTime dakika',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),

                      ],
                    ),

                  ],
                ),
                const SizedBox(height: 16),

                Center(
                    child: Image.network(
                      widget.profilePicture,
                      height: 200,
                    )),

                const SizedBox(height: 16),
                Text(
                  widget.subString,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Etiketler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            widget.sources,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 30,
                        color: Colors.purple,
                      ),
                      onPressed: _toggleLike,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    const Text(
                      'Bu blog faydalı oldu mu ?',
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      '$_likes kişi tarafından faydalı bulundu.',
                      style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 15,
                          fontStyle: FontStyle.italic),
                    ),
                    const Divider(),

                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                CustomButton(onTap: () {
                  showModalBottomSheet(
                    context: context,

                    isScrollControlled: true,
                    builder: (BuildContext
                    context) {
                      return Container(
                        height: 700,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                              right: 10.0,
                              left: 10.0,
                              top: 50.0
                          ),
                          child: Column(
                            mainAxisSize:
                            MainAxisSize
                                .min,
                            children: [
                              const Text(
                                'Bu Yazıyı Bildir',
                                style:
                                TextStyle(
                                  fontSize:
                                  18,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                              const SizedBox(
                                  height:
                                  20),
                              Row(

                                children: [
                                  Icon(Icons.info,color: Colors.grey,),
                                  SizedBox(width: 10.0,),
                                  Text('Bildiriniz sonuçlanır sonuçlanmaz\nsizi haber ederiz.',style: TextStyle(color: Colors.grey),),
                                ],
                              ),
                              const SizedBox(
                                  height:
                                  20),
                              TextField(
                                controller:
                                _reportController,
                                maxLines: 2,
                                decoration:
                                const InputDecoration(
                                  hintText:
                                  'Lütfen sakıncalı içeriği açıklayın...',
                                  border:
                                  OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(
                                  height:
                                  40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        () async {
                                      final String
                                      mailUrl =
                                          'mailto:eren.malkoc.iletisim@gmail.com?subject=Sakıncalı İçerik Bildirimi&body=${_reportController.text} , ${widget.blogId.substring(2, 8)}';

                                      await launchUrl(Uri.parse(mailUrl));


                                      Navigator.pop(
                                          context);
                                    },
                                    child: const Text(
                                        'Gönder'),
                                  ),
                                  SizedBox(
                                    width:
                                    10.0,
                                  ),
                                  TextButton(
                                      onPressed:
                                          () {
                                        Navigator.pop(context);
                                      },
                                      child:
                                      Text('Vazgeç')),


                                ],
                              ),
                              Text('')
                            ],
                          ),
                        ),
                      );
                    },
                  );


                }, text: 'Sorunlu İçerik Bildir'),

SizedBox(height: 10.0,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Blog yazıları faydalı mı ?',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Kendimizi geliştirebilmemiz için geri bildiriminize ihtiyacımız var.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: _handleLike,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLiked ? Colors.blue.shade100 : Colors.grey.shade200,
                            ),
                            child: Icon(
                              Icons.thumb_up_alt_sharp,
                              size: 20,
                              color: isLiked ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleDislike,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDisliked ? Colors.blue.shade100 : Colors.grey.shade200,
                            ),
                            child: Icon(
                              Icons.thumb_down_alt_sharp,
                              size: 20,
                              color: isDisliked ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
