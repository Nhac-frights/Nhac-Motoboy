import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../components/botoes/botao_nhac.dart';

class BemVindoMotoca extends StatelessWidget {
  const BemVindoMotoca({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(
              child: Image(
                image: AssetImage(
                  'assets/um cara em cima da moto de delivery entregando uma pizza para um morador.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 48.h,
              left: 24.w,
              width: 132.w,
              height: 49.h,
              child: const Image(
                image: AssetImage('assets/nhac-branco.png'),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 120.h,
              left: 24.w,
              right: 24.w,
              child: Text(
                'Abra o app. \nAcelere pela cidade. \nFaça o nhac acontecer.',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 32.sp,
                  color: const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.25,
                  height: 1.2,
                ),
              ),
            ),
            Positioned(
              bottom: 40.h,
              left: 24.w,
              right: 24.w,
              height: 49.h,
              child: Row(
                children: [
                  Expanded(
                    child: BotaoNhac(
                      label: 'Começar',
                      onPressed: () {
                        context.push('/email-motoca');
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: BotaoNhac(
                      label: 'Cadastrar',
                      onPressed: () {
                        context.push('/cadastro-motoboy');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
