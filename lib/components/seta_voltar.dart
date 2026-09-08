import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../globals/theme_colors.dart';

class SetaVoltar extends StatelessWidget {
  final Color? cor;
  final VoidCallback? onVoltar;

  const SetaVoltar({super.key, this.cor, this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onVoltar != null) {
          onVoltar!();
        } else if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        } else {
          GoRouter.of(context).go('/');
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: SizedBox(
          width: 32.w,
          height: 32.h,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cor ?? AppColors.texto,
            size: 22.r,
          ),
        ),
      ),
    );
  }
}
