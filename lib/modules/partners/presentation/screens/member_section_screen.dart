import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/member_inbox_entity.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
enum _EntryType { reunion, memorando }

enum _StatusTone { green, orange, blue, grey }

class _Filter {
  final String label;
  final _EntryType? type; // null = Todos

  const _Filter(this.label, this.type);
}

// ─── Screen ───────────────────────────────────────────────────────────────────
@RoutePage()
class MemberSectionScreen extends StatefulWidget {
  const MemberSectionScreen({super.key});

  @override
  State<MemberSectionScreen> createState() => _MemberSectionScreenState();
}

class _MemberSectionScreenState extends State<MemberSectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final PartnersBloc _bloc;
  String _query = '';
  int _selectedFilter = 0;

  static const List<_Filter> _filters = [
    _Filter('Todos', null),
    _Filter('Reuniones', _EntryType.reunion),
    _Filter('Memorandos', _EntryType.memorando),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<PartnersBloc>()
      ..add(MemberInboxRequestEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  List<MemberInboxItemEntity> _visibleEntries(
    List<MemberInboxItemEntity> all,
  ) {
    final filterType = _filters[_selectedFilter].type;
    final query = _query.trim().toLowerCase();
    return all.where((e) {
      final matchesType =
          filterType == null || _typeOf(e.type) == filterType;
      final matchesQuery = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          (e.person ?? '').toLowerCase().contains(query) ||
          _typeLabel(e.type).toLowerCase().contains(query);
      return matchesType && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: TColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          _buildFilters(),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<PartnersBloc, PartnersState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is MemberInboxLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: TColors.primary),
                  );
                }

                if (state is MemberInboxError) {
                  return _buildErrorState(state.message);
                }

                if (state is MemberInboxLoaded) {
                  final entries = _visibleEntries(state.items);
                  if (entries.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    color: TColors.primary,
                    onRefresh: () async {
                      _bloc.add(MemberInboxRequestEvent());
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      itemCount: entries.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          _EntryCard(entry: entries[index]),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.surface,
        border: Border(bottom: BorderSide(color: TColors.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Row(
            children: [
              _IconButtonSquare(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const Expanded(
                child: Text(
                  'Bandeja de Socios',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: TColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Search ───────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: TColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.border, width: 1),
          boxShadow: const [
            BoxShadow(
              color: TColors.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          style: const TextStyle(
            fontSize: 14,
            color: TColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar registros, memorandos...',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: TColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: TColors.textSecondary,
              size: 22,
            ),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: TColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  // ─── Filters ───────────────────────────────────────────────────────────────────
  Widget _buildFilters() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = index == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? TColors.primary : TColors.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected ? TColors.primary : TColors.border,
                  width: 1,
                ),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x331A56FF),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                _filters[index].label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : TColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Empty state ───────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: TColors.primaryLight,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  color: TColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin registros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'No tienes memorandos ni reuniones\npor el momento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: TColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Error state ───────────────────────────────────────────────────────────────
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: TColors.statusOrange,
              size: 44,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: TColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _bloc.add(MemberInboxRequestEvent()),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mapping helpers ────────────────────────────────────────────────────────────
_EntryType _typeOf(String type) =>
    type == 'reunion' ? _EntryType.reunion : _EntryType.memorando;

String _typeLabel(String type) =>
    type == 'reunion' ? 'Reunión' : 'Memorando';

({String label, _StatusTone tone}) _statusOf(String status) {
  switch (status.toUpperCase()) {
    case 'FINALIZADO':
      return (label: 'Finalizado', tone: _StatusTone.grey);
    case 'PENDIENTE':
      return (label: 'Pendiente', tone: _StatusTone.orange);
    default:
      return (label: status, tone: _StatusTone.blue);
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Sin fecha';
  final now = DateTime.now();
  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;
  final time = DateFormat('hh:mm a', 'es').format(date);
  if (isToday) return '$time • Hoy';
  return '${DateFormat('d MMM', 'es').format(date)} • $time';
}

// ─── Entry card ───────────────────────────────────────────────────────────────
class _EntryCard extends StatelessWidget {
  final MemberInboxItemEntity entry;

  const _EntryCard({required this.entry});

  _EntryType get _type => _typeOf(entry.type);

  ({Color bg, Color fg}) get _iconColors {
    switch (_type) {
      case _EntryType.reunion:
        return (bg: TColors.primaryLight, fg: TColors.primary);
      case _EntryType.memorando:
        return _statusOf(entry.status).tone == _StatusTone.grey
            ? (bg: TColors.statusGreyBg, fg: TColors.textSecondary)
            : (bg: TColors.statusOrangeBg, fg: TColors.statusOrange);
    }
  }

  IconData get _icon {
    switch (_type) {
      case _EntryType.reunion:
        return Icons.event_rounded;
      case _EntryType.memorando:
        return Icons.description_rounded;
    }
  }

  Color get _typeLabelColor {
    switch (_type) {
      case _EntryType.reunion:
        return TColors.primary;
      case _EntryType.memorando:
        return _statusOf(entry.status).tone == _StatusTone.grey
            ? TColors.textSecondary
            : TColors.statusOrange;
    }
  }

  ({Color bg, Color fg}) get _statusColors {
    switch (_statusOf(entry.status).tone) {
      case _StatusTone.green:
        return (bg: TColors.statusGreenBg, fg: TColors.statusGreen);
      case _StatusTone.orange:
        return (bg: TColors.statusOrangeBg, fg: TColors.statusOrange);
      case _StatusTone.blue:
        return (bg: TColors.primaryLight, fg: TColors.primary);
      case _StatusTone.grey:
        return (bg: TColors.statusGreyBg, fg: TColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColors = _iconColors;
    final statusColors = _statusColors;
    final status = _statusOf(entry.status);
    final personLabel = entry.personIsResp ? 'Resp:' : 'De:';
    final personValue = entry.person ?? (entry.location ?? '—');

    return Container(
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: TColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColors.bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: iconColors.fg, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _typeLabel(entry.type),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _typeLabelColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(
                      label: status.label,
                      bg: statusColors.bg,
                      fg: statusColors.fg,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: TColors.textPrimary,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$personLabel $personValue',
                  style: const TextStyle(
                    fontSize: 13,
                    color: TColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      _type == _EntryType.reunion
                          ? Icons.access_time_rounded
                          : Icons.calendar_today_rounded,
                      size: 14,
                      color: TColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDate(entry.date),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: TColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small widgets ───────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _StatusBadge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _IconButtonSquare extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButtonSquare({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: TColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: TColors.textPrimary, size: 18),
      ),
    );
  }
}
