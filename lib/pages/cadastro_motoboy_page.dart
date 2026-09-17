import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/botoes/botao_largo_nhac.dart';
import '../../components/nhac_input_field.dart';
import '../../components/seta_voltar.dart';
import '../../controllers/entrega_provider.dart';
import '../../controllers/user_provider.dart';
import '../../globals/theme_colors.dart';
import '../../globals/ui_utils.dart';
import '../../utils/validators.dart';

class CadastroMotoboyPage extends StatefulWidget {
  const CadastroMotoboyPage({super.key});

  @override
  State<CadastroMotoboyPage> createState() => _CadastroMotoboyPageState();
}

class _CadastroMotoboyPageState extends State<CadastroMotoboyPage> {
  late final TextEditingController _cnhController;
  late final TextEditingController _placaController;
  
  String _tipoVeiculoSelecionado = 'MOTO'; // MOTO | BICICLETA | CARRO
  
  bool _isLoading = false;
  bool _formValido = false;
  String? _erroCnh;
  String? _erroPlaca;

  @override
  void initState() {
    super.initState();
    _cnhController = TextEditingController();
    _placaController = TextEditingController();
    
    _cnhController.addListener(_validarFormulario);
    _placaController.addListener(_validarFormulario);
    _validarFormulario();
  }

  @override
  void dispose() {
    _cnhController.removeListener(_validarFormulario);
    _placaController.removeListener(_validarFormulario);
    _cnhController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  void _validarFormulario() {
    if (!mounted) return;
    
    final cnh = _cnhController.text.trim();
    final placa = _placaController.text.trim();
    
    setState(() {
      _erroCnh = Validators.validarCNH(cnh);
      _erroPlaca = Validators.validarPlaca(placa);
      _formValido = _erroCnh == null && 
                    _erroPlaca == null && 
                    cnh.isNotEmpty && 
                    placa.isNotEmpty;
    });
  }

  Future<void> _cadastrarEntregador() async {
    if (!_formValido) return;

    try {
      setState(() => _isLoading = true);
      
      final entregaProvider = context.read<EntregaProvider>();
      final userProvider = context.read<UserProvider>();
      
      final resultado = await entregaProvider.cadastrarEntregador(
        cnh: _cnhController.text.trim(),
        placaVeiculo: _placaController.text.trim().toUpperCase(),
        tipoVeiculo: _tipoVeiculoSelecionado,
      );

      if (!mounted) return;
      
      // Atualiza o UserProvider com os dados do veículo
      userProvider.atualizarVeiculo(
        modelo: '', // Será preenchido posteriormente
        placa: _placaController.text.trim().toUpperCase(),
        cor: '', // Será preenchido posteriormente
      );

      context.showSuccess('Cadastro realizado com sucesso! Você já pode receber pedidos.');
      context.go('/home-motoca');
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
    return Scaffold(
      backgroundColor: AppColors.fundo,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SetaVoltar(),
                      SizedBox(height: 20.h),
                      Text(
                        'Cadastre-se como entregador',
                        style: AppTextStyles.titulo(),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Informe os dados abaixo para começar a receber pedidos de entrega.',
                        style: AppTextStyles.subtitulo(),
                      ),
                      SizedBox(height: 32.h),
                      
                      // Tipo de Veículo
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
                      SizedBox(height: 24.h),
                      
                      // CNH
                      Text(
                        'Número da CNH',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      NhacInputField(
                        controller: _cnhController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        hintText: 'Digite o número da sua CNH',
                        errorText: _erroCnh,
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      
                      // Placa do Veículo
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
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                        hintText: 'Ex: ABC-1234 ou BRA2E19',
                        errorText: _erroPlaca,
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      
                      // Informações adicionais
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.secundaria.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.secundaria.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 24.r,
                              color: AppColors.secundaria,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Após o cadastro, você poderá atualizar os dados do seu veículo e adicionar mais informações no seu perfil.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade800,
                                  height: 1.4,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Botão de cadastro
            Padding(
              padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 32.h, top: 16.h),
              child: BotaoLargoNhac(
                texto: 'Cadastrar como entregador',
                carregando: _isLoading,
                onPressed: _formValido ? _cadastrarEntregador : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formatter para converter texto para maiúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
