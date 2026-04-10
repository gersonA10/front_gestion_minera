import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/admin/users/domain/entity/user_entity.dart';
import 'package:front_gestion_minera/modules/admin/users/presentation/bloc/admin_users_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETA
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const bg       = Color(0xFFF7F8FC);
  static const surface  = Color(0xFFFFFFFF);
  static const primary  = Color(0xFF2563EB);
  static const priLight = Color(0xFFEFF4FF);
  static const textHigh = Color(0xFF111827);
  static const textLow  = Color(0xFF9CA3AF);
  static const border   = Color(0xFFE5E7EB);
  static const green    = Color(0xFF10B981);
  static const red      = Color(0xFFEF4444);
  static const amber    = Color(0xFFF59E0B);
}

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA
// ─────────────────────────────────────────────────────────────────────────────
@RoutePage()
class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final _searchController = TextEditingController();
  String _status = 'Todos';

  @override
  void initState() {
    super.initState();
    context.read<AdminUsersBloc>().add(GetUsersListEvent(status: _status));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) => context.read<AdminUsersBloc>().add(
        GetUsersListEvent(search: value, status: _status),
      );

  void _filter(String status) {
    if (_status == status) return;
    setState(() => _status = status);
    context.read<AdminUsersBloc>().add(
      GetUsersListEvent(search: _searchController.text, status: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        appBar: AppBar(
          backgroundColor: _C.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Usuarios',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _C.textHigh,
              letterSpacing: -0.4,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _AddButton(
                onPressed: () => context.router.push(UserFormRoute()),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(97),
            child: Column(
              children: [
                const Divider(height: 1, color: _C.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _SearchBar(
                    controller: _searchController,
                    onSubmitted: _search,
                    onClear: () {
                      _searchController.clear();
                      _search('');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Row(
                    children: ['Todos', 'Activos', 'Inactivos'].map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: s,
                          selected: _status == s,
                          onTap: () => _filter(s),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: BlocConsumer<AdminUsersBloc, AdminUsersState>(
          listener: (ctx, state) {
            if (state is UserActionSuccess) {
              CustomAlert.show(ctx, title: 'Listo', message: state.message, type: AlertType.success);
            } else if (state is UserActionError) {
              CustomAlert.show(ctx, title: 'Error', message: state.message, type: AlertType.error);
            }
          },
          buildWhen: (p, c) =>
              c is UsersLoading || c is UsersLoaded || c is UsersError,
          builder: (ctx, state) {
            if (state is UsersLoading || state is AdminUsersInitial) {
              return const _Skeleton();
            }
            if (state is UsersError) {
              return _ErrorState(message: state.message);
            }
            if (state is UsersLoaded) {
              if (state.users.isEmpty) return const _EmptyState();
              return RefreshIndicator(
                color: _C.primary,
                backgroundColor: _C.surface,
                onRefresh: () async {
                  ctx.read<AdminUsersBloc>().add(GetUsersListEvent(
                    search: _searchController.text,
                    status: _status,
                    isRefresh: true,
                  ));
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: state.users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _UserCard(
                    index: i,
                    user: state.users[i],
                    onTap: () => context.router.push(UserFormRoute(userId: state.users[i].id)),
                    onToggle: () => ctx.read<AdminUsersBloc>().add(
                      ToggleUserStatusEvent(user: state.users[i]),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTÓN AÑADIR (en AppBar)
// ─────────────────────────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _C.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 18),
            SizedBox(width: 4),
            Text(
              'Nuevo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 14, color: _C.textHigh),
        decoration: InputDecoration(
          hintText: 'Buscar...',
          hintStyle: const TextStyle(color: _C.textLow, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _C.textLow, size: 18),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close_rounded, color: _C.textLow, size: 16),
            onPressed: onClear,
          ),
          filled: true,
          fillColor: _C.bg,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHIP DE FILTRO
// ─────────────────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _C.primary : _C.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _C.primary : _C.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _C.textLow,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TARJETA DE USUARIO
// ─────────────────────────────────────────────────────────────────────────────
class _UserCard extends StatefulWidget {
  final int index;
  final UserEntity user;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _UserCard({
    required this.index,
    required this.user,
    required this.onTap,
    required this.onToggle,
  });

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.05),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.index * 40), () {
      if (mounted) _ac.forward();
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  static Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':      return _C.red;
      case 'socios':     return _C.amber;
      case 'hacienda':   return _C.green;
      case 'vigilancia': return _C.primary;
      default:           return _C.textLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = _roleColor(widget.user.roleName);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: _C.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onTap,
            splashColor: _C.priLight,
            highlightColor: _C.priLight.withOpacity(0.4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Avatar
                  _Avatar(
                    name: widget.user.fullName,
                    color: rc,
                    active: widget.user.isActive,
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.fullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _C.textHigh,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.user.email,
                          style: const TextStyle(fontSize: 12, color: _C.textLow),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _Badge(label: widget.user.roleName, color: rc),
                            if (widget.user.roleName.toLowerCase() == 'socios' &&
                                widget.user.identification != null) ...[
                              const SizedBox(width: 6),
                              _Badge(
                                label: 'CI ${widget.user.identification}',
                                color: _C.textLow,
                                outlined: true,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Toggle
                  _Toggle(active: widget.user.isActive, onTap: widget.onToggle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final Color color;
  final bool active;

  const _Avatar({required this.name, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
          ),
        ),
        Positioned(
          bottom: -1,
          right: -1,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: active ? _C.green : _C.textLow,
              shape: BoxShape.circle,
              border: Border.all(color: _C.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;

  const _Badge({required this.label, required this.color, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: outlined ? Border.all(color: _C.border) : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: outlined ? _C.textLow : color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _Toggle({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 40,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: active ? _C.green : _C.border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: active ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
            ),
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatefulWidget {
  const _Skeleton();

  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  late final Animation<double> _a =
      CurvedAnimation(parent: _ac, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) {
        final c =
            Color.lerp(const Color(0xFFEEF0F4), const Color(0xFFF8F9FB), _a.value)!;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: 7,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, __) => Container(
            height: 76,
            decoration:
                BoxDecoration(color: c, borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _C.border),
            ),
            child: const Icon(Icons.inbox_rounded, size: 28, color: _C.textLow),
          ),
          const SizedBox(height: 14),
          const Text(
            'Sin resultados',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _C.textHigh),
          ),
          const SizedBox(height: 4),
          const Text(
            'Prueba con otro filtro o búsqueda',
            style: TextStyle(fontSize: 13, color: _C.textLow),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _C.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 28, color: _C.red),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _C.textLow),
            ),
          ],
        ),
      ),
    );
  }
}