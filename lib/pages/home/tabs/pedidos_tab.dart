import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../controllers/entrega_provider.dart';
import '../../../globals/theme_colors.dart';
import '../../../models/historico_entrega_model.dart';
import '../../../services/entregador_service.dart';

class PedidosTab extends StatefulWidget {
  const PedidosTab({super.key});

  @override
  State<PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<PedidosTab> {
  final EntregadorService _service = EntregadorService();
  List<HistoricoEntregaModel> _historico = [];
  bool _carregandoHistorico = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() => _carregandoHistorico = true);
    final pagina = await _service.buscarHistorico(status: 'ENTREGUE', size: 15);
    if (!mounted) return;  // ✅ era context.mounted
    setState(() {
      _historico = pagina.itens;
      _carregandoHistorico = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entregaProvider = context.watch<EntregaProvider>();
    final entrega = entregaProvider.entregaAtiva;
    final coletada = entregaProvider.entregaColetada;

    return RefreshIndicator(
      onRefresh: _carregarHistorico,
      color: AppColors.primaria,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 110.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seus Pedidos', style: AppTextStyles.titulo()),
            SizedBox(height: 8.h),
            Text(
              'Acompanhe e gerencie as corridas ativas',
              style: AppTextStyles.subtitulo(),
            ),
            SizedBox(height: 24.h),

            if (entrega != null) ...[
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaria.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: AppColors.primaria.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: coletada ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            coletada ? 'EM TRANSPORTE 🛵' : 'INDO PARA A LOJA 🏪',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: coletada ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                            ),
                          ),
                        ),
                        Text(
                          'R\$ ${entrega.taxaFrete.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      entrega.lojaNome,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.texto,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Entregar para: ${entrega.clienteNome}',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13.sp,
                        color: AppColors.desabilitado,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      entrega.enderecoEntrega?.formatado ?? 'Endereço do cliente',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13.sp,
                        color: AppColors.texto,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        backgroundColor: AppColors.primaria,
                        minimumSize: const Size(double.infinity, 0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      icon: const Icon(Icons.map_rounded, color: Colors.white),
                      label: Text(
                        'VER ROTA NO MAPA',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        context.push('/rota-entrega');
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
            ] else ...[
              SizedBox(height: 12.h),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 56.r,
                      color: AppColors.bordaInativa,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Nenhuma entrega ativa no momento',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.texto,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Fique online na tela inicial para receber pedidos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.sp,
                        color: AppColors.desabilitado,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
            ],

            Text(
              'Histórico recente',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.texto),
            ),
            SizedBox(height: 12.h),
            if (_carregandoHistorico)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(color: AppColors.primaria)),
              )
            else if (_historico.isEmpty)
              Text(
                'Nenhuma entrega concluída ainda.',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 13.sp, color: AppColors.desabilitado),
              )
            else
              ..._historico.map(_buildLinhaHistorico),
          ],
        ),
      ),
    );
  }

  Widget _buildLinhaHistorico(HistoricoEntregaModel item) {
    final data = item.entregueEm ?? item.criadoEm;
    final rotuloData = data != null
        ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}'
        : '';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.lojaNome ?? 'Loja',
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.texto),
                ),
                if (item.bairroEntrega != null)
                  Text(
                    item.bairroEntrega!,
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 12.sp, color: AppColors.desabilitado),
                  ),
                Text(
                  rotuloData,
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 11.sp, color: AppColors.desabilitado),
                ),
              ],
            ),
          ),
          Text(
            'R\$ ${(item.taxaFrete ?? 0).toStringAsFixed(2)}',
            style: TextStyle(fontFamily: 'Roboto', fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }
}