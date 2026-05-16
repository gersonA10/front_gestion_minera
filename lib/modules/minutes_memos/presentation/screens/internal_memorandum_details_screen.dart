import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/entity.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

import '../bloc/minutes_memos_bloc.dart';
import '../widgets/widgets.dart';

@RoutePage()
class InternalMemorandumDetailsScreen extends StatefulWidget {
  const InternalMemorandumDetailsScreen({
    super.key,
    required this.memoId,
  });

  final String memoId;

  @override
  State<InternalMemorandumDetailsScreen> createState() =>
      _InternalMemorandumDetailsScreenState();
}

class _InternalMemorandumDetailsScreenState
    extends State<InternalMemorandumDetailsScreen> {
  late MinutesMemosBloc _minutesMemosBloc;

  @override
  void initState() {
    super.initState();

    _minutesMemosBloc = InjectorContainer.getIt<MinutesMemosBloc>()
      ..add(
        GetMemorandumDetailEvent(
          memoId: widget.memoId,
        ),
      );
  }

  @override
  void dispose() {
    _minutesMemosBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _minutesMemosBloc,
      child: Scaffold(
        backgroundColor: TColors.white,
        body: BlocBuilder<MinutesMemosBloc, MinutesMemosState>(
          builder: (context, state) {
            if (state is MemorandumDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is MemorandumDetailError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(
                        color: TColors.appDisabledColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        context.read<MinutesMemosBloc>().add(
                              GetMemorandumDetailEvent(
                                memoId: widget.memoId,
                              ),
                            );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is MemorandumDetailLoaded) {
              final memorandum = state.memorandum;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            alignment: Alignment.centerLeft,
                            style: IconButton.styleFrom(
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: TColors.appMainDarkColor,
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Memorando Interno',
                            style: TextStyle(
                              color: TColors.appMainDarkColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      const Divider(
                        color: Color(0xFFEEEEEE),
                        thickness: 1,
                      ),

                      const SizedBox(height: 28),

                      Text(
                        memorandum.titulo,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: TColors.appMainTextColor,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FECHA DE EMISIÓN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: TColors.appDisabledColor,
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color:
                                      TColors.appMainDarkColor,
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  DateFormat(
                                    'dd \'de\' MMMM, yyyy',
                                    'es',
                                  ).format(
                                    memorandum.fechaEmision,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color:
                                        TColors.appMainTextColor,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              'RESPONSABLE / DESTINATARIO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: TColors.appDisabledColor,
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color:
                                      TColors.appMainDarkColor,
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: Text(
                                    memorandum
                                            .destinatarioNombre
                                            ?.isNotEmpty ==
                                        true
                                        ? memorandum
                                            .destinatarioNombre!
                                        : 'Sin destinatario',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: TColors
                                          .appMainTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 3,
                                height: 21,
                                color: Colors.red,
                              ),

                              const SizedBox(width: 8),

                              const Text(
                                'Descripción del Cambio',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      TColors.appMainDarkColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              maxHeight: 280,
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                memorandum.contenido,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color:
                                      TColors.appDisabledColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(
                        color: Color(0xFFEEEEEE),
                        thickness: 1,
                      ),

                      if (memorandum.attachments.isNotEmpty)
                        AttachmentsSectionWidget(
                          items: memorandum.attachments
                              .map(
                                (
                                  MemorandumAttachmentEntity
                                      attachment,
                                ) {
                                  final tipo =
                                      attachment.tipoArchivo
                                              .contains(
                                    'image',
                                  )
                                          ? 'image'
                                          : 'pdf';

                                  return AttachmentItem(
                                    tipo: tipo,
                                    nombre:
                                        attachment.nombreArchivo,
                                    peso:
                                        attachment.pesoArchivo,
                                  );
                                },
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}