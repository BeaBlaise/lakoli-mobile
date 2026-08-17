import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/geographie.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../application/auth_controller.dart';
import '../application/geographie_provider.dart';

/// Deux onglets, comme la page web (resources/js/Pages/Auth/Register.tsx) : Utilisateur
/// (personnel) et École — deux flux réellement différents, pas une variante l'un de l'autre
/// (voir RegisterEcoleAction côté Laravel, qui crée à la fois un rôle école et un rôle
/// utilisateur, plus une école en attente de validation admin).
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [Tab(text: 'Utilisateur'), Tab(text: 'École')],
          ),
        ),
        body: const TabBarView(
          children: [_UserRegisterForm(), _EcoleRegisterForm()],
        ),
      ),
    );
  }
}

class _UserRegisterForm extends ConsumerStatefulWidget {
  const _UserRegisterForm();

  @override
  ConsumerState<_UserRegisterForm> createState() => _UserRegisterFormState();
}

class _UserRegisterFormState extends ConsumerState<_UserRegisterForm> {
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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Suivez vos écoles préférées et découvrez leur actualité.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_errorMessage != null) ...[
                _ErrorBanner(message: _errorMessage!),
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
    );
  }
}

class _EcoleRegisterForm extends ConsumerStatefulWidget {
  const _EcoleRegisterForm();

  @override
  ConsumerState<_EcoleRegisterForm> createState() => _EcoleRegisterFormState();
}

class _EcoleRegisterFormState extends ConsumerState<_EcoleRegisterForm> {
  final _nomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _quartierController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();

  String _typeEtablissement = 'public';
  String? _region;
  String? _prefecture;
  String? _commune;

  bool _submitting = false;
  String? _errorMessage;
  Map<String, List<String>>? _fieldErrors;

  @override
  void dispose() {
    _nomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _quartierController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
      _fieldErrors = null;
    });

    final exception = await ref.read(authControllerProvider.notifier).registerEcole(
          nom: _nomController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          typeEtablissement: _typeEtablissement,
          region: _region,
          prefecture: _prefecture,
          commune: _commune,
          quartier: _quartierController.text.trim().isEmpty ? null : _quartierController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
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
    final geographie = ref.watch(geographieProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Votre école sera visible sur Lakoli après validation par un administrateur.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_errorMessage != null) ...[
                _ErrorBanner(message: _errorMessage!),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppTextField(
                label: "Nom de l'établissement",
                controller: _nomController,
                enabled: !_submitting,
                errorText: _fieldErrors?['nom']?.first,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Statut', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'public', label: Text('Public')),
                  ButtonSegment(value: 'prive', label: Text('Privé')),
                ],
                selected: {_typeEtablissement},
                onSelectionChanged: _submitting ? null : (value) => setState(() => _typeEtablissement = value.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              geographie.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: LinearProgressIndicator(),
                ),
                error: (_, __) => Text(
                  'Impossible de charger les régions — vous pourrez les renseigner plus tard depuis le profil.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.error),
                ),
                data: (regions) => _GeographieSelects(
                  regions: regions,
                  region: _region,
                  prefecture: _prefecture,
                  commune: _commune,
                  enabled: !_submitting,
                  onChanged: (region, prefecture, commune) => setState(() {
                    _region = region;
                    _prefecture = prefecture;
                    _commune = commune;
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Quartier',
                controller: _quartierController,
                enabled: !_submitting,
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
                label: 'Email (optionnel)',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_submitting,
                errorText: _fieldErrors?['email']?.first,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Description (optionnel)',
                controller: _descriptionController,
                maxLines: 3,
                enabled: !_submitting,
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
                label: "Créer le compte de l'école",
                onPressed: _submitting ? null : _submit,
                loading: _submitting,
                fullWidth: true,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeographieSelects extends StatelessWidget {
  const _GeographieSelects({
    required this.regions,
    required this.region,
    required this.prefecture,
    required this.commune,
    required this.enabled,
    required this.onChanged,
  });

  final List<RegionGeo> regions;
  final String? region;
  final String? prefecture;
  final String? commune;
  final bool enabled;
  final void Function(String? region, String? prefecture, String? commune) onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedRegion = _findRegionByNom(regions, region);
    final prefectures = selectedRegion?.prefectures ?? const <PrefectureGeo>[];
    final selectedPrefecture = _findPrefectureByNom(prefectures, prefecture);
    final communes = selectedPrefecture?.communes ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Région', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: region,
          items: [for (final r in regions) DropdownMenuItem(value: r.nom, child: Text(r.nom))],
          onChanged: enabled ? (value) => onChanged(value, null, null) : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Préfecture', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: prefecture,
          items: [for (final p in prefectures) DropdownMenuItem(value: p.nom, child: Text(p.nom))],
          onChanged: enabled && prefectures.isNotEmpty ? (value) => onChanged(region, value, null) : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Commune', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: commune,
          items: [for (final c in communes) DropdownMenuItem(value: c, child: Text(c))],
          onChanged: enabled && communes.isNotEmpty ? (value) => onChanged(region, prefecture, value) : null,
        ),
      ],
    );
  }
}

RegionGeo? _findRegionByNom(List<RegionGeo> regions, String? nom) {
  for (final r in regions) {
    if (r.nom == nom) return r;
  }
  return null;
}

PrefectureGeo? _findPrefectureByNom(List<PrefectureGeo> prefectures, String? nom) {
  for (final p in prefectures) {
    if (p.nom == nom) return p;
  }
  return null;
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.error)),
    );
  }
}
