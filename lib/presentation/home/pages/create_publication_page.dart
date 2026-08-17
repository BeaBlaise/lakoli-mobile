import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/user_entity.dart';
import '../../auth/application/auth_controller.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/states/empty_state_view.dart';
import '../application/feed_controller.dart';

/// Réservé aux comptes école — POST /api/v1/publications exige role:ecole côté serveur
/// (Api\V1\PublicationController::store()). Un compte double-rôle (voir bascule de profil,
/// ProfilePage) qui n'a pas actuellement "revêtu" son identité école voit une invitation à
/// basculer plutôt qu'un formulaire qui échouerait en 403 à la soumission.
class CreatePublicationPage extends ConsumerWidget {
  const CreatePublicationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    if (user?.activeRole != UserRole.ecole) {
      return Scaffold(
        appBar: AppBar(title: const Text('Créer')),
        body: Center(
          child: EmptyStateView(
            icon: Icons.add_box_outlined,
            title: 'Réservé aux écoles',
            message: user?.canSwitchProfile ?? false
                ? 'Basculez vers votre profil école (onglet Profil) pour publier.'
                : 'Seuls les comptes école peuvent publier sur Lakoli.',
            actionLabel: (user?.canSwitchProfile ?? false) ? 'Aller au profil' : null,
            onAction: (user?.canSwitchProfile ?? false) ? () => context.go('/profil') : null,
          ),
        ),
      );
    }

    // PublicationPolicy::create() côté Laravel exige ecole.statut === Validee — une école
    // fraîchement inscrite (RegisterEcoleAction) démarre toujours EN_ATTENTE. Sans ce contrôle,
    // le formulaire s'afficherait normalement puis échouerait en 403 à la soumission, sans
    // explication pour l'utilisateur.
    if (user?.ecole?.statut != EcoleStatut.validee) {
      final statut = user?.ecole?.statut;
      return Scaffold(
        appBar: AppBar(title: const Text('Créer')),
        body: Center(
          child: EmptyStateView(
            icon: statut == EcoleStatut.refusee ? Icons.error_outline_rounded : Icons.hourglass_empty_rounded,
            title: statut == EcoleStatut.refusee ? 'Inscription refusée' : 'École en attente de validation',
            message: statut == EcoleStatut.refusee
                ? "La validation de votre école a été refusée. Contactez l'équipe Lakoli pour plus d'informations."
                : 'Un administrateur doit valider votre école avant que vous puissiez publier. Cela peut prendre quelques jours.',
          ),
        ),
      );
    }

    return const _CreatePublicationForm();
  }
}

class _CreatePublicationForm extends ConsumerStatefulWidget {
  const _CreatePublicationForm();

  @override
  ConsumerState<_CreatePublicationForm> createState() => _CreatePublicationFormState();
}

class _CreatePublicationFormState extends ConsumerState<_CreatePublicationForm> {
  final _contentController = TextEditingController();
  final List<XFile> _images = [];
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = 10 - _images.length;
    if (remaining <= 0) return;

    final picked = await ImagePicker().pickMultiImage(limit: remaining);
    if (picked.isEmpty) return;

    setState(() => _images.addAll(picked.take(remaining)));
  }

  Future<void> _submit() async {
    final contenu = _contentController.text.trim();
    if (contenu.isEmpty || _submitting) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(publicationRepositoryProvider)
        .create(contenu, _images.map((f) => f.path).toList());

    if (!mounted) return;

    result.when(
      success: (_) {
        setState(() {
          _submitting = false;
          _contentController.clear();
          _images.clear();
        });
        ref.read(feedControllerProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publication envoyée.')));
        context.go('/');
      },
      failure: (exception) {
        setState(() {
          _submitting = false;
          _errorMessage = exception.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle publication'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: AppButton(
                label: 'Publier',
                onPressed: _contentController.text.trim().isEmpty || _submitting ? null : _submit,
                loading: _submitting,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Text(_errorMessage!, style: TextStyle(color: colors.error)),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            TextField(
              controller: _contentController,
              maxLines: 6,
              minLines: 4,
              enabled: !_submitting,
              decoration: const InputDecoration(hintText: 'Partagez une actualité de votre école…'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final image in _images)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Image.file(File(image.path), width: 88, height: 88, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: InkWell(
                          onTap: _submitting ? null : () => setState(() => _images.remove(image)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_images.length < 10)
                  InkWell(
                    onTap: _submitting ? null : _pickImages,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(Icons.add_photo_alternate_outlined, color: colors.inkMuted),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
