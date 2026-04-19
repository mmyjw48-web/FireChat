import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_massage/screens/chat_screen.dart';
import 'package:my_massage/screens/registration_screen.dart';
import 'package:my_massage/screens/signin_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final _auth = FirebaseAuth.instance;
final singedUser = _auth.currentUser;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MessageMe app',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: WelcomeScreen(),
      initialRoute: singedUser == null
          ? WelcomeScreen.welcom_rout
          : ChatScreen.chat_screen_rout,
      routes: {
        WelcomeScreen.welcom_rout: (context) => WelcomeScreen(),
        ChatScreen.chat_screen_rout: (context) => ChatScreen(),
        SignInScreen.singin_route: (context) => SignInScreen(),

        RegistrationScreen.regisrt_route: (context) => RegistrationScreen(),
      },
    );
  }
}
