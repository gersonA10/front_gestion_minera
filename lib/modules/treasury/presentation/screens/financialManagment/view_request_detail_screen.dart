import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/zoomable_evidence_image.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entity/entity.dart';
import '../../bloc/treasury_bloc.dart';
import '../../widgets/widgtes.dart';

@RoutePage()
class ViewRequestDetailsScreen extends StatefulWidget {
  final String id;
  const ViewRequestDetailsScreen({super.key, required this.id});

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

    return SafeArea(
      top: false,
      bottom: true,
      child: BlocProvider(
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
              if (state is DetailsofanapplicationError) {
                context.router.back();
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
                return Center(child: CircularProgressIndicator());
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
                            ZoomableEvidenceImage(
                              imageUrl: data.evidenciaUrl.startsWith('http')
                                        ? data.evidenciaUrl
                                        : '$baseUrl${data.evidenciaUrl}',
                              // child: Container(
                              //   width: 80,
                              //   height: 80,
                              //   decoration: BoxDecoration(
                              //     color: Colors.orange.shade100,
                              //     borderRadius: BorderRadius.circular(12),
                              //   ),
                              //   child: ClipRRect(
                              //     borderRadius: BorderRadius.circular(12),
                              //     child: Image.network(
                              //       data.evidenciaUrl.startsWith('http')
                              //           ? data.evidenciaUrl
                              //           : '$baseUrl${data.evidenciaUrl}',
                              //       fit: BoxFit.cover,
                              //       errorBuilder: (context, error, stackTrace) {
                              //         return const Icon(
                              //           Icons.broken_image,
                              //           color: Colors.orange,
                              //         );
                              //       },
                              //     ),
                              //   ),
                              // ),
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
                                    final isSelected =
                                        selectedSourceId == res.id;
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
          bottomSheet: BlocBuilder<TreasuryBloc, TreasuryState>(
            builder: (context, state) {
              if (state is DetailsofanapplicationSuccess) {
                final data = state.data;
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
                          onPressed: () =>
                              showRejectPaymentDialog(context, data.requestId),
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
                          onPressed: () {
                            if (selectedSourceId == null) {
                              CustomAlert.show(
                                context,
                                title: 'Atención',
                                message: 'Selecciona una caja origen',
                                type: AlertType.error,
                              );
                              return;
                            }
                            if (_selectedImage == null) {
                              CustomAlert.show(
                                context,
                                title: 'Error',
                                message: 'Tiene que subir su comprobante',
                                type: AlertType.error,
                              );
                              return;
                            }

                            final cajaNombre = state.cash.data
                                .firstWhere((c) => c.id == selectedSourceId)
                                .nombre;
                            final saldoDisponible = state.cash.data
                                .firstWhere((c) => c.id == selectedSourceId)
                                .saldoDisponible;

                            showConfirmPaymentDialog(
                              parentContext: context,
                              monto: data.monto.toString(),
                              cajaSeleccionada: cajaNombre,
                              saldoActual: saldoDisponible.toDouble(),
                              disponible: saldoDisponible.toDouble(),
                              idCash: selectedSourceId ?? '',
                              idPayment: data.requestId,
                              comprobante: _selectedImage!,
                              notaPago: _noteController.text,
                            );
                          },
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
              return SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void showConfirmPaymentDialog({
    required BuildContext parentContext,
    required String monto,
    required String cajaSeleccionada,
    required double saldoActual,
    required double disponible,
    required String idCash,
    required String notaPago,
    required File comprobante,
    required String idPayment,
  }) {
    final bloc = parentContext.read<TreasuryBloc>();
    final double montoNumerico = double.tryParse(monto) ?? 0.0;
    final double saldoFinal = disponible - montoNumerico;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: BlocConsumer<TreasuryBloc, TreasuryState>(
            listener: (context, state) {
              if (state is ConfirmPaymentLoaded) {
                Navigator.of(dialogContext).pop(); // cerrar diálogo
                parentContext.router.back(); // volver de la pantalla detalle

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CustomAlert.show(
                    parentContext,
                    title: 'Éxito',
                    message: state.confirmPayment.message,
                    type: AlertType.success,
                  );
                });
              }

              if (state is ConfirmPaymentError) {
                Navigator.of(dialogContext).pop(); // cerrar diálogo
                parentContext.router.back(); // volver de la pantalla detalle

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CustomAlert.show(
                    parentContext,
                    title: 'Error',
                    message: state.message,
                    type: AlertType.error,
                  );
                });
              }
            },
            builder: (context, state) {
              final bool isLoading = state is ConfirmPaymentLoading;

              return PopScope(
                canPop: !isLoading,
                child: Stack(
                  children: [
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Confirmar Desembolso',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () =>
                                              Navigator.of(dialogContext).pop(),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F4FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.payments_outlined,
                                color: Color(0xFF295AF5),
                                size: 25,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '¿Estás seguro?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'Estás a punto de autorizar un desembolso significativo.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildDialogRow(
                                    'Monto a desembolsar',
                                    monto,
                                    isBold: true,
                                  ),
                                  const Divider(height: 24),
                                  _buildDialogRow(
                                    'Caja seleccionada',
                                    cajaSeleccionada,
                                  ),
                                  const Divider(height: 24),
                                  _buildDialogRow(
                                    'Saldo actual',
                                    disponible.toString(),
                                  ),
                                  const Divider(height: 24),
                                  _buildDialogRow(
                                    'Saldo final estimado',
                                    '$saldoFinal',
                                    color: const Color(0xFF295AF5),
                                    isBold: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'ESTA ACCIÓN NO SE PUEDE DESHACER',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            final request =
                                                ConfirmPaymentRequetsEntity(
                                                  cajaOrigenId: idCash,
                                                  notaPago: notaPago,
                                                  comprobante: comprobante.path,
                                                );

                                            context.read<TreasuryBloc>().add(
                                              ConfirmPaymentEvent(
                                                idRequest: idPayment,
                                                confirmPaymentRequets: request,
                                              ),
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF295AF5),
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (isLoading) ...[
                                          const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'Procesando...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ] else ...[
                                          const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Confirmar Pago',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () =>
                                              Navigator.of(dialogContext).pop(),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (isLoading)
                      Positioned.fill(
                        child: AbsorbPointer(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showRejectPaymentDialog(BuildContext parentContext, String idCash) {
    final TextEditingController reasonController = TextEditingController();
    final bloc = parentContext.read<TreasuryBloc>();

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: BlocConsumer<TreasuryBloc, TreasuryState>(
            listener: (context, state) {
              if (state is RejectAnApplicationLoaded) {
                Navigator.of(dialogContext).pop(); // cerrar diálogo
                parentContext.router.back(); // volver pantalla detalle

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CustomAlert.show(
                    parentContext,
                    title: 'Éxito',
                    message: 'La solicitud ha sido rechazada.',
                    type: AlertType.success,
                  );
                });
              }

              if (state is RejectAnApplicationError) {
                Navigator.of(dialogContext).pop(); // cerrar diálogo
                parentContext.router.back(); // volver pantalla detalle

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CustomAlert.show(
                    parentContext,
                    title: 'Error',
                    message: state.message,
                    type: AlertType.error,
                  );
                });
              }
            },
            builder: (context, state) {
              final bool isLoading = state is RejectAnApplicationLoading;

              return PopScope(
                canPop: !isLoading,
                child: Stack(
                  children: [
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      insetPadding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Rechazar Solicitud',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.grey,
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : () => Navigator.of(
                                              dialogContext,
                                            ).pop(),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF0F0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '¿Estás seguro?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  'Por favor, indica el motivo del rechazo. Esta información será visible para el solicitante.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: TextField(
                                  controller: reasonController,
                                  maxLines: 4,
                                  maxLength: 250,
                                  enabled: !isLoading,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Ej. Falta documentación de respaldo...',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
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
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              final motivo = reasonController
                                                  .text
                                                  .trim();

                                              if (motivo.isEmpty) {
                                                CustomAlert.show(
                                                  parentContext,
                                                  title: 'Atención',
                                                  message:
                                                      'El motivo del rechazo es obligatorio',
                                                  type: AlertType.error,
                                                );
                                                return;
                                              }

                                              context.read<TreasuryBloc>().add(
                                                RejectAnApplicationEvent(
                                                  reason: motivo,
                                                  idCash: idCash,
                                                ),
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isLoading) ...[
                                            const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'Procesando...',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ] else ...[
                                            const Text(
                                              'Confirmar Rechazo',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () => Navigator.of(
                                              dialogContext,
                                            ).pop(),
                                      style: TextButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isLoading)
                      Positioned.fill(
                        child: AbsorbPointer(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
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
          Icon(
            icon,
            color: selected ? const Color(0xFF295AF5) : Colors.grey,
            size: 15,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: selected ? const Color(0xFF295AF5) : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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

  Widget _buildDialogRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
