import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/entrega/card_nova_oferta_dialog.dart';
import '../../components/home/nhac_bottom_nav_bar.dart';
import '../../components/home/status_toggle_button.dart';
import '../../controllers/cadastro_controller.dart';
import '../../controllers/entrega_provider.dart';
import '../../globals/theme_colors.dart';
import 'tabs/ganhos_tab.dart';
import 'tabs/inicio_tab.dart';
import 'tabs/pedidos_tab.dart';
import 'tabs/perfil_tab.dart';

class HomeMotocaPage extends StatefulWidget {
  const HomeMotocaPage({super.key});

  @override
  State<HomeMotocaPage> createState() => _HomeMotocaPageState();
}

class _HomeMotocaPageState extends State<HomeMotocaPage> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final entregaProvider = context.watch<EntregaProvider>();
    final estaOnline = entregaProvider.estaOnline;
    final oferta = entregaProvider.ofertaAtual;

    return Scaffold(
      backgroundColor: AppColors.fundo,
      extendBody: true,
      appBar: _selectedIndex == 3
          ? null
          : AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: AppColors.fundo,
              title: Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: StatusToggleButton(
                  estaOnline: estaOnline,
                  onChanged: (val) {
                    entregaProvider.alternarStatusOnline(val);
                  },
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.logout_rounded,
                    color: AppColors.texto,
                    size: 24.r,
                  ),
                  tooltip: 'Sair da conta',
                  onPressed: () {
                    context.read<CadastroController>().limparDados();
                    context.go('/');
                  },
                ),
                SizedBox(width: 8.w),
              ],
            ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              InicioTab(
                estaOnline: estaOnline,
                onToggleOnline: (val) {
                  entregaProvider.alternarStatusOnline(val);
                },
              ),
              const PedidosTab(),
              const GanhosTab(),
              const PerfilTab(),
            ],
          ),
          Positioned(
            bottom: bottomPadding + 16.h,
            left: 20.w,
            right: 20.w,
            child: NhacBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),
          ),
          // Card de Nova Corrida quando recebida do backend
          if (oferta != null)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: CardNovaOfertaDialog(oferta: oferta),
              ),
            ),
        ],
      ),
    );
  }
}