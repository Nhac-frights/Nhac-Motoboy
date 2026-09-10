import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/cadastro_controller.dart';
import '../../globals/theme_colors.dart';

class HomeMotocaPage extends StatefulWidget {
  const HomeMotocaPage({super.key});

  @override
  State<HomeMotocaPage> createState() => _HomeMotocaPageState();
}

class _HomeMotocaPageState extends State<HomeMotocaPage> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  bool _estaOnline = false;

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

    return Scaffold(
      backgroundColor: AppColors.fundo,
      extendBody: true,
            appBar: _selectedIndex == 3
          ? null
          : AppBar(
              centerTitle: true, 
              elevation: 0,
              backgroundColor: AppColors.fundo,
              
              // --- MEXA AQUI: Adicione o Padding para empurrar para baixo ---
              title: Padding(
                padding: EdgeInsets.only(top: 8.h), // <--- Aumente esse valor (ex: 12.h, 16.h) até ficar onde você quer
                child: _buildTopStatusToggle(),
              ),
              // ---------------------------------------------------------------

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
          // Conteúdo das telas com PageView
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              _buildInicioTab(),
              _buildPedidosTab(),
              _buildGanhosTab(),
              _buildPerfilTab(),
            ],
          ),

          // Barra de Navegação Flutuante no estilo Nhac
          Positioned(
            bottom: bottomPadding + 16.h,
            left: 20.w,
            right: 20.w,
            child: _buildBottomNavBar(),
          ),
        ],
      ),
    );
  }

  // --- NOVO: Toggle de Status com o mesmo estilo da Bottom Navigation ---
  Widget _buildTopStatusToggle() {
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.texto.withValues(alpha: 0.1),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador visual (bolinha)
            Container(
              width: 10.r,
              height: 10.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _estaOnline ? const Color(0xFF4CAF50) : AppColors.desabilitado,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              _estaOnline ? 'Disponível' : 'Indisponível',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: _estaOnline ? const Color(0xFF2E7D32) : AppColors.desabilitado,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20.r,
              color: AppColors.texto,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'Disponível',
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: _estaOnline ? AppColors.primaria : Colors.grey,
                size: 22,
              ),
              SizedBox(width: 12.w),
              const Text(
                'Disponível',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Indisponível',
          child: Row(
            children: [
              Icon(
                Icons.pause_circle_outline,
                color: !_estaOnline ? AppColors.primaria : Colors.grey,
                size: 22,
              ),
              SizedBox(width: 12.w),
              const Text(
                'Indisponível',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        setState(() {
          _estaOnline = (value == 'Disponível');
        });
      },
    );
  }

  // --- Aba 0: Início (Dashboard do Motoboy) ---
  Widget _buildInicioTab() {
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
                            color: _estaOnline
                                ? const Color(0xFF4CAF50)
                                : AppColors.desabilitado,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          _estaOnline
                              ? 'ONLINE PARA PEDIDOS'
                              : 'VOCÊ ESTÁ OFFLINE',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: _estaOnline
                                ? const Color(0xFF2E7D32)
                                : AppColors.desabilitado,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _estaOnline,
                      activeColor: AppColors.primaria,
                      activeTrackColor: AppColors.secundaria,
                      onChanged: (val) {
                        setState(() {
                          _estaOnline = val;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  _estaOnline
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

  // --- Aba 1: Pedidos ---
  Widget _buildPedidosTab() {
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

  // --- Aba 2: Ganhos ---
  Widget _buildGanhosTab() {
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

  // --- Aba 3: Perfil ---
  Widget _buildPerfilTab() {
    final email = context.watch<CadastroController>().email;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Você não tem novas notificações.'),
                    ),
                  );
                },
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF5D201C),
                  ),
                ),
              ),
              Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D201C),
                  fontFamily: 'Roboto',
                ),
              ),
              GestureDetector(
                onTap: () => _mostrarOpcoesConta(context),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_horiz, color: Color(0xFF5D201C)),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),

          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5D201C).withValues(alpha: 0.1),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.two_wheeler_rounded,
                        size: 44.r,
                        color: AppColors.primaria,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5D201C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parceiro Motoca',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D201C),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.two_wheeler_outlined,
                          size: 14.r,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            email.isNotEmpty
                                ? email
                                : 'Honda CG 160 Fan • Placa ABC-1234',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12.sp,
                              fontFamily: 'Roboto',
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('28', 'Entregas'),
              Container(height: 30.h, width: 1.w, color: Colors.grey.shade300),
              _buildStatItem('4.9', 'Avaliação'),
              Container(height: 30.h, width: 1.w, color: Colors.grey.shade300),
              _buildStatItem('R\$ 342', 'Ganhos'),
            ],
          ),
          SizedBox(height: 36.h),

          Text(
            'Sua Conta',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D201C),
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D201C).withValues(alpha: 0.03),
                  blurRadius: 15.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildAccountRow(
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFFFF6961),
                  title: 'Dados Pessoais',
                  subtitle: 'Nome, CPF, CNH e contato...',
                  onTap: () {},
                ),
                Divider(height: 1, color: Colors.grey.shade100, indent: 64.w),
                _buildAccountRow(
                  icon: Icons.two_wheeler_outlined,
                  iconColor: const Color(0xFFFF6961),
                  title: 'Veículo & Moto',
                  subtitle: 'Honda CG 160 • Placa ABC-1234...',
                  onTap: () {},
                ),
                Divider(height: 1, color: Colors.grey.shade100, indent: 64.w),
                _buildAccountRow(
                  icon: Icons.credit_card_outlined,
                  iconColor: const Color(0xFFFF6961),
                  title: 'Dados Bancários',
                  subtitle: 'Chave PIX e conta para repasses...',
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          Text(
            'Configurações',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D201C),
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D201C).withValues(alpha: 0.03),
                  blurRadius: 15.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildAccountRow(
                  icon: Icons.notifications_none,
                  iconColor: const Color(0xFFFF6961),
                  title: 'Notificações',
                  subtitle: 'Alertas sonoros de novos pedidos',
                  onTap: () {},
                ),
                Divider(height: 1, color: Colors.grey.shade100, indent: 64.w),
                _buildAccountRow(
                  icon: Icons.help_outline,
                  iconColor: const Color(0xFFFF6961),
                  title: 'Suporte & Ajuda',
                  subtitle: 'Falar com a equipe Nhac',
                  onTap: () {},
                ),
                Divider(height: 1, color: Colors.grey.shade100, indent: 64.w),
                _buildAccountRow(
                  icon: Icons.logout,
                  iconColor: const Color(0xFFFF6961),
                  title: 'Sair da conta',
                  subtitle: 'Desconectar deste celular',
                  onTap: () {
                    context.read<CadastroController>().limparDados();
                    context.go('/');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            color: const Color(0xFF5D201C),
            fontWeight: FontWeight.w300,
            fontFamily: 'Roboto',
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF5D201C),
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }

  Widget _buildAccountRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      color: const Color(0xFF5D201C),
                      fontFamily: 'Roboto',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.sp,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcoesConta(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Opções da Conta',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: const Color(0xFF5D201C),
                ),
              ),
              SizedBox(height: 28.h),
              InkWell(
                onTap: () => Navigator.pop(ctx),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.help_outline, color: Colors.grey.shade700),
                          SizedBox(width: 12.w),
                          Text(
                            'Ajuda & Suporte',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<CadastroController>().limparDados();
                  context.go('/');
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.logout, color: Colors.grey.shade700),
                          SizedBox(width: 12.w),
                          Text(
                            'Sair da conta',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 36.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6961),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Voltar',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  // --- Barra de Navegação Dinâmica estilo Nhac ---
  Widget _buildBottomNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.texto.withValues(alpha: 0.1),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.two_wheeler_rounded,
            label: 'Início',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.receipt_long_rounded,
            label: 'Pedidos',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Ganhos',
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Perfil',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return Semantics(
      button: true,
      label: label,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.fastOutSlowIn,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 18.w : 12.w,
            vertical: 10.h,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFEBD9) : Colors.transparent,
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26.sp,
                color: isSelected
                    ? AppColors.primaria
                    : const Color(0xFFA0A0A0),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.fastOutSlowIn,
                child: SizedBox(
                  width: isSelected ? null : 0,
                  child: isSelected
                      ? Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: AppColors.primaria,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}