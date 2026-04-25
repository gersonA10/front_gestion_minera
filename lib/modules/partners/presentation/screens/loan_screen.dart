import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:front_gestion_minera/modules/partners/presentation/widgets/custom_card_widget.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Controllers for form fields
  late TextEditingController _amountController;
  late TextEditingController _reasonController;
  late TextEditingController _applicantController;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? photo = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (photo != null) {
                    setState(() {
                      _image = File(photo.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de galería'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? photo = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (photo != null) {
                    setState(() {
                      _image = File(photo.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _amountController = TextEditingController();
    _reasonController = TextEditingController();
    _applicantController = TextEditingController();
    _tabController.addListener(() {
      setState(() {});
      if (_tabController.index == 0 || _tabController.index == 1) {
        _amountController.clear();
        _reasonController.clear();
        _applicantController.clear();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    _applicantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;
    final colors = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => InjectorContainer.getIt<PartnersBloc>(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: colors.backgroundColor,
        body: BlocConsumer<PartnersBloc, PartnersState>(
          listener: (context, state) {
            if (state is LoanRegisterSuccess) {
              CustomAlert.show(
                context,
                title: 'Éxito',
                message: 'La solicitud se ha registrado correctamente.',
                type: AlertType.success,
              );
              context.router.back();
            } else if (state is LoanRegisterError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is LoanRegisterLoading;
            return Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: topPadding * 0.05,
                          vertical: 14,
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => context.router.back(),
                              icon: const Icon(Icons.arrow_back_ios_new),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "Registrar Préstamo",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                      TabBar(
                        dividerColor: Colors.transparent,
                        controller: _tabController,
                        indicatorColor: colors.blue,
                        labelColor: colors.blue,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: "Dinero"),
                          Tab(text: "Gramos"),
                        ],
                      ),
                     
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: const ScrollBehavior().copyWith(
                            overscroll: false,
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 10,
                              bottom: 20,
                            ),
                            child: IndexedStack(
                              index: _tabController.index,
                              children: [
                                CustomForm(
                                  smallSpacing: smallSpacing,
                                  colors: colors,
                                  image: _image,
                                  onOpenCamera: _pickImage,
                                  title: 'Monto',
                                  amountController: _amountController,
                                  reasonController: _reasonController,
                                  applicantController: _applicantController,
                                ),
                                CustomForm(
                                  smallSpacing: smallSpacing,
                                  colors: colors,
                                  image: _image,
                                  onOpenCamera: _pickImage,
                                  title: 'Gramos',
                                  amountController: _amountController,
                                  reasonController: _reasonController,
                                  applicantController: _applicantController,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  final amount =
                                      double.tryParse(_amountController.text) ??
                                      0.0;
                                  final description = _reasonController.text;
                                  final loanType = _tabController.index == 0
                                      ? 'dinero'
                                      : 'gramos';

                                  final comprobanteImg = _image?.path;

                                  if (amount <= 0) {
                                    CustomAlert.show(
                                      context,
                                      title: 'Error',
                                      message:
                                          'Ingrese ${_tabController.index == 0 ? 'monto' : 'cantidad'}',
                                      type: AlertType.warning,
                                    );
                                    return;
                                  }
                                  if (description.isEmpty) {
                                    CustomAlert.show(
                                      context,
                                      title: 'Error',
                                      message: 'Ingrese un  motivo valido.',
                                      type: AlertType.warning,
                                    );
                                    return;
                                  }

                                  if (comprobanteImg == null) {
                                    CustomAlert.show(
                                      context,
                                      title: 'Error',
                                      message: 'Debe agregar un comprobante',
                                      type: AlertType.warning,
                                    );
                                    return;
                                  }
                                  context.read<PartnersBloc>().add(
                                    LoanRegisterEvent(
                                      amount: amount,
                                      description: description,
                                      comprobanteImg: comprobanteImg,
                                      loanType: loanType,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffffc400),
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined),
                              SizedBox(width: 10),
                              Text(
                                "Registrar Préstamo",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black26,
                      child: Center(child: ExcavatorLoader()),
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
