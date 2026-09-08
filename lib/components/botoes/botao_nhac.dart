import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../globals/theme_colors.dart';

class BotaoNhac extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double fontSize;

  const BotaoNhac({
    super.key,
    this.label = 'Começar',
    this.onPressed,
    this.fontSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () => context.push('/email-motoca'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaria,
        foregroundColor: AppColors.fundo,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: fontSize.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: AppColors.fundo,
        ),
      ),
    );
  }
}
