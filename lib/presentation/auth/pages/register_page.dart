import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../application/auth_controller.dart';

/// Inscription utilisateur (personnelle) uniquement — l'inscription école a son propre flux
/// côté web (formulaire plus long : nom de l'établissement, région/préfecture/commune, type
/// d'établissement) qui n'a pas encore d'équivalent mobile. `RegisterUserAction` (partagé par
/// web et API) ne crée que le rôle `user` ; voir CLAUDE.md du dépôt lakoli pour
/// `RegisterEcoleAction`, son pendant côté école.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _errorMessage;
  Map<String, List<String>>? _fieldErrors;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
      _fieldErrors = null;
    });

    final exception = await ref.read(authControllerProvider.notifier).register(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    setState(() {
      _submitting = false;
      _errorMessage = exception?.message;
      _fieldErrors = exception is ServerException ? exception.errors : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Créer un compte', style: textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Suivez vos écoles préférées et découvrez leur actualité.',
                    style: textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.errorBg,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(_errorMessage!, style: textTheme.bodySmall?.copyWith(color: colors.error)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  AppTextField(
                    label: 'Nom complet',
                    controller: _fullNameController,
                    enabled: !_submitting,
                    errorText: _fieldErrors?['full_name']?.first,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Téléphone',
                    hint: '620 00 00 00',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_submitting,
                    errorText: _fieldErrors?['phone']?.first,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Mot de passe',
                    hint: '6 caractères minimum',
                    controller: _passwordController,
                    obscureText: true,
                    enabled: !_submitting,
                    errorText: _fieldErrors?['password']?.first,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: 'Créer mon compte',
                    onPressed: _submitting ? null : _submit,
                    loading: _submitting,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: TextButton(
                      onPressed: _submitting ? null : () => context.pop(),
                      child: const Text('Déjà un compte ? Se connecter'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
