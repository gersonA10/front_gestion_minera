import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/logout_button_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/acta_entity.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/memorandum_entity.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/bloc/minutes_memos_bloc.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

@RoutePage()
class MinutesMemosMainScreen extends StatefulWidget {
  const MinutesMemosMainScreen({super.key});

  @override
  State<MinutesMemosMainScreen> createState() => _MinutesMemosMainScreenState();
}

class _MinutesMemosMainScreenState extends State<MinutesMemosMainScreen> {
  late final MinutesMemosBloc _bloc;
  int selectedTab = 0;
  int selectedFilter = 0;
  DateTimeRange? _customRange;
  final ScrollController _actasScrollController = ScrollController();
  final ScrollController _memosScrollController = ScrollController();

  static const _filters = [
    ('Recientes', 'recientes'),
    ('Semana', 'semana'),
    ('Mes', 'mes'),
    ('Personalizado', 'personalizado'),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<MinutesMemosBloc>();
    _actasScrollController.addListener(_onScrollActas);
    _memosScrollController.addListener(_onScrollMemos);
    _bloc.add(GetActasMoemoCountEvent(filter: _filters[0].$2));
    _bloc.add(GetActasEvent(filter: _filters[0].$2));
  }

  @override
  void dispose() {
    _actasScrollController.dispose();
    _memosScrollController.dispose();
    super.dispose();
  }

  void _onScrollActas() {
    if (_actasScrollController.position.pixels >=
        _actasScrollController.position.maxScrollExtent - 300) {
      _bloc.add(LoadMoreActasEvent());
    }
  }

  void _onScrollMemos() {
    if (_memosScrollController.position.pixels >=
        _memosScrollController.position.maxScrollExtent - 300) {
      _bloc.add(LoadMoreMemorandosEvent());
    }
  }

  void _loadActas({String? filter, String? from, String? to}) {
    _bloc.add(GetActasEvent(filter: filter, from: from, to: to));
  }

  void _loadMemorandos({String? filter, String? from, String? to}) {
    _bloc.add(GetMemorandosEvent(filter: filter, from: from, to: to));
  }

