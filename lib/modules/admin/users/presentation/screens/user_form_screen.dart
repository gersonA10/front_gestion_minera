import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/admin/users/domain/entity/user_entity.dart';
import 'package:front_gestion_minera/modules/admin/users/presentation/bloc/admin_users_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETA (idéntica al management screen para coherencia)
// ─────────────────────────────────────────────────────────────────────────────
class _AppColors {
  static const background    = Color(0xFFF7F8FC);
  static const surface       = Colors.white;
  static const primary       = Color(0xFF2563EB);
  static const primaryLight  = Color(0xFFEFF4FF);
  static const textPrimary   = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const divider       = Color(0xFFE5E7EB);
  static const success       = Color(0xFF10B981);
  static const error         = Color(0xFFEF4444);
  static const amber         = Color(0xFFF59E0B);
}

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA DEL FORMULARIO
// ─────────────────────────────────────────────────────────────────────────────
@RoutePage()
class UserFormScreen extends StatefulWidget {
  final String? userId;
  const UserFormScreen({super.key, this.userId});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _ciController       = TextEditingController();
  final _phoneController    = TextEditingController();

  List<RoleEntity> _availableRoles = [];
  String? _selectedRoleId;
  String? _selectedRoleName;
  bool _isActive        = true;
  bool _obscurePassword = true;
  bool _contentReady    = false;

  bool get _isEditMode => widget.userId != null;
  bool get _isSocio    => _selectedRoleName?.toLowerCase() == 'socios';

  late AdminUsersBloc _adminUsersBloc;

  // Animación general de entrada
  late AnimationController _entryController;
  late Animation<double>   _entryOpacity;
  late Animation<Offset>   _entrySlide;

