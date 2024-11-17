import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:provider/provider.dart';

import '../../models/blog_model.dart';
import '../../services/firebase_auth_methods.dart';
import '../../services/firebase_crud_methods.dart';
import '../../utils/time_ago.dart';
import 'blog_page_detail.dart';


class UserBlogPage extends StatefulWidget {
  static const String routeName = '/user-blog';

  const UserBlogPage({Key? key}) : super(key: key);

  @override
  State<UserBlogPage> createState() => _UserBlogPageState();
}

class _UserBlogPageState extends State<UserBlogPage> {
  String _searchQuery = "";
  final TextEditingController _reportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;
    final blogModel =
    context.read<FirebaseCrudMethods>().getBlogsFromFirebase();

    return Scaffold(
      appBar: AppBar(title: Text('Yazdığınız Bloglar'),),
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
                          .where((blog) =>
                      blog.userId == user.uid &&
                          blog.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
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
                                                Column(
                                                  children: [
                                                    Text(
                                                      blog.userName,
                                                      textAlign: TextAlign.start,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    blog.banned ? Card(child: Padding(

                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text('Yayın için onay bekliyor...',style: TextStyle(color: Colors.red,fontSize: 11,fontWeight: FontWeight.bold),),
                                                    )) : Text('Yayınlandı.',style: TextStyle(color: Colors.green,fontSize: 13,fontWeight: FontWeight.bold),)
                                                  ],
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
                                            Text(TimeAgo.format(blog.createdAt)),
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
                                                text: blog.subtitle.length >= 120
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

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    } else {
                      return const Center(
                        child: Text('Henüz blog eklemediniz.'),
                      );
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
