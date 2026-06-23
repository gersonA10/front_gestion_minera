import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_prefs.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_tts.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../domain/entity/member_loan_list_entity.dart';
import '../bloc/member_loans_list_bloc.dart';
import '../ui_kit.dart';

const _statusFilters = <_FilterDef>[
  _FilterDef('Todos', null),
  _FilterDef('Pendientes', 'pendientes'),
  _FilterDef('Vigentes', 'vigentes'),
  _FilterDef('Pagados', 'pagados'),
  _FilterDef('Rechazados', 'rechazados'),
  _FilterDef('Cancelados', 'cancelados'),
];

const _typeFilters = <_FilterDef>[
  _FilterDef('Todos', null),
  _FilterDef('Dinero', 'dinero'),
  _FilterDef('Oro', 'gramos'),
];

class _FilterDef {
  final String label;
  final String? value;
  const _FilterDef(this.label, this.value);
}

/// Scope del recorrido guiado (coach marks) del módulo Préstamos de Socios.
const String _kMemberLoansScope = 'member_loans';

/// Envuelve un widget como objetivo de coach mark con el estilo del módulo.
Widget _coachMark({
  required GlobalKey key,
  required String title,
  required String description,
  required Widget child,
}) {
  return Showcase(
    key: key,
    scope: _kMemberLoansScope,
    title: title,
    description: description,
    targetBorderRadius: BorderRadius.circular(14),
    targetPadding: const EdgeInsets.all(6),
    tooltipBackgroundColor: MlColors.surface,
    tooltipBorderRadius: BorderRadius.circular(16),
    titleTextStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: MlColors.textPrimary,
      letterSpacing: -0.2,
    ),
    descTextStyle: const TextStyle(
      fontSize: 13,
      height: 1.4,
      color: MlColors.textSecondary,
    ),
    child: child,
  );
}

@RoutePage()
class MemberLoansHomeScreen extends StatefulWidget {
  const MemberLoansHomeScreen({super.key});

  @override
  State<MemberLoansHomeScreen> createState() => _MemberLoansHomeScreenState();
}

class _MemberLoansHomeScreenState extends State<MemberLoansHomeScreen> {
  late final MemberLoansListBloc _bloc;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _scrollController = ScrollController();

  String _status = 'Todos';
  String _type = 'Todos';
  bool _reachedMax = false;

  // ─── Tutorial (coach marks) ───────────────────────────────────────────────
  /// Clave de rol para persistir si Préstamos de Socios ya vio el recorrido.
  static const String _kTutorialRoleKey = 'prestamos_socios';

  late final ShowcaseView _showcaseView;

  final GlobalKey _reportKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _filtersKey = GlobalKey();

  /// Orden del recorrido (de arriba hacia abajo).
  List<GlobalKey> get _showcaseKeys => [_reportKey, _searchKey, _filtersKey];

  /// Locución de cada paso (mismo orden que [_showcaseKeys]).
  static const List<String> _speechByStep = [
    'Reporte. Abre el reporte consolidado de los préstamos de socios para '
        'revisar totales y exportarlos.',
    'Buscar. Encuentra rápidamente un préstamo escribiendo el nombre del socio.',
    'Filtros. Filtra la bandeja por estado: pendientes, vigentes, pagados, '
        'rechazados o cancelados.',
  ];

  void _speakStep(int? index) {
    if (index == null || index < 0 || index >= _speechByStep.length) return;
    TutorialTts.instance.speak(_speechByStep[index]);
  }

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<MemberLoansListBloc>()
      ..add(MemberLoansFetch());
    _scrollController.addListener(_onScroll);

