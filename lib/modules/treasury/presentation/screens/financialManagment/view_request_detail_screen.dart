import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/zoomable_evidence_image.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import '../../bloc/treasury_bloc.dart';
import '../../widgets/widgtes.dart';

String _money(num v) => 'Bs ${NumberFormat('#,##0.00', 'en_US').format(v)}';
String _moneyStr(String v) => _money(double.tryParse(v) ?? 0);

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
                  color: Color(0xFF1A56FF),
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
                  color: Color(0xFF1A56FF),
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
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0D1B3E), size: 20),
              onPressed: () => context.router.back(),
            ),
            title: const Text(
              'Detalle de solicitud',
              style: TextStyle(
                color: Color(0xFF0D1B3E),
                fontWeight: FontWeight.w800,
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
                return const StaffLoader();
              }
              if (state is DetailsofanapplicationSuccess) {
                final data = state.data;
                final cajaMatches =
                    state.cash.data.where((c) => c.id == selectedSourceId);
                final cajaSel = cajaMatches.isEmpty ? null : cajaMatches.first;
                final evidencia = data.evidenciaUrl ?? '';

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AmountHero(
                        monto: data.monto,
                        solicitante: data.solicitante,
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        descripcion: data.descripcion,
                        fecha: formatDate(data.createdAt.toLocal()),
                      ),
                      if (evidencia.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const _MiniLabel('Evidencia de la solicitud'),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ZoomableEvidenceImage(
                            imageUrl: evidencia.startsWith('http')
                                ? evidencia
                                : '$baseUrl$evidencia',
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _ApprovalsCard(flujo: data.flujoAprobacion),
                      const SizedBox(height: 24),
                      const Text(
                        'Autoriza el pago',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D1B3E),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Completa los pasos para desembolsar.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7A99),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _StepCard(
                        number: 1,
                        title: 'Elige la caja de origen',
                        done: selectedSourceId != null,
                        child: Column(
                          children: [
                            for (final c in state.cash.data)
                              _CajaTile(
                                nombre: c.nombre,
                                saldo: c.saldoDisponible,
                                monto: data.monto,
                                selected: selectedSourceId == c.id,
                                onTap: () =>
                                    setState(() => selectedSourceId = c.id),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _StepCard(
                        number: 2,
                        title: 'Sube el comprobante del pago',
                        done: _selectedImage != null,
                        child: _buildUploadArea(),
                      ),
                      const SizedBox(height: 14),
                      const _MiniLabel('Nota del desembolso (opcional)'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Observaciones sobre el desembolso...',
                          hintStyle: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF6B7A99),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: Color(0xFFE8EDF5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: Color(0xFFE8EDF5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFF1A56FF), width: 1.6),
                          ),
                        ),
                      ),
                      if (cajaSel != null &&
                          cajaSel.saldoDisponible < data.monto) ...[
                        const SizedBox(height: 14),
                        _InsufficientBanner(
                          faltante: data.monto - cajaSel.saldoDisponible,
                        ),
                      ],
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
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              showRejectPaymentDialog(context, data.requestId),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text(
                            'Rechazar',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD32F2F),
                            side: const BorderSide(color: Color(0xFFFFD0D2)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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

                            final caja = state.cash.data
                                .firstWhere((c) => c.id == selectedSourceId);
                            if (caja.saldoDisponible < data.monto) {
                              CustomAlert.show(
                                context,
                                title: 'Fondos insuficientes',
                                message:
                                    'La caja "${caja.nombre}" no tiene saldo suficiente para este pago.',
                                type: AlertType.error,
                              );
                              return;
                            }

                            showConfirmPaymentDialog(
                              parentContext: context,
                              monto: data.monto.toString(),
                              cajaSeleccionada: caja.nombre,
                              saldoActual: caja.saldoDisponible,
                              disponible: caja.saldoDisponible,
                              idCash: selectedSourceId ?? '',
                              idPayment: data.requestId,
                              comprobante: _selectedImage!,
                              notaPago: _noteController.text,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A56FF),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Confirmar pago',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
                // Cerramos solo el diálogo y nos quedamos en el detalle para
                // que Hacienda pueda corregir y reintentar (p. ej. fondos).
                Navigator.of(dialogContext).pop();

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
                              padding: const EdgeInsets.only(left: 20, right: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Confirmar desembolso',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF0D1B3E),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF6B7A99),
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () =>
                                              Navigator.of(dialogContext).pop(),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE8EDF5)),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF1A56FF), Color(0xFF0B33B8)],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1A56FF)
                                        .withValues(alpha: 0.28),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.payments_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Vas a desembolsar',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _moneyStr(monto),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 30,
                                      color: Colors.white,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                ],
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
                                    _moneyStr(monto),
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
                                    _money(disponible),
                                  ),
                                  const Divider(height: 24),
                                  _buildDialogRow(
                                    'Saldo final estimado',
                                    _money(saldoFinal),
                                    color: saldoFinal < 0
                                        ? const Color(0xFFD32F2F)
                                        : const Color(0xFF1A56FF),
                                    isBold: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7E6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFC47A00)
                                      .withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFFC47A00),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Esta acción no se puede deshacer.',
                                      style: TextStyle(
                                        color: Color(0xFFC47A00),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                      ),
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
                                      backgroundColor: const Color(0xFF1A56FF),
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
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ] else ...[
                                          const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Confirmar pago',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
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
                                        color: Color(0xFF6B7A99),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
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

  Widget _buildUploadArea() {
    final hasImage = _selectedImage != null;
    return GestureDetector(
      onTap: _showPickerOptions,
      child: Container(
        width: double.infinity,
        height: hasImage ? 150 : 128,
        decoration: BoxDecoration(
          color: hasImage
              ? Colors.white
              : const Color(0xFF1A56FF).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasImage
                ? const Color(0xFFE8EDF5)
                : const Color(0xFF1A56FF).withValues(alpha: 0.3),
            width: 1.4,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_selectedImage!, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded,
                      color: Color(0xFF1A56FF), size: 30),
                  SizedBox(height: 10),
                  Text(
                    'Subir comprobante del desembolso',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF0D1B3E),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Cámara o galería',
                    style: TextStyle(color: Color(0xFF6B7A99), fontSize: 11.5),
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
        Text(label,
            style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: color ?? const Color(0xFF0D1B3E),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}

// ─── Widgets del rediseño ────────────────────────────────────────────────────

const _kCardBorder = Color(0xFFE8EDF5);
const _kPrimary = Color(0xFF1A56FF);
const _kTextPrimary = Color(0xFF0D1B3E);
const _kTextSecondary = Color(0xFF6B7A99);
const _kGreen = Color(0xFF17A05D);
const _kRed = Color(0xFFD32F2F);

BoxDecoration _mlCard() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _kCardBorder),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0D1B3E).withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

class _AmountHero extends StatelessWidget {
  final double monto;
  final String solicitante;
  const _AmountHero({required this.monto, required this.solicitante});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kPrimary, Color(0xFF0B33B8)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -24,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded,
                          color: Colors.white, size: 13),
                      SizedBox(width: 5),
                      Text(
                        'Aprobado · Listo para pagar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Total a desembolsar',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _money(monto),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.person_rounded,
                        color: Colors.white.withValues(alpha: 0.85), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Solicita: $solicitante',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String descripcion;
  final String fecha;
  const _InfoCard({required this.descripcion, required this.fecha});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _mlCard(),
      child: Column(
        children: [
          _row(Icons.notes_rounded, 'Motivo', descripcion),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: _kCardBorder),
          ),
          _row(Icons.event_rounded, 'Fecha', fecha),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _kTextSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11.5, color: _kTextSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary)),
              ],
            ),
          ),
        ],
      );
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: _kTextSecondary,
        ),
      );
}

