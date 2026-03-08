import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
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

  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
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
                    onPressed: () => Navigator.pop(context),
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// TABS DINERO / GRAMOS
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
                    SizedBox(height: smallSpacing),
                    SizedBox(
                      height: 550,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          CustomForm(
                            smallSpacing: smallSpacing,
                            colors: colors,
                            image: _image,
                            onOpenCamera: _openCamera,
                          ),
                          CustomForm(
                            smallSpacing: smallSpacing,
                            colors: colors,
                            image: _image,
                            onOpenCamera: _openCamera,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xffffc400),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}
