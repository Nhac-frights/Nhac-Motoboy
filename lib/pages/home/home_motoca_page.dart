import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/entrega_provider.dart';
import '../../controllers/user_provider.dart';
import '../../components/entrega/oferta_card.dart';
import 'tabs/ganhos_tab.dart';
import 'tabs/pedidos_tab.dart';
import 'tabs/perfil_tab.dart';

class HomeMotocaPage extends StatefulWidget {
  const HomeMotocaPage({super.key});
  @override
  State<HomeMotocaPage> createState() => _HomeMotocaPageState();
}
class _HomeMotocaPageState extends State<HomeMotocaPage> {
  int _tab = 0;
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
    appBar: AppBar(title: const Text('Nhac • Parceiro Motoca')),
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: switch (_tab) { 1 => const PedidosTab(), 2 => const GanhosTab(), 3 => const PerfilTab(), _ => const MotoboyInicio() },
    ))),
    bottomNavigationBar: NavigationBar(selectedIndex: _tab,
      onDestinationSelected: (value) => setState(() => _tab = value),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
        NavigationDestination(key: Key('historico-button'), icon: Icon(Icons.receipt_long), label: 'Corridas'),
        NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Ganhos'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ]),
  );
}
class MotoboyInicio extends StatelessWidget {
  const MotoboyInicio({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<EntregaProvider>();
    final user = context.watch<UserProvider>();
    return RefreshIndicator(onRefresh: p.sincronizar,
      child: ListView(padding: const EdgeInsets.all(20), physics: const AlwaysScrollableScrollPhysics(), children: [
        Text(user.nome.isEmpty ? 'Olá, parceiro!' : 'Olá, ${user.nome}', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (!p.inicializado) const LinearProgressIndicator(),
        if (p.erro != null) _Notice(p.erro!, action: p.sincronizar),
        if (p.aviso != null) _Notice(p.aviso!),
        if (p.inicializado && p.erro == null && !p.isCadastrado)
          Card(child: ListTile(title: const Text('Comece seu cadastro'),
            subtitle: const Text('Informe seus documentos e veículo para receber entregas.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/cadastro-motoboy'))),
        if (p.isCadastrado) ...[
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.status.label, key: const Key('motoboy-status-text'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(!p.cadastroAtivo ? 'Seu cadastro está inativo.'
                : p.emEntrega ? 'Sua disponibilidade é controlada pela corrida ativa.'
                : p.estaOnline ? 'Aguardando novas entregas.' : 'Fique online para receber ofertas.'),
              if (!p.emEntrega && p.cadastroAtivo) FilledButton(
                key: const Key('motoboy-status-toggle'),
                onPressed: p.isLoading ? null : () => p.alternarStatusOnline(!p.estaOnline),
                child: Text(p.isLoading ? 'Atualizando…' : p.estaOnline ? 'Ficar offline' : 'Ficar online')),
            ]))),
          if (p.erroLocalizacao != null) _Notice(p.erroLocalizacao!, action: () => p.atualizarLocalizacao(solicitar: true)),
          if (p.latitudeAtual != null) const ListTile(leading: Icon(Icons.gps_fixed), title: Text('Localização atualizada')),
          if (p.estaOnline) const Text('Mantenha o aplicativo aberto para receber ofertas. Ao ir para segundo plano, solicitamos o status offline.'),
          if (p.entregaAtiva != null) Card(key: const Key('corrida-ativa-card'),
            child: ListTile(leading: const Icon(Icons.delivery_dining),
              title: Text(p.entregaAtiva!.lojaNome),
              subtitle: Text(p.entregaAtiva!.statusPedido.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/rota-entrega'))),
          if (p.estaOnline && !p.emEntrega) ...[
            const SizedBox(height: 20),
            Text('Ofertas disponíveis', style: Theme.of(context).textTheme.titleLarge),
            if (p.ofertas.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Nenhuma entrega disponível no momento.\nVocê será avisado quando uma nova oferta aparecer.', key: Key('ofertas-empty'))),
            for (final offer in p.ofertas) OfertaCard(oferta: offer, busy: p.isLoading,
              aceitar: () async {
                final ok = await p.aceitarOferta(offer.id);
                if (ok && context.mounted) context.push('/rota-entrega');
              }, recusar: () => p.recusarOferta(offer.id)),
          ],
        ],
      ]));
  }
}
class _Notice extends StatelessWidget {
  final String text;
  final VoidCallback? action;
  const _Notice(this.text, {this.action});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(text), if (action != null) TextButton(onPressed: action, child: const Text('Tentar novamente')),
    ])));
}