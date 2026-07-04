import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/bloc/minutes_memos_bloc.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/widgets/actas_theme.dart';
import 'package:front_gestion_minera/modules/minutes_memos/presentation/widgets/participants_dialogo_wisget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
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
  final int _maxFiles = 1;
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

  List<SocioEntity> _listParticipants = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _blocRegister,
      child: Scaffold(
        backgroundColor: AC.background,
        appBar: AcGradientAppBar(
          title: 'Registrar Documento',
          subtitle: 'Acta o memorando interno',
        ),
        body: BlocConsumer<MinutesMemosBloc, MinutesMemosState>(
          listener: (context, state) {
            if (state is CreateMemorandumSucces) {
              CustomAlert.show(
                context,
                title: 'Exito',
                message: 'El memorando ha sido creado exitosamente.',
                type: AlertType.success,
              );
              context.router.maybePop(true);
            }
            if (state is CreateMemorandumError) {
              _showError(state.message);
            }
            if (state is CreateActasSucces) {
              CustomAlert.show(
                context,
                title: 'Exito',
                message: 'La acta ha sido creada exitosamente.',
                type: AlertType.success,
              );
              context.router.maybePop(true);
            }
            if (state is CreateActasError) {
              _showError(state.message);
            }
          },
          builder: (context, state) {
            final isLoading =
                state is CreateMemorandumLoading || state is CreateActasLoading;
            return Stack(
              children: [
                Padding(
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
                          _selectOptionRegister(),
                          const SizedBox(height: 10),
                          const TextTitleCardWidget(
                            title: 'Título del Documento',
                          ),
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
                          const TextTitleCardWidget(
                            title: 'Fecha del Documento',
                          ),
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
                                        GestureDetector(
                                          onTap: _showParticipantsDialog,
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AC.primary,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _listParticipants.isEmpty
                                                        ? 'Seleccionar Destinatario'
                                                        : _listParticipants
                                                              .first
                                                              .fullName,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: TColors
                                                          .appMainDarkColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(
                                                  Icons.people_alt_outlined,
                                                  color: AC.primary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _listParticipants.isNotEmpty
                                            ? _listOfParticipantMinutes()
                                            : SizedBox(),
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: .start,
                                    children: [
                                      const TextTitleCardWidget(
                                        title: 'Ubicación',
                                      ),
                                      Form(
                                        key: _formPlaceKey,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: FormEditMinutesMemosWidget(
                                                controller: placecontroller,
                                                hintTextform:
                                                    'Lugar la reunión',
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
                                      GestureDetector(
                                        onTap: _showParticipantsDialog,
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AC.primary,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _listParticipants.isEmpty
                                                    ? 'Seleccionar participantes'
                                                    : '${_listParticipants.length} participante(s) seleccionado(s)',
                                                style: TextStyle(
                                                  color: AC.primary,
                                                ),
                                              ),
                                              Icon(
                                                Icons.people_alt_outlined,
                                                color: AC.primary,
                                              ),
                                            ],
                                          ),
                                        ),
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
                                            color:
                                                TColors.textFieldDisabledColor,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.all(
                                            15,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            borderSide: BorderSide(
                                              color: TColors
                                                  .textFieldDisabledColor,
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
                      if (_selectedFiles.isEmpty)
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
                                    color: AC.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Subir Foto o PDF',
                                    style: TextStyle(
                                      color: AC.primary,
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
                      _selectedFiles.isNotEmpty
                          ? _buildFilePreview()
                          : SizedBox(),
                      GestureDetector(
                        onTap: isSelected
                            ? (_isUploading ? null : _onSaveAndSendMemorandum)
                            : (_isUploading ? null : _onSaveAndSendActa),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AC.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
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
                                  fontSize: 16,
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
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: StaffLoader(),),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showParticipantsDialog() async {
    FocusScope.of(context).unfocus();
    final result = await showDialog<List<SocioEntity>>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _blocRegister,
        child: ParticipantsDialog(
          initialSelected: _listParticipants,
          singleSelect: isSelected,
        ),
      ),
    );
    if (result != null) {
      setState(() => _listParticipants = result);
    }
  }

  Wrap _listOfParticipantMinutes() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,

      children: _listParticipants.map((participant) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AC.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(
                participant.fullName,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _listParticipants.removeWhere(
                      (s) => s.memberId == participant.memberId,
                    );
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
  }

  void _showError(String msg) {
    CustomAlert.show(
      context,
      title: 'Error',
      message: msg,
      type: AlertType.error,
    );
  }

  void _showError1(String msg) {
    CustomAlert.show(
      context,
      title: 'Error',
      message: msg,
      type: AlertType.error,
    );
  }

  Widget _buildFilePreview() {
    return Column(
      children: _selectedFiles.map((file) {
        final fileName = file.path.split('/').last;
        final isImage = [
          '.jpg',
          '.jpeg',
          '.png',
        ].any((ext) => fileName.toLowerCase().endsWith(ext));

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
            title: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _selectedFiles.remove(file);
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
      // Solo se admite un archivo por documento (el backend lo recibe con
      // multer .single), por eso siempre se elige una sola imagen.
      final XFile? singleFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (singleFile != null) {
        _handleFilesSelection([File(singleFile.path)]);
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'No se Pudo Accede a la Camara o Galeria',
        type: AlertType.error,
      );
    }
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.pickFiles(
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
    FocusScope.of(context).unfocus();
    if (!_formTitleKey.currentState!.validate()) {
      _showError1("El titulo es obligatorio.");
      return;
    }
    if (_listParticipants.isEmpty) {
      _showError1("El destinatario es obligatorio para memorandos.");
      return;
    }
    if (!_formDescriptionKey.currentState!.validate()) {
      _showError1("Debes agregar la descripcion.");
      return;
    }

    if (_selectedFiles.isEmpty) {
      _showError1("Por favor, selecciona al menos un archivo.");
      return;
    }
    setState(() => _isUploading = true);
    final memorandum = CreateMemorandumEntity(
      title: titleController.text,
      contenido: descriptionController.text,
      date: _selectedDate,
      destinatary: _listParticipants.first.fullName,
      destinataryId: _listParticipants.first.memberId,
      attachmentIds: _selectedFiles.map((file) => file.path).toList(),
    );
    _blocRegister.add(
      SubmitCreateMemorandumEvent(memorandumResponse: memorandum),
    );
  }

  Future<void> _onSaveAndSendActa() async {
    FocusScope.of(context).unfocus();
    if (!_formTitleKey.currentState!.validate()) {
      _showError1("El titulo es obligatorio.");
      return;
    }
    if (!_formPlaceKey.currentState!.validate()) {
      _showError1("El lugar es obligatorio para actas.");
      return;
    }
    if (_listParticipants.isEmpty) {
      _showError1("Agrega al menos un participante para actas.");
      return;
    }
    if (!_formDescriptionKey.currentState!.validate()) {
      _showError1("Debes agregar la descripcion.");
      return;
    }

    if (_selectedFiles.isEmpty) {
      _showError1("Por favor, selecciona al menos un archivo.");
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
            (socio) => ParticipantEntity(
              memberId: socio.memberId,
              fullName: socio.fullName,
              rol: null,
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
                          color: isSelected ? AC.primary : Colors.transparent,
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

  Widget _selectOptionRegister() {
    final icons = [Icons.article_outlined, Icons.email_outlined];
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(typeRegister.length, (index) {
          final isActive = _isOptionSelected == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isOptionSelected = index;
                  type = index;
                  isSelected = index == 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isActive ? AC.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AC.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icons[index],
                        size: 16,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        typeRegister[index],
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
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
