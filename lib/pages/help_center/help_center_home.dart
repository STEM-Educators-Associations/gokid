import 'package:flutter/material.dart';
import 'package:gokid/pages/settings/settings_main_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'help_center_detail.dart';

class HelpCenterHome extends StatefulWidget {
  static const String routeName = '/help-center';

  @override
  _HelpCenterHomeState createState() => _HelpCenterHomeState();
}

class _HelpCenterHomeState extends State<HelpCenterHome> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım Merkezi'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.live_help,
              color: Colors.grey,
              size: 150,
            ),
            const Text(
              'Nasıl Yardımcı Olabiliriz?',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Aşağıdan bir kategori seçin',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: const Color(0xffF5F6FA),
                  hintText: 'Yardım Merkezinde Aratın',
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value.toLowerCase();
                  });
                },
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _helpItems.length,
              itemBuilder: (context, index) {
                final item = _helpItems[index];
                if (_searchText.isEmpty ||
                    item.title.toLowerCase().contains(_searchText)) {
                  return ListTile(
                    title: Text(item.title),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HelpCenterDetail(
                            title: item.title,
                            subtitle: item.subtitle,
                            showAction: item.showAction,
                            buttonText: item.buttonText,
                            onPressedCallback: item.onPressedCallback,
                          ),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HelpItem {
  final String title;
  final String subtitle;
  final String buttonText;
  final bool showAction;
  final VoidCallback onPressedCallback;
  BuildContext? context;

  HelpItem({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.showAction,
    required this.onPressedCallback,
  });
}



final List<HelpItem> _helpItems = [
  HelpItem(
    title: 'Uygulama nasıl kullanılır',
    subtitle:
        'Bu uygulama özel gereksinimli bireylerin aileleriyle olan iletişimini artırmak için tasarlanmıştır. Teknik bilgi ve daha fazlası için web sitemizi ziyaret edin.',
    buttonText: 'Daha Fazla Bilgi',
    showAction: true,
    onPressedCallback: () async {

      const url = 'https://gorsel-bag-info-web-app.web.app';
      launchUrl(Uri.parse(url));
    },
  ),
  HelpItem(
    title: 'Uygulamaya giriş yapamıyorum veya kayıt olamıyorum',
    subtitle:
        'Giriş yap veya kayıt ol işlevi tepki vermiyorsa, bu internet bağlantınızın yavaş veya dengesiz olmasından kaynaklanabilir. Lütfen farklı bir ağa bağlanarak daha sonra tekrar deneyin. Daha fazla yardım için : "Yardım Merkezi > Daha fazla yardım " sayfasına gidin.',
    buttonText: 'Daha Fazla Bilgi',
    showAction: false,
    onPressedCallback: () {},
  ),
  HelpItem(
    title:
        'Seslendirme TTS çalışmıyor',
    subtitle:
        'Görsel seslendirme özelliği bazen başlangıçta bazı cihazlarda çalışmayabilir. Bunu düzeltmek için şu adımları takip edin : "Ayarlar > Seslendirme Ayarları > Seslendirme Motorunu Seçin" adımlarını takip edin.',
    buttonText: 'Ayarlara Git',

    showAction: false,

    onPressedCallback: () {

    },
  ),  HelpItem(
    title:
        'Hesabıma daha fazla görsel yükleyemiyorum veya koleksiyon oluşturamıyorum',
    subtitle:
        'Görsel yükleme ve koleksiyon oluşturma işlemleri için her kullanıcının belli bir saklama alanı limiti vardır. Bu limit üzerine çıkıldığında kullanıcı daha fazla görsel ekleyemez veya koleksiyon oluşturamaz. Yer açmak için lütfen eski görsellerinizden veya koleksiyonlarınızdan birkaçını silin.',
    buttonText: 'Bize Ulaşın',
    showAction: false,
    onPressedCallback: () {},
  ),
  HelpItem(
    title: 'Blog yükleyemiyorum veya düzenleyemiyorum ',
    subtitle:
        'Blog yükleme işlemi başarısız oluyorsa bu hesabınızın topluluk kurallarına uymadığı için blog yüklemeye kapatılmasından kaynaklanabilir. Daha fazla bilgi için bize ulaşın.',
    buttonText: 'Bize Ulaşın',
    showAction: false,
    onPressedCallback: () {
      const url = 'https://gorsel-bag-info-web-app.web.app';
      launchUrl(Uri.parse(url));
    },
  ),
  HelpItem(
    title: 'Hesabımı doğrulayamıyorum',
    subtitle:
        'İlk kez kayıt olan kullanıcılar için bir doğrulama bağlantısı göndeririz. Bu hesabınızın güvenliği ve spam koruması içindir. Hesabını doğrulamayan kullanıcılar uygulamayı kullanmaya devam edemez. Bazen iletiler spam kutunuza gelebilir. Eğer hala ileti almadıysanız lütfen şu adımları takip edin: "Yardım Merkezi > Daha Fazla Yardım > Bir Posta Gönderin".',
    buttonText: 'Doğrulama',
    showAction: false,
    onPressedCallback: () {},
  ),
  HelpItem(
    title: 'Koleksiyon oluşturamıyorum veya görsel yükleyemiyorum',
    subtitle:
        'Görsel yükle ve koleksiyon oluştur butonları tepki vermiyorsa, bu internet bağlantınızın yavaş veya dengesiz olmasından kaynaklanabilir. Lütfen farklı bir ağa bağlanarak tekrar deneyin.',
    buttonText: 'Sorun Giderme',
    showAction: false,
    onPressedCallback: () {},
  ),
  HelpItem(
    title: 'Cihaz oturum bilgileri doğru değil',
    subtitle:
        'Ana menüde veya ayarlar sekmesinde yer alan cihaz oturum bilgileri yanlış veya eksik listeleniyorsa kullanıcının her iki cihaz oturumunu kapatıp tekrar her iki cihaz için baştan oturum açması gerekmektedir. Eğer hala sorun devam ediyorsa : " Yardım Merkezi > Daha fazla yardım " sayfasını ziyaret edin. ',
    buttonText: 'Sorun Giderme',
    showAction: false,
    onPressedCallback: () {},
  ),
  HelpItem(
    title: 'Koleksiyonlarım veya görsellerim listelenmiyor',
    subtitle:
        'Koleksiyonlarınız veya yüklediğiniz görseller listelenmiyorsa, bu internet bağlantınızın kararsız olmasından kaynaklanabilir. Lütfen daha sonra farklı bir ağ bağlantısı ile yeniden deneyin.',
    buttonText: '',
    showAction: false,
    onPressedCallback: () async {},
  ),
  HelpItem(
    title: 'Bildirimler gelmiyor veya düzgün çalışmıyor',
    subtitle:
        'Bildirimlerin cihaza ulaşması için ana menüde yer alan ~Diğer cihaz kurulumu tamamlandı ibaresinin çalışması gerekmektedir. ~Diğer cihaz kurulumu bekleniyor ibaresi henüz kurulumların gerçekten tamamlanmadığını gösterir. Eğer hata bunların hiçbiri değilse Daha Fazla Yardım sayfasına gidin. Bunun yanında bildirim izinlerini kontrol etmeyi deneyebilirsiniz. ',
    buttonText: 'Bildirimleri Onar',
    showAction: false,
    onPressedCallback: () async {},
  ),
  HelpItem(
    title: 'Veri Güvenliği',
    subtitle:
        'Verileriniz Üçüncü taraf kişilere kapalı olacak şekilde saklanmaktadır. Hesap bilgilerinizi silme talebinizle tüm verilerinizi kalıcı olarak silinir. Hesap silme talebiniz için : "Yardım Merkezi > Hesabımı Silmek İstiyorum" adımlarını takip edebilirsiniz.',
    buttonText: '',
    showAction: false,
    onPressedCallback: () async {},
  ),
  HelpItem(
    title: 'Hesabımın kalıcı olarak silinmesini talep ediyorum',
    subtitle:
        'Bunu duyduğumuza üzüldük :(\nHesabının kalıcı olarak silinmesi talebini: "Yardım Merkezi > Daha Fazla Yardım > Bir Posta Gönderin" adımlarını takip ederek talebinizi iletebilirsiniz.',
    buttonText: 'Hesabı Sil',
    showAction: false,
    onPressedCallback: () {},
  ),
  HelpItem(
    title: 'Daha fazla yardıma ihtiyacım var',
    subtitle: 'Hala sorunuz mu var? Aşağıdaki bağlantıdan bir posta gönderin.\n\nBunlar için yardımcı olabiliriz :\n-Hesap silme talebi.\n-Daha fazla destek talebi.\n-Editör işlemleri.',
    buttonText: 'Bir Posta Gönderin',
    showAction: true,
    onPressedCallback: () async {
      const url = 'https://gorsel-bag-info-web-app.web.app';
      await launchUrl(Uri.parse(url));
    },
  ),
];
