// lib/src/features/auth/presentation/animated_auth_screen.dart
import 'dart:ui';
import 'package:aic_woippy_app/src/features/auth/presentation/phone_verification_screen.dart';
import 'package:aic_woippy_app/src/features/auth/presentation/reset_by_phone_screen.dart'; // NOUVEL IMPORT
import 'package:aic_woippy_app/src/shared/widgets/fading_edge_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:aic_woippy_app/src/features/auth/application/auth_controller.dart';
import 'package:aic_woippy_app/src/features/auth/data/auth_repository.dart';

class AnimatedAuthScreen extends StatefulWidget {
  const AnimatedAuthScreen({super.key});
  @override
  State<AnimatedAuthScreen> createState() => _AnimatedAuthScreenState();
}

class _AnimatedAuthScreenState extends State<AnimatedAuthScreen> {
  final PageController _pageController = PageController();
  String _resetIdentifier = ""; // Peut être un e-mail ou un téléphone

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Expanded(
                      child: Center(
                        child: Icon(Icons.mosque_outlined, size: 80, color: Colors.white),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.68,
                      decoration: const BoxDecoration(
                        color: Color(0xB3FFFFFF),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _SignInCard(
                            onSwitchToSignUp: () => _navigateToPage(1),
                            onSwitchToPasswordReset: () => _navigateToPage(2),
                          ),
                          _SignUpCard(
                            onSwitchToSignIn: () => _navigateToPage(0),
                          ),
                          _PasswordResetCard(
                            onSwitchToSignIn: () => _navigateToPage(0),
                            onIdentifierSubmitted: (identifier) {
                              setState(() {
                                _resetIdentifier = identifier;
                              });
                              // Si l'identifiant est un email, on va à la page de vérification de code
                              if (identifier.contains('@')) {
                                _navigateToPage(3);
                              }
                              // La logique pour le téléphone est gérée directement dans la carte
                            },
                          ),
                          _CodeVerificationCard(
                            identifier: _resetIdentifier,
                            onCodeVerified: (email) {
                              setState(() {
                                _resetIdentifier = email;
                              });
                              _navigateToPage(4);
                            },
                            onSwitchToSignIn: () => _navigateToPage(0),
                          ),
                          _NewPasswordCard(
                            email: _resetIdentifier,
                            onPasswordResetSuccess: () => _navigateToPage(0),
                          )
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
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}

// --- Les Cartes ---

class _SignInCard extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToSignUp;
  final VoidCallback onSwitchToPasswordReset;
  const _SignInCard({required this.onSwitchToSignUp, required this.onSwitchToPasswordReset});
  @override
  ConsumerState<_SignInCard> createState() => _SignInCardState();
}

class _SignInCardState extends ConsumerState<_SignInCard> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    String identifier = _identifierController.text.trim();
    String emailToSignIn = identifier;

    setState(() {});

    // Si ce n'est pas un email, on cherche l'email associé au téléphone localement
    if (!identifier.contains('@')) {
      final foundEmail = await ref.read(authRepositoryProvider).findUserByPhone(identifier);
      if (foundEmail == null) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aucun compte trouvé avec ce numéro de téléphone."), backgroundColor: Colors.red));
        return;
      }
      emailToSignIn = foundEmail;
    }

