import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../components/botoes/botao_largo_nhac.dart';
import '../../../../components/nhac_input_field.dart';
import '../../../../controllers/user_provider.dart';
import '../../../../globals/theme_colors.dart';
import '../../../../globals/ui_utils.dart';

class EditarVeiculoPage extends StatefulWidget {
  const EditarVeiculoPage({super.key});

  @override
  State<EditarVeiculoPage> createState() => _EditarVeiculoPageState();
}

class _EditarVeiculoPageState extends State<EditarVeiculoPage> {
  late final TextEditingController _modeloController;
  late final TextEditingController _placaController;
  late final TextEditingController _corController;

  bool _isLoading = false;
  bool _formValido = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _modeloController = TextEditingController(text: user.veiculoModelo);
    _placaController = TextEditingController(text: user.veiculoPlaca);
    _corController = TextEditingController(text: user.veiculoCor);

    _modeloController.addListener(_validar);
    _placaController.addListener(_validar);
    _corController.addListener(_validar);
    _validar();
  }

  @override
  void dispose() {
    _modeloController.removeListener(_validar);
    _placaController.removeListener(_validar);
    _corController.removeListener(_validar);
    _modeloController.dispose();
    _placaController.dispose();
    _corController.dispose();
    super.dispose();
  }

  void _validar() {
    if (!mounted) return;
    final modelo = _modeloController.text.trim();
    final placa = _placaController.text.trim();

    setState(() {
      _formValido = modelo.isNotEmpty && placa.isNotEmpty;
    });
  }

  Future<void> _salvarVeiculo() async {
    try {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      context.read<UserProvider>().atualizarVeiculo(
            modelo: _modeloController.text.trim(),
            placa: _placaController.text.trim(),
            cor: _corController.text.trim(),
          );

      if (!mounted) return;
      context.showSuccess('Dados do veículo atualizados com sucesso!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: AppColors.fundo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF5D201C), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Text(
                        'Veículo & Moto',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D201C),
                          height: 1.2,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Atualize os dados da sua motocicleta para identificação nos estabelecimentos e nas entregas.',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade800,
                          height: 1.5,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        'Modelo da Moto',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      NhacInputField(
                        controller: _modeloController,
                        textCapitalization: TextCapitalization.words,
                        hintText: 'Ex: Honda CG 160 Fan',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Placa da Moto',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      NhacInputField(
                        controller: _placaController,
                        textCapitalization: TextCapitalization.characters,
                        hintText: 'Ex: ABC-1234 ou BRA2E19',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Cor da Moto',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      NhacInputField(
                        controller: _corController,
                        textCapitalization: TextCapitalization.words,
                        hintText: 'Ex: Vermelha, Preta, Azul',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 32.h, top: 16.h),
              child: BotaoLargoNhac(
                texto: 'Salvar alterações',
                carregando: _isLoading,
                onPressed: _formValido ? _salvarVeiculo : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
