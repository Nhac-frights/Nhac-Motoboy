import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../components/botoes/botao_largo_nhac.dart';
import '../../../../components/nhac_input_field.dart';
import '../../../../controllers/user_provider.dart';
import '../../../../globals/theme_colors.dart';
import '../../../../globals/ui_utils.dart';

class EditarDadosBancariosPage extends StatefulWidget {
  const EditarDadosBancariosPage({super.key});

  @override
  State<EditarDadosBancariosPage> createState() => _EditarDadosBancariosPageState();
}

class _EditarDadosBancariosPageState extends State<EditarDadosBancariosPage> {
  late final TextEditingController _chaveController;
  late String _tipoSelecionado;
  bool _isLoading = false;
  bool _formValido = false;

  final List<String> _tiposChave = ['CPF', 'Celular', 'E-mail', 'Aleatória'];

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _tipoSelecionado = user.tipoChavePix;
    _chaveController = TextEditingController(text: user.chavePix);
    _chaveController.addListener(_validar);
    _validar();
  }

  @override
  void dispose() {
    _chaveController.removeListener(_validar);
    _chaveController.dispose();
    super.dispose();
  }

  void _validar() {
    if (!mounted) return;
    final chave = _chaveController.text.trim();
    setState(() {
      _formValido = chave.isNotEmpty;
    });
  }

  Future<void> _salvarDadosBancarios() async {
    try {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      context.read<UserProvider>().atualizarDadosBancarios(
            tipo: _tipoSelecionado,
            chave: _chaveController.text.trim(),
          );

      if (!mounted) return;
      context.showSuccess('Dados bancários atualizados com sucesso!');
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
                        'Dados Bancários',
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
                        'Configure sua chave PIX para o repasse automático de seus ganhos e taxas de entrega.',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade800,
                          height: 1.5,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        'Tipo de Chave PIX',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        children: _tiposChave.map((tipo) {
                          final isSelected = _tipoSelecionado == tipo;
                          return ChoiceChip(
                            label: Text(
                              tipo,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF5D201C),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaria,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              side: BorderSide(
                                color: isSelected ? AppColors.primaria : const Color(0xFFC9BCBC),
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _tipoSelecionado = tipo;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Chave PIX',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      NhacInputField(
                        controller: _chaveController,
                        hintText: 'Digite sua chave PIX',
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
                onPressed: _formValido ? _salvarDadosBancarios : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
