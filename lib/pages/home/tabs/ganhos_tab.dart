import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../globals/theme_colors.dart';

class GanhosTab extends StatelessWidget {
  const GanhosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 110.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Extrato & Carteira', style: AppTextStyles.titulo()),
          SizedBox(height: 8.h),
          Text(
            'Resumo dos seus repasses e corridas finalizadas',
            style: AppTextStyles.subtitulo(),
          ),
          SizedBox(height: 24.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.texto.withValues(alpha: 0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Disponível',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    color: AppColors.desabilitado,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'R\$ 0,00',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.texto,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Próximo repasse automático na quarta-feira.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13.sp,
                    color: AppColors.primaria,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
