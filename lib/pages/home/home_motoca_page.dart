import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/entrega/card_nova_oferta_dialog.dart';
import '../../components/home/nhac_bottom_nav_bar.dart';
import '../../components/home/status_toggle_button.dart';
import '../../controllers/cadastro_controller.dart';
import '../../controllers/entrega_provider.dart';
import '../../controllers/user_provider.dart';
import '../../globals/theme_colors.dart';
import '../../services/api_config.dart';
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
  String? _erroLocalizacaoExibido;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().carregarDadosReais();
      // CRÍTICO: sem isto, o backend não reconhece o usuário como
      // entregador e o PATCH /status retorna 404 — o botão online
      // parece "não funcionar".
      context.read<EntregaProvider>().verificarCadastro();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
    );
  }

  /// Mostra o erro de localização/status vindo do EntregaProvider.
  /// Sem isso, o botão online "não faz nada" quando o GPS está desligado
  /// ou o backend recusa a requisição.
  void _mostrarErroSeHouver(EntregaProvider provider) {
    final erro = provider.erroLocalizacao;
    if (erro == null || erro == _erroLocalizacaoExibido) return;

    _erroLocalizacaoExibido = erro;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final entregaProvider = context.watch<EntregaProvider>();
    final estaOnline = entregaProvider.estaOnline;
    final oferta = entregaProvider.ofertaAtual;

    _mostrarErroSeHouver(entregaProvider);

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
                  onPressed: () async {
                    final navContext = context;
                    await ApiConfig.limparSessao();
                    if (!navContext.mounted) return;
                    navContext.read<CadastroController>().limparDados();
                    navContext.read<UserProvider>().limparUsuario();
                    navContext.go('/');
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
              setState(() => _selectedIndex = index);
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