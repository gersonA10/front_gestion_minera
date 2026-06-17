import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/bloc/minutes_memos_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.singleSelect
                          ? 'Seleccionar Destinatario'
                          : 'Seleccionar Participantes',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text(_error!))
                    : _filteredSocios.isEmpty
                    ? const Center(child: Text('No se encontraron socios'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _filteredSocios.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredSocios.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final socio = _filteredSocios[index];
                          final isSelected = _selectedIds.contains(
                            socio.memberId,
                          );
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (_) => _toggleSocio(socio),
                            title: Text(socio.fullName),
                            subtitle: Text(socio.identification),
                            activeColor: TColors.appMainDarkColor,
                          );
                        },
                      ),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Text(
                    widget.singleSelect
                        ? (_selectedIds.isEmpty
                              ? 'Ninguno seleccionado'
                              : '1 seleccionado')
                        : '${_selectedIds.length} seleccionado(s)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.appMainDarkColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(_selectedMap.values.toList()),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
