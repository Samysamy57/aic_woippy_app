// lib/src/features/auth/presentation/phone_verification_screen.dart

import 'dart:ui';
import 'package:aic_woippy_app/src/shared/widgets/fading_edge_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aic_woippy_app/src/features/auth/application/auth_controller.dart';
import 'package:aic_woippy_app/src/features/profile/presentation/dossier_screen.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const PhoneVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends ConsumerState<PhoneVerificationScreen> {
  // ... (toute la logique interne reste la même)
  String? _verificationId;
  final _codeController = TextEditingController();
  bool _isLoading = true;
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _sendVerificationCode()); }
  void _sendVerificationCode() {
    if (!mounted) return;
    setState(() => _isLoading = true);
    ref.read(authControllerProvider.notifier).sendPhoneVerificationCode(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (!mounted) return;
        setState(() => _isLoading = true);
        await ref.read(authControllerProvider.notifier).linkCredential(credential);
        _navigateToNextScreen();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : ${e.message}"), backgroundColor: Colors.red));
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() { _verificationId = verificationId; _isLoading = false; });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!mounted) return;
        setState(() { _verificationId = verificationId; });
      },
    );
  }
  void _submitCode() async {
    if (_verificationId == null || _codeController.text.length != 6) return;
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).verifySmsCodeAndLinkAccount(verificationId: _verificationId!, smsCode: _codeController.text);
      _navigateToNextScreen();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le code est incorrect. Veuillez réessayer."), backgroundColor: Colors.red));
    }
  }
  void _navigateToNextScreen() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const DossierScreen()), (route) => false);
  }
  Widget _buildBackground() {
    return Stack(children: [ Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/background_auth.png'), fit: BoxFit.cover))), BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), child: Container(color: Colors.black.withOpacity(0.3)))]);
  }

  @override
  Widget build(BuildContext context) {
    // ... (la logique de build reste la même, mais avec la nouvelle structure)
    final textTheme = Theme.of(context).textTheme;
    final defaultPinTheme = PinTheme(width: 50, height: 55, textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            _buildBackground(),
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Icon(Icons.phone_android_rounded, size: 80, color: Colors.white),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.68,
                      decoration: const BoxDecoration(
                        color: Color(0xB3FFFFFF),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      child: FadingEdgeScrollView( // <-- ENVELOPPEMENT ICI
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 10.0),
                          children: [
                            Text("Vérification", textAlign: TextAlign.center, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text("Saisissez le code à 6 chiffres envoyé au\n${widget.phoneNumber}", textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                            const SizedBox(height: 32),
                            Pinput(
                              length: 6,
                              controller: _codeController,
                              onCompleted: (pin) => _submitCode(),
                              autofocus: true,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: defaultPinTheme.copyWith(decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: Theme.of(context).primaryColor, width: 2))),
                              validator: (s) => s?.length == 6 ? null : 'Le code doit faire 6 chiffres',
                            ),
                            const SizedBox(height: 24),
                            _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submitCode, child: const Text("Vérifier et continuer")),
                            TextButton(onPressed: _isLoading ? null : _sendVerificationCode, child: const Text("Renvoyer le code")),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}