  Future<void> _onFilterTap(int index) async {
    if (index == 3) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDateRange: _customRange,
        locale: const Locale('es'),
      );
      if (range == null) return;
      _customRange = range;
      final fmt = DateFormat('yyyy-MM-dd');
      final from = fmt.format(range.start);
      final to = fmt.format(range.end);
      setState(() => selectedFilter = index);
      if (selectedTab == 0) {
        _bloc.add(
          GetActasMoemoCountEvent(filter: 'personalizado', from: from, to: to),
        );
        _loadActas(filter: 'personalizado', from: from, to: to);
      } else {
        _bloc.add(
          GetMemosCountEvent(filter: 'personalizado', from: from, to: to),
        );
        _loadMemorandos(filter: 'personalizado', from: from, to: to);
      }
    } else {
      if (selectedFilter == index) return;
      setState(() => selectedFilter = index);
      if (selectedTab == 0) {
        _bloc.add(GetActasMoemoCountEvent(filter: _filters[index].$2));
      } else {
        _bloc.add(GetMemosCountEvent(filter: _filters[index].$2));
      }
      if (selectedTab == 0) {
        _loadActas(filter: _filters[index].$2);
      } else {
        _loadMemorandos(filter: _filters[index].$2);
      }
    }
  }

  void _onTabTap(int index) {
    if (selectedTab == index) return;
    setState(() => selectedTab = index);

    final String? from;
    final String? to;
    final String filter;

    if (selectedFilter == 3 && _customRange != null) {
      final fmt = DateFormat('yyyy-MM-dd');
      from = fmt.format(_customRange!.start);
      to = fmt.format(_customRange!.end);
      filter = 'personalizado';
    } else {
      from = null;
      to = null;
      filter = _filters[selectedFilter].$2;
    }

    if (index == 0) {
      _bloc.add(GetActasMoemoCountEvent(filter: filter, from: from, to: to));
      _loadActas(filter: filter, from: from, to: to);
    } else {
      _bloc.add(GetMemosCountEvent(filter: filter, from: from, to: to));
      _loadMemorandos(filter: filter, from: from, to: to);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.textFieldBackgroundColor,
        appBar: AppBar(
          backgroundColor: TColors.white,
          actions: [
            Padding(padding: const EdgeInsets.all(8.0), child: LogoutButton()),
          ],
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: TColors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TColors.appMainDarkColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Actas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TColors.appMainDarkColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              BlocBuilder<MinutesMemosBloc, MinutesMemosState>(
                buildWhen: (_, s) =>
                    s is ActasMemoCountLoaded ||
                    s is MemosCountLoading ||
                    s is ActasMemoCountLoaded ||
                    s is MemosCountError,
                builder: (context, state) {
                  final actascount1 = state is ActasMemoCountLoaded
                      ? state.actasCount
                      : state is ActasMemoCountLoaded
                      ? state.actasCount
                      : null;
                       final memoAcount2 = state is ActasMemoCountLoaded
                      ? state.memoscount
                      : state is ActasMemoCountLoaded
                      ? state.memoscount
                      : null;
                  final isLoading =
                      state is ActasMemoCountLoading || state is MemosCountLoading;
                  final String? totalValActas = isLoading
                      ? null
                      : actascount1?.total.toString() ?? '-';
                  final String? pendValMemo = isLoading
                      ? null
                      : memoAcount2?.total.toString() ?? '-';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SummaryCardMinutesMemosWidget(
                          label: 'Actas',
                          icon: Icons.description_outlined,
                          iconColor: TColors.appMainColor,
                          value: totalValActas,
                        ),
                        const SizedBox(width: 12),
                        SummaryCardMinutesMemosWidget(
                          label: 'Memorandos',
                          icon: Icons.email,
                          iconColor: TColors.danger,
                          value: pendValMemo,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: TColors.appMainDarkColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: () {
                            context.router.push(
                              RegisterMinutesMemosRoute(isOption: 0),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Registrar Acta',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: TColors.appMainDarkColor,
                            width: 1.5,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            context.router.push(
                              RegisterMinutesMemosRoute(isOption: 1),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: TColors.appMainDarkColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Nuevo Memorando',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _buildTab('Actas Recientes', 0)),
                    Expanded(child: _buildTab('Memorandos', 1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterChip('Recientes', 0),
                    const SizedBox(width: 10),
                    _buildFilterChip('Semana', 1),
                    const SizedBox(width: 10),
                    _buildFilterChip('Mes', 2),
                    const SizedBox(width: 10),
                    _buildFilterChip('Personalizado', 3, icon: Icons.tune),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: selectedTab == 1
                    ? _buildMemorandosList()
                    : _buildActasList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActasList() {
    return BlocBuilder<MinutesMemosBloc, MinutesMemosState>(
      buildWhen: (_, s) =>
          s is ActasLoading || s is ActasLoaded || s is ActasError,
      builder: (context, state) {
        if (state is ActasLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ActasError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: TColors.appDisabledColor),
            ),
          );
        }

        if (state is ActasLoaded) {
          if (state.items.isEmpty) {
            return const Center(
              child: Text(
                'No hay actas registradas',
                style: TextStyle(color: TColors.appDisabledColor),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _loadActas(
              filter: selectedFilter == 3
                  ? 'personalizado'
                  : _filters[selectedFilter].$2,
              from: selectedFilter == 3 && _customRange != null
                  ? DateFormat('yyyy-MM-dd').format(_customRange!.start)
                  : null,
              to: selectedFilter == 3 && _customRange != null
                  ? DateFormat('yyyy-MM-dd').format(_customRange!.end)
                  : null,
            ),
            child: ListView.builder(
              controller: _actasScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildActaCard(state.items[i]);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActaCard(ActaEntity acta) {
    final fmt = DateFormat('dd MMM, yyyy', 'es');
    final fecha = fmt.format(acta.createdAt).toUpperCase();

    String? actualizado;
    if (acta.updatedAt != null) {
      final diff = DateTime.now().difference(acta.updatedAt!);
      if (diff.inHours < 24) {
        actualizado = 'Actualizado hace ${diff.inHours}h';
      } else {
        actualizado = 'Actualizado hace ${diff.inDays}d';
      }
    }

    return MinutesMemosCardPanelWidget(
      tipo: 'minute',
      numero: acta.numero,
      titulo: acta.titulo,
      descripcion: acta.descripcion,
      fecha: fecha,
      estado: acta.estado,
      actualizado: actualizado,
    );
  }

  Widget _buildMemorandosList() {
    return BlocBuilder<MinutesMemosBloc, MinutesMemosState>(
      buildWhen: (_, s) =>
          s is MemorandosLoading ||
          s is MemorandosLoaded ||
          s is MemorandosError,
      builder: (context, state) {
        if (state is MemorandosLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MemorandosError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: TColors.appDisabledColor),
            ),
          );
        }

        if (state is MemorandosLoaded) {
          if (state.items.isEmpty) {
            return const Center(
              child: Text(
                'No hay memorandos registrados',
                style: TextStyle(color: TColors.appDisabledColor),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _loadMemorandos(
              filter: selectedFilter == 3
                  ? 'personalizado'
                  : _filters[selectedFilter].$2,
              from: selectedFilter == 3 && _customRange != null
                  ? DateFormat('yyyy-MM-dd').format(_customRange!.start)
                  : null,
              to: selectedFilter == 3 && _customRange != null
                  ? DateFormat('yyyy-MM-dd').format(_customRange!.end)
                  : null,
            ),
            child: ListView.builder(
              controller: _memosScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildMemorandoCard(state.items[i]);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMemorandoCard(MemorandumEntity memo) {
    final fmt = DateFormat('dd MMM, yyyy', 'es');
    final fecha = fmt.format(memo.createdAt).toUpperCase();

    return MinutesMemosCardPanelWidget(
      tipo: 'memo',
      numero: memo.numero,
      titulo: memo.asunto,
      destinatario: memo.destinatario,
      fecha: fecha,
      estado: memo.estado,
    );
  }

  Widget _buildTab(String text, int index) {
    final bool isActive = selectedTab == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabTap(index),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? TColors.appMainDarkColor
                  : TColors.appDisabledColor,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isActive ? 100 : 0,
            color: TColors.appMainDarkColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, int index, {IconData? icon}) {
    final bool isActive = selectedFilter == index;

    return GestureDetector(
      onTap: () => _onFilterTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? TColors.appMainDarkColor : TColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? TColors.appMainDarkColor
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : TColors.appDisabledColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : TColors.appDisabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
