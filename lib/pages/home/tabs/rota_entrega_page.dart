import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../components/entrega/mapa_rota_widget.dart';
import '../../../controllers/entrega_provider.dart';
import '../../../globals/theme_colors.dart';

class RotaEntregaPage extends StatefulWidget {
  const RotaEntregaPage({super.key});

  @override
  State<RotaEntregaPage> createState() => _RotaEntregaPageState();
}

class _RotaEntregaPageState extends State<RotaEntregaPage> {
  bool _processando = false;

  /// Confirma a retirada na loja (PREPARANDO -> SAIU_ENTREGA no backend).
  /// Antes desta tela ter dois estados, o motoboy só via "CONCLUIR ENTREGA"
  /// mesmo antes de sair da loja - o pedido nunca era marcado como
  /// efetivamente coletado.
  Future<void> _confirmarRetirada(EntregaProvider provider) async {
    setState(() => _processando = true);
    final sucesso = await provider.confirmarColeta();
    if (!mounted) return;
    setState(() => _processando = false);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retirada confirmada! Pode seguir para o cliente.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível confirmar a retirada. Tente novamente.')),
      );
    }
  }

  /// Dá baixa na entrega (SAIU_ENTREGA -> ENTREGUE). Antes, este botão só
  /// limpava o estado local do app e nunca avisava o backend - o pedido
  /// nunca terminava de verdade e o motoboy ficava travado sem receber
  /// novas ofertas.
  Future<void> _concluirEntrega(EntregaProvider provider) async {
    setState(() => _processando = true);
    final sucesso = await provider.concluirEntregaAtual();
    if (!mounted) return;
    setState(() => _processando = false);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrega concluída com sucesso! Parabéns! 🛵🎉')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível concluir a entrega. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entregaProvider = context.watch<EntregaProvider>();
    final entrega = entregaProvider.entregaAtiva;
    final rota = entregaProvider.rotaAtual;
    final coletada = entregaProvider.entregaColetada;

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
              coletada ? 'Em transporte' : 'A caminho da loja',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12.sp,
                color: coletada ? const Color(0xFF2E7D32) : AppColors.primaria,
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
              destaque: !coletada,
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
              destaque: coletada,
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

            // Botão muda conforme a etapa: primeiro confirmar retirada na
            // loja, só depois concluir a entrega no cliente.
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: coletada ? const Color(0xFF2E7D32) : AppColors.primaria,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
              icon: _processando
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(coletada ? Icons.check_circle_rounded : Icons.storefront_rounded, color: Colors.white),
              label: Text(
                coletada ? 'CONCLUIR ENTREGA' : 'CONFIRMAR RETIRADA NA LOJA',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              onPressed: _processando
                  ? null
                  : () => coletada ? _concluirEntrega(entregaProvider) : _confirmarRetirada(entregaProvider),
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
    bool destaque = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: destaque ? Border.all(color: iconeCor, width: 1.5.w) : null,
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