    _showcaseView = ShowcaseView.register(
      scope: _kMemberLoansScope,
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
            color: MlColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Siguiente',
          backgroundColor: MlColors.primary,
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
      delay: const Duration(milliseconds: 500),
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
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_reachedMax) _bloc.add(MemberLoansLoadMore());
    }
  }

  String? _statusValue(String l) =>
      _statusFilters.firstWhere((f) => f.label == l).value;
  String? _typeValue(String l) =>
      _typeFilters.firstWhere((f) => f.label == l).value;

  void _fetch() {
    final search = _searchController.text.trim();
    _bloc.add(MemberLoansFetch(
      status: _statusValue(_status),
      loanType: _typeValue(_type),
      search: search.isEmpty ? null : search,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MlColors.background,
      body: Column(
        children: [
          MlGradientHeader(
            title: 'Préstamos de Socios',
            subtitle: 'Ofertas de préstamo de socios para evaluar y gestionar.',
            onBack: () => Navigator.of(context).maybePop(),
            actions: [
              MlGlassButton(
                icon: Icons.help_outline_rounded,
                onTap: _startTutorial,
              ),
              const SizedBox(width: 8),
              _coachMark(
                key: _reportKey,
                title: 'Reporte',
                description:
                    'Abre el reporte consolidado de los préstamos de socios '
                    'para revisar totales y exportarlos.',
                child: MlGlassButton(
                  icon: Icons.assessment_rounded,
                  onTap: () =>
                      context.router.push(const MemberLoansReportRoute()),
                ),
              ),
            ],
          ),
          _coachMark(
            key: _searchKey,
            title: 'Buscar',
            description:
                'Encuentra rápidamente un préstamo escribiendo el nombre del '
                'socio.',
            child: _search(),
          ),
          _coachMark(
            key: _filtersKey,
            title: 'Filtros',
            description:
                'Filtra la bandeja por estado para enfocarte en lo que '
                'necesitas revisar.',
            child: _statusBar(),
          ),
          const SizedBox(height: 8),
          _typeBar(),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<MemberLoansListBloc, MemberLoansListState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is MemberLoansListLoading ||
                    state is MemberLoansListInitial) {
                  return const Center(child: ExcavatorLoader());
                }
                if (state is MemberLoansListError) {
                  return MlStateView(
                    icon: Icons.cloud_off_rounded,
                    color: MlColors.red,
                    title: 'No pudimos cargar la bandeja',
                    subtitle: state.message,
                  );
                }
                if (state is MemberLoansListLoaded) {
                  _reachedMax = state.hasReachedMax;
                  if (state.items.isEmpty) {
                    return const MlStateView(
                      icon: Icons.inbox_rounded,
                      color: MlColors.primary,
                      title: 'Sin préstamos',
                      subtitle: 'No hay préstamos para este filtro.',
                    );
                  }
                  return RefreshIndicator(
                    color: MlColors.primary,
                    onRefresh: () async => _fetch(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: state.items.length + (_reachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.4, color: MlColors.primary),
                              ),
                            ),
                          );
                        }
                        final item = state.items[index];
                        return _LoanCard(
                          item: item,
                          onTap: () => context.router.push(
                            MemberLoanManageRoute(loanId: item.loanId),
                          ),
                        );
                      },
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

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: MlColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MlColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded,
                size: 20, color: MlColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  _searchFocus.unfocus();
                  _fetch();
                },
                style: const TextStyle(
                    fontSize: 13.5, color: MlColors.textPrimary),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: 'Buscar por socio',
                  hintStyle: TextStyle(
                      fontSize: 13.5, color: MlColors.textSecondary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _searchController.clear();
                    _searchFocus.unfocus();
                    _fetch();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.close_rounded,
                        size: 20, color: MlColors.textSecondary),
                  ),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                _searchFocus.unfocus();
                _fetch();
              },
              child: Container(
                margin: const EdgeInsets.all(6),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [MlColors.primary, MlColors.primaryDeep],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBar() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _statusFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _statusFilters[i];
          return MlChip(
            label: f.label,
            active: _status == f.label,
            onTap: () {
              setState(() => _status = f.label);
              _fetch();
            },
          );
        },
      ),
    );
  }

  Widget _typeBar() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _typeFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _typeFilters[i];
          final active = _type == f.label;
          return GestureDetector(
            onTap: () {
              setState(() => _type = f.label);
              _fetch();
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active
                    ? MlColors.gold.withValues(alpha: 0.18)
                    : MlColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: active ? MlColors.goldDeep : MlColors.border),
              ),
              child: Text(
                f.label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: active ? MlColors.goldDeep : MlColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final MemberLoanListItemEntity item;
  final VoidCallback onTap;
  const _LoanCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final st = mlStatusStyle(item.status.isNotEmpty ? item.status : item.estado);
    final amount = mlMoney(item.montoOGramos, isGrams: item.isGrams);
    final interest = item.hasInterest && item.tasaInteresMensual != null
        ? (item.isGrams
            ? '${mlNum(item.tasaInteresMensual!)} g/mes'
            : '${mlNum(item.tasaInteresMensual!)} %/mes')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: MlColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MlColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B3E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (item.isGrams
                                ? MlColors.gold
                                : MlColors.primary)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        item.isGrams
                            ? Icons.diamond_outlined
                            : Icons.payments_rounded,
                        color:
                            item.isGrams ? MlColors.goldDeep : MlColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.socio.isEmpty ? 'Socio' : item.socio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: MlColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 12, color: MlColors.textSecondary),
                              const SizedBox(width: 5),
                              Text(
                                mlDate(item.createdAt),
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    color: MlColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    MlStatusBadge(style: st),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: MlColors.border),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.isGrams ? 'Gramos' : 'Monto',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: MlColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(amount,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: MlColors.textPrimary,
                                letterSpacing: -0.3)),
                      ],
                    ),
                    const Spacer(),
                    if (interest != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: MlColors.gold.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.percent_rounded,
                                size: 12, color: MlColors.goldDeep),
                            const SizedBox(width: 4),
                            Text(interest,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: MlColors.goldDeep)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
