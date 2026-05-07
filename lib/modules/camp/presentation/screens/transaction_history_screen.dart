import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../bloc/camp_bloc.dart';
import '../widgets/widgets.dart';

@RoutePage()
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late final CampBloc _historyBloc;
  final ScrollController _scrollController = ScrollController();

  static const _filters = [
    ('Todos', 'TODOS'),
    ('En Revisión', 'EN_REVISION'),
    ('Pend. Recibo', 'PENDIENTE_RECIBO'),
    ('Completados', 'COMPLETADO'),
    ('Rechazados', 'RECHAZADO'),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _historyBloc = InjectorContainer.getIt<CampBloc>();
    _scrollController.addListener(_onScroll);
    _historyBloc.add(GetCampHistoryEvent(status: _filters[0].$2));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _historyBloc.add(LoadMoreCampHistoryEvent());
    }
  }

  void _onFilterTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _historyBloc.add(GetCampHistoryEvent(status: _filters[index].$2));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _historyBloc,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: TColors.appMainDarkColor,
          titleSpacing: 0,
          toolbarHeight: 90,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: TColors.white),
            onPressed: () => context.router.back(),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historial de Solicitudes',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              Text(
                'Jefe de Campamento',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: List.generate(_filters.length, (index) {
                    final selected = _selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _onFilterTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? TColors.appMainColor
                                : TColors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: selected
                                  ? TColors.appMainColor
                                  : TColors.appDisabledColor,
                            ),
                          ),
                          child: Text(
                            _filters[index].$1,
                            style: TextStyle(
                              color: selected
                                  ? TColors.white
                                  : TColors.appDisabledColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<CampBloc, CampState>(
                  buildWhen: (_, curr) =>
                      curr is CampHistoryLoading ||
                      curr is CampHistoryLoaded ||
                      curr is CampHistoryError,
                  builder: (context, state) {
                    if (state is CampHistoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CampHistoryError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _historyBloc.add(
                                GetCampHistoryEvent(
                                  status: _filters[_selectedIndex].$2,
                                  isRefresh: true,
                                ),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is CampHistoryLoaded) {
                      if (state.items.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay solicitudes registradas',
                            style: TextStyle(
                              color: TColors.appDisabledColor,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => _historyBloc.add(
                          GetCampHistoryEvent(
                            status: _filters[_selectedIndex].$2,
                            isRefresh: true,
                          ),
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 6, bottom: 16),
                          itemCount:
                              state.items.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.items.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return CardRequestDetailWidget(
                              transaction: state.items[index],
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
