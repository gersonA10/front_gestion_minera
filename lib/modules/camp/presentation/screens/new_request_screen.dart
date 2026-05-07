import 'package:auto_route/auto_route.dart';
import 'package:front_gestion_minera/modules/camp/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final montoController = TextEditingController();
  final fechaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    DateTime hoy = DateTime.now();
    fechaController.text = "${hoy.month}/${hoy.day}/${hoy.year}";
  }

  Future<void> _seleccionarFecha() async {
    DateTime hoy = DateTime.now();
    DateTime maxFecha = DateTime(hoy.year, hoy.month + 1, hoy.day);

    final fecha = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: maxFecha,
    );

    if (fecha != null) {
      fechaController.text = "${fecha.month}/${fecha.day}/${fecha.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        title: Text("Nueva Solicitud", style: TextStyle(color: TColors.white)),
        backgroundColor: const Color(0xFF0A1D37),
        leading: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detalles",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Complete la información.",
              style: TextStyle(color: TColors.greyText),
            ),
            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                     CustomTextFormFieldWidget(
                      label: "Título",
                      icon: Icons.campaign_rounded,
                      hint: "Compra de Viveres",
                      controller: tituloController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Ingrese un título";
                        }
                        return null;
                      },
                    ),
                     CustomTextFormFieldWidget(
                      label: "Monto solicitado (Bs)",
                      icon: Icons.money,
                      hint: "0.00",
                      suffixText: "Bs",
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      controller: montoController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Ingrese un monto";
                        }
                        final monto = double.tryParse(value.replaceAll(',', '.'));
                        if (monto == null || monto <= 0) {
                          return "El monto debe ser mayor a 0";
                        }
                        return null;
                      },
                    ),
                     CustomTextFormFieldWidget(
                      label: "Fecha estimada de compra",
                      icon: Icons.calendar_today_rounded,
                      hint: "mm/dd/yyyy",
                      controller: fechaController,
                      readOnly: true,
                      onTap: _seleccionarFecha,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Seleccione una fecha";
                        }
                        return null;
                      },
                    ),
                     CustomTextFormFieldWidget(
                      label: "Descripción o detalle de compra",
                      icon: Icons.description_rounded,
                      hint: "Describa los insumos, herramientas o servicios requeridos para la operación...",
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    "Esta solicitud será revisada por vigilancia.",
                    style: TextStyle(color: TColors.appMainColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  print("Formulario enviado");
                }
              },
              icon: Icon(Icons.send, color: TColors.white,),
              label: Text("Enviar Solicitud", style: TextStyle(color: TColors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E88E5),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
