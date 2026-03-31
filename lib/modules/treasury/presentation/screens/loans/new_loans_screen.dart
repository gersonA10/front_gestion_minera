import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
 

 @RoutePage()
class NewLoansScreen extends StatefulWidget {
  const NewLoansScreen({super.key});

  @override
  State<NewLoansScreen> createState() => _NewLoansScreenState();
}

class _NewLoansScreenState extends State<NewLoansScreen> {
  final _prestamista = TextEditingController();
  final _monto = TextEditingController(text: '0.00');
  final _plazo = TextEditingController(text: '12');
  final _tasa = TextEditingController(text: '5.00');
  String _moneda = 'BOB';
  String _tipoInteres = 'Simple';

  late final DateTime _fechaInicio;

  @override
  void initState() {
    super.initState();
    _fechaInicio = DateTime.now();
  }

  String get _fechaFormateada =>
      '${_fechaInicio.month.toString().padLeft(2, '0')}/${_fechaInicio.day.toString().padLeft(2, '0')}/${_fechaInicio.year}';

  // Colors matching the design
  static const _bgColor = Color(0xFF1A1A1A);
  static const _cardColor = Color(0xFF2A2A2A);
  static const _amber = Color(0xFFD4A017);
  static const _amberLight = Color(0x33D4A017);
  static const _textPrimary = Color(0xFFE0E0E0);
  static const _textSecondary = Color(0xFFA0A0A0);
  static const _inputBg = Color(0xFF333333);
  static const _borderColor = Color(0xFF4A4A2A);

  @override
  void dispose() {
    _prestamista.dispose();
    _monto.dispose();
    _plazo.dispose();
    _tasa.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({String? hint, Widget? prefix, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: _inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _amber, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          'Nuevo Préstamo',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _amber.withValues(alpha: 0.3)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.person_outline, 'Detalles del Prestamista'),
            const SizedBox(height: 12),
            _label('Prestamista (Entidad / Persona)'),
            const SizedBox(height: 8),
            TextField(
              controller: _prestamista,
              style: const TextStyle(color: _textPrimary),
              decoration: _inputDecoration(
                hint: 'Ej. Banco Nacional, Juan Pérez',
              ),
            ),
            const SizedBox(height: 28),
            _sectionHeader(Icons.account_balance, 'Condiciones del Préstamo'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Monto Principal'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _monto,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: _textPrimary),
                        decoration: _inputDecoration(
                          prefix: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('\$ ', style: TextStyle(color: _textSecondary)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Moneda'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _moneda,
                            isExpanded: true,
                            dropdownColor: _cardColor,
                            style: const TextStyle(color: _textPrimary, fontSize: 14),
                            icon: const Icon(Icons.keyboard_arrow_down, color: _textSecondary),
                            items: ['BOB']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _moneda = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Plazo (Meses)'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _plazo,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: _textPrimary),
                        decoration: _inputDecoration(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Tasa Anual (%)'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _tasa,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: _textPrimary),
                        decoration: _inputDecoration(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('Fecha de Inicio'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: _textSecondary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _fechaFormateada,
                      style: const TextStyle(color: _textPrimary, fontSize: 14),
                    ),
                  ),
                  const Icon(Icons.lock_outline, color: _textSecondary, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _amberLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _amber.withValues(alpha:  0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _amber.withValues(alpha:  0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.percent, color: _amber, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TIPO DE INTERÉS',
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tipoInteres,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.lock_outline, color: _textSecondary, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _amberLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _amber.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: _amber, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: _textSecondary, fontSize: 13, height: 1.5),
                        children: [
                          TextSpan(text: 'Este préstamo se calcula bajo '),
                          TextSpan(
                            text: 'interés simple',
                            style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
                          ),
                          TextSpan(
                            text: '. El interés se calcula únicamente sobre el capital inicial y no se capitaliza.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                // Simular préstamo
              },
              icon: const Icon(Icons.grid_view_rounded, size: 20),
              label: const Text(
                'Simular Préstamo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: _amber, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(color: _textSecondary, fontSize: 13),
    );
  }
}