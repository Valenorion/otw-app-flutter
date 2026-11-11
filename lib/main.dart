import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahan wajib untuk getRedirectResult
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // Tambahan wajib untuk kIsWeb

import 'firebase_options.dart'; // File otomatis dari FlutterFire[cite: 15]
import 'screens/login_screen.dart'; //[cite: 15]
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //[cite: 15]

  try {
    // Inisialisasi universal untuk Web, Android, & iOS[cite: 15]
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, //[cite: 15]
    );
    debugPrint(
      "FIREBASE BERHASIL DIINISIALISASI DENGAN FLUTTERFIRE!",
    ); //[cite: 15]

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Izin Notifikasi: ${settings.authorizationStatus}');

    // Ambil FCM Token untuk device ini
    try {
      String? token = await messaging.getToken();
      debugPrint('FCM TOKEN DEVICE INI: $token');

      if (token != null && FirebaseAuth.instance.currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({'fcmToken': token}, SetOptions(merge: true));
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Menerima pesan di Foreground: ${message.messageId}');
        if (message.notification != null) {
          debugPrint(
            'Isi Notifikasi: ${message.notification!.title} - ${message.notification!.body}',
          );
          // (Nanti kita sambungkan ke flutter_local_notifications di sini)
        }
      });

      messaging.onTokenRefresh.listen((newToken) async {
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({'fcmToken': newToken}, SetOptions(merge: true));
        }
      });
    } catch (e) {
      debugPrint('Gagal mendapat token FCM: $e');
    }

    // Pengecekan hasil redirect khusus untuk Web
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      final userCredential = await FirebaseAuth.instance.getRedirectResult();
      if (userCredential.user != null) {
        debugPrint(
          "LOGIN BERHASIL VIA REDIRECT: ${userCredential.user?.displayName}",
        );
      }
    }
  } catch (e) {
    debugPrint("ERROR FIREBASE: $e"); //[cite: 15]
  }

  runApp(const MyApp()); //[cite: 15]
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //[cite: 15]

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //[cite: 15]
      title: 'OTW App', //[cite: 15]
      theme: ThemeData(
        brightness: Brightness.dark, //[cite: 15]
        scaffoldBackgroundColor: const Color(0xFF050609), //[cite: 15]
        fontFamily: GoogleFonts.spaceGrotesk().fontFamily, //[cite: 15]
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainLayout();
          }
          return LoginScreen();
        },
      ), //[cite: 15]
    );
  }
}
