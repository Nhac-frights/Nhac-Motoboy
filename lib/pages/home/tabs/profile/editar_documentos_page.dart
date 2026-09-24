import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '../../../../components/botoes/botao_largo_nhac.dart';
import '../../../../components/nhac_input_field.dart';
import '../../../../controllers/user_provider.dart';
import '../../../../globals/theme_colors.dart';
import '../../../../globals/ui_utils.dart';
import '../../../../utils/validators.dart';

class EditarDocumentosPage extends StatefulWidget {
  const EditarDocumentosPage({super.key});

  @override
  State<EditarDocumentosPage> createState() => _EditarDocumentosPageState();
}

class _EditarDocumentosPageState extends State<EditarDocumentosPage> {
  late final TextEditingController _cpfController;
  late final TextEditingController _cnhController;
  late final MaskTextInputFormatter _cpfFormatter;
  late final MaskTextInputFormatter _cnhFormatter;

  bool _isLoading = false;
  bool _formValido = false;
  String? _erroCpf;
  String? _erroCnh;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();

    _cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {'#': RegExp(r'[0-9]')},
      initialText: user.cpf,
    );
    _cnhFormatter = MaskTextInputFormatter(
      mask: '###########',
      filter: {'#': RegExp(r'[0-9]')},
      initialText: user.cnh,
    );

    _cpfController = TextEditingController(text: _cpfFormatter.getMaskedText());
    _cnhController = TextEditingController(text: _cnhFormatter.getMaskedText());

    _cpfController.addListener(_validarCampos);
    _cnhController.addListener(_validarCampos);
    _validarCampos();
  }

  @override
  void dispose() {
    _cpfController.removeListener(_validarCampos);
    _cnhController.removeListener(_validarCampos);
    _cpfController.dispose();
    _cnhController.dispose();
    super.dispose();
  }

  void _validarCampos() {
    if (!mounted) return;
    final cpf = _cpfController.text.trim();
    final cnh = _cnhController.text.trim();

    final erroCpfTemp = Validators.validarCPF(cpf);
    String? erroCnhTemp;

    if (cnh.isEmpty) {
      erroCnhTemp = 'CNH obrigatória';
    } else if (cnh.replaceAll(RegExp(r'\D'), '').length != 11) {
      erroCnhTemp = 'A CNH deve ter 11 dígitos';
    }

    setState(() {
      _erroCpf = cpf.isEmpty ? null : erroCpfTemp;
      _erroCnh = cnh.isEmpty ? null : erroCnhTemp;
      _formValido = erroCpfTemp == null &&
          erroCnhTemp == null &&
          cpf.isNotEmpty &&
          cnh.isNotEmpty;
    });
  }

  Future<void> _salvarDocumentos() async {
    try {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      context.read<UserProvider>().atualizarDocumentos(
            cpf: _cpfController.text.trim(),
            cnh: _cnhController.text.trim(),
          );

      if (!mounted) return;
      context.showSuccess('Documentos atualizados com sucesso!');
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
                        'Documentos do Motoboy',
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
                        'Mantenha seu CPF e CNH atualizados para garantir a regularidade do seu cadastro como entregador.',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade800,
                          height: 1.5,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        'CPF',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      NhacInputField(
                        controller: _cpfController,
                        inputFormatters: [_cpfFormatter],
                        keyboardType: TextInputType.number,
                        errorText: _erroCpf,
                        hintText: '000.000.000-00',
                        validator: Validators.validarCPF,
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20.h),
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
                        inputFormatters: [_cnhFormatter],
                        keyboardType: TextInputType.number,
                        errorText: _erroCnh,
                        hintText: '11 dígitos da CNH',
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
                onPressed: _formValido ? _salvarDocumentos : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
