import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../controllers/entrega_provider.dart';
import '../../../globals/theme_colors.dart';

class PedidosTab extends StatelessWidget {
  const PedidosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final entregaProvider = context.watch<EntregaProvider>();
    final entrega = entregaProvider.entregaAtiva;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
            // Card de Entrega Ativa
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
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'EM TRANSPORTE 🛵',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
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

                  // Botão de abrir mapa da rota
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
          ] else ...[
            // Estado Vazio
            SizedBox(height: 30.h),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 64.r,
                    color: AppColors.bordaInativa,
                  ),
                  SizedBox(height: 16.h),
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
          ],
        ],
      ),
    );
  }
}
