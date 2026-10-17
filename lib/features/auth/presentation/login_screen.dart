import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kabulfit_brand_logo.dart';
import '../application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (_, next) {
      if (next.hasValue && next.value != null) context.go('/');
    });

    return Scaffold(
      appBar: AppBar(title: const Text('KABULFIT')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 28,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            BrandColors.deepBurgundy,
                            BrandColors.burgundy,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Column(
                        children: [
                          KabulFitBrandLogo(
                            white: true,
                            width: 230,
                            height: 85,
                          ),
                          SizedBox(height: 7),
                          Text(
                            'HERITAGE IN EVERY STITCH',
                            style: TextStyle(
                              color: BrandColors.champagne,
                              fontSize: 10,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      strings.text('welcome'),
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      switch (Localizations.localeOf(context).languageCode) {
                        'fa' => 'برای ادامه وارد حساب خود شوید',
                        'ps' => 'د دوام لپاره خپل حساب ته ننوځئ',
                        _ => 'Sign in to discover your personal collection',
                      },
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: strings.text('email'),
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return strings.text('invalidEmail');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: strings.text('password'),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? strings.text('required')
                          : null,
                    ),
                    if (auth.hasError) ...[
                      const SizedBox(height: 12),
                      Text(
                        auth.error.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: auth.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                ref
                                    .read(authControllerProvider.notifier)
                                    .signIn(_email.text.trim(), _password.text);
                              }
                            },
                      child: auth.isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : Text(strings.text('signIn')),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push('/register'),
                      child: Text(strings.text('createAccount')),
                    ),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(strings.text('continueAsGuest')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
