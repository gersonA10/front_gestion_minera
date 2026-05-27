import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/employee_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/employee_profile_end_status_widgets.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';


@RoutePage()
class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  late final StaffBloc _bloc;
  WorkerStatusWidget _selectedStatus = WorkerStatusWidget.activo;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    _bloc.add(GetEmployeeProfileEvent(widget.employeeId));
  }

  WorkerStatusWidget _mapStatus(String apiStatus) {
    switch (apiStatus.toUpperCase()) {
      case 'ACTIVO':
        return WorkerStatusWidget.activo;
      case 'DESCANSO':
        return WorkerStatusWidget.descanso;
      default:
        return WorkerStatusWidget.inactivo;
    }
  }

  String _formatSalary(double amount) {
    return NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatSeniority(int months) {
    final years = months ~/ 12;
    final rem = months % 12;
    if (years == 0) return '$rem ${rem == 1 ? "Mes" : "Meses"}';
    if (rem == 0) return '$years ${years == 1 ? "Año" : "Años"}';
    return '$years ${years == 1 ? "Año" : "Años"}, $rem ${rem == 1 ? "Mes" : "Meses"}';
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy', 'es').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'PERFIL DEL TRABAJADOR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: TColors.profileTitleText,
              letterSpacing: 1.4,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<StaffBloc, StaffState>(
          builder: (context, state) {
            if (state is EmployeeProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is EmployeeProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: TColors.disabled),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: const TextStyle(color: TColors.disabled),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => _bloc
                          .add(GetEmployeeProfileEvent(widget.employeeId)),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is EmployeeProfileLoaded) {
              final e = state.employee;
              _selectedStatus = _mapStatus(e.status);
              return _buildContent(e);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(EmployeeEntity e) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildAvatarSection(e),
          const SizedBox(height: 28),
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildPayrollCard(e),
          const SizedBox(height: 16),
          _buildSeniorityCard(e),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(EmployeeEntity e) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: TColors.border, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: e.profilePhotoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: e.profilePhotoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: TColors.avatarBackground,
                          child: const Icon(Icons.person_rounded,
                              size: 52, color: TColors.avatarIconColor),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: TColors.avatarBackground,
                          child: const Icon(Icons.person_rounded,
                              size: 52, color: TColors.avatarIconColor),
                        ),
                      )
                    : Container(
                        color: TColors.avatarBackground,
                        child: const Icon(Icons.person_rounded,
                            size: 52, color: TColors.avatarIconColor),
                      ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _mapStatus(e.status).dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: TColors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          e.fullName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: TColors.profileDarkText,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          e.position.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: TColors.profileBlue,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          e.nationalId,
          style: const TextStyle(
            fontSize: 11,
            color: TColors.profileMutedLabel,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, size: 15, color: TColors.profileMutedLabel),
              SizedBox(width: 6),
              Text(
                'ESTADO DEL TRABAJADOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: TColors.profileMutedLabel,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: WorkerStatusWidget.values.map((status) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStatus = status),
                  child: StatusChip(
                    status: status,
                    isSelected: _selectedStatus == status,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollCard(EmployeeEntity e) {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCIONES DE NÓMINA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: TColors.profileMutedLabel,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: TColors.profileIconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: TColors.profileBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.credit_card_rounded,
            label: 'Sueldo Base',
            value: _formatSalary(e.baseMonthlySalary),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.business_rounded,
            label: 'Departamento',
            value: e.department,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.schedule_rounded,
            label: 'Turno',
            value: e.shiftType,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: TColors.profileCardInnerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: TColors.profileIconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 15, color: TColors.profileBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: TColors.profileBodyText,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: TColors.profileDarkText,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeniorityCard(EmployeeEntity e) {
    return CardWidget(
      backgroundColor: TColors.seniorityCardBg,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColors.seniorityIconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: TColors.seniorityIconColor,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ANTIGÜEDAD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: TColors.seniorityLabelColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatSeniority(e.monthsSeniority),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TColors.profileDarkText,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (e.hiredDate.isNotEmpty || e.seniorityLevel.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: TColors.seniorityIconBg),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _seniorityDetail(
                  label: 'Desde',
                  value: _formatDate(e.hiredDate),
                ),
                _seniorityDetail(
                  label: 'Nivel',
                  value: e.seniorityLevel,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _seniorityDetail({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: TColors.seniorityLabelColor,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: TColors.profileDarkText,
          ),
        ),
      ],
    );
  }
}

