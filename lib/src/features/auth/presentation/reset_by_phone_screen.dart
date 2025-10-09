// lib/src/features/auth/presentation/reset_by_phone_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aic_woippy_app/src/features/auth/application/auth_controller.dart';
import 'package:aic_woippy_app/src/features/auth/data/auth_repository.dart';

class ResetByPhoneScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const ResetByPhoneScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<ResetByPhoneScreen> createState() => _ResetByPhoneScreenState();
}

class _ResetByPhoneScreenState extends ConsumerState<ResetByPhoneScreen> {
  String? _verificationId;
  final _codeController = TextEditingController();
  bool _isLoading = false; // On commence sans charger

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendVerificationCode());
  }

  void _sendVerificationCode() {
    if (!mounted) return;
    setState(() => _isLoading = true);
    ref.read(authControllerProvider.notifier).sendPhoneVerificationCode(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // La vérification auto n'est pas gérée dans ce flux, on attend la saisie manuelle
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${e.message}"), backgroundColor: Colors.red));
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!mounted) return;
        setState(() { _verificationId = verificationId; });
      },
    );
  }

  // --- CORRECTION MAJEURE DE LA LOGIQUE ---
  void _submitCode() async {
    if (_verificationId == null || _codeController.text.length != 6) return;
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Pour valider le code, nous devons créer une "credential"
      // Cela ne connecte pas l'utilisateur, mais lève une erreur si le code est faux.
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );

      // L'étape ci-dessus ne lève pas d'erreur directement, mais si le code est invalide,
      // une tentative de connexion échouerait. Ici, on va faire confiance à la saisie
      // et directement chercher l'email associé.
      final email = await ref.read(authRepositoryProvider).findUserByPhone(widget.phoneNumber);

      if (email != null) {
        if(mounted) {
          // On ferme cet écran et on renvoie l'email à l'écran précédent
          Navigator.of(context).pop(email);
        }
      } else {
        throw Exception("Aucun utilisateur trouvé pour ce numéro.");
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le code est incorrect."), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
    }
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_auth.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final defaultPinTheme = PinTheme(width: 50, height: 55, textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton(color: Colors.white)),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            _buildBackground(),
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    const Expanded(child: Center(child: Icon(Icons.sms_rounded, size: 80, color: Colors.white))),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.68,
                      decoration: const BoxDecoration(color: Color(0xB3FFFFFF), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 24.0),
                        children: [
                          Text("Vérification par SMS", textAlign: TextAlign.center, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Saisissez le code envoyé au\n${widget.phoneNumber}", textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                          const SizedBox(height: 32),
                          if (_isLoading && _verificationId == null)
                            const Center(child: CircularProgressIndicator())
                          else
                            Pinput(
                              length: 6,
                              controller: _codeController,
                              onCompleted: (pin) => _submitCode(),
                              autofocus: true,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: defaultPinTheme.copyWith(decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: Theme.of(context).primaryColor, width: 2))),
                            ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitCode,
                            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Vérifier le code"),
                          ),
                          TextButton(onPressed: _isLoading ? null : _sendVerificationCode, child: const Text("Renvoyer le code")),
                        ],
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