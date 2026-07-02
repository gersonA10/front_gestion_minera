import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_route_observer.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/widgets/card_machinery_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class ListMachineryScreen extends StatefulWidget {
  /// Estado por el que abrir el listado ya filtrado (ej. 'INACTIVO').
  /// Debe coincidir con uno de los `status` de [_ListMachineryScreenState.estados].
  final String? initialStatus;

  const ListMachineryScreen({super.key, this.initialStatus});

  @override
  State<ListMachineryScreen> createState() => _ListMachineryScreenState();
}

class _ListMachineryScreenState extends State<ListMachineryScreen>
    with RouteAware {
  final List<Map<String, dynamic>> estados = [
    {"estado": "Todo", "color": TColors.appMainColor, "status": 'TODOS'},
    {"estado": "Activo", "color": TColors.success, "status": 'ACTIVO'},
    {"estado": "Inactivo", "color": TColors.danger, "status": 'INACTIVO'},
    {
      "estado": "Mantenimiento",
      "color": TColors.warning,
      "status": 'EN MANTENIMIENTO',
    },
  ];
  int _selectIndexType = 0;
  int _selectIndexState = 0;

  List<MachineryEntity>? _cacheinventory;
  List<TypeMachineryEntity>? _cacheTypeMachine;
  late MachineryBloc _machineryBloc;
  bool _cachedHasReachedMax = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  String? filterState;
  String? filterType;
  bool _isLoadingMore = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Si llega un estado inicial, pre-seleccionamos el chip correspondiente
    // y abrimos el listado ya filtrado por ese estado.
    if (widget.initialStatus != null) {
      final idx =
          estados.indexWhere((e) => e['status'] == widget.initialStatus);
      if (idx != -1) {
        _selectIndexState = idx;
        filterState = estados[idx]['status'] as String;
      }
    }

    // Inventario + tipos de máquina en paralelo. Los tipos se piden una sola
    // vez aquí (antes se re-disparaban en cada carga de inventario).
    _machineryBloc = InjectorContainer.getIt<MachineryBloc>()
      ..add(ListInventoryMachineryEvent(status: filterState))
      ..add(ListTypeMachinery());
  }

  /// Reintento de la carga inicial: inventario (con el filtro actual) + tipos.
  void _retryInitial() {
    _dispatchFilter();
    _machineryBloc.add(ListTypeMachinery());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Volvimos al listado desde el detalle: recargamos con el filtro actual.
    _dispatchFilter();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_cachedHasReachedMax) return;
    if (_isLoadingMore) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      _isLoadingMore = true;
      _machineryBloc.add(LoadMoreListInventoryMachineryEvent());
    }
  }

  /// Lanza la búsqueda con un pequeño retraso para no disparar una petición
  /// por cada pulsación de tecla.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _dispatchFilter();
    });
  }

  void _dispatchFilter() {
    _machineryBloc.add(
      ListInventoryMachineryEvent(
        search: searchController.text.isNotEmpty ? searchController.text : null,
        status: filterState,
        type: filterType,
      ),
    );
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _debounce?.cancel();
    _scrollController.dispose();
    searchController.dispose();
    _machineryBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _machineryBloc,
      child: Scaffold(
        backgroundColor: TColors.background,
        appBar: AppBar(
          backgroundColor: TColors.white,
          surfaceTintColor: TColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: TColors.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: const Text(
            'Listado de Maquinaria',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: TColors.border),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: BlocBuilder<MachineryBloc, MachineryState>(
                  buildWhen: (previous, current) =>
                      current is InventoryMachineryLoading ||
                      current is InventoryMachineryLoaded ||
                      current is InventoryMachineryError ||
                      current is TypeMachineryLoading ||
                      current is TypeMachineryLoaded ||
                      current is TypeMachineryError,
                  builder: (context, state) {
                    if (state is InventoryMachineryLoaded) {
                      _cacheinventory = state.machinery;
                      _cachedHasReachedMax = state.hasReachedMax;

                      _isLoadingMore = false;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        if (!_scrollController.hasClients) return;

                        final position = _scrollController.position;

                        final isNotScrollable =
                            position.maxScrollExtent <=
                            position.viewportDimension;

                        if (isNotScrollable &&
                            !_cachedHasReachedMax &&
                            !_isLoadingMore) {
                          _isLoadingMore = true;
                          _machineryBloc.add(
                            LoadMoreListInventoryMachineryEvent(),
                          );
                        }
                      });
                    }
                    if (state is TypeMachineryLoaded &&
                        _cacheTypeMachine == null) {
                      _cacheTypeMachine = state.types;
                    }

                    // Un "cargar más" fallido también debe liberar el flag,
                    // si no la paginación queda bloqueada y el footer girando.
                    if (state is InventoryMachineryError) {
                      _isLoadingMore = false;
                    }

                    final bool isLoading = state is InventoryMachineryLoading;

                    // Carga inicial: sin datos en caché todavía.
                    if (_cacheinventory == null || _cacheTypeMachine == null) {
                      // Mostramos error si falló justo lo que aún no tenemos
                      // en caché (inventario o tipos).
                      final invFailed = _cacheinventory == null &&
                          state is InventoryMachineryError;
                      final typesFailed = _cacheTypeMachine == null &&
                          state is TypeMachineryError;
                      if (invFailed || typesFailed) {
                        final message = state is InventoryMachineryError
                            ? state.message
                            : (state as TypeMachineryError).message;
                        return _ListErrorState(
                          message: message,
                          onRetry: _retryInitial,
                        );
                      }
                      return const _MachineryListSkeleton();
                    }

                    final inventory = _cacheinventory!;
                    final types = _cacheTypeMachine!;

                    return Column(
                      children: [
                        const SizedBox(height: 4),
                        SizedBox(height: 38, child: _filterTypes(types)),
                        const SizedBox(height: 12),
                        _filterState(),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Stack(
                            children: [
                              RefreshIndicator(
                                onRefresh: () async {
                                  _dispatchFilter();
                                  try {
                                    await _machineryBloc.stream
                                        .firstWhere(
                                          (s) =>
                                              s is InventoryMachineryLoaded ||
                                              s is InventoryMachineryError,
                                        )
                                        .timeout(const Duration(seconds: 15));
                                  } catch (_) {
                                    // Timeout / sin estado terminal: cerramos
                                    // el indicador igualmente.
                                  }
                                },
                                color: TColors.appMainColor,
                                backgroundColor: TColors.white,
                                child: inventory.isEmpty
                                    ? _buildEmptyScrollable()
                                    : ListView.builder(
                                        controller: _scrollController,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          10,
                                          16,
                                          24,
                                        ),
                                        itemCount: inventory.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index == inventory.length) {
                                            return _buildListFooter(
                                              inventory.length,
                                            );
                                          }
                                          return CardMachineryWidget(
                                            machine: inventory[index],
                                          );
                                        },
                                      ),
                              ),
                              // Barra de progreso sutil al filtrar/buscar con
                              // datos ya visibles (sin overlay que bloquee).
                              if (isLoading)
                                const Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: LinearProgressIndicator(
                                    minHeight: 2.5,
                                    color: TColors.appMainColor,
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: TextField(
        controller: searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14.5, color: TColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: TColors.white,
          hintText: 'Buscar maquinaria...',
          hintStyle: const TextStyle(
            color: TColors.textSecondary,
            fontSize: 14.5,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: TColors.iconMuted,
            size: 22,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: TColors.iconMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                    _dispatchFilter();
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TColors.appMainColor, width: 1.4),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TColors.border),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyScrollable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const _ListEmptyState(),
          ),
        );
      },
    );
  }

  Widget _buildListFooter(int count) {
    if (_isLoadingMore && !_cachedHasReachedMax) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: StaffLoader(),
      );
    }
    if (_cachedHasReachedMax && count > 0) {
      return const Padding(
        padding: EdgeInsets.only(top: 14, bottom: 4),
        child: Center(
          child: Text(
            'No hay más maquinaria',
            style: TextStyle(
              color: TColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return const SizedBox(height: 4);
  }

  Widget _filterTypes(List<TypeMachineryEntity> types) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: types.length,
      itemBuilder: (BuildContext context, int index) {
        final isSelected = _selectIndexType == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectIndexType = index;
              filterType = types[index].code;
            });
            _dispatchFilter();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? TColors.appMainDarkColor : TColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? TColors.appMainDarkColor : TColors.border,
              ),
            ),
            child: Text(
              types[index].name,
              style: TextStyle(
                color: isSelected ? TColors.white : TColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _filterState() {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: estados.length,
        itemBuilder: (BuildContext context, int index) {
          final isSelected = _selectIndexState == index;
          final colorestado = estados[index]['color'] as Color;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectIndexState = index;
                filterState = estados[index]['status'];
              });
              _dispatchFilter();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorestado.withValues(alpha: 0.12)
                    : TColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? colorestado.withValues(alpha: 0.6)
                      : TColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: colorestado, size: 9),
                  const SizedBox(width: 6),
                  Text(
                    estados[index]['estado'],
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isSelected ? colorestado : TColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton animado para la carga inicial (filtros + tarjetas).
class _MachineryListSkeleton extends StatefulWidget {
  const _MachineryListSkeleton();

  @override
  State<_MachineryListSkeleton> createState() => _MachineryListSkeletonState();
}

class _MachineryListSkeletonState extends State<_MachineryListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();
  late final Animation<double> _a =
      CurvedAnimation(parent: _ac, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, _) {
        final c = Color.lerp(
          const Color(0xFFEAEDF2),
          const Color(0xFFF6F8FB),
          _a.value,
        )!;
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Chips de tipo.
            Row(
              children: [
                _bone(c, width: 70, height: 34, radius: 12),
                const SizedBox(width: 8),
                _bone(c, width: 90, height: 34, radius: 12),
                const SizedBox(width: 8),
                _bone(c, width: 80, height: 34, radius: 12),
              ],
            ),
            const SizedBox(height: 14),
            // Chips de estado.
            Row(
              children: [
                _bone(c, width: 60, height: 28, radius: 20),
                const SizedBox(width: 8),
                _bone(c, width: 72, height: 28, radius: 20),
                const SizedBox(width: 8),
                _bone(c, width: 90, height: 28, radius: 20),
              ],
            ),
            const SizedBox(height: 18),
            // Tarjetas.
            ...List.generate(6, (_) => _cardBone(c)),
          ],
        );
      },
    );
  }

  Widget _bone(
    Color c, {
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _cardBone(Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: [
          _bone(c, width: 64, height: 64, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bone(c, width: 150, height: 13, radius: 6),
                const SizedBox(height: 8),
                _bone(c, width: 110, height: 11, radius: 6),
                const SizedBox(height: 12),
                _bone(c, width: 80, height: 18, radius: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vacío del listado.
class _ListEmptyState extends StatelessWidget {
  const _ListEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: TColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 34,
                color: TColors.appMainColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin resultados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No encontramos maquinaria con estos filtros.\n'
              'Prueba con otra búsqueda o estado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de error del listado.
class _ListErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ListErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: TColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: TColors.danger,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: TColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: TColors.appMainColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Reintentar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
