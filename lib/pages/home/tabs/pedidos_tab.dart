import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../globals/theme_colors.dart';

class PedidosTab extends StatelessWidget {
  const PedidosTab({super.key});

  @override
  Widget build(BuildContext context) {
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
          SizedBox(height: 40.h),
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
      ),
    );
  }
}
