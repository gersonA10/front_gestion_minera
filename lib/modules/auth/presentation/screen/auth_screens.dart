import 'dart:math' as math;

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

/// Paleta del login: tarjeta blanca sobre un fondo claro a color
/// (azul + dorado de marca) con acentos para que no se vea plano.
class _AuthPalette {
  static const Color blue = Color(0xFF1152D4);
  static const Color blueDeep = Color(0xFF0B3CA0);
  static const Color gold = Color(0xFFEFC805);
  static const Color goldDeep = Color(0xFFCFA227);
  static const Color bgTop = Color(0xFFD7E5FF);
  static const Color bgMid = Color(0xFFEAF0FB);
  static const Color bgBottom = Color(0xFFFBEFD3);
  static const Color field = Color(0xFFF3F6FC);
}

@RoutePage()
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AuthBloc _authBloc;

  /// Controla la entrada escalonada (fade + slide) de los elementos del card.
  late final AnimationController _entryController;

  /// Controla el halo pulsante del logo.
  late final AnimationController _pulseController;

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
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
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
    _entryController.dispose();
    _pulseController.dispose();
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

  void _submitForm() {
    FocusScope.of(context).unfocus();
    _loginWithBiometric = false;
    // Usamos la instancia del bloc directamente: el `context` del State está
    // por encima del BlocProvider, así que context.read fallaría aquí.
    _authBloc.add(
      AuthDataEvent(
        username: _userController.text,
        password: _passwordController.text,
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
        backgroundColor: _AuthPalette.bgMid,
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
                // ── Fondo claro a color con orbes azul/dorado ──
                const Positioned.fill(child: _AnimatedBackground()),

                // ── Contenido ──
                Positioned.fill(
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: _LoginCard(
                            width: screenSize.width * 0.9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // ── Logo con halo azul/dorado pulsante ──
                                _StaggerItem(
                                  controller: _entryController,
                                  start: 0.0,
                                  end: 0.45,
                                  scaleFrom: 0.82,
                                  child: _PulsingLogo(pulse: _pulseController),
                                ),
                                SizedBox(height: smallSpacing * 1.5),
                                _StaggerItem(
                                  controller: _entryController,
                                  start: 0.12,
                                  end: 0.55,
                                  child: Text(
                                    'Tigres Dorados',
                                    style: AppTextStyles.mainStyle25Bold(
                                      context,
                                    ),
                                  ),
                                ),
                                SizedBox(height: smallSpacing * 0.6),
                                // Acento dorado bajo el título
                                _StaggerItem(
                                  controller: _entryController,
                                  start: 0.16,
                                  end: 0.58,
                                  child: const _GoldAccentBar(),
                                ),
                                SizedBox(height: smallSpacing * 0.7),
                                _StaggerItem(
                                  controller: _entryController,
                                  start: 0.2,
                                  end: 0.6,
                                  child: Text(
                                    'Acceso al Sistema de Gestión Minera',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.mainStyleGrey12(
                                      context,
                                    ),
                                  ),
                                ),
                                SizedBox(height: smallSpacing * 2),

                                // ── Usuario ──
                                _StaggerItem(
                                  controller: _entryController,
                                  start: 0.3,
                                  end: 0.72,
                                  child: _AnimatedField(
                                    controller: _userController,
                                    label: 'Usuario o Correo',
                                    hint: 'correo',
                                    icon: Icons.person_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    onSubmitted: (_) {},
                                  ),
                                ),
                                SizedBox(height: smallSpacing),

                                // ── Contraseña ──
                                _StaggerItem(
                                  controller: _entryController,
                                  start: 0.38,
                                  end: 0.8,
                                  child: _AnimatedField(
                                    controller: _passwordController,
                                    label: 'Contraseña',
                                    hint: 'Ingrese su contraseña',
                                    icon: Icons.lock_outline,
                                    obscure: _obscurePassword,
                                    onSubmitted: (_) =>
                                        isLoading ? null : _submitForm(),
                                    suffix: IconButton(
                                      splashRadius: 20,
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.lead,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: smallSpacing * 1.6),

                                // ── Botón principal ──
                                _StaggerItem(
                                  controller: _entryController,
                                  start: 0.46,
                                  end: 0.88,
                                  child: _PrimaryButton(
                                    label: 'Iniciar Sesión',
                                    loading: isLoading,
                                    onPressed: isLoading ? null : _submitForm,
                                  ),
                                ),

                                // ── Botón biométrico ──
                                if (_biometricAvailable &&
                                    _biometricEnabled) ...[
                                  SizedBox(height: smallSpacing * 1.6),
                                  _StaggerItem(
                                    controller: _entryController,
                                    start: 0.54,
                                    end: 0.94,
                                    child: const _BiometricDivider(),
                                  ),
                                  SizedBox(height: smallSpacing * 1.6),
                                  _StaggerItem(
                                    controller: _entryController,
                                    start: 0.6,
                                    end: 1.0,
                                    child: _BiometricButton(
                                      isFaceId: _isFaceId,
                                      onTap: isLoading
                                          ? null
                                          : _loginWithBiometrics,
                                    ),
                                  ),
                                ],

                                SizedBox(height: smallSpacing * 2),
                                _StaggerItem(
                                  controller: _entryController,
                                  start: 0.66,
                                  end: 1.0,
                                  slideY: 12,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Desarrollado por XploreMore y Gicager Systems',
                                        style: AppTextStyles.mainStyleGrey10(
                                          context,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        appVersion.isEmpty ? "" : appVersion,
                                        style: AppTextStyles.mainStyleGrey10(
                                          context,
                                        ).copyWith(
                                          fontSize: 10,
                                          letterSpacing: 0.5,
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

// ── Animación de entrada escalonada ─────────────────────────────────────────

/// Aplica fade + slide (y opcionalmente scale) a su [child] dentro de la
/// ventana [start]..[end] del [controller] padre.
class _StaggerItem extends StatelessWidget {
  final AnimationController controller;
  final double start;
  final double end;
  final double slideY;
  final double? scaleFrom;
  final Widget child;

  const _StaggerItem({
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.slideY = 26,
    this.scaleFrom,
  });

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final t = anim.value;
        Widget result = Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * slideY),
            child: child,
          ),
        );
        if (scaleFrom != null) {
          result = Transform.scale(
            scale: scaleFrom! + (1 - scaleFrom!) * t,
            child: result,
          );
        }
        return result;
      },
      child: child,
    );
  }
}

// ── Tarjeta blanca con franja superior a color ──────────────────────────────

class _LoginCard extends StatelessWidget {
  final double width;
  final Widget child;

  const _LoginCard({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: _AuthPalette.blue.withValues(alpha: 0.18),
            blurRadius: 44,
            spreadRadius: -10,
            offset: const Offset(0, 24),
          ),
          BoxShadow(
            color: _AuthPalette.gold.withValues(alpha: 0.10),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Franja de color que enmarca la cabecera
            Container(
              height: 6,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _AuthPalette.blue,
                    _AuthPalette.gold,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 34,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pequeña barra de acento con degradado dorado bajo el título.
class _GoldAccentBar extends StatelessWidget {
  const _GoldAccentBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 4,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_AuthPalette.gold, _AuthPalette.goldDeep],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ── Fondo animado claro con orbes ───────────────────────────────────────────

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 * math.pi;
        return Stack(
          children: [
            // Base con degradado diagonal azul → crema (claro pero a color)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _AuthPalette.bgTop,
                      _AuthPalette.bgMid,
                      _AuthPalette.bgBottom,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -100 + math.sin(t) * 24,
              left: -80 + math.cos(t) * 32,
              child: _orb(320, _AuthPalette.blue.withValues(alpha: 0.22)),
            ),
            Positioned(
              bottom: -120 + math.cos(t * 0.9) * 28,
              right: -80 + math.sin(t * 0.9) * 36,
              child: _orb(340, _AuthPalette.gold.withValues(alpha: 0.26)),
            ),
            Positioned(
              bottom: 90 + math.sin(t * 1.3) * 36,
              left: -50 + math.cos(t * 1.3) * 22,
              child: _orb(210, _AuthPalette.blue.withValues(alpha: 0.16)),
            ),
            Positioned(
              top: 130 + math.cos(t * 1.1) * 28,
              right: -40 + math.sin(t * 1.1) * 24,
              child: _orb(180, _AuthPalette.gold.withValues(alpha: 0.16)),
            ),
          ],
        );
      },
    );
  }
}

// ── Logo con halo azul/dorado pulsante ──────────────────────────────────────

class _PulsingLogo extends StatelessWidget {
  final AnimationController pulse;

  const _PulsingLogo({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final glow = 0.16 + pulse.value * 0.22;
        final spread = 1.0 + pulse.value * 7.0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _AuthPalette.field,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _AuthPalette.blue.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _AuthPalette.blue.withValues(alpha: glow),
                blurRadius: 26,
                spreadRadius: spread,
                offset: const Offset(-3, 0),
              ),
              BoxShadow(
                color: _AuthPalette.gold.withValues(alpha: glow),
                blurRadius: 26,
                spreadRadius: spread,
                offset: const Offset(3, 0),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Image.asset(height: 104, AssetImageApp.getLogoApp),
    );
  }
}

// ── Campo de texto con foco animado ─────────────────────────────────────────

class _AnimatedField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const _AnimatedField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  State<_AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<_AnimatedField> {
  final FocusNode _node = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(() {
      if (mounted) setState(() => _focused = _node.hasFocus);
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = _AuthPalette.blue;
    final iconColor = _focused ? accent : Theme.of(context).colorScheme.lead;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            widget.label,
            style: AppTextStyles.mainStyle12Bold(context),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _focused ? Colors.white : _AuthPalette.field,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _focused ? accent : Colors.transparent,
              width: 1.6,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _node,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscure,
            textCapitalization: TextCapitalization.none,
            onFieldSubmitted: widget.onSubmitted,
            cursorColor: accent,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.mainStyle12(context).copyWith(
                color: Theme.of(context).colorScheme.lead,
              ),
              prefixIcon: Icon(widget.icon, color: iconColor),
              suffixIcon: widget.suffix,
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Botón principal con glow + press-scale ──────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_AuthPalette.blue, _AuthPalette.blueDeep],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _AuthPalette.blue.withValues(alpha: enabled ? 0.42 : 0),
                blurRadius: _pressed ? 8 : 20,
                spreadRadius: -2,
                offset: Offset(0, _pressed ? 3 : 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.label,
                  style: AppTextStyles.mainStyleWhite14Bold(context),
                ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ──────────────────────────────────────────────────────

class _BiometricDivider extends StatelessWidget {
  const _BiometricDivider();

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

class _BiometricButton extends StatefulWidget {
  final bool isFaceId;
  final VoidCallback? onTap;

  const _BiometricButton({required this.isFaceId, required this.onTap});

  @override
  State<_BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<_BiometricButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    const blue = _AuthPalette.blue;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: blue.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: blue.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isFaceId ? Icons.face_outlined : Icons.fingerprint,
                    size: 24,
                    color: blue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.isFaceId
                      ? 'Acceder con Face ID'
                      : 'Acceder con Huella',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blue,
                  ),
                ),
              ],
            ),
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