    try {
      await ref.read(authControllerProvider.notifier).signIn(
        email: emailToSignIn,
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return FadingEdgeScrollView(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 24.0),
          children: [
            Text('Bienvenue', textAlign: TextAlign.center, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Connectez-vous pour continuer', textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 32),
            TextFormField(
              controller: _identifierController,
              decoration: const InputDecoration(labelText: 'Email ou Téléphone'),
              keyboardType: TextInputType.visiblePassword, // Permet les @ et les chiffres
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
              validator: (v) => v!.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => v!.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 24),
            isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submit, child: const Text('Se connecter')),
            Column(
              children: [
                TextButton(onPressed: isLoading ? null : widget.onSwitchToPasswordReset, child: Text("Mot de passe oublié ?", style: TextStyle(color: Theme.of(context).primaryColor))),
                TextButton(onPressed: isLoading ? null : widget.onSwitchToSignUp, child: RichText(text: TextSpan(text: 'Pas encore de compte ? ', style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]), children: [TextSpan(text: 'S\'inscrire', style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))]))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _SignUpCard extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToSignIn;
  const _SignUpCard({required this.onSwitchToSignIn});
  @override
  ConsumerState<_SignUpCard> createState() => _SignUpCardState();
}
class _SignUpCardState extends ConsumerState<_SignUpCard> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = {'firstName': TextEditingController(), 'lastName': TextEditingController(), 'email': TextEditingController(), 'phone': TextEditingController(), 'password': TextEditingController()};
  final _focusNodes = {'lastName': FocusNode(), 'email': FocusNode(), 'phone': FocusNode(), 'password': FocusNode()};
  String _selectedCountryCode = '+33';
  @override
  void dispose() { _controllers.values.forEach((c) => c.dispose()); _focusNodes.values.forEach((n) => n.dispose()); super.dispose(); }
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    String localPhone = _controllers['phone']!.text.trim();
    if (localPhone.startsWith('0')) { localPhone = localPhone.substring(1); }
    final String fullPhoneNumber = _selectedCountryCode + localPhone;
    try {
      await ref.read(authControllerProvider.notifier).signUp(firstName: _controllers['firstName']!.text.trim(), lastName: _controllers['lastName']!.text.trim(), email: _controllers['email']!.text.trim(), phone: fullPhoneNumber, password: _controllers['password']!.text.trim());
      if(!mounted) return;
      navigator.push(MaterialPageRoute(builder: (context) => PhoneVerificationScreen(phoneNumber: fullPhoneNumber)));
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red)); }
    }
  }
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    return FadingEdgeScrollView(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 24.0),
          children: [
            Text('Créer un compte', textAlign: TextAlign.center, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Renseignez vos informations', textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 24),
            TextFormField(controller: _controllers['firstName'], decoration: const InputDecoration(labelText: 'Prénom'), textInputAction: TextInputAction.next, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_focusNodes['lastName']), validator: (v) => v!.isEmpty ? 'Champ requis' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _controllers['lastName'], focusNode: _focusNodes['lastName'], decoration: const InputDecoration(labelText: 'Nom'), textInputAction: TextInputAction.next, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_focusNodes['email']), validator: (v) => v!.isEmpty ? 'Champ requis' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _controllers['email'], focusNode: _focusNodes['email'], decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_focusNodes['phone']), validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email invalide' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _controllers['phone'], focusNode: _focusNodes['phone'], decoration: InputDecoration(labelText: 'Téléphone', prefixIcon: Padding(padding: const EdgeInsets.only(left: 12.0), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _selectedCountryCode, items: <String>['+33', '+32', '+41', '+49', '+213'].map<DropdownMenuItem<String>>((String value) { return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))); }).toList(), onChanged: (String? newValue) { setState(() { _selectedCountryCode = newValue!; }); })))), keyboardType: TextInputType.phone, textInputAction: TextInputAction.next, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_focusNodes['password']), validator: (v) { if (v!.isEmpty) return 'Champ requis'; if (int.tryParse(v) == null) return 'Numéro invalide'; return null; }),
            const SizedBox(height: 12),
            TextFormField(controller: _controllers['password'], focusNode: _focusNodes['password'], decoration: const InputDecoration(labelText: 'Mot de passe'), obscureText: true, textInputAction: TextInputAction.done, onFieldSubmitted: (_) => _submit(), validator: (v) => v!.length < 6 ? '6 caractères minimum' : null),
            const SizedBox(height: 24),
            isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submit, child: const Text('S\'inscrire')),
            const SizedBox(height: 12),
            TextButton(onPressed: isLoading ? null : widget.onSwitchToSignIn, child: RichText(text: TextSpan(text: 'Déjà un compte ? ', style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]), children: [TextSpan(text: 'Se connecter', style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))]))),
          ],
        ),
      ),
    );
  }
}

class _PasswordResetCard extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToSignIn;
  final Function(String) onIdentifierSubmitted;
  const _PasswordResetCard({required this.onSwitchToSignIn, required this.onIdentifierSubmitted});
  @override
  ConsumerState<_PasswordResetCard> createState() => __PasswordResetCardState();
}

