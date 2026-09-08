import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../components/botoes/botao_largo_nhac.dart';
import '../../components/seta_voltar.dart';
import '../../controllers/cadastro_controller.dart';
import '../../globals/theme_colors.dart';
import '../../globals/ui_utils.dart';

class VerificacaoNumeroPage extends StatefulWidget {
  const VerificacaoNumeroPage({super.key});

  @override
  State<VerificacaoNumeroPage> createState() => _VerificacaoNumeroPageState();
}

class _VerificacaoNumeroPageState extends State<VerificacaoNumeroPage> {
  final TextEditingController _pinController = TextEditingController();
  int _tempoRestante = 60;
  bool _podeReenviar = false;
  bool _codigoValido = false;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarTimer();
  }

  void _iniciarTimer() {
    setState(() {
      _tempoRestante = 60;
      _podeReenviar = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_tempoRestante > 0) {
        setState(() {
          _tempoRestante--;
        });
      } else {
        setState(() {
          _podeReenviar = true;
        });
        timer.cancel();
      }
    });
  }

  void _reenviarCodigo() {
    if (!_podeReenviar) return;
    _iniciarTimer();
    context.showSuccess('Código reenviado com sucesso via SMS!');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _confirmarCodigo() async {
    if (!_codigoValido) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);

    context.showSuccess('Número verificado com sucesso!');
    context.go('/home-motoca');
  }

  @override
  Widget build(BuildContext context) {
    final telefone = context.watch<CadastroController>().telefone;

    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SetaVoltar(),
                      SizedBox(height: 20.h),
                      Text(
                        'Digite o código',
                        style: AppTextStyles.titulo(),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        telefone.isNotEmpty
                            ? 'Insira o código de 6 dígitos que enviamos para o número $telefone'
                            : 'Insira o código de 6 dígitos que enviamos por SMS.',
                        style: AppTextStyles.subtitulo(),
                      ),
                      SizedBox(height: 32.h),
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        autoFocus: true,
                        cursorColor: AppColors.primaria,
                        textStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.texto,
                        ),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12.r),
                          fieldHeight: 52.h,
                          fieldWidth: 44.w,
                          activeColor: AppColors.primaria,
                          selectedColor: AppColors.primaria,
                          inactiveColor: AppColors.bordaInativa,
                          activeFillColor: Colors.transparent,
                          selectedFillColor: Colors.transparent,
                          inactiveFillColor: Colors.transparent,
                          borderWidth: 1.5,
                        ),
                        enableActiveFill: true,
                        onChanged: (valor) {
                          setState(() {
                            _codigoValido = valor.trim().length == 6;
                          });
                        },
                        onCompleted: (valor) {
                          _confirmarCodigo();
                        },
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: TextButton(
                          onPressed: _podeReenviar ? _reenviarCodigo : null,
                          child: Text(
                            _podeReenviar
                                ? 'Reenviar código por SMS'
                                : 'Reenviar código em 00:${_tempoRestante.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: _podeReenviar
                                  ? AppColors.primaria
                                  : AppColors.desabilitado,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BotaoLargoNhac(
                texto: 'Confirmar',
                carregando: _isLoading,
                onPressed: _codigoValido ? _confirmarCodigo : null,
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
