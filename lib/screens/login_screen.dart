import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

import '../theme/app_colors.dart';
import '../widgets/login_background.dart';
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        try {
          // Coba gunakan Popup terlebih dahulu untuk Web
          userCredential = await FirebaseAuth.instance.signInWithPopup(
            authProvider,
          );
        } catch (popupError) {
          // Jika popup diblokir/dibatalkan, gunakan fallback Redirect
          debugPrint("Popup gagal, mencoba Redirect: $popupError");
          await FirebaseAuth.instance.signInWithRedirect(authProvider);
          return; // Hentikan eksekusi karena browser akan berpindah halaman
        }
      } else {
        // Logika Android/Native menggunakan google_sign_in v7+
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        await googleSignIn.initialize(
          serverClientId: '43297154872-hebu3a25nlh8o6m5evrt65aqftbgpnni.apps.googleusercontent.com',
        );

        final GoogleSignInAccount? googleUser = await googleSignIn
            .authenticate();

        // Tangani jika user membatalkan pilihan akun
        if (googleUser == null) {
          setState(() => _isLoading = false);
          return;
        }

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }

      debugPrint("LOGIN BERHASIL: ${userCredential.user?.displayName}");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (e) {
      debugPrint("ERROR LOGIN: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Gagal/Dibatalkan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const LoginBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _LoginHeader(),
                  const Spacer(),
                  const _LoginLogo(),
                  const SizedBox(height: 40),
                  const _LoginHeroText(),
                  const SizedBox(height: 32),
                  const _LoginPagination(),
                  const Spacer(),
                  _buildLoginButton(), // Tombol dipanggil sebagai metode agar bisa akses state _isLoading
                  const SizedBox(height: 24),
                  const _LoginFooter(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Slicing khusus untuk Tombol Login karena membutuhkan akses ke state internal
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF4F4F4),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.g_mobiledata, size: 28),
                SizedBox(width: 8),
                Text(
                  'Continue with Google',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_outward, size: 16, color: Colors.black54),
              ],
            ),
    );
  }
}

// ============================================================================
// HASIL SLICING WIDGET UI (Disimpan di bagian bawah file atau bisa dipindah ke folder terpisah)
// ============================================================================

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'OTW.',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.neonYellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonYellow,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonYellow.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          const Text(
            'OW',
            style: TextStyle(
              color: Colors.transparent,
              fontSize: 100,
              fontWeight: FontWeight.w900,
              letterSpacing: -15,
              shadows: [Shadow(color: AppColors.neonYellow, blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHeroText extends StatelessWidget {
  const _LoginHeroText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'YOUR NEXT GAME STARTS HERE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.neonYellow,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Ready to play?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Find your squad, share every win, and stay in the\ngame.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _LoginPagination extends StatelessWidget {
  const _LoginPagination();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neonYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: TextStyle(color: Colors.white38, fontSize: 10),
        children: [
          TextSpan(
            text: 'Terms',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.white54,
            ),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy.',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.white54,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