class __PasswordResetCardState extends ConsumerState<_PasswordResetCard> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final identifier = _identifierController.text.trim();
    final isEmail = identifier.contains('@');

    try {
      if (isEmail) {
        await ref.read(authControllerProvider.notifier).requestPasswordResetCode(email: identifier);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Si un compte existe, un code vous a été envoyé."), backgroundColor: Colors.green));
          widget.onIdentifierSubmitted(identifier);
        }
      } else {
        // C'est un numéro, on navigue vers l'écran de vérification SMS dédié
        final navigator = Navigator.of(context);
        if(!mounted) return;
        // --- MODIFICATION ICI ---
        // On attend le retour de l'écran ResetByPhoneScreen
        final emailFromPhone = await navigator.push<String?>(
          MaterialPageRoute(builder: (context) => ResetByPhoneScreen(phoneNumber: identifier)),
        );

        // Si on a récupéré un email, on lance la suite du processus
        if (emailFromPhone != null && emailFromPhone.isNotEmpty) {
          widget.onIdentifierSubmitted(emailFromPhone);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return FadingEdgeScrollView(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 24.0),
          children: [
            Text('Mot de passe oublié', textAlign: TextAlign.center, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Entrez votre e-mail ou téléphone pour recevoir un code.', textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 32),
            TextFormField(
              controller: _identifierController,
              decoration: const InputDecoration(labelText: 'Email ou Téléphone'),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => v!.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 24),
            isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submit, child: const Text('Envoyer le code')),
            const SizedBox(height: 12),
            TextButton(onPressed: isLoading ? null : widget.onSwitchToSignIn, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.arrow_back), const SizedBox(width: 8), Text("Retour à la connexion", style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))])),
          ],
        ),
      ),
    );
  }
}

class _CodeVerificationCard extends ConsumerStatefulWidget {
  final String identifier; // L'email de l'étape précédente
  final Function(String) onCodeVerified;
  final VoidCallback onSwitchToSignIn;
  const _CodeVerificationCard({required this.identifier, required this.onCodeVerified, required this.onSwitchToSignIn});
  @override
  ConsumerState<_CodeVerificationCard> createState() => _CodeVerificationCardState();
}

class _CodeVerificationCardState extends ConsumerState<_CodeVerificationCard> {
  final _codeController = TextEditingController();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_codeController.text.length != 6) return;
    try {
      await ref.read(authControllerProvider.notifier).verifyResetCode(
        email: widget.identifier,
        code: _codeController.text,
      );
      if(mounted) widget.onCodeVerified(widget.identifier);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final defaultPinTheme = PinTheme(width: 50, height: 55, textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)));

    return FadingEdgeScrollView(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 24.0),
        children: [
          Text('Vérification', textAlign: TextAlign.center, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Saisissez le code envoyé à :\n${widget.identifier}', textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 32),
          Pinput(
            controller: _codeController,
            length: 6,
            autofocus: true,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: Theme.of(context).primaryColor, width: 2))),
            validator: (s) => s?.length == 6 ? null : 'Le code doit faire 6 chiffres',
          ),
          const SizedBox(height: 24),
          isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submit, child: const Text('Vérifier')),
        ],
      ),
    );
  }
}

class _NewPasswordCard extends ConsumerStatefulWidget {
  final String email;
  final VoidCallback onPasswordResetSuccess;
  const _NewPasswordCard({required this.email, required this.onPasswordResetSuccess});
  @override
  ConsumerState<_NewPasswordCard> createState() => _NewPasswordCardState();
}

class _NewPasswordCardState extends ConsumerState<_NewPasswordCard> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).resetPassword(
        email: widget.email,
        newPassword: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mot de passe réinitialisé avec succès !"), backgroundColor: Colors.green));
        widget.onPasswordResetSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return FadingEdgeScrollView(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 24.0),
          children: [
            Text('Nouveau mot de passe', textAlign: TextAlign.center, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Choisissez un nouveau mot de passe sécurisé.', textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 32),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
              obscureText: true,
              validator: (v) => v!.length < 6 ? '6 caractères minimum' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
              obscureText: true,
              validator: (v) {
                if (v != _passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submit, child: const Text('Réinitialiser le mot de passe')),
          ],
        ),
      ),
    );
  }
}