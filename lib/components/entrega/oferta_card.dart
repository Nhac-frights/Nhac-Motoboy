import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../globals/theme_colors.dart';
import '../../models/oferta_entrega_model.dart';

class OfertaCard extends StatelessWidget {
  final OfertaEntregaModel oferta;
  final bool busy;
  final VoidCallback aceitar, recusar;
  const OfertaCard({super.key, required this.oferta, required this.busy, required this.aceitar, required this.recusar});

  @override
  Widget build(BuildContext context) {
    final seconds = oferta.segundosEm(DateTime.now());
    final expirada = seconds <= 0;
    return Container(
      key: Key('oferta-card-${oferta.id}'),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.primaria.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: AppColors.texto.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(oferta.lojaNome,
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.texto)),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: expirada ? AppColors.bordaInativa.withValues(alpha: 0.3) : AppColors.primaria.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                expirada ? 'Expirada' : '${seconds}s',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: expirada ? AppColors.desabilitado : AppColors.primaria,
                ),
              ),
            ),
          ]),
          SizedBox(height: 4.h),
          Text(oferta.lojaEndereco, style: AppTextStyles.subtitulo()),
          SizedBox(height: 10.h),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 16.r, color: AppColors.desabilitado),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                'Destino: ${[oferta.clienteBairro, oferta.clienteCidade].whereType<String>().join(', ')}',
                style: AppTextStyles.subtitulo(),
              ),
            ),
          ]),
          SizedBox(height: 6.h),
          Text('R\$ ${oferta.taxaFrete.toStringAsFixed(2)}',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.texto)),
          SizedBox(height: 14.h),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                key: Key('oferta-recusar-${oferta.id}'),
                onPressed: busy || expirada ? null : recusar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.texto,
                  side: BorderSide(color: AppColors.bordaInativa),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('Recusar'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: FilledButton(
                key: Key('oferta-aceitar-${oferta.id}'),
                onPressed: busy || expirada ? null : aceitar,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaria,
                  disabledBackgroundColor: AppColors.bordaInativa,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('Aceitar'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
