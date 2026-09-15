import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../components/entrega/mapa_rota_widget.dart';
import '../../../controllers/entrega_provider.dart';
import '../../../globals/theme_colors.dart';

class RotaEntregaPage extends StatelessWidget {
  const RotaEntregaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entregaProvider = context.watch<EntregaProvider>();
    final entrega = entregaProvider.entregaAtiva;
    final rota = entregaProvider.rotaAtual;

    if (entrega == null) {
      return Scaffold(
        backgroundColor: AppColors.fundo,
        appBar: AppBar(
          title: const Text('Rota de Entrega'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Nenhuma entrega ativa no momento.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entrega #${entrega.pedidoId.length > 8 ? entrega.pedidoId.substring(0, 8) : entrega.pedidoId}',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.texto,
              ),
            ),
            Text(
              'Em transporte',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12.sp,
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.texto),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mapa com a rota traçada
            if (rota != null)
              MapaRotaWidget(rota: rota)
            else
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaria),
                ),
              ),

            SizedBox(height: 20.h),

            // Card da Coleta (Loja)
            _buildCardInfo(
              titulo: 'Ponto de Retirada (Restaurante)',
              icone: Icons.storefront_rounded,
              iconeCor: AppColors.primaria,
              nome: entrega.lojaNome,
              detalhe: entrega.lojaEndereco,
            ),

            SizedBox(height: 14.h),

            // Card da Entrega (Cliente)
            _buildCardInfo(
              titulo: 'Ponto de Entrega (Cliente)',
              icone: Icons.home_rounded,
              iconeCor: const Color(0xFF2E7D32),
              nome: entrega.clienteNome,
              detalhe: entrega.enderecoEntrega?.formatado ?? 'Endereço não informado',
              telefone: entrega.clienteTelefone,
            ),

            SizedBox(height: 14.h),

            // Card Financeiro da Corrida
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.bordaInativa),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seu ganho no frete:',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12.sp,
                          color: AppColors.desabilitado,
                        ),
                      ),
                      Text(
                        'R\$ ${entrega.taxaFrete.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Pagamento:',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12.sp,
                          color: AppColors.desabilitado,
                        ),
                      ),
                      Text(
                        entrega.formaPagamento,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.texto,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Botão de Concluir Entrega
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
              label: Text(
                'CONCLUIR ENTREGA',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                entregaProvider.concluirEntrega();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entrega concluída com sucesso! Parabéns! 🛵🎉')),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo({
    required String titulo,
    required IconData icone,
    required Color iconeCor,
    required String nome,
    required String detalhe,
    String? telefone,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: iconeCor, size: 18.r),
              SizedBox(width: 8.w),
              Text(
                titulo,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.desabilitado,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            nome,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.texto,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            detalhe,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13.sp,
              color: AppColors.texto.withValues(alpha: 0.7),
            ),
          ),
          if (telefone != null && telefone.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF2E7D32)),
                SizedBox(width: 6.w),
                Text(
                  telefone,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
