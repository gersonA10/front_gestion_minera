import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/bloc/minutes_memos_bloc.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/widgets/actas_theme.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';

import '../../domain/entity/entity.dart';

class ParticipantsDialog extends StatefulWidget {
  final List<SocioEntity> initialSelected;
  final bool singleSelect;

  const ParticipantsDialog({
    super.key,
    required this.initialSelected,
    this.singleSelect = false,
  });

  @override
  State<ParticipantsDialog> createState() => _ParticipantsDialogState();
}

class _ParticipantsDialogState extends State<ParticipantsDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  late Set<String> _selectedIds;
  late Map<String, SocioEntity> _selectedMap;
  List<SocioEntity> _filteredSocios = [];
  bool _isLoading = true;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialSelected.map((s) => s.memberId).toSet();
    _selectedMap = {for (final s in widget.initialSelected) s.memberId: s};
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    context.read<MinutesMemosBloc>().add(GetSociosEvent());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MinutesMemosBloc>().add(LoadMoreSociosEvent());
    }
  }

  void _onSearchChanged() {
    // Búsqueda en el backend (cubre todos los socios, no solo los ya cargados).
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final query = _searchController.text.trim();
      context.read<MinutesMemosBloc>().add(
        GetSociosEvent(search: query.isEmpty ? null : query),
      );
    });
  }

  void _toggleSocio(SocioEntity socio) {
    setState(() {
      if (widget.singleSelect) {
        if (_selectedIds.contains(socio.memberId)) {
          _selectedIds.clear();
          _selectedMap.clear();
        } else {
          _selectedIds.clear();
          _selectedMap.clear();
          _selectedIds.add(socio.memberId);
          _selectedMap[socio.memberId] = socio;
        }
      } else {
        if (_selectedIds.contains(socio.memberId)) {
          _selectedIds.remove(socio.memberId);
          _selectedMap.remove(socio.memberId);
        } else {
          _selectedIds.add(socio.memberId);
          _selectedMap[socio.memberId] = socio;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MinutesMemosBloc, MinutesMemosState>(
      listenWhen: (_, state) => state is SociosLoaded || state is SociosError,
      listener: (context, state) {
        if (state is SociosLoaded) {
          setState(() {
            _filteredSocios = state.socios;
            _hasMore = state.hasMore;
            _isLoading = false;
            _error = null;
          });
        } else if (state is SociosError) {
          setState(() {
            _error = state.message;
            _isLoading = false;
          });
        }
      },
      child: Dialog(
        backgroundColor: AC.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _buildSearchField(),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: _buildBody(),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AC.primary, AC.primaryDeep],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Icon(
              widget.singleSelect
                  ? Icons.person_rounded
                  : Icons.groups_2_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.singleSelect
                  ? 'Seleccionar destinatario'
                  : 'Seleccionar participantes',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(fontSize: 14, color: AC.textPrimary),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre...',
        hintStyle: const TextStyle(color: AC.textSecondary, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: AC.textSecondary),
        filled: true,
        fillColor: AC.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AC.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AC.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AC.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const StaffLoader();
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AC.textSecondary),
          ),
        ),
      );
    }
    if (_filteredSocios.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron socios',
          style: TextStyle(color: AC.textSecondary),
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredSocios.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == _filteredSocios.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: StaffLoader(),
          );
        }
        final socio = _filteredSocios[index];
        final isSelected = _selectedIds.contains(socio.memberId);
        return _SocioTile(
          socio: socio,
          selected: isSelected,
          onTap: () => _toggleSocio(socio),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    final count = _selectedIds.length;
    final label = widget.singleSelect
        ? (count == 0 ? 'Ninguno seleccionado' : '1 destinatario')
        : '$count seleccionado(s)';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AC.surface,
        border: Border(top: BorderSide(color: AC.border)),
      ),
      child: Row(
        children: [
          Icon(
            count == 0 ? Icons.info_outline_rounded : Icons.check_circle_rounded,
            size: 16,
            color: count == 0 ? AC.textSecondary : AC.green,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: count == 0 ? AC.textSecondary : AC.textPrimary,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AC.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () =>
                Navigator.of(context).pop(_selectedMap.values.toList()),
            child: const Text(
              'Confirmar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocioTile extends StatelessWidget {
  final SocioEntity socio;
  final bool selected;
  final VoidCallback onTap;

  const _SocioTile({
    required this.socio,
    required this.selected,
    required this.onTap,
  });

  String get _initials {
    final parts = socio.fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final first = parts.isNotEmpty ? parts[0] : '?';
    return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AC.primary.withValues(alpha: 0.07) : AC.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AC.primary : AC.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: selected
                    ? AC.primary
                    : AC.primary.withValues(alpha: 0.12),
                child: Text(
                  _initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AC.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      socio.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AC.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      socio.identification,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AC.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? AC.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AC.primary : AC.border,
                    width: 1.6,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        size: 15, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
