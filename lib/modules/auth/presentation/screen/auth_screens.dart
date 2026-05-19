import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/services/biometric_service.dart';
import 'package:front_gestion_minera/core/services/secure_credential_service.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/loadin_overlay.widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:front_gestion_minera/utils/assets.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

@RoutePage()
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AuthBloc _authBloc;
  String appVersion = "";

  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _isFaceId = false;

  /// Distingue si el login actual fue iniciado por biometría o por el formulario.
  bool _loginWithBiometric = false;

  /// Evita lanzar el prompt biométrico más de una vez por ciclo de vida del widget.
  bool _hasAutoTriggered = false;

  /// Evita llamadas concurrentes al prompt biométrico.
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authBloc = InjectorContainer.getIt<AuthBloc>();
    _initBiometric();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      appVersion = "v${info.version}";
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initBiometric() async {
    final available = await BiometricService.isAvailable();
    if (!available) return;

    final enabled = await SecureCredentialService.isBiometricEnabled();
    final types = await BiometricService.getAvailableBiometrics();

    if (!mounted) return;

    setState(() {
      _biometricAvailable = true;
      _biometricEnabled = enabled;
      _isFaceId = types.contains(BiometricType.face);
    });

    // Auto-prompt solo si el usuario ya activó el acceso biométrico
    if (enabled && !_hasAutoTriggered) {
      _hasAutoTriggered = true;
      _loginWithBiometrics();
    }
  }

  Future<void> _loginWithBiometrics() async {
    if (_isAuthenticating) return;
    _isAuthenticating = true;

    try {
      final authenticated = await BiometricService.authenticate();
      if (!authenticated || !mounted) return;

      final credentials = await SecureCredentialService.getCredentials();
      if (credentials == null || !mounted) return;

      _loginWithBiometric = true;
      _authBloc.add(
        AuthDataEvent(
          username: credentials.username,
          password: credentials.password,
        ),
      );
    } finally {
      _isAuthenticating = false;
    }
  }

  void _navigateByRole(String role) {
    if (role == 'hacienda') {
      context.router.replaceAll([const TreasuryRoute()]);
    } else if (role == 'socios') {
      context.router.replaceAll([PartnersRoute(nombre: '')]);
    } else if (role == 'vigilancia') {
      context.router.replaceAll([const HomeSurveillanceRoute()]);
    } else if (role == 'admin') {
      context.router.replaceAll([const AdminHomeRoute()]);
    } else if (role == 'jefe_maquinas') {
      context.router.replaceAll([const HomeMachinaryRoute()]);
    } else if (role == 'jefe_campamento') {
      context.router.replaceAll([const HomeDashboardCampRoute()]);
    } else if (role == 'actas') {
      context.router.replaceAll([const MinutesMemosMainRoute()]);
    } else if (role == 'jefe_personal') {
      context.router.replaceAll([const StaffMainRoute()]);
    }
  }

  //cambiado
  /// Muestra el dialog para activar la huella tras un login exitoso con formulario.
  Future<void> _offerBiometricSetup(String role) async {
    final label = _isFaceId ? 'Face ID' : 'huella dactilar';
    final enable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _isFaceId ? Icons.face_outlined : Icons.fingerprint,
              color: Theme.of(ctx).colorScheme.blue,
            ),
            const SizedBox(width: 10),
            const Text(
              'Acceso rápido',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Deseas usar tu $label para ingresar más rápido en futuros accesos?',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Ahora no',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Activar',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (enable == true) {
      await SecureCredentialService.saveCredentials(
        _userController.text,
        _passwordController.text,
      );
      if (mounted) setState(() => _biometricEnabled = true);
    }

    if (mounted) _navigateByRole(role);
  }

  void _showChangePasswordSheet(BuildContext context, String tempToken) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _authBloc,
        child: _ChangePasswordSheet(
          tempToken: tempToken,
          email: _userController.text,
          onPasswordChanged: (email, newPassword) {
            _loginWithBiometric = true;
            _authBloc.add(
              AuthDataEvent(username: email, password: newPassword),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double smallSpacing = screenSize.height * 0.02;

    return BlocProvider.value(
      value: _authBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthRequirePasswordChange) {
              _showChangePasswordSheet(context, state.tempToken);
            } else if (state is ChangePasswordSuccess) {
              _userController.clear();
              _passwordController.clear();
              final focusScope = FocusScope.of(context);
              Future.delayed(const Duration(milliseconds: 400), () {
                if (mounted) focusScope.unfocus();
              });
              CustomAlert.show(
                context,
                title: 'Contraseña actualizada',
                message:
                    'Tu contraseña fue actualizada correctamente. Por favor, inicia sesión.',
                type: AlertType.success,
              );
            } else if (state is AuthError) {
              // Si falló el login biométrico, limpiamos las credenciales guardadas
              if (_loginWithBiometric) {
                _loginWithBiometric = false;
                SecureCredentialService.clearCredentials();
                setState(() => _biometricEnabled = false);
              }
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            } else if (state is AuthSuccess) {
              final role = state.data.roleName;

              if (_loginWithBiometric) {
                // Login biométrico exitoso → navegar directo
                _loginWithBiometric = false;
                _navigateByRole(role);
              } else {
                // Login con formulario → limpiar credenciales previas (puede ser otro usuario)
                // y ofrecer guardar las nuevas
                SecureCredentialService.clearCredentials();
                setState(() => _biometricEnabled = false);

                if (_biometricAvailable) {
                  _offerBiometricSetup(role);
                } else {
                  _navigateByRole(role);
                }
              }
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Stack(
              children: [
                Center(
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
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.bajo,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset(
                              height: 120,
                              AssetImageApp.getLogoApp,
                            ),
                          ),
                          SizedBox(height: smallSpacing * 1.5),
                          Text(
                            'Tigres Dorados',
                            style: AppTextStyles.mainStyle25Bold(context),
                          ),
                          SizedBox(height: smallSpacing * 0.5),
                          Text(
                            'Acceso al Sistema de Gestión Minera',
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
                            controller: _userController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'correo',
                              hintStyle: AppTextStyles.mainStyle12(context)
                                  .copyWith(
                                    color: Theme.of(context).colorScheme.lead,
                                  ),
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
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Ingrese su contraseña',
                              hintStyle: AppTextStyles.mainStyle12(context)
                                  .copyWith(
                                    color: Theme.of(context).colorScheme.lead,
                                  ),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
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
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      FocusScope.of(context).unfocus();
                                      _loginWithBiometric = false;
                                      context.read<AuthBloc>().add(
                                        AuthDataEvent(
                                          username: _userController.text,
                                          password: _passwordController.text,
                                        ),
                                      );
                                    },
                              child: Text(
                                'Iniciar Sesión',
                                style: AppTextStyles.mainStyleWhite14Bold(
                                  context,
                                ),
                              ),
                            ),
                          ),

                          // ── Botón biométrico ──
                          if (_biometricAvailable && _biometricEnabled) ...[
                            SizedBox(height: smallSpacing * 1.5),
                            _BiometricDivider(),
                            SizedBox(height: smallSpacing * 1.5),
                            _BiometricButton(
                              isFaceId: _isFaceId,
                              onTap: state is AuthLoading
                                  ? null
                                  : _loginWithBiometrics,
                            ),
                          ],

                          SizedBox(height: smallSpacing * 2),
                          Column(
                            children: [
                              Text(
                                'Desarrollado por XploreMore y Gicager Systems',
                                style: AppTextStyles.mainStyleGrey10(context),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appVersion.isEmpty ? "" : appVersion,
                                style: AppTextStyles.mainStyleGrey10(
                                  context,
                                ).copyWith(fontSize: 10, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLoading) const LoginLoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ──────────────────────────────────────────────────────

class _BiometricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'o continúa con',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }
}

class _BiometricButton extends StatelessWidget {
  final bool isFaceId;
  final VoidCallback? onTap;

  const _BiometricButton({required this.isFaceId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.bajo,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFaceId ? Icons.face_outlined : Icons.fingerprint,
                size: 28,
                color: Theme.of(context).colorScheme.blue,
              ),
              const SizedBox(width: 10),
              Text(
                isFaceId ? 'Acceder con Face ID' : 'Acceder con Huella',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Change Password Bottom Sheet ────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  final String tempToken;
  final String email;
  final void Function(String email, String newPassword) onPasswordChanged;

  const _ChangePasswordSheet({
    required this.tempToken,
    required this.email,
    required this.onPasswordChanged,
  });

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      ChangePasswordEvent(
        tempToken: widget.tempToken,
        newPassword: _newPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ChangePasswordError) {
          CustomAlert.show(
            context,
            title: 'Error',
            message: state.message,
            type: AlertType.error,
          );
        } else if (state is ChangePasswordSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Cambiar Contraseña',
                      style: AppTextStyles.mainStyle25Bold(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Es tu primer inicio de sesión. Debes establecer una nueva contraseña para continuar.',
                      style: AppTextStyles.mainStyleGrey12(context),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Nueva Contraseña',
                      style: AppTextStyles.mainStyle12Bold(context),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu nueva contraseña';
                        }
                        if (value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Nueva contraseña',
                        hintStyle: AppTextStyles.mainStyle12(
                          context,
                        ).copyWith(color: Theme.of(context).colorScheme.lead),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.bajo,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Confirmar Contraseña',
                      style: AppTextStyles.mainStyle12Bold(context),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirma tu contraseña';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Repite la contraseña',
                        hintStyle: AppTextStyles.mainStyle12(
                          context,
                        ).copyWith(color: Theme.of(context).colorScheme.lead),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.bajo,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Guardar Contraseña',
                                style: AppTextStyles.mainStyleWhite14Bold(
                                  context,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
