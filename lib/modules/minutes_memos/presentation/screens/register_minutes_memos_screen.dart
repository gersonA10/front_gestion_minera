import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../widgets/widgets.dart';

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

  List<File> _selectedFiles = [];
  final int _maxFiles = 5;
  final int _maxFileSize = 10 * 1024 * 1024;
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

  List<String> _listParticipants = ['hola', 'hola2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        title: TextTitleCardWidget(title: 'Registrar Documento'),
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

                const TextTitleCardWidget(title: 'Título del Documento'),
                const SizedBox(height: 10),
                !isSelected
                    ? FormEditMinutesMemosWidget(
                        hintTextform: 'Ej. Acta de asamblea',
                        maxLength: 200,
                      )
                    : FormEditMinutesMemosWidget(
                        hintTextform: 'Ej. Memorando Interno',
                        maxLength: 200,
                      ),
                const SizedBox(height: 10),
                const TextTitleCardWidget(title: 'Fecha del Documento'),
                _buildCalendar(),
                const SizedBox(height: 10),
                Container(
                  child: isSelected
                      ? Column(
                          crossAxisAlignment: .start,
                          children: [
                            const TextTitleCardWidget(title: 'Destinatario'),
                            Row(
                              children: [
                                Expanded(
                                  child: FormEditMinutesMemosWidget(
                                    hintTextform: 'Persona a quien se dirige',
                                    maxLength: 150,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: .start,
                          children: [
                            const TextTitleCardWidget(title: 'Ubicación'),
                            Row(
                              children: [
                                Expanded(
                                  child: FormEditMinutesMemosWidget(
                                    hintTextform: 'Lugar la reunión',
                                    maxLength: 150,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const TextTitleCardWidget(title: 'Participantes'),
                            Row(
                              children: [
                                Expanded(
                                  child: FormEditMinutesMemosWidget(
                                    hintTextform: 'Nombre del participante',
                                  ),
                                ),
                                const SizedBox(width: 10),
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
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _listParticipants.isNotEmpty
                                ? Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: _listParticipants.map((
                                      participant,
                                    ) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: TColors.appMainColor,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              Text(
                                                participant,
                                                style: TextStyle(
                                                  color: TColors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              GestureDetector(
                                                child: Container(
                                                  padding: EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    color: TColors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  
                                                  child: Icon(
                                                    Icons
                                                        .delete_forever_outlined,
                                                    color: TColors.white,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  )
                                : SizedBox(),
                          ],
                        ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    const TextTitleCardWidget(title: 'Contenido / Descripción'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            minLines: 4,
                            maxLines: 6,
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
            DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: Radius.circular(15),
                color: TColors.appDisabledColor,
                dashPattern: [6, 3],
                strokeWidth: 1,
                padding: EdgeInsets.zero,
              ),
              child: GestureDetector(
                onTap: () {
                  _showPickerOptions();
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
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
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 60,
                width: .infinity,
                decoration: BoxDecoration(
                  color: TColors.appMainDarkColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: .center,
                  children: [
                    Icon(Icons.send_outlined, color: TColors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Guardar y Enviar',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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

  void _handleFilesSelection(List<File> newFiles) async {
    List<File> validFiles = [];
    for (File file in newFiles) {
      if (_selectedFiles.length + validFiles.length >= _maxFiles) {
        _showError("Límite máximo de $_maxFiles archivos alcanzado.");
        break;
      }

      int size = await file.length();
      if (size <= _maxFileSize) {
        validFiles.add(file);
      } else {
        _showError("El archivo ${file.path.split('/').last} supera los 10MB.");
      }
    }

    setState(() {
      _selectedFiles.addAll(validFiles);
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        _handleFilesSelection([File(pickedFile.path)]);
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  Future<void> _pickPDF() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        List<File> files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        _handleFilesSelection(files);
      }
    } catch (e) {
      debugPrint("Error al seleccionar archivos: $e");
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
                  _pickPDF();
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
