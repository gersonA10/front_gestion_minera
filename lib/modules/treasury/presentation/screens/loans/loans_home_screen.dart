import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:intl/intl.dart';

enum LoanFilter { todos, activos, enMora, finalizado }

extension LoanFilterExt on LoanFilter {
  String get label {
    switch (this) {
      case LoanFilter.todos:
        return 'Todos';
      case LoanFilter.activos:
        return 'Activos';
      case LoanFilter.enMora:
        return 'En Mora';
      case LoanFilter.finalizado:
        return 'Finalizados';
    }
  }

  IconData get icon {
    switch (this) {
      case LoanFilter.todos:
        return Icons.grid_view_rounded;
      case LoanFilter.activos:
        return Icons.play_circle_outline_rounded;
      case LoanFilter.enMora:
        return Icons.warning_amber_rounded;
      case LoanFilter.finalizado:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color get activeIconColor {
    switch (this) {
      case LoanFilter.todos:
        return Color(0xFF1F2937);
      case LoanFilter.activos:
        return const Color(0xFF3B82F6);
      case LoanFilter.enMora:
        return const Color(0xFFEF4444);
      case LoanFilter.finalizado:
        return const Color(0xFF16A34A);
    }
  }
}

enum LoanStatus { activo, enMora, finalizado }

extension LoanStatusExt on LoanStatus {
  String get label {
    switch (this) {
      case LoanStatus.activo:
        return 'Activo';
      case LoanStatus.enMora:
        return 'En Mora';
      case LoanStatus.finalizado:
        return 'Finalizado';
    }
  }

  Color get color {
    switch (this) {
      case LoanStatus.activo:
        return const Color(0xFF3B82F6);
      case LoanStatus.enMora:
        return const Color(0xFFEF4444);
      case LoanStatus.finalizado:
        return const Color(0xFF16A34A);
    }
  }

  Color get bgColor {
    switch (this) {
      case LoanStatus.activo:
        return const Color(0xFFEFF6FF);
      case LoanStatus.enMora:
        return const Color(0xFFFEF2F2);
      case LoanStatus.finalizado:
        return const Color(0xFFF0FDF4);
    }
  }
}

class Loan {
  final String id;
  final String empresa;
  final String loanId;
  final double totalPrestado;
  final double totalPagado;
  final LoanStatus status;
  final DateTime? proximoVencimiento;
  final int? diasVencido;

  const Loan({
    required this.id,
    required this.empresa,
    required this.loanId,
    required this.totalPrestado,
    required this.totalPagado,
    required this.status,
    this.proximoVencimiento,
    this.diasVencido,
  });

  double get pendiente => totalPrestado - totalPagado;
  double get progreso =>
      totalPrestado > 0 ? (totalPagado / totalPrestado) * 100 : 0;
  int get progresoInt => progreso.round();
}

@RoutePage()
class LoansHomeScreen extends StatefulWidget {
  const LoansHomeScreen({super.key});

  @override
  State<LoansHomeScreen> createState() => _LoansHomeScreenState();
}

class _LoansHomeScreenState extends State<LoansHomeScreen> {
  LoanFilter _selectedFilter = LoanFilter.todos;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Loan> _allLoans = [
    Loan(
      id: '1',
      empresa: 'Minera San Cristóbal S.A.',
      loanId: 'LP-2023-884',
      totalPrestado: 50000.00,
      totalPagado: 37500.00,
      status: LoanStatus.activo,
      proximoVencimiento: DateTime(2023, 10, 15),
    ),
    Loan(
      id: '2',
      empresa: 'Transportes del Sur SRL',
      loanId: 'TS-2023-102',
      totalPrestado: 120000.00,
      totalPagado: 74800.00,
      status: LoanStatus.enMora,
      proximoVencimiento: DateTime(2023, 9, 30),
      diasVencido: 5,
    ),
    Loan(
      id: '3',
      empresa: 'Cooperativa El Progreso',
      loanId: 'CP-2022-005',
      totalPrestado: 15000.00,
      totalPagado: 15000.00,
      status: LoanStatus.finalizado,
      proximoVencimiento: DateTime(2023, 8, 12),
    ),
  ];

  List<Loan> get _filteredLoans {
    var loans = _allLoans;

    if (_selectedFilter != LoanFilter.todos) {
      loans = loans.where((l) {
        switch (_selectedFilter) {
          case LoanFilter.activos:
            return l.status == LoanStatus.activo;
          case LoanFilter.enMora:
            return l.status == LoanStatus.enMora;
          case LoanFilter.finalizado:
            return l.status == LoanStatus.finalizado;
          default:
            return true;
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      loans = loans
          .where(
            (l) =>
                l.empresa.toLowerCase().contains(q) ||
                l.loanId.toLowerCase().contains(q),
          )
          .toList();
    }

    return loans;
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$${formatter.format(value)}';
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return DateFormat("dd MMM, yyyy • HH:mm", "es").format(localDate);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loans = _filteredLoans;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(NewLoansRoute());
        },
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
      appBar: AppBar(
        backgroundColor: color.white,
        surfaceTintColor: color.white,
        centerTitle: true,
        title: Text(
          'Préstamos Internos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                children: [
                  Container(
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        border: InputBorder.none,
                        hintText: 'Buscar prestamo',
                        hintStyle: TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 35,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: LoanFilter.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final filter = LoanFilter.values[i];
                        final isActive = _selectedFilter == filter;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive
                                    ? const Color(0xFF1F2937)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  filter.icon,
                                  size: 16,
                                  color: isActive
                                      ? Colors.white
                                      : filter.activeIconColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  filter.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: loans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inbox_rounded,
                            size: 56,
                            color: Color(0xFFD1D5DB),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No se encontraron resultados'
                                : 'No hay préstamos',
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: loans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _LoanCard(
                        loan: loans[i],
                        formatCurrency: _formatCurrency,
                        formatDate: _formatDate,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final Loan loan;
  final String Function(double) formatCurrency;
  final String Function(DateTime) formatDate;

  const _LoanCard({
    required this.loan,
    required this.formatCurrency,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                decoration: BoxDecoration(
                  color: loan.status.bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: loan.status.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  loan.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: loan.status.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          Text(
            loan.empresa,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'ID: ${loan.loanId}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Prestado',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatCurrency(loan.totalPrestado),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    loan.status == LoanStatus.finalizado
                        ? 'Total Pagado'
                        : 'Pendiente',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    loan.status == LoanStatus.finalizado
                        ? formatCurrency(loan.totalPagado)
                        : formatCurrency(loan.pendiente),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: loan.status == LoanStatus.finalizado
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de pago',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: loan.status.color,
                ),
              ),
              Text(
                '${loan.progresoInt}%',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: loan.progreso / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(loan.status.color),
            ),
          ),
          const SizedBox(height: 10),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    switch (loan.status) {
      case LoanStatus.activo:
        return Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, height: 1),
                  children: [
                    const TextSpan(
                      text: 'Próximo vencimiento: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                        fontSize: 10,
                      ),
                    ),
                    TextSpan(
                      text: loan.proximoVencimiento != null
                          ? formatDate(loan.proximoVencimiento!)
                          : '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case LoanStatus.enMora:
        return Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 15,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, height: 1),
                  children: [
                    TextSpan(
                      text: 'Vencido hace ${loan.diasVencido ?? 0} días: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                        fontSize: 10,
                      ),
                    ),
                    TextSpan(
                      text: loan.proximoVencimiento != null
                          ? formatDate(loan.proximoVencimiento!)
                          : '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case LoanStatus.finalizado:
        return Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 15,
              color: Color(0xFF16A34A),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, height: 1),
                  children: [
                    const TextSpan(
                      text: 'Pagado totalmente: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                        fontSize: 10,
                      ),
                    ),
                    TextSpan(
                      text: loan.proximoVencimiento != null
                          ? formatDate(loan.proximoVencimiento!)
                          : '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }
}
