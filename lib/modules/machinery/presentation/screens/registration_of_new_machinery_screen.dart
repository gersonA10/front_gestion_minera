import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../widgets/widgets.dart';

@RoutePage()
class RegistrationOfNewMachineryScreen extends StatefulWidget {
  const RegistrationOfNewMachineryScreen({super.key});

  @override
  State<RegistrationOfNewMachineryScreen> createState() =>
      _RegistrationOfNewMachineryScreenState();
}

class _RegistrationOfNewMachineryScreenState
    extends State<RegistrationOfNewMachineryScreen> {
  late final MachineryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<MachineryBloc>()..add(ListTypeMachinery());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.background,
        appBar: AppBar(
          backgroundColor: TColors.white,
          surfaceTintColor: TColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: TColors.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: const BackButton(color: TColors.textPrimary),
          title: const Text(
            'Registrar maquinaria',
            style: TextStyle(
              color: TColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: TColors.border),
          ),
        ),
        body: const RegistrationFormBody(),
      ),
    );
  }
}
