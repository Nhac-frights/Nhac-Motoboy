import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'controllers/cadastro_controller.dart';
import 'controllers/user_provider.dart';
import 'globals/router.dart';
import 'globals/theme_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CadastroController()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MeuApp(),
    ),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Nhac Motoboy',
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: AppColors.fundo,
            colorScheme: ColorScheme.light(
              primary: AppColors.primaria,
              surface: AppColors.fundo,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.fundo,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}
