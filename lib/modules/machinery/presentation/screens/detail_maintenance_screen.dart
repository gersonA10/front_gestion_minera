import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/widgets/detail_body_widget.dart';

@RoutePage()
class DetailMaintenanceScreen extends StatelessWidget {
  final String maintenanceId;

  const DetailMaintenanceScreen({super.key, required this.maintenanceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InjectorContainer.getIt<MachineryBloc>()
            ..add(FetchDetailMaintenanceEvent(machineId: maintenanceId)),
      child: const _DetailMaintenanceView(),
    );
  }
}

class _DetailMaintenanceView extends StatelessWidget {
  const _DetailMaintenanceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Mantenimiento')),
      body: BlocBuilder<MachineryBloc, MachineryState>(
        builder: (context, state) {
          if (state is DetailMaintenanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DetailMaintenanceError) {
            return Center(child: Text(state.message));
          }

          if (state is DetailMaintenanceLoaded) {
            return DetailBody(detail: state.detail);
          }

          return const SizedBox();
        },
      ),
    );
  }
}
