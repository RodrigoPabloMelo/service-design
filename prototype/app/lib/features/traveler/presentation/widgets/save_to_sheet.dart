import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/folder_cover.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_sheet.dart';

/// "Salvar em" (ref. Pinterest, D-28): as viagens dela numa lista
/// segmentada e, no fim, "Nova viagem". Devolve o id da pasta escolhida
/// (criada na hora, se for nova) ou null se fechou.
Future<String?> showSaveToSheet(BuildContext context) => showMareSheet<String>(
      context,
      builder: (_) => const SaveToSheet(),
    );

/// Só o passo "Nova viagem" (botão + da aba Salvos). Devolve o id criado.
Future<String?> showNewFolderSheet(BuildContext context) =>
    showMareSheet<String>(
      context,
      builder: (_) => const SaveToSheet(createOnly: true),
    );

class SaveToSheet extends StatefulWidget {
  const SaveToSheet({this.createOnly = false, super.key});

  /// Abre direto no passo de criar, sem a lista.
  final bool createOnly;

  @override
  State<SaveToSheet> createState() => _SaveToSheetState();
}

class _SaveToSheetState extends State<SaveToSheet> {
  late bool _creating = widget.createOnly;
  late final _name = TextEditingController(
      text: widget.createOnly ? TravelerMock.newFolderHint : null)
    ..selection = TextSelection(
        baseOffset: 0,
        extentOffset:
            widget.createOnly ? TravelerMock.newFolderHint.length : 0);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _create() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(travelerCubit().createFolder(name));
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final s = travelerCubit().state;
    final folders = s.folders;
    final n = folders.length + 1;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          TravelSpace.gutter,
          TravelSpace.sm,
          TravelSpace.gutter,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          curve: kExploreEase,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetBar(
                title: _creating ? 'Nova viagem' : 'Salvar em',
                leading: _creating && !widget.createOnly
                    ? TextAction(
                        'Voltar',
                        onTap: () => setState(() => _creating = false),
                      )
                    : null,
                onClose: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: TravelSpace.sm),
              if (_creating) ...[
                _NameField(controller: _name, onSubmit: _create),
                const SizedBox(height: TravelSpace.xl),
                ListenableBuilder(
                  listenable: _name,
                  builder: (context, _) => PrimaryButton(
                    label: widget.createOnly ? 'Criar viagem' : 'Criar e salvar',
                    onPressed: _name.text.trim().isEmpty ? null : _create,
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: TravelSpace.cardPad),
                  child: Text('Suas viagens',
                      style: TravelType.section.copyWith(color: p.inkMuted)),
                ),
                const SizedBox(height: TravelSpace.sm),
                for (var i = 0; i < folders.length; i++) ...[
                  if (i > 0) const SizedBox(height: TravelSpace.segmentGap),
                  _FolderRow(
                    title: TravelerMock.folderLabel(folders[i], s.trip),
                    detail: _count(folders[i].roleIds.length),
                    cover: FolderCover(
                      roleIds: folders[i].roleIds,
                      radius: 16,
                      mosaic: false,
                    ),
                    radius: segmentRadius(i, n),
                    onTap: () => Navigator.of(context).pop(folders[i].id),
                  ),
                ],
                const SizedBox(height: TravelSpace.segmentGap),
                _FolderRow(
                  title: 'Nova viagem',
                  cover: ColoredBox(
                    color: p.accent,
                    child: const Center(
                      child: FaIcon(TravelIcons.plus,
                          size: 18, color: Colors.white),
                    ),
                  ),
                  radius: segmentRadius(n - 1, n),
                  onTap: () {
                    _name.text = TravelerMock.newFolderHint;
                    _name.selection = TextSelection(
                        baseOffset: 0, extentOffset: _name.text.length);
                    setState(() => _creating = true);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _count(int n) => n == 1 ? '1 rolê' : '$n rolês';

/// Tile 72 da lista segmentada: capa 56 (raio 12), nome e contagem.
class _FolderRow extends StatelessWidget {
  const _FolderRow({
    required this.title,
    required this.cover,
    required this.radius,
    required this.onTap,
    this.detail,
  });

  final String title;
  final String? detail;
  final Widget cover;
  final BorderRadius radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: [title, if (detail != null) detail!].join(', '),
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: p.s1, borderRadius: radius),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 56,
                // Concêntrico: tile 24 − padding 8 = 16.
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: cover,
                ),
              ),
              const SizedBox(width: TravelSpace.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TravelType.headline.copyWith(color: p.ink)),
                    if (detail != null)
                      Text(detail!,
                          style: TravelType.footnote.copyWith(
                              color: p.inkMuted,
                              fontFeatures: TravelType.tabular)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Campo do nome da viagem: `s2` raio 12, 52 de altura (igual ao "Onde?").
class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nome da viagem',
              style: TravelType.section.copyWith(color: p.inkMuted)),
          const SizedBox(height: TravelSpace.sm),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: p.s2,
              borderRadius: BorderRadius.circular(TravelSpace.rInner),
            ),
            child: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              cursorColor: p.accent,
              style: TravelType.body.copyWith(color: p.ink, height: 1.2),
              decoration: InputDecoration.collapsed(
                hintText: 'Cidade, mês',
                hintStyle:
                    TravelType.body.copyWith(color: p.inkMuted, height: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
