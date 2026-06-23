import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:intl/intl.dart';
import '../../domain/entity/entity.dart';
import '../bloc/camp_bloc.dart';

/// Paleta compartida con los módulos de socios y hacienda.
class _C {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const field = Color(0xFFF6F8FC);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const textMuted = Color(0xFF9AA8C2);
  static const border = Color(0xFFE8EDF5);
  static const danger = Color(0xFFD32F2F);
}

@RoutePage()
class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  late final CampBloc _campBloc;
  final _formKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final montoController = TextEditingController();
  final fechaController = TextEditingController();
  final detailController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _campBloc = InjectorContainer.getIt<CampBloc>();
    fechaController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    tituloController.dispose();
    montoController.dispose();
    fechaController.dispose();
    detailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _C.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final monto = double.parse(
      montoController.text.trim().replaceAll(',', '.'),
    );

    _campBloc.add(
      CreateCampRequestEvent(
        request: CreateCampRequestEntity(
          concept: tituloController.text.trim(),
          detail: detailController.text.trim(),
          requestedAmount: monto,
          estimatedPurchaseDate: _selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _campBloc,
      child: Scaffold(
        backgroundColor: _C.background,
        body: BlocConsumer<CampBloc, CampState>(
          listener: (context, state) {
            if (state is CampRequestCreated) {
              CustomAlert.show(
                context,
                title: "Solicitud Creada",
                message: "Tu solicitud ha sido creada exitosamente.",
                type: AlertType.success,
              );
              Navigator.of(context).pop(true);
            }
            if (state is CampRequestCreateError) {
              CustomAlert.show(
                context,
                title: "Error",
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is CampRequestCreating;
            return Stack(
              children: [
                Column(
                  children: [
                    const _Header(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Card(
                                child: Column(
                                  children: [
                                    _Field(
                                      label: "Título",
                                      icon: Icons.campaign_rounded,
                                      hint: "Compra de víveres",
                                      controller: tituloController,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? "Ingrese un título"
                                              : null,
                                    ),
                                    const SizedBox(height: 18),
                                    _Field(
                                      label: "Monto solicitado",
                                      icon: Icons.payments_rounded,
                                      hint: "0.00",
                                      suffixText: "Bs",
                                      controller: montoController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return "Ingrese un monto";
                                        }
                                        final m = double.tryParse(
                                          v.replaceAll(',', '.'),
                                        );
                                        if (m == null || m <= 0) {
                                          return "El monto debe ser mayor a 0";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                    _Field(
                                      label: "Fecha estimada de compra",
                                      icon: Icons.calendar_today_rounded,
                                      hint: "dd/mm/aaaa",
                                      controller: fechaController,
                                      readOnly: true,
                                      onTap: _pickDate,
                                      validator: (v) =>
                                          (v == null || v.isEmpty)
                                              ? "Seleccione una fecha"
                                              : null,
                                    ),
                                    const SizedBox(height: 18),
                                    _Field(
                                      label: "Descripción o detalle",
                                      icon: Icons.description_rounded,
                                      hint:
                                          "Describa los insumos, herramientas o "
                                          "servicios requeridos...",
                                      maxLines: 4,
                                      controller: detailController,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? "Ingrese un detalle"
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const _InfoNote(
                                text:
                                    "Esta solicitud será revisada por vigilancia.",
                              ),
                              const SizedBox(height: 28),
                              _SubmitButton(
                                isLoading: isLoading,
                                onPressed: _onSubmit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(child: ExcavatorLoader()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Header con degradado ────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.primary, _C.primaryDeep],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -34,
            right: -26,
            child: _circle(130, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 36,
            right: 40,
            child: _circle(60, _C.gold.withValues(alpha: 0.16)),
          ),
          Positioned(
            bottom: -46,
            left: -28,
            child: _circle(110, Colors.white.withValues(alpha: 0.05)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 20, 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GlassBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        const Text(
                          'Nueva solicitud',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _C.gold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Registra una compra para su revisión',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.back(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// ─── Tarjeta contenedora ─────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: child,
    );
  }
}

// ─── Campo de formulario ─────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final String? suffixText;
  final bool readOnly;
  final VoidCallback? onTap;

  const _Field({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffixText,
    this.readOnly = false,
    this.onTap,
  });

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: _C.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _C.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _C.textMuted, fontSize: 13.5),
            filled: true,
            fillColor: _C.field,
            isDense: true,
            suffixText: suffixText,
            suffixStyle: const TextStyle(
              color: _C.textSecondary,
              fontWeight: FontWeight.w700,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: _border(_C.border),
            focusedBorder: _border(_C.primary, 1.5),
            errorBorder: _border(_C.danger),
            focusedErrorBorder: _border(_C.danger, 1.5),
            errorStyle: const TextStyle(fontSize: 11.5, color: _C.danger),
          ),
        ),
      ],
    );
  }
}

// ─── Nota informativa ────────────────────────────────────────────────────────

class _InfoNote extends StatelessWidget {
  final String text;
  const _InfoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: _C.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: _C.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Botón de envío ──────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.primary,
          disabledBackgroundColor: _C.primary.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Enviar solicitud',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
