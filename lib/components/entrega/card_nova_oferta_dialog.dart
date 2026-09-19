import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../controllers/entrega_provider.dart';
import '../../globals/theme_colors.dart';
import '../../models/oferta_entrega_model.dart';

class CardNovaOfertaDialog extends StatelessWidget {
  final OfertaEntregaModel oferta;

  const CardNovaOfertaDialog({super.key, required this.oferta});

  @override
  Widget build(BuildContext context) {
    final entregaProvider = context.watch<EntregaProvider>();
    final segundos = entregaProvider.segundosRestantes;
    final progresso = segundos / 45.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaria.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaria.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🛵', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6.w),
                      Text(
                        'NOVA CORRIDA',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaria,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 36.r,
                      height: 36.r,
                      child: CircularProgressIndicator(
                        value: progresso.clamp(0.0, 1.0),
                        strokeWidth: 3.5,
                        backgroundColor: AppColors.bordaInativa.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          segundos > 10 ? AppColors.primaria : const Color(0xFFD32F2F),
                        ),
                      ),
                    ),
                    Text(
                      '$segundos',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: segundos > 10 ? AppColors.texto : const Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 18.h),

            Center(
              child: Column(
                children: [
                  Text(
                    'Você recebe por esta entrega:',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 13.sp,
                      color: AppColors.desabilitado,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'R\$ ${oferta.taxaFrete.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
            const Divider(color: AppColors.bordaInativa, height: 1),
            SizedBox(height: 16.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.secundaria.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.store_rounded, color: AppColors.primaria, size: 20.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Retirada no Restaurante',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11.sp,
                          color: AppColors.desabilitado,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        oferta.lojaNome,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.texto,
                        ),
                      ),
                      if (oferta.lojaEndereco.isNotEmpty)
                        Text(
                          oferta.lojaEndereco,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12.sp,
                            color: AppColors.desabilitado,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Color(0xFF2E7D32), size: 20),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entrega no Cliente',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11.sp,
                          color: AppColors.desabilitado,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        oferta.clienteBairro != null
                            ? '${oferta.clienteBairro} - ${oferta.clienteCidade ?? ""}'
                            : 'Endereço do Cliente',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.texto,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: const BorderSide(color: AppColors.bordaInativa),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    onPressed: () {
                      entregaProvider.recusarOfertaAtual();
                    },
                    child: Text(
                      'Recusar',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.desabilitado,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: AppColors.primaria,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    onPressed: entregaProvider.isLoading
                        ? null
                        : () async {
                            // Captura o messenger ANTES do await: o dialog pode
                            // sair da árvore (countdown zerando, por ex.) e
                            // ScaffoldMessenger.of(context) explodiria depois.
                            final messenger = ScaffoldMessenger.maybeOf(context);
                            final ok = await entregaProvider.aceitarOfertaAtual();
                            if (!ok && context.mounted && messenger != null) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Não foi possível aceitar a corrida.'),
                                ),
                              );
                            }
                          },
                    child: entregaProvider.isLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'ACEITAR CORRIDA',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}