  @override
  void initState() {
    super.initState();
    _adminUsersBloc = InjectorContainer.getIt<AdminUsersBloc>();
    _adminUsersBloc.add(LoadFormDependenciesEvent(userId: widget.userId));

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryOpacity = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ciController.dispose();
    _phoneController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> userData = {
        'full_name': _nameController.text.trim(),
        'role_id':   _selectedRoleId,
        'role_name': _selectedRoleName,
        'identification': _isSocio ? _ciController.text.trim() : null,
        'phone':          _isSocio ? _phoneController.text.trim() : null,
      };

      if (_isEditMode) {
        userData['is_active'] = _isActive;
        userData['password']  = _passwordController.text;
      } else {
        userData['email']    = _emailController.text.trim();
        userData['password'] = _passwordController.text;
      }

      _adminUsersBloc.add(SaveUserEvent(userData: userData, userId: widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _adminUsersBloc,
      child: BlocConsumer<AdminUsersBloc, AdminUsersState>(
        listener: (context, state) {
          if (state is FormDependenciesLoaded) {
            setState(() {
              _availableRoles = state.roles;
              if (state.userToEdit != null) {
                final u = state.userToEdit!;
                _nameController.text  = u.fullName;
                _emailController.text = u.email;
                _isActive = u.isActive;
                if (_availableRoles.any((r) => r.id == u.roleId)) {
                  _selectedRoleId   = u.roleId;
                  _selectedRoleName = u.roleName;
                }
                if (u.roleName.toLowerCase() == 'socios') {
                  _ciController.text    = u.identification ?? '';
                  _phoneController.text = u.phone ?? '';
                }
              }
              _contentReady = true;
            });
            _entryController.forward();
          } else if (state is UserActionSuccess) {
            CustomAlert.show(
              context,
              title: 'Éxito',
              message: state.message,
              type: AlertType.success,
            );
            _adminUsersBloc.add(GetUsersListEvent(isRefresh: true));
            context.router.back();
          } else if (state is UserActionError) {
            CustomAlert.show(
              context,
              title: 'Error',
              message: state.message,
              type: AlertType.error,
            );
          }
        },
        builder: (context, state) {
          final isSaving = state is UserActionLoading;
          final isLoading = !_contentReady;

          return Scaffold(
            backgroundColor: _AppColors.background,
            appBar: _buildAppBar(context),
            body: Stack(
              children: [
                // ── Skeleton mientras carga ─────────────────────────────────
                if (isLoading) const _FormSkeleton(),

                // ── Contenido del formulario ────────────────────────────────
                if (!isLoading)
                  FadeTransition(
                    opacity: _entryOpacity,
                    child: SlideTransition(
                      position: _entrySlide,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Sección info básica
                              _SectionHeader(
                                icon: Icons.person_outline_rounded,
                                title: 'Información básica',
                              ),
                              const SizedBox(height: 16),

                              // Rol
                              _StyledDropdown(
                                label: 'Rol del usuario',
                                icon: Icons.admin_panel_settings_outlined,
                                value: _selectedRoleId,
                                items: _availableRoles.map((r) {
                                  return DropdownMenuItem(
                                    value: r.id,
                                    child: Text(r.name.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedRoleId   = v;
                                    _selectedRoleName = _availableRoles
                                        .firstWhere((r) => r.id == v)
                                        .name;
                                  });
                                },
                                validator: (v) =>
                                    v == null ? 'Seleccione un rol' : null,
                              ),
                              const SizedBox(height: 14),

                              // Nombre
                              _StyledTextField(
                                controller: _nameController,
                                label: 'Nombre completo',
                                icon: Icons.badge_outlined,
                                validator: (v) =>
                                    v!.isEmpty ? 'Campo requerido' : null,
                              ),
                              const SizedBox(height: 14),

                              // Email (solo creación)
                              if (!_isEditMode) ...[
                                _StyledTextField(
                                  controller: _emailController,
                                  label: 'Correo electrónico',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) =>
                                      v!.contains('@') ? null : 'Correo inválido',
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Contraseña
                              _StyledTextField(
                                controller: _passwordController,
                                label: _isEditMode
                                    ? 'Nueva contraseña (opcional)'
                                    : 'Contraseña',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                validator: (v) {
                                  if (!_isEditMode && v!.isEmpty) return 'Requerida';
                                  if (v!.isNotEmpty && v.length < 6) return 'Mínimo 6 caracteres';
                                  return null;
                                },
                              ),

                              // Estado (solo edición)
                              if (_isEditMode) ...[
                                const SizedBox(height: 20),
                                _StatusToggleRow(
                                  isActive: _isActive,
                                  onChanged: (v) => setState(() => _isActive = v),
                                ),
                              ],

                              // Sección socios
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: _isSocio
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const SizedBox(height: 28),
                                          _SectionHeader(
                                            icon: Icons.card_membership_outlined,
                                            title: 'Datos del socio',
                                          ),
                                          const SizedBox(height: 16),
                                          _StyledTextField(
                                            controller: _ciController,
                                            label: 'Carnet de identidad (CI)',
                                            icon: Icons.fingerprint_rounded,
                                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                                          ),
                                          const SizedBox(height: 14),
                                          _StyledTextField(
                                            controller: _phoneController,
                                            label: 'Teléfono',
                                            icon: Icons.phone_outlined,
                                            keyboardType: TextInputType.phone,
                                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              const SizedBox(height: 36),

                              // Botón guardar
                              _SaveButton(
                                isLoading: isSaving,
                                isEditMode: _isEditMode,
                                onPressed: _saveUser,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Overlay de guardado ─────────────────────────────────────
                if (isSaving)
                  AnimatedOpacity(
                    opacity: isSaving ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      color: Colors.black.withOpacity(0.25),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: _AppColors.primary,
                              strokeWidth: 2.5,
                            ),
                          ),
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
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: _AppColors.textPrimary,
        onPressed: () => context.router.back(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditMode ? 'Editar usuario' : 'Nuevo usuario',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            _isEditMode ? 'Modifica los datos del usuario' : 'Completa el formulario',
            style: const TextStyle(
              fontSize: 12,
              color: _AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: _AppColors.divider),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENCABEZADO DE SECCIÓN
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _AppColors.primary, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _AppColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CAMPO DE TEXTO ESTILIZADO
// ─────────────────────────────────────────────────────────────────────────────
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: _AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _AppColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: _AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.error, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DROPDOWN ESTILIZADO
// ─────────────────────────────────────────────────────────────────────────────
class _StyledDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const _StyledDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _AppColors.textPrimary),
      dropdownColor: _AppColors.surface,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _AppColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: _AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: _AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.error),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROW DE ESTADO (activo / inactivo) — solo modo edición
// ─────────────────────────────────────────────────────────────────────────────
class _StatusToggleRow extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const _StatusToggleRow({required this.isActive, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive
            ? _AppColors.success.withOpacity(0.06)
            : _AppColors.divider.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? _AppColors.success.withOpacity(0.3)
              : _AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
            color: isActive ? _AppColors.success : _AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'Usuario activo' : 'Usuario inactivo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isActive ? _AppColors.success : _AppColors.textSecondary,
                  ),
                ),
                Text(
                  isActive
                      ? 'Puede acceder al sistema'
                      : 'Acceso al sistema deshabilitado',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _AppColors.success,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: _AppColors.divider,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTÓN GUARDAR
// ─────────────────────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final bool isEditMode;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isLoading,
    required this.isEditMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _AppColors.primary.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEditMode ? Icons.save_outlined : Icons.person_add_rounded,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              isEditMode ? 'Guardar cambios' : 'Crear usuario',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON DEL FORMULARIO
// ─────────────────────────────────────────────────────────────────────────────
class _FormSkeleton extends StatefulWidget {
  const _FormSkeleton();

  @override
  State<_FormSkeleton> createState() => _FormSkeletonState();
}

class _FormSkeletonState extends State<_FormSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) {
        final shimmer = Color.lerp(
          const Color(0xFFE5E7EB),
          const Color(0xFFF3F4F6),
          _a.value,
        )!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección header
              Row(
                children: [
                  _Bone(width: 32, height: 32, radius: 8, color: shimmer),
                  const SizedBox(width: 10),
                  _Bone(width: 140, height: 14, radius: 6, color: shimmer),
                ],
              ),
              const SizedBox(height: 18),
              for (int i = 0; i < 4; i++) ...[
                _Bone(width: double.infinity, height: 52, radius: 12, color: shimmer),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 28),
              _Bone(width: double.infinity, height: 52, radius: 14, color: shimmer),
            ],
          ),
        );
      },
    );
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _Bone({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}