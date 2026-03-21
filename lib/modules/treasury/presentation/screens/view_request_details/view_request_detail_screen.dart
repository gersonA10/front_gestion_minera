import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entity/entity.dart';
import '../../bloc/treasury_bloc.dart';
import '../../widgets/widgtes.dart';

@RoutePage()
class ViewRequestDetailsScreen extends StatefulWidget {
  final String id;
  final BondBalanceResponseEntity data;
  const ViewRequestDetailsScreen({
    super.key,
    required this.id,
    required this.data,
  });

  @override
  State<ViewRequestDetailsScreen> createState() =>
      _ViewRequestDetailsScreenState();
}

class _ViewRequestDetailsScreenState extends State<ViewRequestDetailsScreen> {
  final TextEditingController _noteController = TextEditingController();

  String? selectedSourceId;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const String baseUrl = 'https://tu-servidor.com';

    return BlocProvider(
      create: (context) =>
          InjectorContainer.getIt<TreasuryBloc>()
            ..add(DetailsofanapplicationEvent(id: widget.id)),
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.router.back(),
          ),
          title: Text(
            'Detalle de Solicitud',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocConsumer<TreasuryBloc, TreasuryState>(
          listener: (context, state) {
            if (state is DashboardDataError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            if (state is DetailsofanapplicationLoading) {
              return  Center(child: CircularProgressIndicator());
            }
            if (state is DetailsofanapplicationSuccess) {
              final data = state.data;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 23),
                      child: Column(
                        children: [
                          Text(
                            data.monto.toString(),
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Aprobado por Administración y Vigilancia',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(title: 'Información General'),
                          WhiteCard(
                            child: Column(
                              children: [
                                _infoRow('Descripción', data.descripcion),
                                Divider(
                                  height: 24,
                                  color: Theme.of(context).colorScheme.alpa,
                                ),
                                _infoRow('Solicitante', data.solicitante),
                                Divider(
                                  height: 24,
                                  color: Theme.of(context).colorScheme.alpa,
                                ),
                                _infoRow(
                                  'Fecha Creación',
                                  data.createdAt.toString(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const SectionTitle(
                            title: 'Historial de Aprobaciones',
                          ),
                          data.flujoAprobacion.isEmpty
                              ? const Text("No hay historial disponible")
                              : WhiteCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: data.flujoAprobacion
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          final index = entry.key;
                                          final res = entry.value;
                                          final isLast =
                                              index ==
                                              data.flujoAprobacion.length - 1;

                                          return _timelineItem(
                                            res.etapa,
                                            'Aprobado por: ${res.aprobador}\n${res.fecha}',
                                            true,
                                            isLast: isLast,
                                          );
                                        })
                                        .toList(),
                                  ),
                                ),
                          const SizedBox(height: 24),
                          const SectionTitle(title: 'Evidencia Adjunta'),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                data.evidenciaUrl.startsWith('http')
                                    ? data.evidenciaUrl
                                    : '$baseUrl${data.evidenciaUrl}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.broken_image,
                                    color: Colors.orange,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const SectionTitle(title: 'Gestión de Pago'),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Origen de Fondos',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: state.cash.data.map((res) {
                                  final isSelected = selectedSourceId == res.id;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedSourceId = res.id;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        child: _sourceOption(
                                          res.nombre,
                                          res.nombre.contains('Chica')
                                              ? Icons.money
                                              : Icons.account_balance,
                                          isSelected,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Nota de Pago (Opcional)',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _noteController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Añadir observaciones sobre el desembolso...',
                                  hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Comprobante de Pago',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildUploadArea(),
                            ],
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
        bottomSheet: _buildBottomActions(),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF1C1C1E),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _timelineItem(
    String title,
    String date,
    bool completed, {
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Icon(
              Icons.check_circle,
              color: completed ? const Color(0xFF295AF5) : Colors.grey,
              size: 18,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: const Color(0xFF295AF5).withValues(alpha: 0.2),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              date,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sourceOption(String title, IconData icon, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF1F4FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? const Color(0xFF295AF5) : Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: selected ? const Color(0xFF295AF5) : Colors.grey, size: 15,),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: selected ? const Color(0xFF295AF5) : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _showPickerOptions,
      child: Container(
        width: double.infinity,
        padding: _selectedImage == null
            ? const EdgeInsets.symmetric(vertical: 30)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF295AF5).withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: _selectedImage != null
            ? Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Botón para eliminar la imagen seleccionada
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 15,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: const [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF295AF5),
                    size: 30,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Subir Evidencia de Desembolso',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Toca para abrir cámara o galería',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F4FF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '✕ Rechazar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF295AF5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '✓ Confirmar Pago',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
