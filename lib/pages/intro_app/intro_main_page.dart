import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokid/services/firebase_crud_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/firebase_auth_methods.dart';

class IntroScreenMain extends StatefulWidget {
  static const String routeName = '/intro-screen-main';

  @override
  _IntroScreenMainState createState() => _IntroScreenMainState();
}

class _IntroScreenMainState extends State<IntroScreenMain> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _introPages = [
    IntroPage(
      title: "Amacımız",
      description:
          "Bu uygulama, Özel Gereksinimli çocukların ebeveynleriyle olan iletişimini artırmayı amaçlamaktadır.",
      image: "assets/images/ic/what_si_ic.png",
      showButton: true,
    ),
    IntroPage(
      title: "Nasıl Kullanılır ?",
      description:
          "Yüklediğiniz görselleri oluşturduğunuz koleksiyonlarda organize edin.",
      image: "assets/images/ic/files_ic.png",
      showButton: false,
    ),
    IntroPage(
      title: "Çocuk Modu ile Tam Denetimli Serbestlik",
      description: "Çocuk modu ile seçtiğiniz görselleri organize edin.",
      image: "assets/images/ic/child_mode_ic.png",
      showButton: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkIfIntroSeen();
  }

  Future<void> _checkIfIntroSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = prefs.getBool('seenIntro') ?? false;

    if (seen) {
      _navigateToHome();
    }
  }

  Future<void> _setIntroSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenIntro', true);
  }

  void _navigateToHome() {}

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    final anyChild = context.read<FirebaseCrudMethods>().getChildrenByUserId(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Başlamadan Önce',
          style: TextStyle(fontSize: 28.0),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _introPages.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _introPages[index];
            },
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Positioned(
            bottom: 80.0,
            left: 50,
            right: 50,
            child: Visibility(
              visible: _currentPage == _introPages.length - 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await _setIntroSeen();


                        anyChild.then((childrenList) {
                          if (childrenList.isEmpty) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/set-up-child-mode', (route) => false);
                            print('Children list is empty.');
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/setup-token', (route) => false);
                          }
                        }).catchError((error) {
                          print('Error fetching children: $error');
                        });

                      },
                      child: const Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Hesap Kurulumunu Tamamlayın',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _introPages.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 20.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class IntroPage extends StatelessWidget {
  final bool showButton;
  final String title;
  final String description;
  final String image;

  IntroPage(
      {required this.title,
      required this.description,
      required this.image,
      required this.showButton});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            image,
            height: 300.0,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(height: 30.0),
          Text(
            textAlign: TextAlign.center,
            title,
            style: const TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 30.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
            ),
          ),
          const SizedBox(height: 50.0),
          Visibility(
              visible: showButton,
              child: TextButton(
                  onPressed: () {
                    const url = 'https://gorsel-bag-info-web-app.web.app';
                    launchUrl(Uri.parse(url));
                  },
                  child: const Text(
                    'Daha fazla bilgi alın.',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  )))
        ],
      ),
    );
  }
}
