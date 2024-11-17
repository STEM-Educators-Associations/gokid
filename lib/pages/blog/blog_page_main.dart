import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:provider/provider.dart';

import '../../models/blog_model.dart';
import '../../services/firebase_crud_methods.dart';
import '../../utils/time_ago.dart';
import 'blog_page_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogPage extends StatefulWidget {
  static const String routeName = '/blog-main-screen';

  const BlogPage({Key? key}) : super(key: key);

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  String _searchQuery = "";
  final TextEditingController _reportController = TextEditingController();
  final List<String> tags = [
    '#AngelmanSendromu',
    '#ÖzelÇocuklar',
    '#SevgiyleBüyüyoruz',
    '#BirlikteDahaGüçlüyüz',
    '#UmutHerYerde',
    '#FarklılıklarımızZenginliktir',
    '#CesurAileler',
    '#HayataBağlılık',
    '#PozitifDüşünce',
    '#BirlikteDahaİyi',
    '#KüçükAdımlarBüyükBaşarılar',
    '#HerkesİçinEşitlik',
    '#PaylaştıkçaGüçleniriz',
    '#İlhamKaynağı',
    '#DayanışmaZamanı',
    '#KucaklayıcıToplum',
    '#UmutlaYolaDevam',
    '#KalptenKalbe',
    '#YüreklereDokunmak',
    '#SevgiDoluYolculuk',
    '#BirlikteYükseliyoruz',
    '#GüzelYarınlarİçin',
    '#HerAdımBirBaşarı',
    '#İlhamVericiHikayeler',
    '#DestekHerYerde',
    '#BirlikteDahaMutluyuz',
  ];

  @override
  Widget build(BuildContext context) {
    final blogModel =
        context.read<FirebaseCrudMethods>().getBlogsFromFirebase();

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 70,
            child: FloatingActionButton.extended(

              heroTag: 'write_blog',
              onPressed: () {
                Navigator.pushNamed(context, '/create-blog');
              },
              icon: const Icon(Icons.add_circle),
              label: const Text('Blog\nOluştur',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
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
                  hintText: 'Anahtar Kelime Girin',
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RandomTagSelector(tags: tags),)
            ,
            Expanded(
              child: FutureBuilder<List<BlogModel>>(
                future: blogModel,
                builder: (BuildContext context,
                    AsyncSnapshot<List<BlogModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: CircularProgressIndicator(
                              strokeWidth: 6,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Bloglar Yükleniyor...',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    );
                  } else {
                    if (snapshot.hasData) {
                      List<BlogModel> filteredBlogs = snapshot.data!
                          .where((blog) => blog.title
                              .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) && !blog.banned)
                          .toList();

                      filteredBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      if (filteredBlogs.isEmpty) {
                        return ListView(
                          children: [
                            const SizedBox(height: 50),
                            SizedBox(
                              height: 300,
                              child: Image.asset('assets/images/bg/cat_bg.png',
                                  height: 300),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              "Aramanızla eşleşen blog bulunamadı.",
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      } else {
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 1.0,
                          ),
                          itemCount: filteredBlogs.length,
                          itemBuilder: (BuildContext context, int index) {
                            BlogModel blog = filteredBlogs[index];

                            return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: GestureDetector(
                                onTap: () async {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BlogPageDetail(
                                        title: blog.title,
                                        subString: blog.subtitle,
                                        userName: blog.userName,
                                        profilePicture: blog.image,
                                        sources: blog.sources,
                                        isEditor: blog.isEditor,
                                        createdAt:
                                            TimeAgo.format(blog.createdAt),
                                        likes: blog.likes,
                                        blogId: blog.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                ProfilePicture(
                                                  name: blog.userName,
                                                  radius: 15,
                                                  fontsize: 15,
                                                  tooltip: true,
                                                ),
                                                const SizedBox(width: 5.0),
                                                Text(
                                                  blog.userName,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 1.0),
                                                if (blog.isEditor)
                                                  const Icon(
                                                    Icons.verified_rounded,
                                                    size: 20,
                                                    color: Colors.blue,
                                                  ),
                                              ],
                                            ),
                                            Text(
                                                TimeAgo.format(blog.createdAt)),
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        Center(
                                          child: Image.network(
                                            blog.image,
                                            height: 110,
                                            width: 400,
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${blog.title} \n\n',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    blog.subtitle.length >= 120
                                                        ? blog.subtitle
                                                            .substring(0, 120)
                                                        : blog.subtitle,
                                                style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' ...Devamını Oku',
                                                style: TextStyle(
                                                  color: Colors.purple
                                                      .withOpacity(1),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        const Divider(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0, left: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${blog.likes} kişi tarafından faydalı bulundu',
                                                style: const TextStyle(
                                                    color: Colors.deepPurple),
                                              ),
                                              const SizedBox(width: 5.0),
                                              Container(
                                                height: 40,
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.info_outlined,
                                                        size: 25,
                                                      ),
                                                      onPressed: () {
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
                                                                        Text('Bildiriniz sonuçlanır sonuçlanmaz\nsizi haber edeceğiz.',style: TextStyle(color: Colors.grey),),
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
                                                                                'mailto:eren.malkoc.iletisim@gmail.com?subject=Sakıncalı İçerik Bildirimi&body=${_reportController.text} , ${blog.id.substring(2, 8)}';

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
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Bir hata oluştu: ${snapshot.error}'));
                    } else {
                      return const Center(child: Text('Veri bulunamadı.'));
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
class RandomTagSelector extends StatelessWidget {
  final List<String> tags;

  RandomTagSelector({required this.tags});

  @override
  Widget build(BuildContext context) {

    final random = Random();
    String randomTag = tags[random.nextInt(tags.length)];
    String randomTag2 = tags[random.nextInt(tags.length)];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Popüler Etiketler',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(width: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(randomTag),
              ),
            ),
            SizedBox(width: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(randomTag2),
              ),
            ),
            SizedBox(width: 8),

          ],
        ),
      ),
    );

  }
}


