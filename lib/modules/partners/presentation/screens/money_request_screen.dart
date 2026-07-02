import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/partners_bloc.dart';

class _ReqColors {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
}

@RoutePage()
class MoneyRequestScreen extends StatefulWidget {
  const MoneyRequestScreen({super.key});

  @override
  State<MoneyRequestScreen> createState() => _MoneyRequestScreenState();
}

class _MoneyRequestScreenState extends State<MoneyRequestScreen> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String _area = 'Cargando...';
  String _solicitante = 'Cargando...';

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final role = await UserSession.getRole();
    final fullName = await UserSession.getFullName();
    if (!mounted) return;
    setState(() {
      _area = role.isNotEmpty ? role : 'Administración';
      _solicitante = fullName;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: _ReqColors.primary),
                title: const Text('Tomar foto'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Future.delayed(const Duration(milliseconds: 200));
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: _ReqColors.primary),
                title: const Text('Elegir de galería'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Future.delayed(const Duration(milliseconds: 200));
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(BuildContext blocContext) {
    final monto = double.tryParse(_montoController.text) ?? 0.0;
    if (monto <= 0) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'Ingrese un monto válido',
        type: AlertType.warning,
      );
      return;
    }
    if (_selectedImage == null) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'Debe agregar un comprobante',
        type: AlertType.warning,
      );
      return;
    }
    if (_descripcionController.text.trim().isEmpty) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'Debe agregar una descripción o motivo',
        type: AlertType.warning,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    blocContext.read<PartnersBloc>().add(
          PartnersSubmitMoneyRequestEvent(
            area: _area,
            requestedAmount: monto,
            description: _descripcionController.text.trim(),
            evidenceUrlPath: _selectedImage!.path,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectorContainer.getIt<PartnersBloc>(),
      child: Scaffold(
        backgroundColor: _ReqColors.background,
        body: Column(
          children: [
            _GradientHeader(
              title: 'Solicitud de Dinero',
              subtitle:
                  'Registra una solicitud de egreso con su comprobante. Hacienda la evaluará.',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: BlocConsumer<PartnersBloc, PartnersState>(
                listener: (context, state) {
                  if (state is PartnersMoneyRequestSuccess) {
                    CustomAlert.show(
                      context,
                      title: 'Éxito',
                      message: 'La solicitud se ha registrado correctamente.',
                      type: AlertType.success,
                    );
                    context.router.back();
                  } else if (state is PartnersMoneyRequestError) {
                    CustomAlert.show(
                      context,
                      title: 'Error',
                      message: state.message,
                      type: AlertType.error,
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is PartnersMoneyRequestLoading;

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionLabel('COMPROBANTE DE EGRESO'),
                            const SizedBox(height: 10),
                            _ReceiptPicker(
                              image: _selectedImage,
                              onTap: _showImageSourceSelector,
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.business_outlined,
                                    label: 'Área / Rol',
                                    value: _area,
                                    iconColor: _ReqColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.person_outline_rounded,
                                    label: 'Solicitante',
                                    value: _solicitante,
                                    iconColor: const Color(0xFFB8930A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            const _SectionLabel('MONTO A SOLICITAR'),
                            const SizedBox(height: 10),
                            _AmountField(controller: _montoController),
                            const SizedBox(height: 22),
                            const _SectionLabel('DESCRIPCIÓN / MOTIVO'),
                            const SizedBox(height: 10),
                            _DescriptionField(controller: _descripcionController),
                            const SizedBox(height: 28),
                            _PrimaryButton(
                              label: 'Solicitar Egreso',
                              icon: Icons.send_rounded,
                              loading: isLoading,
                              onTap: isLoading ? null : () => _submit(context),
                            ),
                          ],
                        ),
                      ),
                      if (isLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.25),
                            child: const Center(child: StaffLoader(),),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header gradiente ────────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _GradientHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_ReqColors.primary, _ReqColors.primaryDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -24,
            child: _circle(120, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 26,
            right: 36,
            child: _circle(64, _ReqColors.gold.withValues(alpha: 0.18)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: onBack,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ─── Piezas del formulario ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _ReqColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _ReceiptPicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  const _ReceiptPicker({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          color: image == null
              ? _ReqColors.primary.withValues(alpha: 0.04)
              : _ReqColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: image == null
                ? _ReqColors.primary.withValues(alpha: 0.3)
                : _ReqColors.border,
            width: 1.4,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: image != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(image!, fit: BoxFit.cover),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded,
                              color: Colors.white, size: 15),
                          SizedBox(width: 6),
                          Text(
                            'Cambiar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _ReqColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _ReqColors.primary.withValues(alpha: 0.12),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      color: _ReqColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Toca para subir el comprobante',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _ReqColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cámara o galería',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _ReqColors.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _ReqColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ReqColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _ReqColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _ReqColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ReqColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ReqColors.border),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _ReqColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Bs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _ReqColors.primary,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _ReqColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                filled: false,
                fillColor: Colors.transparent,
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _ReqColors.textSecondary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(right: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const _DescriptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ReqColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ReqColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(
          fontSize: 13.5,
          color: _ReqColors.textPrimary,
          height: 1.4,
        ),
        decoration: const InputDecoration(
          filled: false,
          fillColor: Colors.transparent,
          hintText: 'Ej. Pago de servicios de logística minera...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: _ReqColors.textSecondary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null && !widget.loading;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_ReqColors.primary, _ReqColors.primaryDeep],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: _ReqColors.primary.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(widget.icon, color: Colors.white, size: 19),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
