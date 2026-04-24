import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/widgets/card_machinery_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class ListMachineryScreen extends StatefulWidget {
  const ListMachineryScreen({super.key});

  @override
  State<ListMachineryScreen> createState() => _ListMachineryScreenState();
}

class _ListMachineryScreenState extends State<ListMachineryScreen> {
  List<Map<String, dynamic>> estados = [
    {
      "estado": "Todo",
      "color": TColors.darkBackgroundSplash,
      "status": 'TODOS',
    },
    {"estado": "Activo", "color": TColors.green, "status": 'ACTIVO'},
    {"estado": "Inactivo", "color": TColors.red, "status": 'INACTIVO'},
    {
      "estado": "Mantenimiento",
      "color": TColors.homeTopColor,
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _machineryBloc = InjectorContainer.getIt<MachineryBloc>()
      ..add(ListInventoryMachineryEvent());
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

  @override
  void dispose() {
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
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(title: Text('Listado de Maquinaria')),
        body: SafeArea(
          child: Column(
            children: [
              TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hint: Text(
                    'Buscar por nombre',
                    style: TextStyle(color: TColors.greyText),
                  ),
                ),
                onChanged: (value) => _machineryBloc.add(
                  ListInventoryMachineryEvent(
                    search: (searchController.text.isNotEmpty)
                        ? searchController.text
                        : null,
                    status: filterState,
                    type: filterType,
                  ),
                ),
              ),
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

                      _machineryBloc.add(ListTypeMachinery());

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

                    final bool isLoading = state is InventoryMachineryLoading;
                    final bool isLoadingType = state is TypeMachineryLoading;

                    if (_cacheinventory == null) {
                      if (isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is InventoryMachineryError) {
                        return Center(child: Text(state.message));
                      }
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_cacheTypeMachine == null) {
                      if (isLoadingType) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is TypeMachineryError) {
                        return Center(child: Text(state.message));
                      }
                      return const Center(child: CircularProgressIndicator());
                    }
                    final inventory = _cacheinventory!;
                    final hasReachedMax = _cachedHasReachedMax;

                    final types = _cacheTypeMachine!;

                    return Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            _machineryBloc.add(
                              ListInventoryMachineryEvent(
                                search: (searchController.text.isNotEmpty)
                                    ? searchController.text
                                    : null,
                                status: filterState,
                                type: filterType,
                              ),
                            );

                            await _machineryBloc.stream.firstWhere(
                              (state) => state is! InventoryMachineryLoading,
                            );
                          },
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 15),
                                  // filtro de tipo
                                  SizedBox(
                                    height: 40,
                                    child: _filterTypes(types),
                                  ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    height: 30,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Estado: ',
                                          style: TextStyle(
                                            color: TColors.appDisabledColor,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          // filtro de estados
                                          child: _filterState(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: inventory.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          return CardMachineryWidget(
                                            machine: inventory[index],
                                          );
                                        },
                                  ),
                                  if (inventory.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'No hay lotes con este estado',
                                          style: TextStyle(
                                            color: Color(0xFF9CA3AF),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_isLoadingMore && !_cachedHasReachedMax)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  const SizedBox(height: 80),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isLoading)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        if (isLoading)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.1),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
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

  ListView _filterTypes(List<TypeMachineryEntity> types) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: types.length,
      itemBuilder: (BuildContext context, int index) {
        final isSelected = _selectIndexType == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectIndexType = index;
              filterType = types[index].code;
            });
            _machineryBloc.add(
              ListInventoryMachineryEvent(
                search: (searchController.text.isNotEmpty)
                    ? searchController.text
                    : null,
                status: filterState,
                type: filterType,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: isSelected ? TColors.appMainDarkColor : TColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                types[index].name,
                style: TextStyle(
                  color: isSelected ? TColors.white : TColors.bgColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ListView _filterState() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
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
            _machineryBloc.add(
              ListInventoryMachineryEvent(
                search: (searchController.text.isNotEmpty)
                    ? searchController.text
                    : null,
                status: filterState,
                type: filterType,
              ),
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 5),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorestado.withValues(alpha: 0.5)
                  : TColors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                if (isSelected)
                  Icon(
                    Icons.circle,
                    color: Color.lerp(colorestado, Colors.black, 0.3)!,
                    size: 10,
                  ),
                const SizedBox(width: 5),
                Center(
                  child: Text(
                    estados[index]['estado'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Color.lerp(colorestado, Colors.black, 0.5)!
                          : TColors.appBackgroundDarkColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
