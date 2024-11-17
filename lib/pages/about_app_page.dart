import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gokid/pages/kvkk_page.dart';
import 'package:gokid/widgets/custom_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  static const String routeName = '/about-app';

  const AboutAppPage({super.key});

  Future<String> _getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return 'Version: ${packageInfo.version} (Build: ${packageInfo.buildNumber})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uygulama Hakkında'),
                         actions: [
                           Icon(Icons.security_rounded,color: Colors.grey,size: 18,),
                           Padding(
                             padding: const EdgeInsets.all(5.0),
                             child: Text('secured by\nSnaplock',style: GoogleFonts.jetBrainsMono(color: Colors.grey,fontSize: 9),textAlign: TextAlign.center,),
                           ),
                         ]

      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/ic/playstore.png',
                    height: 100,
                    width: 100,
                  ),
                  const Text(
                      "GoKid",
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<String>(
                    future: _getVersionInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Versiyon bilgisi alınamadı.');
                      } else {
                        return Text(
                            snapshot.data ?? 'Version info not available');
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),


                  SizedBox(
                      width: 300,
                      child:
                          CustomButton(onTap: () {
                            Navigator.pushNamed(context, KVKKPage.routeName);
                          }, text: 'Aydınlatma Metni')),
                  SizedBox(
                    height: 50,
                  ),
                  TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,

                          builder: (BuildContext context) {
                            return Container(
                              padding: const EdgeInsets.all(16.0),
                              height: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:  [
                                  Text(
                                    'Silinen Verilerin Kurtarılması',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Tüm görsel verilerinizi siz silseniz bile belli bir süre saklarız. '
                                        'Silinen verilerin geri getirilmesi talebiniz için lütfen yardım merkezine başvurun.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(height: 10,),
                                  TextButton(onPressed: () {
                                    const url = 'https://angelman.cbu.edu.tr/kvkk.php';
                                    launchUrl(Uri.parse(url));

                                  }, child: Text('Verilerinizi saklanması ile ilgili daha fazla bilgi için tıklayın.',style: TextStyle(fontSize: 12),),)

                                ],
                              ),
                            );
                          },
                        );


                      }, child: Text('Silinen Verilerin\n Kurtarılması')),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            const url = 'https://gorsel-bag-info-web-app.web.app';
                            launchUrl(Uri.parse(url));
                          }, child: Text('Online İşlemler')),

                    ],
                  ),
                  Divider(),
                  TextButton(
                      onPressed: () {
                        const url = 'https://github.com/erenmalkoc/gokid';
                        launchUrl(Uri.parse(url));


                      }, child: Text('Açık Kaynak Lisanları')),
                  SizedBox(height: 10,),

                  FaIcon(
                    FontAwesomeIcons.github,
                    color: Colors.grey,

                  ),
                  SizedBox(height: 50,),

                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white.withOpacity(0.0),
              padding: const EdgeInsets.all(20.0),
              child: Opacity(
                opacity: 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(),
                    InkWell(
                      onTap: (){
                        launchUrl(Uri.parse(
                            'https://www.linkedin.com/in/eren-malkoc/'));
                      },
                      child: Image.asset(
                        'assets/images/bg/e_logo.png',
                        height: 70,
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        launchUrl(Uri.parse(
                            'https://www.linkedin.com/in/eren-malkoc/'));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('© 2024'),
                          SizedBox(width: 10.0,),

                        ],
                      ),
                    ),
                    SizedBox(height: 20.0,),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
