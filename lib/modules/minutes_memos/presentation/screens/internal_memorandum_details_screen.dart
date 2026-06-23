import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/memorandum_detail_entity.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/widgets/actas_theme.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

import '../bloc/minutes_memos_bloc.dart';

@RoutePage()
class InternalMemorandumDetailsScreen extends StatefulWidget {
  const InternalMemorandumDetailsScreen({
    super.key,
    required this.memoId,
  });

  final String memoId;

  @override
  State<InternalMemorandumDetailsScreen> createState() =>
      _InternalMemorandumDetailsScreenState();
}

class _InternalMemorandumDetailsScreenState
    extends State<InternalMemorandumDetailsScreen> {
  late MinutesMemosBloc _minutesMemosBloc;

  @override
  void initState() {
    super.initState();
    _minutesMemosBloc = InjectorContainer.getIt<MinutesMemosBloc>()
      ..add(GetMemorandumDetailEvent(memoId: widget.memoId));
  }

  @override
  void dispose() {
    _minutesMemosBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _minutesMemosBloc,
      child: BlocBuilder<MinutesMemosBloc, MinutesMemosState>(
        builder: (context, state) {
          if (state is MemorandumDetailLoading) {
            return Scaffold(
              backgroundColor: TColors.white,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is MemorandumDetailError) {
            return Scaffold(
              backgroundColor: TColors.white,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(
                        color: TColors.appDisabledColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        context.read<MinutesMemosBloc>().add(
                              GetMemorandumDetailEvent(memoId: widget.memoId),
                            );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MemorandumDetailLoaded) {
            final memorandum = state.memorandum;
            return Scaffold(
              backgroundColor: TColors.white,
              appBar: const AcGradientAppBar(title: 'Memorando Interno'),
              bottomNavigationBar: _buildDownloadButton(context),
              body: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMemoHeader(memorandum),
                      const SizedBox(height: 20),
                      _buildInfoCard(memorandum),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(memorandum),
                      if (memorandum.attachments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                        _buildAttachmentsSection(memorandum),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: TColors.white,
            body: const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildMemoHeader(MemorandumDetailEntity memorandum) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEMORANDO NO. ${memorandum.numero}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AC.memo,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          memorandum.titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.appMainTextColor,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(MemorandumDetailEntity memorandum) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FECHA DE EMISIÓN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: TColors.appDisabledColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AC.primary,
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat("dd 'de' MMMM, yyyy", 'es')
                    .format(memorandum.fechaEmision),
                style: const TextStyle(
                  fontSize: 13,
                  color: TColors.appMainTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'RESPONSABLE / DESTINATARIO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: TColors.appDisabledColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 14,
                color: AC.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  memorandum.destinatarioNombre?.isNotEmpty == true
                      ? memorandum.destinatarioNombre!
                      : 'Sin destinatario',
                  style: const TextStyle(
                    fontSize: 13,
                    color: TColors.appMainTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(MemorandumDetailEntity memorandum) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 3, height: 21, color: AC.memo),
            const SizedBox(width: 8),
            const Text(
              'Descripción del Cambio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AC.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          memorandum.contenido,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: TColors.appDisabledColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(MemorandumDetailEntity memorandum) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.attach_file, size: 16, color: Colors.blueGrey),
            const SizedBox(width: 6),
            Text(
              'Archivos Adjuntos (${memorandum.attachments.length})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AC.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...memorandum.attachments.map((a) => _buildAttachmentPreview(a)),
      ],
    );
  }

  Widget _buildAttachmentPreview(MemorandumAttachmentEntity attachment) {
    final lowerType = attachment.tipoArchivo.toLowerCase();
    final lowerName = attachment.nombreArchivo.toLowerCase();
    final isImage = lowerType.contains('image') ||
        lowerType == 'jpg' ||
        lowerType == 'jpeg' ||
        lowerType == 'png' ||
        lowerType == 'gif' ||
        lowerType == 'webp' ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.gif') ||
        lowerName.endsWith('.webp');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF4F6F8),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            color: const Color(0xFFE0E4EC),
            child: isImage && attachment.url.isNotEmpty
                ? Image.network(
                    attachment.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const _MemoAttachmentPlaceholder(isImage: true),
                  )
                : const _MemoAttachmentPlaceholder(isImage: false),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isImage ? Icons.image_outlined : Icons.picture_as_pdf,
                  size: 16,
                  color: TColors.appDisabledColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    attachment.nombreArchivo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TColors.appMainTextColor,
                    ),
                  ),
                ),
                Text(
                  attachment.pesoArchivo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.appDisabledColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text(
              'Descargar PDF',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AC.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoAttachmentPlaceholder extends StatelessWidget {
  final bool isImage;
  const _MemoAttachmentPlaceholder({required this.isImage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isImage ? Icons.broken_image_outlined : Icons.picture_as_pdf,
            size: 36,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 6),
          Text(
            isImage ? 'No se pudo cargar la imagen' : 'Documento PDF',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
