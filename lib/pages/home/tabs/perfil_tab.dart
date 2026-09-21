import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../controllers/user_provider.dart';
import '../../../controllers/entrega_provider.dart';
class PerfilTab extends StatelessWidget {
  const PerfilTab({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final delivery = context.watch<EntregaProvider>();
    final profile = delivery.perfilEntregador;
    return ListView(padding: const EdgeInsets.all(24), children: [
      Text('Seu perfil', style: Theme.of(context).textTheme.headlineSmall),
      if (user.isLoading) const LinearProgressIndicator(),
      if (user.erro != null) TextButton(onPressed: user.carregarDadosReais, child: Text('${user.erro} Tentar novamente')),
      ListTile(title: Text(user.nome), subtitle: const Text('Nome'), trailing: const Icon(Icons.edit_outlined),
        onTap: () => context.push('/editar-nome')),
      ListTile(title: Text(user.email), subtitle: const Text('E-mail'), trailing: const Icon(Icons.edit_outlined),
        onTap: () => context.push('/editar-email')),
      ListTile(title: Text(user.telefone), subtitle: const Text('Telefone'), trailing: const Icon(Icons.edit_outlined),
        onTap: () => context.push('/editar-telefone')),
      ListTile(title: const Text('Alterar senha'), leading: const Icon(Icons.lock_outline),
        onTap: () => context.push('/editar-senha')),
      const Divider(),
      if (profile != null) ...[
        Text('Documentos e veículo', style: Theme.of(context).textTheme.titleLarge),
        ListTile(title: Text(profile.cnh ?? 'Não informado'), subtitle: const Text('CNH')),
        ListTile(title: Text('${profile.tipoVeiculo ?? ''} • ${profile.placaVeiculo ?? ''}'), subtitle: const Text('Veículo cadastrado')),
      ] else ListTile(title: const Text('Cadastrar documentos e veículo'), trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/cadastro-motoboy')),
      const SizedBox(height: 24),
      OutlinedButton(key: const Key('logout-button'), onPressed: () => delivery.sair(), child: const Text('Sair da conta')),
    ]);
  }
}