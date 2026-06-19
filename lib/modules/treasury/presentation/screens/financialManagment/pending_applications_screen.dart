import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:intl/intl.dart';

import '../../widgets/widgtes.dart';

class _C {
  static const primary = Color(0xFF1A56FF);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
}

@RoutePage()
class PendingApplicationsScreen extends StatefulWidget {
  const PendingApplicationsScreen({super.key});

  @override
  State<PendingApplicationsScreen> createState() =>
      _PendingApplicationsScreenState();
}

class _PendingApplicationsScreenState extends State<PendingApplicationsScreen> {
  late final TreasuryBloc _treasuryBloc;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _treasuryBloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(ListOfPendingRequestsEvent(isRefresh: false));
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _treasuryBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _treasuryBloc.add(LoadMorePendingEvent());
    }
  }

  Future<void> _onRefresh() async {
    _treasuryBloc.add(ListOfPendingRequestsEvent(isRefresh: true));
  }

  String _money(num v) => 'Bs ${NumberFormat('#,##0.00', 'en_US').format(v)}';

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _treasuryBloc,
      child: Scaffold(
        backgroundColor: _C.background,
        appBar: AppBar(
          backgroundColor: _C.background,
          surfaceTintColor: _C.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _C.textPrimary, size: 20),
            onPressed: () => context.router.back(),
          ),
          title: const Text(
            'Solicitudes pendientes',
            style: TextStyle(
              color: _C.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          builder: (context, state) {
            if (state is ListOfPendingRequestsLoading) {
              return const Center(child: ExcavatorLoader());
            }

            if (state is ListOfPendingRequestsError) {
              return RefreshIndicator(
                color: _C.primary,
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 140),
                    _StateView(
                      icon: Icons.cloud_off_rounded,
                      color: const Color(0xFFD32F2F),
                      title: 'No pudimos cargar',
                      subtitle: state.message,
                    ),
                  ],
                ),
              );
            }

            if (state is ListOfPendingRequestsSuccess) {
              final items = state.list;
              final total = items.fold<double>(
                0.0,
                (sum, item) => sum + (double.tryParse(item.amount) ?? 0.0),
              );

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: _SummaryHeader(
                      count: state.totalRecords,
                      total: _money(total),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: _C.primary,
                      onRefresh: _onRefresh,
                      child: items.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 80),
                                _StateView(
                                  icon: Icons.check_circle_rounded,
                                  color: Color(0xFF17A05D),
                                  title: 'Todo al día',
                                  subtitle:
                                      'No hay solicitudes pendientes por revisar.',
                                ),
                              ],
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: items.length + 1,
                              itemBuilder: (context, index) {
                                if (index == items.length) {
                                  if (!state.hasReachedMax) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: _C.primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        'Mostrando todas las solicitudes.',
                                        style: TextStyle(
                                          color: _C.textSecondary,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return RequestDetailCard(item: items[index]);
                              },
                            ),
                    ),
                  ),
                ],
              );
            }

            // Estado inicial: mientras llega la primera respuesta (el handler
            // no emite Loading cuando isRefresh es false), mostramos el loader.
            return const Center(child: ExcavatorLoader());
          },
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int count;
  final String total;
  const _SummaryHeader({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B3E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFC47A00).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.assignment_late_rounded,
                color: Color(0xFFC47A00), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count ${count == 1 ? 'solicitud' : 'solicitudes'}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Esperan tu revisión y decisión',
                  style: TextStyle(fontSize: 11.5, color: _C.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total acumulado',
                style: TextStyle(fontSize: 10.5, color: _C.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                total,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _C.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _StateView({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: _C.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
