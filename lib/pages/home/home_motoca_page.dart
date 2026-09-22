import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/entrega_provider.dart';
import '../../controllers/user_provider.dart';
import '../../globals/theme_colors.dart';
import 'tabs/ganhos_tab.dart';
import 'tabs/motoboy_inicio.dart';
import 'tabs/pedidos_tab.dart';
import 'tabs/perfil_tab.dart';

class HomeMotocaPage extends StatefulWidget {
  const HomeMotocaPage({super.key});
  @override
  State<HomeMotocaPage> createState() => _HomeMotocaPageState();
}

class _HomeMotocaPageState extends State<HomeMotocaPage> {
  int _tab = 0;

  static const _titulos = ['Nhac • Parceiro Motoca', 'Corridas', 'Ganhos', 'Perfil'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().carregarDadosReais();
      context.read<EntregaProvider>().sincronizar();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.fundo,
        appBar: AppBar(
          backgroundColor: AppColors.fundo,
          elevation: 0,
          centerTitle: false,
          title: Text(
            _titulos[_tab],
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
              color: AppColors.texto,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: switch (_tab) {
                1 => const PedidosTab(),
                2 => const GanhosTab(),
                3 => const PerfilTab(),
                _ => const MotoboyInicio(),
              },
            ),
          ),
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primaria.withValues(alpha: 0.15),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: states.contains(WidgetState.selected) ? AppColors.primaria : AppColors.desabilitado,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected) ? AppColors.primaria : AppColors.desabilitado,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            elevation: 8,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Início'),
              NavigationDestination(
                key: Key('historico-button'),
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Corridas',
              ),
              NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments_rounded), label: 'Ganhos'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Perfil'),
            ],
          ),
        ),
      );
}
