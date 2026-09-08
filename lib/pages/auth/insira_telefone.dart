import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '../../components/botoes/botao_largo_nhac.dart';
import '../../components/nhac_input_field.dart';
import '../../components/seta_voltar.dart';
import '../../controllers/cadastro_controller.dart';
import '../../globals/theme_colors.dart';

class InsiraTelefonePage extends StatefulWidget {
  const InsiraTelefonePage({super.key});

  @override
  State<InsiraTelefonePage> createState() => _InsiraTelefonePageState();
}

class _InsiraTelefonePageState extends State<InsiraTelefonePage> {
  final TextEditingController _telefoneController = TextEditingController();
  bool _numeroValido = false;
  bool _isLoading = false;

  final maskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _telefoneController.dispose();
    super.dispose();
  }

  void _verificarNumero(String valor) {
    final apenasNumeros = maskFormatter.getUnmaskedText();
    setState(() {
      _numeroValido = apenasNumeros.length == 11;
    });
  }

  Future<void> _avancar() async {
    if (!_numeroValido) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _isLoading = false);

    context.read<CadastroController>().setTelefone(_telefoneController.text.trim());
    context.push('/verificacao-numero');
  }

  @override
  Widget build(BuildContext context) {
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
                        'Qual o seu número?',
                        style: AppTextStyles.titulo(),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Enviaremos um código de 6 dígitos por SMS para confirmar o seu número de celular.',
                        style: AppTextStyles.subtitulo(),
                      ),
                      SizedBox(height: 28.h),
                      NhacInputField(
                        controller: _telefoneController,
                        autofocus: true,
                        keyboardType: TextInputType.phone,
                        hintText: '(00) 00000-0000',
                        inputFormatters: [maskFormatter],
                        onChanged: _verificarNumero,
                        onFieldSubmitted: (_) => _avancar(),
                      ),
                    ],
                  ),
                ),
              ),
              BotaoLargoNhac(
                texto: 'Continuar',
                carregando: _isLoading,
                onPressed: _numeroValido ? _avancar : null,
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
