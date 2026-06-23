import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_prefs.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_tts.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/acta_entity.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/memorandum_entity.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/bloc/minutes_memos_bloc.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/widgets/actas_theme.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/utils/greeting_util.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';

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

  // ─── Tutorial (coach marks) ────────────────────────────────────────────────
  static const String _kTutorialRoleKey = 'actas';
  static const String _kShowcaseScope = 'minutes_memos_actas';

  late final ShowcaseView _showcaseView;

  final GlobalKey _kStats = GlobalKey();
  final GlobalKey _kRegisterActa = GlobalKey();
  final GlobalKey _kRegisterMemo = GlobalKey();
  final GlobalKey _kTabs = GlobalKey();
  final GlobalKey _kFilters = GlobalKey();

  List<GlobalKey> get _showcaseKeys =>
      [_kStats, _kRegisterActa, _kRegisterMemo, _kTabs, _kFilters];

  static const List<String> _speechByStep = [
    'Resumen. Aquí ves de un vistazo cuántas actas y cuántos memorandos hay '
        'registrados en el sistema.',
    'Registrar Acta. Crea una nueva acta de reunión: defines la fecha, la '
        'ubicación, los participantes y adjuntas la evidencia.',
    'Nuevo Memorando. Emite un memorando interno dirigido a un destinatario, '
        'con su contenido y los archivos de respaldo.',
    'Listado. Cambia entre la lista de actas y la de memorandos para revisar '
        'todo lo que se ha registrado.',
    'Filtros. Acota los documentos por fecha: recientes, esta semana, este mes '
        'o un rango personalizado.',
  ];

  void _speakStep(int? index) {
    if (index == null || index < 0 || index >= _speechByStep.length) return;
    TutorialTts.instance.speak(_speechByStep[index]);
  }

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<MinutesMemosBloc>();
    _actasScrollController.addListener(_onScrollActas);
    _memosScrollController.addListener(_onScrollMemos);
    _bloc.add(GetActasMoemoCountEvent(filter: _filters[0].$2));
    _bloc.add(GetActasEvent(filter: _filters[0].$2));

    _showcaseView = ShowcaseView.register(
      scope: _kShowcaseScope,
      enableAutoScroll: true,
      onStart: (index, _) => _speakStep(index),
      onFinish: _markTutorialSeen,
      onDismiss: (_) => _markTutorialSeen(),
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
      ),
      globalTooltipActions: [
        const TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: 'Saltar',
          backgroundColor: Colors.transparent,
          textStyle: TextStyle(
            color: AC.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Siguiente',
          backgroundColor: AC.primary,
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTutorial());
  }

  Future<void> _maybeStartTutorial() async {
    final alreadySeen = await TutorialPrefs.hasSeen(_kTutorialRoleKey);
    if (alreadySeen || !mounted) return;
    _startTutorial();
  }

  void _startTutorial() {
    _showcaseView.startShowCase(
      _showcaseKeys,
      delay: const Duration(milliseconds: 600),
    );
  }

  void _markTutorialSeen() {
    TutorialTts.instance.stop();
    TutorialPrefs.markSeen(_kTutorialRoleKey);
  }

  @override
  void dispose() {
    TutorialTts.instance.stop();
    _showcaseView.unregister();
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
        _bloc.add(GetActasEvent(filter: 'personalizado', from: from, to: to));
        _loadActas(filter: 'personalizado', from: from, to: to);
      } else {
        _bloc.add(
          GetMemorandosEvent(filter: 'personalizado', from: from, to: to),
        );
        _loadMemorandos(filter: 'personalizado', from: from, to: to);
      }
    } else {
      if (selectedFilter == index) return;
      setState(() => selectedFilter = index);
      if (selectedTab == 0) {
        _bloc.add(GetActasEvent(filter: _filters[index].$2));
        _loadActas(filter: _filters[index].$2);
      } else {
        _bloc.add(GetMemorandosEvent(filter: _filters[index].$2));
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
      _bloc.add(GetActasEvent(filter: filter, from: from, to: to));
      _loadActas(filter: filter, from: from, to: to);
    } else {
      _bloc.add(GetMemorandosEvent(filter: filter, from: from, to: to));
      _loadMemorandos(filter: filter, from: from, to: to);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AC.background,
        body: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildRegisterButtons(),
            const SizedBox(height: 22),
            _buildTabsAndFilters(),
            const SizedBox(height: 14),
            Expanded(
              child: selectedTab == 1
                  ? _buildMemorandosList()
                  : _buildActasList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AC.primary, AC.primaryDeep],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AC.primary.withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -34,
            right: -26,
            child: _circle(140, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 40,
            right: 44,
            child: _circle(64, AC.gold.withValues(alpha: 0.18)),
          ),
          Positioned(
            bottom: -48,
            left: -28,
            child: _circle(116, Colors.white.withValues(alpha: 0.05)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              GreetingUtil.getGreeting(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              UserSession.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AcGlassIconButton(
                        icon: Icons.help_outline_rounded,
                        tooltip: 'Ver tutorial',
                        onTap: _startTutorial,
                      ),
                      const SizedBox(width: 8),
                      const AcGlassLogoutButton(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Actas y Memorandos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AC.gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Showcase(
                    key: _kStats,
                    scope: _kShowcaseScope,
                    title: 'Resumen',
                    description:
                        'Aquí ves de un vistazo cuántas actas y memorandos hay '
                        'registrados.',
                    targetBorderRadius: BorderRadius.circular(18),
                    targetPadding: const EdgeInsets.all(6),
                    tooltipBackgroundColor: AC.surface,
                    tooltipBorderRadius: BorderRadius.circular(16),
                    titleTextStyle: _tipTitleStyle,
                    descTextStyle: _tipDescStyle,
                    child: _buildStatsRow(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return BlocBuilder<MinutesMemosBloc, MinutesMemosState>(
      buildWhen: (_, s) =>
          s is ActasMemoCountLoaded ||
          s is ActasMemoCountLoading ||
          s is MemosCountLoading ||
          s is MemosCountError,
      builder: (context, state) {
        final count =
            state is ActasMemoCountLoaded ? state : null;
        final isLoading =
            state is ActasMemoCountLoading || state is MemosCountLoading;

        final actas = isLoading ? null : (count?.actasCount.total.toString());
        final memos = isLoading ? null : (count?.memoscount.total.toString());

        return Row(
          children: [
            _StatPill(
              label: 'Actas',
              value: actas ?? '—',
              icon: Icons.article_rounded,
              loading: isLoading,
            ),
            const SizedBox(width: 12),
            _StatPill(
              label: 'Memorandos',
              value: memos ?? '—',
              icon: Icons.mark_email_unread_rounded,
              loading: isLoading,
            ),
          ],
        );
      },
    );
  }

  // ─── Botones de registro ─────────────────────────────────────────────────────
  Widget _buildRegisterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Showcase(
              key: _kRegisterActa,
              scope: _kShowcaseScope,
              title: 'Registrar Acta',
              description:
                  'Crea una nueva acta de reunión con participantes, ubicación '
                  'y adjuntos.',
              targetBorderRadius: BorderRadius.circular(14),
              targetPadding: const EdgeInsets.all(4),
              tooltipBackgroundColor: AC.surface,
              tooltipBorderRadius: BorderRadius.circular(16),
              titleTextStyle: _tipTitleStyle,
              descTextStyle: _tipDescStyle,
              child: _ActionButton(
                label: 'Registrar Acta',
                icon: Icons.add_rounded,
                filled: true,
                accent: AC.primary,
                onTap: () async {
                  await context.router.push(
                    RegisterMinutesMemosRoute(isOption: 0),
                  );
                  _bloc.add(GetActasMoemoCountEvent());
                  _bloc.add(GetActasEvent());
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Showcase(
              key: _kRegisterMemo,
              scope: _kShowcaseScope,
              title: 'Nuevo Memorando',
              description:
                  'Emite un memorando interno dirigido a un destinatario, con '
                  'su contenido y respaldos.',
              targetBorderRadius: BorderRadius.circular(14),
              targetPadding: const EdgeInsets.all(4),
              tooltipBackgroundColor: AC.surface,
              tooltipBorderRadius: BorderRadius.circular(16),
              titleTextStyle: _tipTitleStyle,
              descTextStyle: _tipDescStyle,
              child: _ActionButton(
                label: 'Nuevo Memorando',
                icon: Icons.edit_outlined,
                filled: false,
                accent: AC.memo,
                onTap: () async {
                  await context.router.push(
                    RegisterMinutesMemosRoute(isOption: 1),
                  );
                  _bloc.add(GetActasMoemoCountEvent());
                  _bloc.add(GetMemorandosEvent());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tabs + filtros ──────────────────────────────────────────────────────────
  Widget _buildTabsAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Showcase(
            key: _kTabs,
            scope: _kShowcaseScope,
            title: 'Listado',
            description:
                'Cambia entre la lista de actas y la de memorandos.',
            targetBorderRadius: BorderRadius.circular(14),
            targetPadding: const EdgeInsets.all(6),
            tooltipBackgroundColor: AC.surface,
            tooltipBorderRadius: BorderRadius.circular(16),
            titleTextStyle: _tipTitleStyle,
            descTextStyle: _tipDescStyle,
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AC.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AC.border),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTab('Actas', 0)),
                  Expanded(child: _buildTab('Memorandos', 1)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Showcase(
          key: _kFilters,
          scope: _kShowcaseScope,
          title: 'Filtros',
          description:
              'Filtra por fecha: recientes, semana, mes o un rango '
              'personalizado.',
          targetBorderRadius: BorderRadius.circular(14),
          targetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          tooltipBackgroundColor: AC.surface,
          tooltipBorderRadius: BorderRadius.circular(16),
          titleTextStyle: _tipTitleStyle,
          descTextStyle: _tipDescStyle,
          child: SizedBox(
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
                _buildFilterChip('Personalizado', 3, icon: Icons.tune_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String text, int index) {
    final bool isActive = selectedTab == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? AC.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AC.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String text, int index, {IconData? icon}) {
    final bool isActive = selectedFilter == index;
    return GestureDetector(
      onTap: () => _onFilterTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AC.primary : AC.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AC.primary : AC.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : AC.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AC.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Listas ──────────────────────────────────────────────────────────────────
  Widget _buildActasList() {
    return BlocBuilder<MinutesMemosBloc, MinutesMemosState>(
      buildWhen: (_, s) =>
          s is ActasLoading || s is ActasLoaded || s is ActasError,
      builder: (context, state) {
        if (state is ActasLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ActasError) {
          return _ErrorView(message: state.message);
        }
        if (state is ActasLoaded) {
          if (state.items.isEmpty) {
            return const _EmptyView(
              icon: Icons.article_outlined,
              message: 'No hay actas registradas',
            );
          }
          return RefreshIndicator(
            color: AC.primary,
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
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
      itemId: acta.id,
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
          return _ErrorView(message: state.message);
        }
        if (state is MemorandosLoaded) {
          if (state.items.isEmpty) {
            return const _EmptyView(
              icon: Icons.mark_email_read_outlined,
              message: 'No hay memorandos registrados',
            );
          }
          return RefreshIndicator(
            color: AC.primary,
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
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
      itemId: memo.id,
      tipo: 'memo',
      numero: memo.numero,
      titulo: memo.asunto,
      destinatario: memo.destinatario,
      fecha: fecha,
      estado: memo.estado,
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  static const TextStyle _tipTitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AC.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle _tipDescStyle = TextStyle(
    fontSize: 13,
    height: 1.4,
    color: AC.textSecondary,
  );
}

// ─── Píldora de estadística (en el header) ──────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool loading;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                  const SizedBox(height: 3),
                  Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Botón de acción (registrar) ───────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final Color accent;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? accent : AC.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: filled ? null : Border.all(color: accent, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: filled ? Colors.white : accent,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: filled ? Colors.white : accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Estados vacío / error ──────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyView({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AC.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: AC.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AC.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AC.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: AC.danger,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AC.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
