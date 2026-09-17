import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../components/botoes/botao_largo_nhac.dart';
import '../../../../components/nhac_input_field.dart';
import '../../../../controllers/entrega_provider.dart';
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
  
  String _tipoVeiculoSelecionado = 'MOTO'; // MOTO | BICICLETA | CARRO

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

  Future<void> _cadastrarEntregador() async {
    try {
      setState(() => _isLoading = true);
      
      final entregaProvider = context.read<EntregaProvider>();
      final resultado = await entregaProvider.cadastrarEntregador(
        cnh: context.read<UserProvider>().cnh,
        placaVeiculo: _placaController.text.trim().toUpperCase(),
        tipoVeiculo: _tipoVeiculoSelecionado,
      );

      if (!mounted) return;
      
      // Atualiza o UserProvider com os dados do veículo
      context.read<UserProvider>().atualizarVeiculo(
            modelo: _modeloController.text.trim(),
            placa: _placaController.text.trim().toUpperCase(),
            cor: _corController.text.trim(),
          );

      context.showSuccess('Cadastro realizado com sucesso! Você já pode receber pedidos.');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      // Trata erro de cadastro duplicado ou outros erros de negócio
      final mensagemErro = e.toString().replaceAll('Exception: ', '');
      context.showError(mensagemErro);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entregaProvider = context.watch<EntregaProvider>();
    final isCadastrado = entregaProvider.isCadastrado;

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: AppColors.fundo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF5D201C), size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isCadastrado ? 'Veículo & Moto' : 'Cadastro de Entregador',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D201C),
            fontFamily: 'Roboto',
          ),
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
                        isCadastrado ? 'Atualize os dados da sua motocicleta' : 'Cadastre-se como entregador',
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
                        isCadastrado
                            ? 'Atualize os dados da sua motocicleta para identificação nos estabelecimentos e nas entregas.'
                            : 'Informe os dados do seu veículo para começar a receber pedidos de entrega.',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade800,
                          height: 1.5,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 28.h),
                      
                      // Seletor de tipo de veículo (apenas para cadastro)
                      if (!isCadastrado) ...[
                        Text(
                          'Tipo de Veículo',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5D201C),
                            fontFamily: 'Roboto',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.bordaInativa),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _tipoVeiculoSelecionado,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5D201C)),
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFF5D201C),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'MOTO', child: Text('Motocicleta')),
                                DropdownMenuItem(value: 'BICICLETA', child: Text('Bicicleta')),
                                DropdownMenuItem(value: 'CARRO', child: Text('Carro')),
                              ],
                              onChanged: (valor) {
                                setState(() {
                                  _tipoVeiculoSelecionado = valor!;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                      
                      Text(
                        'Modelo do Veículo',
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
                        'Placa do Veículo',
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
                        'Cor do Veículo',
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
                texto: isCadastrado ? 'Salvar alterações' : 'Cadastrar como entregador',
                carregando: _isLoading,
                onPressed: _formValido 
                    ? (isCadastrado ? null : _cadastrarEntregador)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
