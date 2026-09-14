import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../components/nhac_menu_tile.dart';
import '../../../../controllers/user_provider.dart';
import '../../../../globals/theme_colors.dart';
import 'editar_documentos_page.dart';
import 'editar_email_page.dart';
import 'editar_foto_page.dart';
import 'editar_nome_page.dart';
import 'editar_senha_page.dart';
import 'editar_telefone_page.dart';
import 'editar_veiculo_page.dart';

class DadosPessoaisTab extends StatelessWidget {
  const DadosPessoaisTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final temFoto = userProvider.fotoPerfil != null && userProvider.fotoPerfil!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: AppColors.fundo,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF5D201C),
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Dados Pessoais',
          style: TextStyle(
            color: Color(0xFF5D201C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 16.0),
            NhacMenuTile(
              titulo: 'Foto de Perfil',
              subtitulo: temFoto ? 'Alterar foto' : 'Adicionar foto',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditarFotoPage()),
                );
              },
            ),
            NhacMenuTile(
              titulo: 'Nome',
              subtitulo: userProvider.nome,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditarNomePage()),
                );
              },
            ),
            if (userProvider.email.isNotEmpty)
              NhacMenuTile(
                titulo: 'E-mail',
                subtitulo: userProvider.email,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditarEmailPage()),
                  );
                },
              ),
            NhacMenuTile(
              titulo: 'Telefone',
              subtitulo: userProvider.telefone,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditarTelefonePage()),
                );
              },
            ),
            NhacMenuTile(
              titulo: 'Documentos (CPF & CNH)',
              subtitulo: '${userProvider.cpf} • CNH: ${userProvider.cnh}',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditarDocumentosPage()),
                );
              },
            ),
            NhacMenuTile(
              titulo: 'Veículo & Moto',
              subtitulo: '${userProvider.veiculoModelo} • ${userProvider.veiculoPlaca}',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditarVeiculoPage()),
                );
              },
            ),
            if (userProvider.hasPassword)
              NhacMenuTile(
                titulo: 'Senha',
                subtitulo: '**************',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditarSenhaPage()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
