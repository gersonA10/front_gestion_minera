import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';

import '../../../domain/entity/entity.dart';

class _C {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
  static const green = Color(0xFF17A05D);
  static const amber = Color(0xFFC47A00);
}

String _money(double v) {
  final neg = v < 0;
  final s = v.abs().toStringAsFixed(2);
  final parts = s.split('.');
  final buf = StringBuffer();
  for (int i = 0; i < parts[0].length; i++) {
    if (i > 0 && (parts[0].length - i) % 3 == 0) buf.write(',');
    buf.write(parts[0][i]);
  }
  return '${neg ? '-' : ''}Bs $buf.${parts[1]}';
}

@RoutePage()
class ReconciliationsScreen extends StatefulWidget {
  const ReconciliationsScreen({super.key});

  @override
  State<ReconciliationsScreen> createState() => _ReconciliationsScreenState();
}

class _ReconciliationsScreenState extends State<ReconciliationsScreen> {
  late final TreasuryBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(GetReconciliationsEvent(isRefresh: true))
      ..add(GetCashRegistersEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      _bloc.add(LoadMoreReconciliationsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: _C.background,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: BlocConsumer<TreasuryBloc, TreasuryState>(
                    listenWhen: (p, c) =>
                        c is ExecuteReconciliationLoading ||
                        c is ExecuteReconciliationSuccess ||
                        c is ExecuteReconciliationError,
                    listener: (context, state) {
                      if (state is ExecuteReconciliationLoading) {
                        setState(() => _submitting = true);
                      } else if (state is ExecuteReconciliationSuccess) {
                        setState(() => _submitting = false);
                        final r = state.result;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: _C.green,
                            content: Text(
                              r.differenceType == 'DEVOLUCION'
                                  ? 'Devolución registrada: ${_money(r.amount)} ingresó a la caja.'
                                  : 'Compensación registrada: ${_money(r.amount)} pagado.',
                            ),
                          ),
                        );
                        _bloc.add(GetReconciliationsEvent(isRefresh: true));
                      } else if (state is ExecuteReconciliationError) {
                        setState(() => _submitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFFD32F2F),
                            content: Text(state.message),
                          ),
                        );
                      }
                    },
                    buildWhen: (p, c) =>
                        c is ReconciliationsLoading ||
                        c is ReconciliationsLoaded ||
                        c is ReconciliationsError,
                    builder: (context, state) {
                      if (state is ReconciliationsLoading ||
                          state is TreasuryInitial) {
                        return const Center(
                          child: CircularProgressIndicator(color: _C.primary),
                        );
                      }
                      if (state is ReconciliationsError) {
                        return _ErrorView(
                          message: state.message,
                          onRetry: () => _bloc.add(
                            GetReconciliationsEvent(isRefresh: true),
                          ),
                        );
                      }
                      if (state is ReconciliationsLoaded) {
                        if (state.items.isEmpty) return const _EmptyView();
                        return RefreshIndicator(
                          color: _C.primary,
                          onRefresh: () async => _bloc.add(
                            GetReconciliationsEvent(isRefresh: true),
                          ),
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                            itemCount: state.hasReachedMax
                                ? state.items.length
                                : state.items.length + 1,
                            itemBuilder: (context, index) {
                              if (index >= state.items.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }
                              return _ReconCard(
                                item: state.items[index],
                                onTap: () =>
                                    _openExecuteSheet(state.items[index]),
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
            if (_submitting)
              Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.primary, _C.primaryDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 20, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.router.back(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Reposiciones pendientes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _C.gold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Concilia las diferencias de las solicitudes de Campamento',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openExecuteSheet(ReconciliationItemEntity item) {
    final isCompensacion = item.differenceType == 'COMPENSACION';
    final amount = item.differenceAmount.abs();
    final notaController = TextEditingController();
    String? selectedCajaId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final cajas = _bloc.cashRegisters;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (sheetContext, setSheet) {
              final selectedCaja = cajas
                  .where((c) => c.id == selectedCajaId)
                  .cast<CashRegisterEntity?>()
                  .firstOrNull;
              final insufficient = isCompensacion &&
                  selectedCaja != null &&
                  selectedCaja.saldoDisponible < amount;
              final canConfirm = selectedCajaId != null && !insufficient;

              return Container(
                decoration: const BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _C.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isCompensacion
                          ? 'Compensar gasto adicional'
                          : 'Registrar devolución',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _C.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCompensacion
                          ? 'Se pagará ${_money(amount)} desde la caja seleccionada (gastó de más).'
                          : 'Ingresará ${_money(amount)} a la caja seleccionada (sobrante devuelto).',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: _C.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Caja',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (cajas.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Cargando cajas...',
                            style: TextStyle(color: _C.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...cajas.map((caja) {
                        final selected = caja.id == selectedCajaId;
                        final low =
                            isCompensacion && caja.saldoDisponible < amount;
                        return GestureDetector(
                          onTap: () =>
                              setSheet(() => selectedCajaId = caja.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? _C.primary.withValues(alpha: 0.06)
                                  : _C.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected ? _C.primary : _C.border,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: selected ? _C.primary : _C.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        caja.nombre,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _C.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Saldo: ${_money(caja.saldoDisponible)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: low
                                              ? const Color(0xFFD32F2F)
                                              : _C.textSecondary,
                                          fontWeight: low
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (low)
                                  const Text(
                                    'Sin fondos',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD32F2F),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notaController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Nota (opcional)',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9AA8C2),
                          fontSize: 13.5,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF6F8FC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _C.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _C.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: canConfirm
                            ? () {
                                _bloc.add(
                                  ExecuteReconciliationEvent(
                                    requestId: item.requestId,
                                    cajaOrigenId: selectedCajaId!,
                                    nota: notaController.text.trim().isEmpty
                                        ? null
                                        : notaController.text.trim(),
                                  ),
                                );
                                Navigator.of(sheetContext).pop();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primary,
                          disabledBackgroundColor:
                              _C.primary.withValues(alpha: 0.4),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          insufficient
                              ? 'Caja sin fondos suficientes'
                              : (isCompensacion
                                  ? 'Confirmar pago'
                                  : 'Confirmar devolución'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ReconCard extends StatelessWidget {
  final ReconciliationItemEntity item;
  final VoidCallback onTap;

  const _ReconCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompensacion = item.differenceType == 'COMPENSACION';
    final diffColor = isCompensacion ? _C.amber : _C.green;
    final amount = item.differenceAmount.abs();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
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
                  children: [
                    Expanded(
                      child: Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: diffColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCompensacion ? 'Compensación' : 'Devolución',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: diffColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.solicitante,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _C.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _amountCol('Solicitado', item.requestedAmount, _C.textSecondary),
                    Container(width: 1, height: 30, color: _C.border),
                    _amountCol('Gastado', item.finalAmount, _C.textPrimary),
                    Container(width: 1, height: 30, color: _C.border),
                    _amountCol(
                      isCompensacion ? 'A pagar' : 'A devolver',
                      amount,
                      diffColor,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 16,
                      color: _C.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Conciliar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.primary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: _C.textSecondary,
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

  Widget _amountCol(String label, double value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, color: _C.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            _money(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _C.green.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 36,
                  color: _C.green,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin reposiciones pendientes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Todas las solicitudes de Campamento\nestán conciliadas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _C.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: _C.textSecondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
