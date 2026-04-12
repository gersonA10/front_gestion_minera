import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import '../../widgets/widgtes.dart';

@RoutePage()
class NewExtractionScreen extends StatelessWidget {
  const NewExtractionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectorContainer.getIt<TreasuryBloc>(),
      child: const _NewExtractionBody(),
    );
  }
}

class _NewExtractionBody extends StatefulWidget {
  const _NewExtractionBody();

  @override
  State<_NewExtractionBody> createState() => _NewExtractionBodyState();
}

class _NewExtractionBodyState extends State<_NewExtractionBody> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  final DateTime _today = DateTime.now();
  late final DateTime _minDate;

  final _pesoController = TextEditingController(text: '0.00');
  final _purezaController = TextEditingController(text: '96');
  final _observacionesController = TextEditingController();

  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(_today.year, _today.month, _today.day);
    _displayedMonth = DateTime(_today.year, _today.month);
    _minDate = _selectedDate.subtract(const Duration(days: 3));
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _purezaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  double get _pesoTotal =>
      double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0;

  double get _pureza =>
      double.tryParse(_purezaController.text.replaceAll(',', '.')) ?? 0.0;

  bool get _isFormValid =>
      _pesoTotal > 0 && _pureza > 0 && _pureza <= 100 && _selectedImage != null;

  bool _isDaySelectable(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final min = DateTime(_minDate.year, _minDate.month, _minDate.day);
    final max = DateTime(_today.year, _today.month, _today.day);
    return !d.isBefore(min) && !d.isAfter(max);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    if (next.isAfter(DateTime(_today.year, _today.month + 1))) return;
    setState(() => _displayedMonth = next);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked != null) {
      final file = File(picked.path);
      final size = await file.length();
      if (size > 5 * 1024 * 1024) {
        if (!mounted) return;
        CustomAlert.show(
          context,
          title: 'Atención',
          message: 'La imagen no debe superar los 5MB',
          type: AlertType.error,
        );
        return;
      }
      setState(() => _selectedImage = file);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Seleccionar imagen',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
            ImageSourceOption(
              icon: Icons.camera_alt_rounded,
              label: 'Tomar foto',
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
            ImageSourceOption(
              icon: Icons.photo_library_rounded,
              label: 'Galería',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            SizedBox(height: MediaQuery.of(ctx).viewPadding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_isFormValid || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final formData = NewExtractionRequetsEntity(
      extractionDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      grossWeightGrams: _pesoTotal.toString(),
      purityPercent: _pureza.toString(),
      observations: _observacionesController.text,
      evidencia: _selectedImage!.path,
    );

    context.read<TreasuryBloc>().add(
      NewExtractionEvent(newExtractionRequets: formData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => context.router.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Nueva Extracción',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<TreasuryBloc, TreasuryState>(
          listener: (context, state) {
            if (state is NewExtractionLoaded) {
              showExtractionSuccessDialog(
                context: context,
                loteId: state.newExtraction.batchCode,
                pesoGramos: _pesoTotal.toString(),
                message: state.newExtraction.message,
              );
            } else if (state is NewExtractionError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is NewExtractionLoading;
        
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalendar(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildPesoField()),
                                const SizedBox(width: 14),
                                Expanded(child: _buildPurezaField()),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildOroPuroInfo(),
                            const SizedBox(height: 24),
                            _buildEvidenciaSection(),
                            const SizedBox(height: 24),
                            _buildObservaciones(),
                            const SizedBox(height: 28),
                            _buildSubmitButton(isLoading),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.1),
                    child: const Center(
                      child: ExcavatorLoader(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final monthName = DateFormat('MMMM yyyy', 'es').format(_displayedMonth);
    final capitalizedMonth =
        '${monthName[0].toUpperCase()}${monthName.substring(1)}';

    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final prevMonthDays = DateTime(year, month, 0).day;

    final dayLabels = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
    final cells = <CalendarCell>[];

    for (int i = startWeekday - 1; i >= 0; i--) {
      final day = prevMonthDays - i;
      cells.add(
        CalendarCell(
          day: day,
          date: DateTime(year, month - 1, day),
          isCurrentMonth: false,
        ),
      );
    }

    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(
        CalendarCell(
          day: d,
          date: DateTime(year, month, d),
          isCurrentMonth: true,
        ),
      );
    }

    final remaining = (7 - cells.length % 7) % 7;
    for (int i = 1; i <= remaining; i++) {
      cells.add(
        CalendarCell(
          day: i,
          date: DateTime(year, month + 1, i),
          isCurrentMonth: false,
        ),
      );
    }

    final rows = <List<CalendarCell>>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(cells.sublist(i, i + 7));
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _previousMonth,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 24,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Text(
                capitalizedMonth,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: dayLabels.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          ...rows.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: row.map((cell) {
                  final isSelected = _isSameDay(cell.date, _selectedDate);
                  final isSelectable =
                      cell.isCurrentMonth && _isDaySelectable(cell.date);
                  final isToday = _isSameDay(cell.date, _today);

                  Color textColor;
                  if (!cell.isCurrentMonth) {
                    textColor = const Color(0xFFD1D5DB);
                  } else if (isSelected) {
                    textColor = Colors.white;
                  } else if (!isSelectable) {
                    textColor = const Color(0xFFD1D5DB);
                  } else {
                    textColor = const Color(0xFF1F2937);
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: isSelectable
                          ? () => setState(() => _selectedDate = cell.date)
                          : null,
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${cell.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPesoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Peso Total (g)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _pesoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                final text = newValue.text;
                if (text.isEmpty) return newValue;
                final regex = RegExp(r'^\d*\.?\d{0,2}$');
                return regex.hasMatch(text) ? newValue : oldValue;
              }),
            ],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: InputBorder.none,
              hintText: '0.00',
              hintStyle: TextStyle(color: Color(0xFFD1D5DB)),
              suffixIcon: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.scale_rounded,
                  size: 22,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurezaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pureza (%)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _purezaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: InputBorder.none,
              hintText: '96',
              hintStyle: TextStyle(color: Color(0xFFD1D5DB)),
              suffixIcon: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  '%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              suffixIconConstraints: BoxConstraints(
                minWidth: 40,
                minHeight: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOroPuroInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFF3B82F6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Este lote ingresará '),
                  TextSpan(
                    text: '${_pesoController.text} g',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' de oro puro al inventario basado en el peso y pureza indicados.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenciaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Evidencia Fotográfica ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              TextSpan(
                text: '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: _selectedImage != null
              ? _buildImagePreview()
              : _buildImagePlaceholder(),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFFBFDBFE),
          radius: 14,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_rounded, size: 36, color: Color(0xFF93C5FD)),
            SizedBox(height: 10),
            Text(
              'Subir foto del pesaje',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'JPG, PNG hasta 5MB',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.file(_selectedImage!, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImage = null),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Cambiar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObservaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Observaciones',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            Text(
              'Opcional',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TapRegion(
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              controller: _observacionesController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
                hintText: 'Detalles adicionales sobre la extracción...',
                hintStyle: TextStyle(color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (_isFormValid && !isLoading && !_isSubmitting) ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          disabledBackgroundColor: const Color(0xFFBFDBFE),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Registrar Extracción',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}

class CalendarCell {
  final int day;
  final DateTime date;
  final bool isCurrentMonth;

  const CalendarCell({
    required this.day,
    required this.date,
    required this.isCurrentMonth,
  });
}

void showExtractionSuccessDialog({
  required BuildContext context,
  required String loteId,
  required String pesoGramos,
  required String message,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Cerrar',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    pageBuilder: (context, _, __) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            MediaQuery.of(context).viewPadding.bottom + 24,
          ),
          child: Material(
            color: Colors.transparent,
            child: ExtractionSuccessContent(
              loteId: loteId,
              pesoGramos: pesoGramos,
              message: message,
            ),
          ),
        ),
      );
    },
  );
}
