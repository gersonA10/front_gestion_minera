import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:front_gestion_minera/modules/partners/presentation/widgets/custom_card_widget.dart';
import 'package:image_picker/image_picker.dart';

class _LoanColors {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const goldDeep = Color(0xFFCFA227);
  static const background = Color(0xFFF5F7FB);
  static const textPrimary = Color(0xFF0D1B3E);
}

@RoutePage()
class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  /// 0 = Dinero (Bs), 1 = Gramos
  int _selectedIndex = 0;
  bool _hasInterest = false;

  // Controllers for form fields
  late TextEditingController _amountController;
  late TextEditingController _reasonController;
  late TextEditingController _applicantController;
  late TextEditingController _interestRateController;

  bool get _isMoney => _selectedIndex == 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _reasonController = TextEditingController();
    _applicantController = TextEditingController();
    _interestRateController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _applicantController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  void _onTypeChanged(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
      _amountController.clear();
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: _LoanColors.primary),
                title: const Text('Tomar foto'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? photo = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (photo != null) {
                    setState(() {
                      _image = File(photo.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: _LoanColors.primary,
                ),
                title: const Text('Seleccionar de galería'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? photo = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (photo != null) {
                    setState(() {
                      _image = File(photo.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final description = _reasonController.text;
    final loanType = _isMoney ? 'dinero' : 'gramos';
    final comprobanteImg = _image?.path;

    if (amount <= 0) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'Ingrese ${_isMoney ? 'el monto' : 'la cantidad'}',
        type: AlertType.warning,
      );
      return;
    }
    if (description.isEmpty) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'Ingrese un motivo válido.',
        type: AlertType.warning,
      );
      return;
    }

    double? interestRate;
    if (_hasInterest) {
      interestRate = double.tryParse(_interestRateController.text) ?? 0.0;
      if (interestRate <= 0) {
        CustomAlert.show(
          context,
          title: 'Error',
          message: _isMoney
              ? 'Ingrese una tasa de interés válida.'
              : 'Ingrese los gramos de interés.',
          type: AlertType.warning,
        );
        return;
      }
    }

    if (comprobanteImg == null) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'Debe agregar un comprobante',
        type: AlertType.warning,
      );
      return;
    }

    context.read<PartnersBloc>().add(
      LoanRegisterEvent(
        amount: amount,
        description: description,
        comprobanteImg: comprobanteImg,
        loanType: loanType,
        hasInterest: _hasInterest,
        interestRate: interestRate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double smallSpacing = screenSize.height * 0.02;
    final colors = Theme.of(context).colorScheme;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return BlocProvider(
      create: (context) => InjectorContainer.getIt<PartnersBloc>(),
      child: Scaffold(
        backgroundColor: _LoanColors.background,
        body: BlocConsumer<PartnersBloc, PartnersState>(
          listener: (context, state) {
            if (state is LoanRegisterSuccess) {
              CustomAlert.show(
                context,
                title: 'Éxito',
                message:
                    'Tu oferta de préstamo se registró. Hacienda la evaluará para aprobarla o rechazarla.',
                type: AlertType.success,
              );
              context.router.back();
            } else if (state is LoanRegisterError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is LoanRegisterLoading;
            return Stack(
              children: [
                Column(
                  children: [
                    _LoanHeader(onBack: () => context.router.back()),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: const ScrollBehavior().copyWith(
                          overscroll: false,
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Column(
                            children: [
                              _TypeSelector(
                                selectedIndex: _selectedIndex,
                                onChanged: _onTypeChanged,
                              ),
                              const SizedBox(height: 18),
                              CustomForm(
                                smallSpacing: smallSpacing,
                                colors: colors,
                                image: _image,
                                onOpenCamera: _pickImage,
                                title: _isMoney ? 'Monto' : 'Gramos',
                                amountController: _amountController,
                                reasonController: _reasonController,
                                applicantController: _applicantController,
                                hasInterest: _hasInterest,
                                onInterestChanged: (v) =>
                                    setState(() => _hasInterest = v),
                                interestRateController: _interestRateController,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _SubmitBar(
                      isLoading: isLoading,
                      onPressed: isLoading ? null : () => _submit(context),
                    ),
                  ],
                ),
                if (isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black26,
                      child: Center(child: ExcavatorLoader()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Header con degradado ───────────────────────────────────────────────────

class _LoanHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _LoanHeader({required this.onBack});

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
          colors: [_LoanColors.primary, _LoanColors.primaryDeep],
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
            top: 30,
            right: 40,
            child: _circle(60, _LoanColors.gold.withValues(alpha: 0.18)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 22),
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
                      const Expanded(
                        child: Text(
                          'Registrar Préstamo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Ofrece un préstamo a la empresa. Define el monto y, si lo deseas, el interés mensual.',
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

// ─── Selector animado Dinero / Gramos ───────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _TypeSelector({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F7),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: selectedIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                _segment(0, 'Dinero', Icons.attach_money_rounded),
                _segment(1, 'Gramos', Icons.diamond_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment(int index, String label, IconData icon) {
    final selected = selectedIndex == index;
    final color = selected ? _LoanColors.primary : const Color(0xFF8A97AD);
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: color),
                const SizedBox(width: 7),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Barra inferior con botón de envío ──────────────────────────────────────

class _SubmitBar extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SubmitBar({required this.isLoading, required this.onPressed});

  @override
  State<_SubmitBar> createState() => _SubmitBarState();
}

class _SubmitBarState extends State<_SubmitBar> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EDF5))),
      ),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_LoanColors.gold, _LoanColors.goldDeep],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _LoanColors.gold.withValues(alpha: enabled ? 0.22 : 0),
                  blurRadius: _pressed ? 6 : 12,
                  spreadRadius: -4,
                  offset: Offset(0, _pressed ? 2 : 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: _LoanColors.textPrimary,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save_outlined,
                        color: _LoanColors.textPrimary,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Registrar Préstamo',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: _LoanColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
