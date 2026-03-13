import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/surveillance/domain/entity/contribution_entity.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/bloc/surveillance_bloc.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class CalculationPreviewSheet extends StatelessWidget {
  final ContributionCalculationEntity calculation;
  final String motivo;
  final Function(ContributionRegistrationEntity) onSuccess;

  const CalculationPreviewSheet({
    super.key,
    required this.calculation,
    required this.motivo,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<SurveillanceBloc, SurveillanceState>(
      listener: (context, state) {
        if (state is SurveillanceRegisterSuccess) {
          onSuccess(state.registration);
        } else if (state is SurveillanceRegisterError) {
          CustomAlert.show(
            context,
            title: 'Error de Registro',
            message: state.message,
            type: AlertType.error,
          );
        }
      },
      builder: (context, state) {
        final isRegistering = state is SurveillanceRegisterLoading;

        return PopScope(
          canPop: !isRegistering,
          child: Container(
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: colors.lead.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.blue.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.calculate_rounded,
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
                                'Previsualización del cálculo',
                                style: AppTextStyles.mainStyle16Bold(context).copyWith(
                                  fontSize: 18,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Verifica el resumen antes de registrar la contribución.',
                                style: AppTextStyles.mainStyle12(context).copyWith(
                                  color: colors.lead.withValues(alpha: 0.85),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (motivo.trim().isNotEmpty) ...[
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Motivo',
                              style: AppTextStyles.mainStyle12(context).copyWith(
                                color: colors.lead,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              motivo,
                              style: AppTextStyles.mainStyle14Bold(context).copyWith(
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _SectionCard(
                      child: Column(
                        children: [
                          _ProfessionalDetailRow(
                            label: 'Monto total',
                            value: 'Bs. ${calculation.montoTotal.toStringAsFixed(2)}',
                            icon: Icons.account_balance_wallet_outlined,
                            isHighlighted: true,
                          ),
                          const SizedBox(height: 18),
                          _ProfessionalDivider(color: colors),
                          const SizedBox(height: 18),
                          _ProfessionalDetailRow(
                            label: 'Cantidad de personas',
                            value: '${calculation.cantidadPersonas}',
                            icon: Icons.group_outlined,
                          ),
                          const SizedBox(height: 18),
                          _ProfessionalDivider(color: colors),
                          const SizedBox(height: 18),
                          _ProfessionalDetailRow(
                            label: 'Monto por persona',
                            value: 'Bs. ${calculation.montoPorPersona.toStringAsFixed(2)}',
                            icon: Icons.payments_outlined,
                            valueColor: colors.green,
                            isHighlighted: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.blue.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.blue.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Una vez registrado, el sistema generará la contribución de aportes con base en este cálculo.',
                              style: AppTextStyles.mainStyle12(context).copyWith(
                                color: colors.lead,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isRegistering
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              side: BorderSide(
                                color: colors.lead.withValues(alpha: 0.18),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: colors.white,
                            ),
                            child: Text(
                              'Cancelar',
                              style: AppTextStyles.mainStyle14Bold(context).copyWith(
                                color: colors.lead,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isRegistering
                                ? null
                                : () {
                                    context.read<SurveillanceBloc>().add(
                                          RegisterContributionEvent(
                                            montoTotal: calculation.montoTotal,
                                            motivo: motivo,
                                          ),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              backgroundColor: colors.blue,
                              disabledBackgroundColor:
                                  colors.blue.withValues(alpha: 0.65),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(opacity: animation, child: child),
                              child: isRegistering
                                  ? Row(
                                      key: const ValueKey('loading'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Registrando...',
                                          style: AppTextStyles.mainStyle14Bold(context)
                                              .copyWith(color: colors.white),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Confirmar registro',
                                      key: const ValueKey('text'),
                                      style: AppTextStyles.mainStyle14Bold(context)
                                          .copyWith(color: colors.white),
                                    ),
                            ),
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
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.lead.withValues(alpha: 0.08),
        ),
      ),
      child: child,
    );
  }
}

class _ProfessionalDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlighted;
  final Color? valueColor;

  const _ProfessionalDetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlighted = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.mainStyle12(context).copyWith(
              color: colors.lead,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: (isHighlighted
                    ? AppTextStyles.mainStyle14Bold(context)
                    : AppTextStyles.mainStyle14Bold(context))
                .copyWith(
              color: valueColor ?? colors.black,
              fontSize: isHighlighted ? 15 : 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfessionalDivider extends StatelessWidget {
  final ColorScheme color;

  const _ProfessionalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: color.lead.withValues(alpha: 0.08),
    );
  }
}