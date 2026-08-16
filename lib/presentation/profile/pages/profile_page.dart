import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/user_entity.dart';
import '../../auth/application/auth_controller.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_button.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    if (user == null) return const SizedBox.shrink();

    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Column(
              children: [
                AppAvatar(imageUrl: user.avatarUrl, name: user.fullName, size: AppAvatarSize.xl),
                const SizedBox(height: AppSpacing.md),
                Text(user.fullName, style: textTheme.titleLarge),
                if (user.phone != null) ...[
                  const SizedBox(height: 2),
                  Text(user.phone!, style: textTheme.bodyMedium?.copyWith(color: colors.inkMuted)),
                ],
              ],
            ),
          ),
          if (user.canSwitchProfile) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text('Basculer de profil', style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ce compte a aussi un profil école — passez de l\'un à l\'autre sans vous déconnecter.',
              style: textTheme.bodySmall?.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            _RoleSwitcher(user: user),
          ],
          const SizedBox(height: AppSpacing.xxxl),
          AppButton(
            label: 'Se déconnecter',
            variant: AppButtonVariant.destructive,
            fullWidth: true,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _RoleSwitcher extends ConsumerStatefulWidget {
  const _RoleSwitcher({required this.user});

  final UserEntity user;

  @override
  ConsumerState<_RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends ConsumerState<_RoleSwitcher> {
  bool _switching = false;

  Future<void> _switchTo(UserRole role) async {
    if (role == widget.user.activeRole || _switching) return;

    setState(() => _switching = true);
    final exception = await ref.read(authControllerProvider.notifier).switchActiveRole(role);
    if (!mounted) return;
    setState(() => _switching = false);

    if (exception != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.message)));
    }
  }

  String _label(UserRole role) => switch (role) {
        UserRole.user => 'Personnel',
        UserRole.ecole => 'École',
        UserRole.admin => 'Admin',
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final role in widget.user.availableRoles)
          ChoiceChip(
            label: Text(_label(role)),
            selected: role == widget.user.activeRole,
            onSelected: _switching ? null : (_) => _switchTo(role),
          ),
      ],
    );
  }
}
