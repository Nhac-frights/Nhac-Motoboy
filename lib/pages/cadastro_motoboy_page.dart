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

    final erroCnh = Validators.validarCNH(cnh);
    final erroPlaca = Validators.validarPlaca(placa);
    final formValido = erroCnh == null &&
        erroPlaca == null &&
        cnh.isNotEmpty &&
        placa.isNotEmpty;

    if (erroCnh == _erroCnh &&
        erroPlaca == _erroPlaca &&
        formValido == _formValido) {
      return;
    }

    setState(() {
      _erroCnh = erroCnh;
      _erroPlaca = erroPlaca;
      _formValido = formValido;
    });
  }

  Future<void> _cadastrarEntregador() async {
    if (!_formValido) return;

    final cnh = _cnhController.text.trim();
    final placa = _placaController.text.trim().toUpperCase();
    final tipoVeiculo = _tipoVeiculoSelecionado;
    final entregaProvider = context.read<EntregaProvider>();
    final userProvider = context.read<UserProvider>();

    try {
      setState(() => _isLoading = true);

      await entregaProvider.cadastrarEntregador(
        cnh: cnh,
        placaVeiculo: placa,
        tipoVeiculo: tipoVeiculo,
      );

      if (!mounted) return;

      userProvider.atualizarVeiculo(
        modelo: '',
        placa: placa,
        cor: '',
      );

      // ✅ Mostrar SnackBar ANTES de navegar: ainda estamos no Scaffold
      // desta tela, então o messenger está vivo.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso! Você já pode receber pedidos.'),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // ✅ Navega por último: o SnackBar fica flutuando por cima da nova tela.
      if (mounted) {
        context.go('/home-motoca');
      }
    } catch (e) {
      if (!mounted) return;

      final mensagemErro = e.toString().replaceAll('Exception: ', '');

      // Erro de negócio: já é cadastrado.
      if (mensagemErro.toLowerCase().contains('já possui cadastro')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Você já é entregador. Bem-vindo de volta!'),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
        if (mounted) {
          context.go('/home-motoca');
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagemErro),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF5D201C),
                            ),
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
                              if (valor == null) return;
                              setState(() => _tipoVeiculoSelecionado = valor);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

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
                        inputFormatters: [UpperCaseTextFormatter()],
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

                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.secundaria.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.secundaria.withValues(alpha: 0.3),
                          ),
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

            Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                bottom: 32.h,
                top: 16.h,
              ),
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