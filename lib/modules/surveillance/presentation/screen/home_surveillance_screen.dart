import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/logout_button_widget.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_prefs.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_tts.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/bloc/surveillance_bloc.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/request_card_widget.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import 'package:showcaseview/showcaseview.dart';

/// Scope del recorrido guiado (coach marks) del módulo Vigilancia.
const String _kSurveillanceScope = 'surveillance_vigilancia';

/// Paleta del tooltip del recorrido (este módulo usa colores del tema).
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF0D1B3E);
const Color _kTextSecondary = Color(0xFF6B7A99);
const Color _kAccent = Color(0xFF1A56FF);

/// Envuelve un widget como objetivo de coach mark con el estilo del módulo.
Widget _coachMark({
  required GlobalKey key,
  required String title,
  required String description,
  required Widget child,
}) {
  return Showcase(
    key: key,
    scope: _kSurveillanceScope,
    title: title,
    description: description,
    targetBorderRadius: BorderRadius.circular(20),
    targetPadding: const EdgeInsets.all(8),
    tooltipBackgroundColor: _kSurface,
    tooltipBorderRadius: BorderRadius.circular(16),
    titleTextStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: _kTextPrimary,
      letterSpacing: -0.2,
    ),
    descTextStyle: const TextStyle(
      fontSize: 13,
      height: 1.4,
      color: _kTextSecondary,
    ),
    child: child,
  );
}

@RoutePage()
class HomeSurveillanceScreen extends StatefulWidget {
  const HomeSurveillanceScreen({super.key});

  @override
  State<HomeSurveillanceScreen> createState() => _HomeSurveillanceScreenState();
}

class _HomeSurveillanceScreenState extends State<HomeSurveillanceScreen> {
  late final SurveillanceBloc _surveillanceBloc;
  late final ScrollController _scrollController;

  // ─── Tutorial (coach marks) ───────────────────────────────────────────────
  /// Clave de rol para persistir si Vigilancia ya vio el recorrido guiado.
  static const String _kTutorialRoleKey = 'vigilancia';

  late final ShowcaseView _showcaseView;

  /// Evita re-evaluar el auto-inicio en cada rebuild del estado cargado.
  bool _tutorialAutoChecked = false;

  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _summaryKey = GlobalKey();
  final GlobalKey _sectionKey = GlobalKey();

  /// Orden del recorrido (de arriba hacia abajo).
  List<GlobalKey> get _showcaseKeys => [_headerKey, _summaryKey, _sectionKey];

  /// Locución de cada paso (mismo orden que [_showcaseKeys]).
  static const List<String> _speechByStep = [
    'Bandeja de vigilancia. Aquí gestionas las solicitudes pendientes; con el '
        'botón Historial revisas las que ya resolviste.',
    'Resumen. El total de solicitudes pendientes de revisión en este momento.',
    'Solicitudes pendientes. Toca una para ver su detalle y aprobarla o '
        'rechazarla.',
  ];

  void _speakStep(int? index) {
    if (index == null || index < 0 || index >= _speechByStep.length) return;
    TutorialTts.instance.speak(_speechByStep[index]);
  }

