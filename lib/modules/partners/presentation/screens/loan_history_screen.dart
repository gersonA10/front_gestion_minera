import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/loan_histori_entity.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:front_gestion_minera/modules/partners/presentation/widgets/custom_card_widget.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class LoanHistoryScreen extends StatefulWidget {
  const LoanHistoryScreen({super.key});

  @override
  State<LoanHistoryScreen> createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends State<LoanHistoryScreen> {
  late String _activeFilter;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late PartnersBloc _bloc;

  //Guardar en cache
  List<LoanHistoryDataEntity>? _cachedHistory;

  @override
  void initState() {
    super.initState();
    _activeFilter = 'todos';
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String searchText) {
    if (!mounted) return;

    searchText = searchText.trim();

    if (searchText.isEmpty) {
      if (_activeFilter == 'todos') {
        _bloc.add(LoanHistoryRequestEvent());
      } else {
        _bloc.add(LoanHistoryStatustEvent(status: _activeFilter));
      }
    } else {
      _bloc.add(LoanHistorySearchEvent(search: searchText));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;
    final colors = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) {
        _bloc = InjectorContainer.getIt<PartnersBloc>()
          ..add(LoanHistoryRequestEvent());
        return _bloc;
      },
      child: Scaffold(
        backgroundColor: colors.white,
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).colorScheme.white,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.white,
          centerTitle: true,
          title: Text(
            'Historial de Préstamos',
            style: AppTextStyles.mainStyle14Bold(context),
          ),
        ),
        body: BlocBuilder<PartnersBloc, PartnersState>(
          builder: (context, state) {
            bool isLoading =
                state is LoanHistoryLoading ||
                state is LoanHistoryStatusLoading;

            if (state is LoanHistorySuccess) {
              _cachedHistory = state.history;
            } else if (state is LoanHistoryStatusSuccess) {
              _cachedHistory = state.history;
            }

            if (_cachedHistory == null) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is LoanHistoryError || state is LoanHistoryStatusError) {
                final errorMessage = state is LoanHistoryError
                    ? state.message
                    : (state as LoanHistoryStatusError).message;
                return Center(child: Text('Error: $errorMessage'));
              }
              return const SizedBox();
            }

            if (state is LoanHistoryError || state is LoanHistoryStatusError) {
              final errorMessage = state is LoanHistoryError
                  ? state.message
                  : (state as LoanHistoryStatusError).message;
              return Padding(
                padding: EdgeInsets.all(topPadding * 0.05),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search, size: smallSpacing * 1),
                            onPressed: () =>
                                _performSearch(_searchController.text),
                          ),
                          hintText: 'Buscar por motivo',
                          hintStyle: AppTextStyles.mainStyleGrey12(context),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: smallSpacing * 0.5),
                    Row(
                      children: [
                        FilterButton(
                          text: 'Todos',
                          active: _activeFilter == 'todos',
                          onTap: () {
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                            setState(() {
                              _activeFilter = 'todos';
                            });
                            context.read<PartnersBloc>().add(
                              LoanHistoryRequestEvent(),
                            );
                          },
                        ),
                        SizedBox(width: smallSpacing * 1),
                        FilterButton(
                          text: 'Pagado',
                          active: _activeFilter == 'pagado',
                          onTap: () {
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                            setState(() {
                              _activeFilter = 'pagado';
                            });
                            context.read<PartnersBloc>().add(
                              LoanHistoryStatustEvent(status: 'pagado'),
                            );
                          },
                        ),
                        SizedBox(width: smallSpacing * 1),
                        FilterButton(
                          text: 'Pendiente',
                          active: _activeFilter == 'pendiente',
                          onTap: () {
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                            setState(() {
                              _activeFilter = 'pendiente';
                            });
                            context.read<PartnersBloc>().add(
                              LoanHistoryStatustEvent(status: 'pendiente'),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: smallSpacing * 0.5),
                    Expanded(
                      child: Center(child: Text('Error: $errorMessage')),
                    ),
                  ],
                ),
              );
            }

            final loansHistory = _cachedHistory!;

            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(topPadding * 0.05),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search, size: smallSpacing * 1),
                              onPressed: () =>
                                  _performSearch(_searchController.text),
                            ),
                            hintText: 'Buscar por motivo',
                            hintStyle: AppTextStyles.mainStyleGrey12(context),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: smallSpacing * 0.5),

                      // Reemplaza el Row de FilterButton por este bloque:
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            FilterButton(
                              text: 'Todos',
                              active: _activeFilter == 'todos',
                              onTap: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                                setState(() => _activeFilter = 'todos');
                                context.read<PartnersBloc>().add(
                                  LoanHistoryRequestEvent(),
                                );
                              },
                            ),
                            SizedBox(width: smallSpacing * 0.5),
                            FilterButton(
                              text: 'Pendiente',
                              active:
                                  _activeFilter == 'en revisión' ||
                                  _activeFilter == 'pendiente',
                              onTap: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                                setState(() => _activeFilter = 'en revisión');
                                context.read<PartnersBloc>().add(
                                  LoanHistoryStatustEvent(
                                    status: 'en revisión',
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: smallSpacing * 0.5),
                            FilterButton(
                              text: 'Aprobado',
                              active: _activeFilter == 'aprobado',
                              onTap: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                                setState(() => _activeFilter = 'aprobado');
                                context.read<PartnersBloc>().add(
                                  LoanHistoryStatustEvent(status: 'aprobado'),
                                );
                              },
                            ),
                            SizedBox(width: smallSpacing * 0.5),
                            FilterButton(
                              text: 'Rechazado',
                              active: _activeFilter == 'rechazado',
                              onTap: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                                setState(() => _activeFilter = 'rechazado');
                                context.read<PartnersBloc>().add(
                                  LoanHistoryStatustEvent(status: 'rechazado'),
                                );
                              },
                            ),
                            SizedBox(width: smallSpacing * 0.5),
                            FilterButton(
                              text: 'Pagado',
                              active: _activeFilter == 'pagado',
                              onTap: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                                setState(() => _activeFilter = 'pagado');
                                context.read<PartnersBloc>().add(
                                  LoanHistoryStatustEvent(status: 'pagado'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: smallSpacing * 0.5),
                      Expanded(
                        child: ListView.builder(
                          itemCount: loansHistory.length,
                          itemBuilder: (context, index) {
                            final data = loansHistory[index];
                            return LoanCard(
                              small: smallSpacing,
                              date: formatDate((data.createdAt)),
                              reason: data.description,
                              amount: data.amountOrQuantity,
                              status: data.status,
                              motivoRechazo: data.motivoRechazo,
                              loanType: data.loanType,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: const LinearProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  ),
                if (isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: const Color(0xFFF5F5F7).withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
