import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kabulfit_bottom_navigation.dart';
import '../../../core/widgets/kabulfit_brand_logo.dart';
import '../application/auth_controller.dart';

/// Customer account screen from the approved luxury-fashion mockup.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider).value;
    final locale = Localizations.localeOf(context).languageCode;
    final email = session?.email;
    final initial = (email == null || email.isEmpty)
        ? 'K'
        : email[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const KabulFitBrandLogo(width: 160, height: 50)),
      bottomNavigationBar: const KabulFitBottomNavigation(selectedIndex: 4),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [BrandColors.deepBurgundy, BrandColors.burgundy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: BrandColors.cream,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 25,
                      color: BrandColors.burgundy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 17),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email == null
                            ? strings.text('welcome')
                            : strings.text('account'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email ?? strings.text('signIn'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: BrandColors.champagne),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.settings_outlined, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 19),
          if (session == null) ...[
            FilledButton(
              onPressed: () => context.push('/login'),
              child: Text(strings.text('signIn')),
            ),
            const SizedBox(height: 9),
            OutlinedButton(
              onPressed: () => context.push('/register'),
              child: Text(strings.text('createAccount')),
            ),
            const SizedBox(height: 16),
          ],
          _AccountAction(
            icon: Icons.receipt_long_outlined,
            label: strings.text('myOrders'),
            onTap: () => context.push('/orders'),
          ),
          _AccountAction(
            icon: Icons.menu_book_outlined,
            label: switch (locale) {
              'fa' => 'رهنمای اندازه‌گیری',
              'ps' => 'د اندازې لارښود',
              _ => 'Measurement guide',
            },
            onTap: () => context.push('/measurement-guide'),
          ),
          _AccountAction(
            icon: Icons.straighten_outlined,
            label: strings.text('myMeasurements'),
            onTap: () => context.go('/measurements'),
          ),
          _AccountAction(
            icon: Icons.favorite_border_outlined,
            label: strings.text('wishlist'),
            onTap: () => context.push('/wishlist'),
          ),
          _AccountAction(
            icon: Icons.location_on_outlined,
            label: strings.text('addresses'),
            onTap: () => context.push('/addresses'),
          ),
          _AccountAction(
            icon: Icons.checkroom_outlined,
            label: strings.text('myTailoring'),
            onTap: () => context.push('/tailoring'),
          ),
          const SizedBox(height: 16),
          const Divider(),
          _AccountAction(
            icon: Icons.language_outlined,
            label: strings.text('language'),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              builder: (sheetContext) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final entry in [
                        ('en', 'English'),
                        ('fa', 'دری'),
                        ('ps', 'پښتو'),
                      ])
                        ListTile(
                          title: Text(entry.$2),
                          trailing: locale == entry.$1
                              ? const Icon(
                                  Icons.check,
                                  color: BrandColors.burgundy,
                                )
                              : null,
                          onTap: () {
                            ref
                                .read(appLocaleProvider.notifier)
                                .change(entry.$1);
                            Navigator.of(sheetContext).pop();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (session != null) ...[
            const Divider(),
            _AccountAction(
              icon: Icons.logout,
              label: switch (locale) {
                'fa' => 'خروج از حساب',
                'ps' => 'له حسابه وتل',
                _ => 'Sign out',
              },
              danger: true,
              onTap: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go('/');
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(
          icon,
          color: danger
              ? Theme.of(context).colorScheme.error
              : BrandColors.burgundy,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: danger
                ? Theme.of(context).colorScheme.error
                : BrandColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: BrandColors.mutedInk,
        ),
        onTap: onTap,
      ),
    ),
  );
}
