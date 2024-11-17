import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gokid/pages/navigation_page.dart';
import 'package:gokid/pages/login_page.dart';
import 'package:gokid/pages/wait_verifiction.dart';
import 'package:gokid/routes/route.dart';
import 'package:gokid/services/firebase_auth_methods.dart';
import 'package:gokid/services/firebase_crud_methods.dart';
import 'package:gokid/services/local_methods.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'bloc/user_bloc/user_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setDefaultTtsEngine();
  runApp(const MyApp());
}

Future<void> setDefaultTtsEngine() async {
  final FlutterTts flutterTts = FlutterTts();
  List<dynamic>? engines = await flutterTts.getEngines;

  if (engines != null && engines.contains("com.google.android.tts")) {
    await flutterTts.setEngine("com.google.android.tts");
  } else {
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                UserBloc(FirebaseCrudMethods(FirebaseFirestore.instance))),
        Provider<LocalMethods>(
          create: (_) => LocalMethods(),
        ),
        Provider<FirebaseAuthMethods>(
          create: (_) => FirebaseAuthMethods(FirebaseAuth.instance),
        ),
        Provider<FirebaseCrudMethods>(
          create: (_) => FirebaseCrudMethods(FirebaseFirestore.instance),
        ),
        Provider<VerificationPage>(
          create: (_) => const VerificationPage(),
        ),
        StreamProvider(
          create: (context) => context.read<FirebaseAuthMethods>().authState,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Mulish',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: Routing.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  static const String routeName = '/';

  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return NavigationPage(currentIndex: 0);
    }
    return const LoginScreen();
  }
}
