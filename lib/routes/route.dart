import 'package:flutter/material.dart';
import 'package:gokid/hardware/device_info_ios.dart';
import 'package:gokid/main.dart';
import 'package:gokid/notification/request_notif_permission_screen.dart';
import 'package:gokid/pages/check_token/check_token.dart';
import 'package:gokid/pages/child_mode/child_mode_home.dart';
import 'package:gokid/pages/question_mode/q_main_screen.dart';
import 'package:gokid/pages/settings/notif_settings.dart';
import 'package:upgrader/upgrader.dart';
import '../hardware/device_info_android.dart';
import '../pages/about_app_page.dart';
import '../pages/blog/blog_page_main.dart';
import '../pages/blog/create_blog.dart';
import '../pages/blog/user_blog.dart';
import '../pages/child_mode/set_up_child_mode.dart';
import '../pages/create_collection_page.dart';
import '../pages/donation/donation_page.dart';
import '../pages/help_center/help_center_home.dart';
import '../pages/home_page.dart';
import '../pages/intro_app/intro_main_page.dart';
import '../pages/kvkk_page.dart';
import '../pages/login_email_password_screen.dart';
import '../pages/login_page.dart';
import '../pages/navigation_page.dart';
import '../pages/premium/get_premium_main_page.dart';
import '../pages/settings/settings_main_page.dart';
import '../pages/settings/setup_settings.dart';
import '../pages/settings/voice_settings.dart';
import '../pages/settings_page.dart';
import '../pages/signup_email_password_screen.dart';
import '../pages/tts.dart';
import '../pages/user_account_page.dart';
import '../pages/wait_verifiction.dart';

import 'package:page_transition/page_transition.dart';

class Routing {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AuthWrapper.routeName:
        return PageTransition(
          child: UpgradeAlert(
              upgrader: Upgrader(
                  countryCode: 'tr', messages: UpgraderMessages(code: 'tr')),
              showLater: false,
              showIgnore: false,
              showReleaseNotes: true,
              barrierDismissible: true,
              child: const AuthWrapper()),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case HomeScreen.routeName:
        return PageTransition(
          child: const HomeScreen(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case EmailPasswordSignup.routeName:
        return PageTransition(
          child: const EmailPasswordSignup(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case DeviceSetup.routeName:
        return PageTransition(
          child: const DeviceSetup(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case UserBlogPage.routeName:
        return PageTransition(
          child: const UserBlogPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case VoiceSettings.routeName:
        return PageTransition(
          child: const VoiceSettings(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case EmailPasswordLogin.routeName:
        return PageTransition(
          child: const EmailPasswordLogin(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );

      case SettingsPage.routeName:
        return PageTransition(
          child: const SettingsPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case CollectionPage.routeName:
        return PageTransition(
          child: CollectionPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case VerificationPage.routeName:
        return PageTransition(
          child: const VerificationPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case LoginScreen.routeName:
        return PageTransition(
          child: const LoginScreen(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case UserAccountPage.routeName:
        return PageTransition(
          child: const UserAccountPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );

      case KVKKPage.routeName:
        return PageTransition(
          child: const KVKKPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case CreateCollection.routeName:
        return PageTransition(
          child: const CreateCollection(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case HelpCenterHome.routeName:
        return PageTransition(
          child: HelpCenterHome(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case CreateBlogPage.routeName:
        return PageTransition(
          child: const CreateBlogPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case AboutAppPage.routeName:
        return PageTransition(
          child: const AboutAppPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );

      case DeviceInfoPageAndroid.routeName:
        return PageTransition(
          child: const DeviceInfoPageAndroid(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case DeviceInfoPageIOS.routeName:
        return PageTransition(
          child: const DeviceInfoPageIOS(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case NotifSettings.routeName:
        return PageTransition(
          child: const NotifSettings(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case NavigationPage.routeName:
        return PageTransition(
          child: NavigationPage(currentIndex: 0),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );

      case SettingsMainPage.routeName:
        return PageTransition(
          child: SettingsMainPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case BlogPage.routeName:
        return PageTransition(
          child: const BlogPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );

      case GetPremiumMainPage.routeName:
        return PageTransition(
          child: GetPremiumMainPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case IntroScreenMain.routeName:
        return PageTransition(
          child: IntroScreenMain(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case SetUpChildModePage.routeName:
        return PageTransition(
          child: SetUpChildModePage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case DonationPage.routeName:
        return PageTransition(
          child: const DonationPage(),
          type: PageTransitionType.bottomToTop,
          settings: settings,
        );
      case RequestNotifPermissionScreen.routeName:
        return PageTransition(
          child: const RequestNotifPermissionScreen(),
          type: PageTransitionType.fade,
          settings: settings,
        );
      case CheckToken.routeName:
        return PageTransition(
          child: const CheckToken(),
          type: PageTransitionType.fade,
          settings: settings,
        );

      case AskQScreen.routeName:
        return PageTransition(
          child: const AskQScreen(),
          type: PageTransitionType.fade,
          settings: settings,
        );

      case ChildLockScreen.routeName:
        return PageTransition(
          child: const ChildLockScreen(
            isThis: false,
          ),
          type: PageTransitionType.leftToRight,
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text(
                'Ölümcül Hata',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.dangerous_outlined,
                      color: Colors.red,
                      size: 100,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                        'Navigasyon Bozuldu :(  ${settings.name} bu rota bulunamadı. Girmeye çalıştığınız sayfa yok.'),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}
