import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/kabulfit_brand_logo.dart';
import '../application/auth_controller.dart';

/// Registers against Laravel's existing /auth/register endpoint.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({this.next, super.key});
  final String? next;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirmation]) {
      c.dispose();
    }
    super.dispose();
  }

  String _copy(BuildContext context, String en, String fa, String ps) =>
      switch (Localizations.localeOf(context).languageCode) {
        'fa' => fa,
        'ps' => ps,
        _ => en,
      };

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (_, next) {
      if (next.hasValue && next.value != null) {
        context.go(widget.next == '/measurement-guide'
            ? '/measurement-guide' : '/account');
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(local.text('createAccount'))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: KabulFitBrandLogo(width: 210)),
                    const SizedBox(height: 22),
                    Text(
                      local.text('createAccount'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _name,
                      autofillHints: const [AutofillHints.name],
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: _copy(
                          context,
                          'Full name',
                          'نام کامل',
                          'بشپړ نوم',
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) => (value?.trim().length ?? 0) < 2
                          ? local.text('required')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: local.text('email'),
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                      validator: (value) =>
                          value == null || !value.contains('@')
                          ? local.text('invalidEmail')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: InputDecoration(
                        labelText: _copy(
                          context,
                          'Phone (optional)',
                          'شماره تماس (اختیاری)',
                          'د تلیفون شمېره (اختیاري)',
                        ),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: local.text('password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        final pass = value ?? '';
                        if (pass.length < 8 ||
                            !RegExp('[A-Za-z]').hasMatch(pass) ||
                            !RegExp('[0-9]').hasMatch(pass)) {
                          return _copy(
                            context,
                            'At least 8 characters, including letters and numbers.',
                            'حداقل ۸ حرف شامل حروف و اعداد.',
                            'لږ تر لږه ۸ توري، له تورو او شمېرو سره.',
                          );
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmation,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: _copy(
                          context,
                          'Confirm password',
                          'تکرار رمز عبور',
                          'پټنوم تایید کړئ',
                        ),
                        prefixIcon: const Icon(Icons.verified_user_outlined),
                      ),
                      validator: (value) => value != _password.text
                          ? _copy(
                              context,
                              'Passwords do not match.',
                              'رمزهای عبور مطابقت ندارند.',
                              'پټنومونه یو شان نه دي.',
                            )
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
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: auth.isLoading
                          ? null
                          : () {
                              if (_form.currentState!.validate()) {
                                ref
                                    .read(authControllerProvider.notifier)
                                    .register(
                                      name: _name.text.trim(),
                                      email: _email.text.trim(),
                                      phone: _phone.text.trim(),
                                      password: _password.text,
                                      passwordConfirmation: _confirmation.text,
                                    );
                              }
                            },
                      child: auth.isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : Text(local.text('createAccount')),
                    ),
                    TextButton(
                      onPressed: () => context.go(widget.next == '/measurement-guide'
                          ? '/login?next=%2Fmeasurement-guide' : '/login'),
                      child: Text(
                        _copy(
                          context,
                          'Already have an account? Sign in',
                          'حساب دارید؟ وارد شوید',
                          'حساب لرئ؟ ننوځئ',
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(local.text('continueAsGuest')),
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
