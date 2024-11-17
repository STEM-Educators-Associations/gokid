import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:gokid/models/collection_model.dart';
import 'package:gokid/pages/blog/user_blog.dart';
import 'package:gokid/pages/edit_user_profile_page.dart';
import 'package:gokid/pages/help_center/help_center_home.dart';
import 'package:gokid/pages/settings/settings_main_page.dart';
import 'package:gokid/services/firebase_crud_methods.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:provider/provider.dart';
import '../models/blog_model.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_methods.dart';
import '../widgets/custom_button.dart';

class UserAccountPage extends StatefulWidget {
  static const String routeName = '/user-account-page';

  const UserAccountPage({Key? key}) : super(key: key);

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;
    final userModel =
        context.read<FirebaseCrudMethods>().getUserFromFirebase(user.uid);
    final collectionModel =
        context.read<FirebaseCrudMethods>().getCollectionsByUserId(user.uid);
    final blogModel = context
        .read<FirebaseCrudMethods>()
        .getBlogsFromFirebaseForUser(user.uid);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabım'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, HelpCenterHome.routeName);
              },
              icon: const Icon(Icons.help))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<UserModel?>(
                        future: userModel,
                        builder: (BuildContext context,
                            AsyncSnapshot<UserModel?> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  AvatarGlow(
                                    glowColor: Colors.deepPurple,
                                    repeat: false,
                                    glowCount: 10,
                                    child: ProfilePicture(
                                      name: snapshot.data!.userName,
                                      radius: 70,
                                      fontsize: 80,
                                      tooltip: true,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        snapshot.data!.userName,
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      if (snapshot.data!.isVerified)
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Colors.blue,
                                        ),
                                      if (snapshot.data!.isVerified)
                                        const Text(
                                          'Editör',
                                          style: TextStyle(color: Colors.grey),
                                        )
                                    ],
                                  ),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Kullanıcı Kimliği\n${snapshot.data!.userId.substring(2, 8)}",
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  snapshot.data!.isVerified
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              right: 60,
                                              left: 60,
                                              top: 10,
                                              bottom: 10),
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.verified_user,
                                                  color: Colors.green,
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text('Doğrulanmış Hesap'),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              right: 60,
                                              left: 60,
                                              top: 10,
                                              bottom: 10),
                                          child: Container(
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.cancel,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text('Doğrulanmamış Hesap')
                                              ],
                                            ),
                                          ),
                                        ),
                                  if (!snapshot.data!.isVerified &&
                                      !user.isAnonymous)
                                    CustomButton(
                                      onTap: () {
                                        context
                                            .read<FirebaseAuthMethods>()
                                            .sendEmailVerification(context);

                                      },
                                      text: 'Hesabını Doğrula',
                                    ),
                                ],
                              );
                            } else {
                              return const Text(
                                  'Kullanıcı bilgileri yüklenemedi.');
                            }
                          }
                        },
                      ),
                      FutureBuilder<List<CollectionModel>>(
                        future: collectionModel,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<CollectionModel>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: Text(''));
                          } else {
                            if (snapshot.hasData) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: 60, left: 60, bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.collections),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          Text(
                                            '${snapshot.data!.length.toString()} Koleksiyon',
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return const Text(
                                  'Kullanıcı bilgileri yüklenemedi.');
                            }
                          }
                        },
                      ),
                      FutureBuilder<List<BlogModel>>(
                        future: blogModel,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<BlogModel>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: Text('Bilgiler Yükleniyor...'));
                          } else {
                            if (snapshot.hasData) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: 60, left: 60, bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ListTile(
                                          title: Text(
                                            '${snapshot.data!.length.toString()} Blog',
                                          ),
                                          subtitle: const Text(
                                            'Detayları ve düzenlemeleri görün.',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          leading:
                                              const Icon(Icons.text_snippet),
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                UserBlogPage.routeName);
                                          },
                                          trailing: const Icon(
                                              Icons.arrow_forward_ios_rounded)),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return const Text(
                                  'Kullanıcı bilgileri yüklenemedi.');
                            }
                          }
                        },
                      ),
                      FutureBuilder<List<BlogModel>>(
                        future: blogModel,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<BlogModel>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: Text('Lütfen Bekleyiniz'));
                          } else {
                            if (snapshot.hasData) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: 60, left: 60, bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ListTile(
                                          title: const Text(
                                            'Bağışlarım',
                                          ),
                                          subtitle: const Text(
                                            'Sertifikalarınız ve geçmiş bağışlarınız.',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          leading: const Icon(
                                              Icons.volunteer_activism),
                                          onTap: () {
                                            Navigator.pushNamed(context, '/donation');
                                          },
                                          trailing: const Icon(
                                              Icons.arrow_forward_ios_rounded)),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return const Text(
                                  'Kullanıcı bilgileri yüklenemedi.');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  CustomButton(
                    onTap: () {
                      final userModelFuture = userModel;

                      userModelFuture.then((userModel) {
                        if (userModel != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(userModel: userModel),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kullanıcı bilgileri yüklenemedi.')),
                          );
                        }
                      });
                    },
                    text: 'Profilini Düzenle',
                  ),

                  const Divider(),
                  CustomButton(
                    onTap: () {
                      Navigator.pushNamed(context, SettingsMainPage.routeName);
                    },
                    text: 'Uygulama Ayarları',
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Çıkış Yap"),
                        content: const Text(
                            "Çıkış yapmak istediğinize emin misiniz?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("İptal"),
                          ),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<FirebaseAuthMethods>()
                                  .signOut(context);
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login-screen',
                                (route) => false,
                              );
                            },
                            child: const Text("Evet"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.exit_to_app_rounded,
                        color: Colors.redAccent,
                      ),
                      Text(
                        'Oturumu Kapat',
                        style: TextStyle(color: Colors.red, fontSize: 15),
                      ),
                      SizedBox(
                        height: 30.0,
                      )
                    ])),
            const SizedBox(
              height: 30.0,
            )
          ],
        ),
      ),
    );
  }
}
