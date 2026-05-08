import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

@RoutePage()
class RegisterMinutesMemosScreen extends StatefulWidget {
  final int isOption;
  const RegisterMinutesMemosScreen({super.key, required this.isOption});

  @override
  State<RegisterMinutesMemosScreen> createState() =>
      _RegisterMinutesMemosScreenState();
}

class _RegisterMinutesMemosScreenState
    extends State<RegisterMinutesMemosScreen> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  final DateTime _today = DateTime.now();
  late final DateTime _minDate;

  late bool isSelected;
  late int _isOptionSelected;
  List<String> typeRegister = ['Acta', 'Memorando'];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _isOptionSelected = widget.isOption;
    isSelected = widget.isOption == 1;

    _selectedDate = DateTime(_today.year, _today.month, _today.day);
    _displayedMonth = DateTime(_today.year, _today.month);
    _minDate = _selectedDate.subtract(const Duration(days: 5));
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        title: Text(
          'Registrar Documento',
          style: TextStyle(
            color: TColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(15),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'TIPO DE DOCUMENTO',
                  style: TextStyle(
                    color: TColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  decoration: BoxDecoration(
                    color: TColors.appMainDarkColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectOptionRegister(),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Titulo Del Documento',
                  style: TextStyle(
                    color: TColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: isSelected
                        ? 'Ej. Acta de asamblea'
                        : 'Ej. Memorando Interno',
                    hintStyle: TextStyle(color: TColors.textFieldDisabledColor),
                    filled: true,
                    fillColor: TColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Fecha de Emisión',
                  style: TextStyle(
                    color: TColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildCalendar(),
                const SizedBox(height: 10),
                Container(
                  child: isSelected
                      ? Column(
                          crossAxisAlignment: .start,
                          children: [
                            const Text(
                              'Destinatario',
                              style: TextStyle(
                                color: TColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: TColors.white,
                                      hintText: 'Persona a quien se dirige',
                                      hintStyle: TextStyle(
                                        color: TColors.textFieldDisabledColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: .start,
                          children: [
                            const Text(
                              'Ubicación',
                              style: TextStyle(
                                color: TColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: TColors.white,
                                      hintText: 'Lugar de la reunión',
                                      hintStyle: TextStyle(
                                        color: TColors.textFieldDisabledColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Participantes',
                              style: TextStyle(
                                color: TColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: TColors.white,
                                      hintText: 'Nombre del Participante',
                                      hintStyle: TextStyle(
                                        color: TColors.textFieldDisabledColor,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: TColors.appMainDarkColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: TColors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    const Text(
                      'Contenido / Descripción',
                      style: TextStyle(
                        color: TColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            minLines: 4, // Altura mínima inicial
                            maxLines: 6, // Permite que crezca un poco más
                            decoration: InputDecoration(
                              hintText:
                                  'Redacte el contenido del documento aquí...',
                              hintStyle: TextStyle(
                                color: TColors.textFieldDisabledColor,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: TColors.textFieldDisabledColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _showPickerOptions();
              },
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: TColors.appMainDarkColor),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: TColors.appMainDarkColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Subir Foto / PDF',
                      style: TextStyle(
                        color: TColors.appMainDarkColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      //bottomNavigationBar: Container(),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Seleccionar evidencia',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF295AF5),
                ),
                title: const Text('Elegir de la Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Color(0xFF295AF5),
                ),
                title: const Text('Tomar Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.file_present,
                  color: Color(0xFF295AF5),
                ),
                title: const Text('Subir Archivo PDF'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
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

  ListView _selectOptionRegister() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: typeRegister.length,
      itemBuilder: (BuildContext context, int index) {
        final isSelectedbutton = _isOptionSelected == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _isOptionSelected = index;
              if (!isSelectedbutton) {
                isSelected = !isSelected;
              }
            });
          },
          child: AnimatedContainer(
            width: 140,
            margin: EdgeInsets.only(left: 5),
            padding: EdgeInsets.symmetric(horizontal: 30),
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isSelectedbutton
                  ? TColors.appMainDarkColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                typeRegister[index],
                style: TextStyle(
                  color: isSelectedbutton ? TColors.white : TColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
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
