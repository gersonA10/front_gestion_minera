import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/bloc/minutes_memos_bloc.dart';
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
  late final MinutesMemosBloc _blocRegister;

  TextEditingController participantController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController placecontroller = TextEditingController();
  TextEditingController destinataryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final _formTitleKey = GlobalKey<FormState>();
  final _formPlaceKey = GlobalKey<FormState>();
  final _formDescriptionKey = GlobalKey<FormState>();
  final _formDestinataryKey = GlobalKey<FormState>();

  late int type = widget.isOption;
  bool _isUploading = false;
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  final DateTime _today = DateTime.now();
  late final DateTime _minDate;

  late bool isSelected;
  late int _isOptionSelected;
  List<String> typeRegister = ['Acta', 'Memorando'];

  final List<File> _selectedFiles = [];
  final int _maxFiles = 5;
  final int _maxFileSize = 10 * 1024 * 1024;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, String>> _attachmentId = [];

  @override
  void initState() {
    super.initState();
    _isOptionSelected = widget.isOption;
    isSelected = widget.isOption == 1;

    _selectedDate = DateTime(_today.year, _today.month, _today.day);
    _displayedMonth = DateTime(_today.year, _today.month);
    _minDate = _selectedDate.subtract(const Duration(days: 5));
    _blocRegister = InjectorContainer.getIt<MinutesMemosBloc>();
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

  final List<String> _listParticipants = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _blocRegister,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: TColors.white,
          title: TextTitleCardWidget(title: 'Registrar Documento'),
        ),
        body: BlocConsumer<MinutesMemosBloc, MinutesMemosState>(
          listener: (context, state) {
            if (state is CreateMemorandumSucces) {
              _showUploadedSuccessfully(context);
            }
            if (state is CreateMemorandumError) {
              _showError(state.message);
            }
            if (state is CreateActasSucces) {
              _showUploadedSuccessfully(context);
            }
            if (state is CreateActasError) {
              _showError(state.message);
            }
            if (state is UploadFileRecordsSuccess) {
              _attachmentId.add(state.attachmentId);
            }
          },
          builder: (context, state) {
            return Padding(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.appMainDarkColor.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _selectOptionRegister(),
                      ),
                      const SizedBox(height: 10),

                      const TextTitleCardWidget(title: 'Título del Documento'),
                      const SizedBox(height: 10),
                      !isSelected
                          ? Form(
                              key: _formTitleKey,
                              child: FormEditMinutesMemosWidget(
                                controller: titleController,
                                hintTextform: 'Ej. Acta de asamblea',
                                maxLength: 200,
                              ),
                            )
                          : Form(
                              key: _formTitleKey,
                              child: FormEditMinutesMemosWidget(
                                controller: titleController,
                                hintTextform: 'Ej. Memorando Interno',
                                maxLength: 200,
                              ),
                            ),
                      const SizedBox(height: 10),
                      const TextTitleCardWidget(title: 'Fecha del Documento'),
                      _buildCalendar(),
                      const SizedBox(height: 10),
                      Container(
                        child: isSelected
                            ? Form(
                                key: _formDestinataryKey,
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    const TextTitleCardWidget(
                                      title: 'Destinatario',
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FormEditMinutesMemosWidget(
                                            controller: destinataryController,
                                            hintTextform:
                                                'Persona a quien se dirige',
                                            maxLength: 150,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: .start,
                                children: [
                                  const TextTitleCardWidget(title: 'Ubicación'),
                                  Form(
                                    key: _formPlaceKey,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: FormEditMinutesMemosWidget(
                                            controller: placecontroller,
                                            hintTextform: 'Lugar la reunión',
                                            maxLength: 150,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const TextTitleCardWidget(
                                    title: 'Participantes',
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FormEditMinutesMemosWidget(
                                          controller: participantController,
                                          hintTextform:
                                              'Nombre del participante',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          final value = participantController
                                              .text
                                              .trim();

                                          if (value.isEmpty) return;
                                          setState(() {
                                            _listParticipants.add(value);
                                            participantController.clear();
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: TColors.appMainDarkColor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                      ? _listOfParticipantMinutes()
                                      : SizedBox(),
                                ],
                              ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          const TextTitleCardWidget(
                            title: 'Contenido / Descripción',
                          ),
                          const SizedBox(height: 10),
                          Form(
                            key: _formDescriptionKey,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Campo requerido';
                                      }
                                      if (value.trim().length < 20) {
                                        return 'Debe tener al menos 20 caracteres';
                                      }

                                      return null;
                                    },
                                    controller: descriptionController,
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
                  ),
                  const SizedBox(height: 10),
                  _selectedFiles.isNotEmpty ? _buildFilePreview() : SizedBox(),
                  GestureDetector(
                    onTap: isSelected
                        ? (_isUploading ? null : _onSaveAndSendMemorandum)
                        : (_isUploading ? null : _onSaveAndSendActa),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isUploading
                            ? Colors.grey
                            : TColors.appMainDarkColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: _isUploading
                            ? const SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send_outlined,
                                    color: TColors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isSelected
                                        ? 'Guardar y Enviar Memorandum'
                                        : 'Guardar y Enviar Acta',
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<dynamic> _showUploadedSuccessfully(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: TColors.appMainDarkColor,
                size: 90,
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Éxito!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Se subió correctamente',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: TColors.appMainTextColor),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.appMainDarkColor,
                    foregroundColor: TColors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    context.router.popUntil((route) => route.isFirst);
                    setState(() {
                      _isUploading = false;

                      titleController.clear();
                      placecontroller.clear();
                      descriptionController.clear();
                      destinataryController.clear();
                      _listParticipants.clear();
                      _selectedFiles.clear();
                    });
                  },
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Wrap _listOfParticipantMinutes() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,

      children: _listParticipants.map((participant) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

          decoration: BoxDecoration(
            color: Colors.blue,

            borderRadius: BorderRadius.circular(20),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(participant, style: const TextStyle(color: Colors.white)),

              const SizedBox(width: 5),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _listParticipants.remove(participant);
                  });
                },

                child: Container(
                  padding: const EdgeInsets.all(2),

                  decoration: BoxDecoration(
                    color: Colors.red,

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Icon(
                    Icons.delete_forever_outlined,

                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
    final typeDocument = isSelected ? 'MEMORANDO' : 'ACTA';
    for (final file in validFiles) {
      _blocRegister.add(
        UploadFileRecordEvent(
          fileRecord: FileUploadEntity(
            documentType: typeDocument,
            file: file.path,
          ),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.red.shade600,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    return Column(
      children: _selectedFiles.asMap().entries.map((entry) {
        final index = entry.key;
        final file = entry.value;

        final fileName = file.path.split('/').last;

        final isImage = [
          '.jpg',
          '.jpeg',
          '.png',
        ].any((ext) => fileName.toLowerCase().endsWith(ext));
        print(_attachmentId);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: TColors.appDisabledColor.withValues(alpha: 0.5),
            ),
          ),
          child: ListTile(
            leading: isImage
                ? Image.file(file, width: 40, height: 40, fit: BoxFit.cover)
                : const Icon(Icons.picture_as_pdf, color: Colors.red),

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),

                if (index < _attachmentId.length)
                  Text(
                    _attachmentId[index]['nombre'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  )
                else
                  const Text(
                    "pending...",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),

            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _selectedFiles.remove(file);

                  // opcional: mantener sync simple
                  if (index < _attachmentId.length) {
                    _attachmentId.removeAt(index);
                  }
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final XFile? singleFile = await _picker.pickImage(
          source: source,
          imageQuality: 80,
        );
        if (singleFile != null) {
          _handleFilesSelection([File(singleFile.path)]);
        }
      } else {
        final List<XFile> pickedFiles = await _picker.pickMultiImage(
          limit: 5,
          imageQuality: 80,
        );

        if (pickedFiles.isNotEmpty) {
          _handleFilesSelection(
            pickedFiles.map((xfile) => File(xfile.path)).toList(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
      _showError('No se Pudo Accede a la Camara o Galeria');
    }
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.pickFiles(
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
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onSaveAndSendMemorandum() async {
    if (!_formTitleKey.currentState!.validate()) {
      _showError("El titulo es obligatorio.");
      return;
    }
    if (!_formDestinataryKey.currentState!.validate()) {
      _showError("El destinatario es obligatorio para memorandos.");
      return;
    }
    if (!_formDescriptionKey.currentState!.validate()) {
      _showError("Debes agregar la descripcion.");
      return;
    }

    if (_selectedFiles.isEmpty) {
      _showError("Por favor, selecciona al menos un archivo.");
      return;
    }

    setState(() => _isUploading = true);

    final memorandum = CreateMemorandumEntity(
      title: titleController.text,
      contenido: descriptionController.text,
      date: _selectedDate,
      destinatary: destinataryController.text,
      destinataryId: 'a83c6910-154d-4d2b-b58f-97c4b448259b',
      attachmentIds: _selectedFiles.map((file) => file.path).toList(),
    );
    _blocRegister.add(
      SubmitCreateMemorandumEvent(memorandumResponse: memorandum),
    );
  }

  Future<void> _onSaveAndSendActa() async {
    if (!_formTitleKey.currentState!.validate()) {
      _showError("El titulo es obligatorio.");
      return;
    }
    if (!_formPlaceKey.currentState!.validate()) {
      _showError("El lugar es obligatorio para actas.");
      return;
    }
    if (_listParticipants.isEmpty) {
      _showError("Agrega al menos un participante para actas.");
      return;
    }
    if (!_formDescriptionKey.currentState!.validate()) {
      _showError("Debes agregar la descripcion.");
      return;
    }

    if (_selectedFiles.isEmpty) {
      _showError("Por favor, selecciona al menos un archivo.");
      return;
    }
    setState(() => _isUploading = true);

    final acta = CreateActaEntity(
      title: titleController.text,
      description: descriptionController.text,
      date: _selectedDate,
      place: placecontroller.text,
      participants: _listParticipants
          .map(
            (participante) => ParticipantEntity(
              fullName: participante,
              rol: 'rol',
              attendanceStatus: 'PRESENTE',
            ),
          )
          .toList(),
      attachmentIds: _selectedFiles.map((file) => file.path).toList(),
    );

    _blocRegister.add(SubmitCreateActaEvent(actaResponse: acta));
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
              type = index;
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
