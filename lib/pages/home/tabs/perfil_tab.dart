import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../controllers/cadastro_controller.dart';
import '../../../globals/theme_colors.dart';

class PerfilTab extends StatelessWidget {
  const PerfilTab({super.key});

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

  @override
  Widget build(BuildContext context) {
    final email = context.watch<CadastroController>().email;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de topo estilo Nhac (Notificações, Título Perfil, Mais opções)
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

          // Header com foto de perfil e dados
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

          // Estatísticas do Motoboy no estilo idêntico ao Nhac
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

          // Seção 1: "Sua Conta"
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

          // Seção 2: "Configurações & Suporte"
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
}