  @override
  void initState() {
    super.initState();
    _surveillanceBloc = InjectorContainer.getIt<SurveillanceBloc>()
      ..add(MonitoringTrayEvent());

    _scrollController = ScrollController()..addListener(_onScroll);

    _showcaseView = ShowcaseView.register(
      scope: _kSurveillanceScope,
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
            color: _kTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Siguiente',
          backgroundColor: _kAccent,
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Inicia el recorrido la primera vez que la bandeja termina de cargar.
  void _maybeAutoStartTutorial() {
    if (_tutorialAutoChecked) return;
    _tutorialAutoChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final alreadySeen = await TutorialPrefs.hasSeen(_kTutorialRoleKey);
      if (alreadySeen || !mounted) return;
      _startTutorial();
    });
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _surveillanceBloc.add(LoadMoreRequestEvent());
    }
  }

  Future<void> _fetchHistory({bool isRefresh = false}) async {
    _surveillanceBloc.add(MonitoringTrayEvent(isRefresh: isRefresh));

    await _surveillanceBloc.stream.firstWhere(
      (state) => state is SurveillanceSuccess || state is SurveillanceError,
    );
  }

  @override
  void dispose() {
    TutorialTts.instance.stop();
    _showcaseView.unregister();
    _scrollController.dispose();
    _surveillanceBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _surveillanceBloc,
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _fetchHistory(isRefresh: true),
            child: _buildInboxView(),
          ),
        ),
      ),
    );
  }

  Widget _buildInboxView() {
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<SurveillanceBloc, SurveillanceState>(
      listener: (context, state) {
        if (state is SurveillanceSuccess) _maybeAutoStartTutorial();
      },
      builder: (context, state) {
        if (state is SurveillanceLoading) {
          return _buildLoadingState();
        }

        if (state is SurveillanceError) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              _buildTopHeader(),
              const SizedBox(height: 20),
              _StatusCard(
                icon: Icons.error_outline_rounded,
                title: 'No pudimos cargar la bandeja',
                subtitle: state.message,
                buttonText: 'Reintentar',
                onPressed: () {
                  _surveillanceBloc.add(MonitoringTrayEvent(isRefresh: true));
                },
                iconColor: colors.red,
              ),
            ],
          );
        }

        if (state is SurveillanceSuccess) {
          final items = state.list;

          return ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _coachMark(
                key: _headerKey,
                title: 'Bandeja de vigilancia',
                description:
                    'Gestiona las solicitudes pendientes y, con "Historial", '
                    'revisa las que ya resolviste.',
                child: _buildTopHeader(showHelp: true),
              ),
              const SizedBox(height: 20),
              _coachMark(
                key: _summaryKey,
                title: 'Resumen',
                description:
                    'El total de solicitudes pendientes de revisión en este '
                    'momento.',
                child: _buildSummaryCard(total: state.totalRecords),
              ),
              const SizedBox(height: 20),
              _coachMark(
                key: _sectionKey,
                title: 'Solicitudes pendientes',
                description:
                    'Toca una solicitud para ver su detalle y aprobarla o '
                    'rechazarla.',
                child: _buildSectionHeader(
                  title: 'Solicitudes pendientes',
                  subtitle: '${state.totalRecords} por revisar',
                ),
              ),
              const SizedBox(height: 14),
              if (items.isEmpty)
                const _EmptyRequestsState()
              else
                ...List.generate(items.length, (index) {
                  final item = items[index];
                  return RequestCard(
                    date: formatDate(item.createdAt),
                    name: item.name,
                    area: item.rol,
                    small: 12,
                    item: item,
                  );
                }),
              const SizedBox(height: 8),
              if (!state.hasReachedMax)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Cargando más solicitudes...'),
                      ],
                    ),
                  ),
                )
              else if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text(
                      'Ya viste todas las solicitudes disponibles.',
                      style: AppTextStyles.mainStyle10(context).copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTopHeader({bool showHelp = false}) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.blue.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bandeja de solicitudes',
                      style: AppTextStyles.mainStyle16Bold(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestiona y revisa las solicitudes pendientes de aprobación.',
                      style: AppTextStyles.mainStyle12(context).copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (showHelp) ...[
                GestureDetector(
                  onTap: _startTutorial,
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.blue.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: colors.blue,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const LogoutButton(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.router.push(const HistoryRequestsRoute());
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Historial'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required int total}) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colors.blue,
            colors.blue.withValues(alpha: .82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.blue.withValues(alpha: .18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.pending_actions_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total solicitudes',
                  style: AppTextStyles.mainStyleWhite14Bold(context),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pendientes de revisión en este momento',
                  style: AppTextStyles.mainStyleWhite10Bold(context).copyWith(
                    color: Colors.white.withValues(alpha: .90),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.mainStyle14Bold(context)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.mainStyle12(context).copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        _buildTopHeader(),
        const SizedBox(height: 20),
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 126,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyRequestsState extends StatelessWidget {
  const _EmptyRequestsState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.blue.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 34,
              color: colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay solicitudes pendientes',
            style: AppTextStyles.mainStyle14Bold(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando ingresen nuevas solicitudes, aparecerán aquí para su revisión.',
            style: AppTextStyles.mainStyle12(context).copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;
  final Color iconColor;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 46, color: iconColor),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTextStyles.mainStyle14Bold(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.mainStyle12(context).copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.blue,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonText,
                style: AppTextStyles.mainStyleWhite12Bold(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}