class _ApprovalsCard extends StatelessWidget {
  final List<FlujoAprobacionEntity> flujo;
  const _ApprovalsCard({required this.flujo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _mlCard(),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.fact_check_rounded,
                color: _kGreen, size: 20),
          ),
          title: const Text(
            'Aprobaciones',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _kTextPrimary),
          ),
          subtitle: Text(
            flujo.isEmpty
                ? 'Sin historial'
                : '${flujo.length} ${flujo.length == 1 ? 'etapa aprobada' : 'etapas aprobadas'}',
            style: const TextStyle(fontSize: 11.5, color: _kTextSecondary),
          ),
          children: [
            for (int i = 0; i < flujo.length; i++)
              _approvalRow(flujo[i], i == flujo.length - 1),
          ],
        ),
      ),
    );
  }

  Widget _approvalRow(FlujoAprobacionEntity res, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.check_circle_rounded, color: _kGreen, size: 18),
            if (!isLast)
              Container(
                width: 2,
                height: 26,
                color: _kGreen.withValues(alpha: 0.25),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(res.etapa,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: _kTextPrimary)),
                const SizedBox(height: 1),
                Text('${res.aprobador} · ${formatDate(res.fecha.toLocal())}',
                    style: const TextStyle(
                        color: _kTextSecondary, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final bool done;
  final Widget child;
  const _StepCard({
    required this.number,
    required this.title,
    required this.done,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _mlCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: (done ? _kGreen : _kPrimary).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded, color: _kGreen, size: 16)
                    : Center(
                        child: Text(
                          '$number',
                          style: const TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CajaTile extends StatelessWidget {
  final String nombre;
  final double saldo;
  final double monto;
  final bool selected;
  final VoidCallback onTap;
  const _CajaTile({
    required this.nombre,
    required this.saldo,
    required this.monto,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final insufficient = saldo < monto;
    final restante = saldo - monto;
    final isChica = nombre.toLowerCase().contains('chica');
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? _kPrimary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _kPrimary : _kCardBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    isChica ? Icons.payments_rounded : Icons.account_balance_rounded,
                    color: _kPrimary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre,
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary)),
                      const SizedBox(height: 1),
                      Text('Disponible: ${_money(saldo)}',
                          style: const TextStyle(
                              fontSize: 11.5, color: _kTextSecondary)),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _kPrimary : _kCardBorder,
                      width: 2,
                    ),
                    color: selected ? _kPrimary : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: (insufficient ? _kRed : _kGreen)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      insufficient
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_rounded,
                      size: 15,
                      color: insufficient ? _kRed : _kGreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        insufficient
                            ? 'Fondos insuficientes (faltan ${_money(monto - saldo)})'
                            : 'Saldo tras el pago: ${_money(restante)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: insufficient ? _kRed : _kGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsufficientBanner extends StatelessWidget {
  final double faltante;
  const _InsufficientBanner({required this.faltante});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kRed.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: _kRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'La caja seleccionada no alcanza para este pago (faltan ${_money(faltante)}). Elige otra caja.',
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: _kRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
