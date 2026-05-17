import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';
import '../../domain/entity/entity.dart';
import '../bloc/minutes_memos_bloc.dart';

@RoutePage()
class ActaDetailsScreen extends StatefulWidget {
  const ActaDetailsScreen({super.key, required this.actaId});

  final String actaId;

  @override
  State<ActaDetailsScreen> createState() => _ActaDetailsScreenState();
}

class _ActaDetailsScreenState extends State<ActaDetailsScreen> {
  late MinutesMemosBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<MinutesMemosBloc>()
      ..add(GetActaDetailEvent(actaId: widget.actaId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<MinutesMemosBloc, MinutesMemosState>(
        builder: (context, state) {
          if (state is ActaDetailLoading) {
            return const Scaffold(
              backgroundColor: TColors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ActaDetailError) {
            return Scaffold(
              backgroundColor: TColors.white,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: TColors.appDisabledColor),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context
                          .read<MinutesMemosBloc>()
                          .add(GetActaDetailEvent(actaId: widget.actaId)),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ActaDetailLoaded) {
            return _buildScaffold(context, state.acta);
          }

          return const Scaffold(backgroundColor: TColors.white);
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, ActaDetailEntity acta) {
    return Scaffold(
      backgroundColor: TColors.white,
      bottomNavigationBar: _buildDownloadButton(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const Divider(color: Color(0xFFEEEEEE), thickness: 1),
              const SizedBox(height: 24),
              _buildActaHeader(acta),
              const SizedBox(height: 20),
              _buildInfoCard(
                icon: Icons.calendar_today_outlined,
                label: 'FECHA',
                value: DateFormat('dd \'de\' MMMM, yyyy', 'es')
                    .format(acta.fechaEmision),
              ),
              if (acta.ubicacion != null)
                _buildInfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'UBICACIÓN',
                  value: acta.ubicacion!,
                ),
              if (acta.descripcion != null) ...[
                const SizedBox(height: 24),
                _buildSectionHeader(Icons.list_alt_outlined, 'Descripcion'),
                const SizedBox(height: 12),
                Text(
                  acta.descripcion!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: TColors.appDisabledColor,
                  ),
                ),
              ],
              if (acta.participants.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionHeader(
                  Icons.group_outlined,
                  'Participantes (${acta.participants.length})',
                ),
                const SizedBox(height: 12),
                ...acta.participants
                    .take(2)
                    .map((p) => _buildParticipantTile(p)),
                if (acta.participants.length > 2) ...[
                  const SizedBox(height: 4),
                  _buildVerTodosButton(context, acta.participants),
                ],
              ],
              if (acta.attachments.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                const SizedBox(height: 16),
                _buildSectionHeader(Icons.attach_file, 'Documento Adjunto'),
                const SizedBox(height: 12),
                ...acta.attachments.map((a) => _buildAttachmentPreview(a)),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(
            Icons.arrow_back,
            color: TColors.appMainDarkColor,
            size: 22,
          ),
        ),
        const Spacer(),
        const Text(
          'Detalle de Acta',
          style: TextStyle(
            color: TColors.appMainDarkColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildActaHeader(ActaDetailEntity acta) {
    return Container(
      padding: const EdgeInsets.only(left: 14),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: TColors.appMainColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTA NO. ${acta.numero}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TColors.appMainDarkColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            acta.titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TColors.appMainDarkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: TColors.appMainDarkColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: TColors.appDisabledColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.appMainDarkColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: TColors.appMainColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TColors.appMainColor,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantTile(ActaParticipantEntity participant) {
    final initials = _getInitials(participant.fullName);
    final avatarColor = _getAvatarColor(participant.fullName);
    final isPresente =
        participant.attendanceStatus.toLowerCase() == 'presente';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.appMainTextColor,
                  ),
                ),
                if (participant.position != null)
                  Text(
                    participant.position!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.appDisabledColor,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPresente
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              participant.attendanceStatus.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isPresente ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerTodosButton(
      BuildContext context, List<ActaParticipantEntity> participants) {
    return OutlinedButton(
      onPressed: () => _showAllParticipants(context, participants),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
        side: const BorderSide(color: TColors.appMainDarkColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Ver Todos los Participantes',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: TColors.appMainDarkColor,
        ),
      ),
    );
  }

  void _showAllParticipants(
      BuildContext context, List<ActaParticipantEntity> participants) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.group_outlined,
                      size: 20, color: TColors.appMainColor),
                  const SizedBox(width: 8),
                  Text(
                    'Participantes (${participants.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TColors.appMainDarkColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: participants.length,
                itemBuilder: (_, i) => _buildParticipantTile(participants[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview(ActaAttachmentEntity attachment) {
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
                        const _AttachmentPlaceholder(isImage: true),
                  )
                : const _AttachmentPlaceholder(isImage: false),
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

  Widget _buildDownloadButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: TColors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Descargando PDF...')),
          );
        },
        icon: const Icon(Icons.download_outlined, size: 18),
        label: const Text(
          'Descargar PDF',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.appMainDarkColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0]
        .substring(0, parts[0].length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  Color _getAvatarColor(String name) {
    const colors = [
      Color(0xFF607D8B),
      Color(0xFFE53935),
      Color(0xFF7B1FA2),
      Color(0xFF00897B),
      Color(0xFF1565C0),
      Color(0xFF558B2F),
      Color(0xFFE65100),
    ];
    final index =
        name.codeUnits.fold(0, (sum, c) => sum + c) % colors.length;
    return colors[index];
  }
}

class _AttachmentPlaceholder extends StatelessWidget {
  final bool isImage;

  const _AttachmentPlaceholder({required this.isImage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
        size: 48,
        color: const Color(0xFFB0BEC5),
      ),
    );
  }
}
