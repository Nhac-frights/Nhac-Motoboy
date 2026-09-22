import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../components/botoes/botao_largo_nhac.dart';
import '../../../components/nhac_menu_tile.dart';
import '../../../controllers/entrega_provider.dart';
import '../../../controllers/user_provider.dart';
import '../../../globals/theme_colors.dart';

class PerfilTab extends StatelessWidget {
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final delivery = context.watch<EntregaProvider>();
    final profile = delivery.perfilEntregador;
    return ListView(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
      children: [
        Text('Seu perfil', style: AppTextStyles.titulo()),
        SizedBox(height: 16.h),
        if (user.isLoading)
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator(color: AppColors.primaria)),
        if (user.erro != null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: TextButton(
              onPressed: user.carregarDadosReais,
              style: TextButton.styleFrom(foregroundColor: AppColors.primaria),
              child: Text('${user.erro} Tentar novamente'),
            ),
          ),
        _SecaoCard(children: [
          NhacMenuTile(titulo: user.nome, subtitulo: 'Nome', onTap: () async => context.push('/editar-nome')),
          const Divider(height: 1, color: AppColors.bordaInativa),
          NhacMenuTile(titulo: user.email, subtitulo: 'E-mail', onTap: () async => context.push('/editar-email')),
          const Divider(height: 1, color: AppColors.bordaInativa),
          NhacMenuTile(titulo: user.telefone, subtitulo: 'Telefone', onTap: () async => context.push('/editar-telefone')),
          const Divider(height: 1, color: AppColors.bordaInativa),
          NhacMenuTile(titulo: 'Alterar senha', onTap: () async => context.push('/editar-senha')),
        ]),
        SizedBox(height: 20.h),
        Text('Documentos e veículo',
            style: TextStyle(fontFamily: 'Roboto', fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.texto)),
        SizedBox(height: 8.h),
        if (profile != null)
          _SecaoCard(children: [
            _InfoRow(label: 'CNH', valor: profile.cnh ?? 'Não informado'),
            const Divider(height: 1, color: AppColors.bordaInativa),
            _InfoRow(label: 'Veículo cadastrado', valor: '${profile.tipoVeiculo ?? ''} • ${profile.placaVeiculo ?? ''}'),
          ])
        else
          _SecaoCard(children: [
            NhacMenuTile(titulo: 'Cadastrar documentos e veículo', onTap: () async => context.push('/cadastro-motoboy')),
          ]),
        SizedBox(height: 28.h),
        BotaoLargoNhac(
          key: const Key('logout-button'),
          texto: 'Sair da conta',
          isSecundario: true,
          onPressed: () => delivery.sair(),
        ),
      ],
    );
  }
}

class _SecaoCard extends StatelessWidget {
  final List<Widget> children;
  const _SecaoCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: AppColors.texto.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );
}

class _InfoRow extends StatelessWidget {
  final String label, valor;
  const _InfoRow({required this.label, required this.valor});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.subtitulo()),
            SizedBox(height: 4.h),
            Text(valor, style: TextStyle(fontFamily: 'Roboto', fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.texto)),
          ],
        ),
      );
}
