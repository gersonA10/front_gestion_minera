import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController userController = TextEditingController(
    text: 'juan.hacienda@mina.com',
  );
  final TextEditingController passwordController = TextEditingController(
    text: '12345',
  );
  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double smallSpacing = screenSize.height * 0.02;

    return BlocProvider(
      create: (context) => InjectorContainer.getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
               CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            } else if (state is AuthLoading) {
              CustomAlert.show(
                context,
                title: 'Cargando...',
                message: 'Iniciando sesion, por favor espere...',
                type: AlertType.success,
              );
            } else if (state is AuthSuccess) {
              final role = state.data.roleName;

              if (role == 'hacienda') {
                context.router.replaceAll([const TreasuryRoute()]);
              } else if (role == 'socios') {
                context.router.replaceAll([PartnersRoute(nombre: '')]);
              } else if (role == 'vigilancia') {
                context.router.replaceAll([const TreasuryRoute()]);
              }
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  width: screenSize.width * 0.9,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.lead,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.bajo,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.precision_manufacturing,
                          size: 38,
                          color: Theme.of(context).colorScheme.blue,
                        ),
                      ),
                      SizedBox(height: smallSpacing * 1.5),
                      Text(
                        'Gestión Minera',
                        style: AppTextStyles.mainStyle25Bold(context),
                      ),
                      SizedBox(height: smallSpacing * 0.5),
                      Text(
                        'Acceso al Sistema Corporativo',
                        style: AppTextStyles.mainStyleGrey12(context),
                      ),
                      SizedBox(height: smallSpacing * 2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Usuario o Correo',
                          style: AppTextStyles.mainStyle12Bold(context),
                        ),
                      ),
                      SizedBox(height: smallSpacing * 0.5),
                      TextFormField(
                        controller: userController,
                        decoration: InputDecoration(
                          hintText: 'nombre@empresa.com',
                          hintStyle: AppTextStyles.mainStyle12(context),
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.bajo,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: smallSpacing * 0.5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Contraseña',
                          style: AppTextStyles.mainStyle12Bold(context),
                        ),
                      ),
                      SizedBox(height: smallSpacing * 0.5),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Ingrese su contraseña',
                          hintStyle: AppTextStyles.mainStyle12(context),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.bajo,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: smallSpacing * 0.5),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                    AuthDataEvent(
                                      username: userController.text,
                                      password: passwordController.text,
                                    ),
                                  );
                                },
                          child: Text(
                            'Iniciar Sesión',
                            style: AppTextStyles.mainStyleWhite14Bold(context),
                          ),
                        ),
                      ),
                      SizedBox(height: smallSpacing * 2),
                      Text(
                        'Desarrollado por XploreMore y Gicager Systems',
                        style: AppTextStyles.mainStyleGrey10(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
