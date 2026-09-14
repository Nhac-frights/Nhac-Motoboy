import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../controllers/cadastro_controller.dart';
import '../../../controllers/entrega_provider.dart';
import '../../../globals/theme_colors.dart';

class InicioTab extends StatelessWidget {
  final bool estaOnline;
  final ValueChanged<bool> onToggleOnline;

  const InicioTab({
    super.key,
    required this.estaOnline,
    required this.onToggleOnline,
  });

  @override
  Widget build(BuildContext context) {
    final email = context.watch<CadastroController>().email;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 110.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Olá, Parceiro Motoca! 🛵', style: AppTextStyles.titulo()),
          SizedBox(height: 4.h),
          Text(
            email.isNotEmpty ? email : 'Pronto para as entregas de hoje?',
            style: AppTextStyles.subtitulo(),
          ),
          SizedBox(height: 24.h),

          // Card de Status Online / Offline
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 14.r,
                          height: 14.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: estaOnline
                                ? const Color(0xFF4CAF50)
                                : AppColors.desabilitado,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          estaOnline
                              ? 'ONLINE PARA PEDIDOS'
                              : 'VOCÊ ESTÁ OFFLINE',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: estaOnline
                                ? const Color(0xFF2E7D32)
                                : AppColors.desabilitado,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: estaOnline,
                      activeThumbColor: AppColors.primaria,
                      activeTrackColor: AppColors.secundaria,
                      onChanged: onToggleOnline,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  estaOnline
                      ? 'Procurando chamadas de restaurantes próximos a você...'
                      : 'Ative o interruptor acima para começar a receber pedidos de entrega.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    color: AppColors.desabilitado,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Painel de Ganhos Rápidos
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.secundaria.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.secundaria, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Ganhos de Hoje',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.desabilitado,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'R\$ 0,00',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.texto,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40.h,
                  width: 1.w,
                  color: AppColors.bordaInativa,
                ),
                Column(
                  children: [
                    Text(
                      'Entregas Feitas',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.desabilitado,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '0',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.texto,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
