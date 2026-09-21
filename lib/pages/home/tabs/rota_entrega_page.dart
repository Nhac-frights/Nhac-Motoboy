import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/entrega_provider.dart';
import '../../../components/entrega/mapa_rota_widget.dart';
import '../../chat_page.dart';

class RotaEntregaPage extends StatelessWidget {
  const RotaEntregaPage({super.key});
  Future<void> _confirm(BuildContext context, EntregaProvider p, bool collect) async {
    final accepted = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(collect ? 'Confirmar retirada?' : 'Confirmar entrega?'),
      content: Text(collect ? 'Confirme após receber o pedido na loja.' : 'Confirme após entregar o pedido ao cliente.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Voltar')),
        FilledButton(key: const Key('corrida-confirmar-dialog'), onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar'))]));
    if (accepted != true || !context.mounted) return;
    final ok = collect ? await p.confirmarColeta() : await p.concluirEntregaAtual();
    if (!context.mounted) return;
    if (ok && !collect) context.go('/home-motoca');
  }
  @override
  Widget build(BuildContext context) {
    final p = context.watch<EntregaProvider>();
    final active = p.entregaAtiva;
    return Scaffold(appBar: AppBar(title: const Text('Sua corrida')),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800),
      child: active == null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(p.aviso ?? 'Nenhuma corrida ativa.'),
        TextButton(onPressed: () => context.go('/home-motoca'), child: const Text('Voltar ao início')),
      ])) : RefreshIndicator(onRefresh: p.sincronizar, child: ListView(
        padding: const EdgeInsets.all(20), children: [
          Text(active.statusPedido.label, key: const Key('corrida-status-text'), style: Theme.of(context).textTheme.headlineSmall),
          if (p.isLoading) const LinearProgressIndicator(),
          if (p.erro != null) Text(p.erro!, style: const TextStyle(color: Colors.red)),
          ListTile(leading: const Icon(Icons.store), title: Text(active.lojaNome), subtitle: Text(active.lojaEndereco)),
          ListTile(leading: const Icon(Icons.person_pin_circle), title: Text(active.clienteNome),
            subtitle: Text(active.enderecoEntrega?.formatado ?? 'Endereço indisponível')),
          if (active.observacao?.isNotEmpty == true) Text('Observação: ${active.observacao}'),
          Text('Frete: R\$ ${active.taxaFrete.toStringAsFixed(2)}'),
          if (p.rotaAtual != null) ...[
            const SizedBox(height: 16),
            MapaRotaWidget(rota: p.rotaAtual!, latitude: p.latitudeAtual, longitude: p.longitudeAtual),
            Text('Loja → cliente: ${p.rotaAtual!.distanciaKm.toStringAsFixed(1)} km • estimativa ${p.rotaAtual!.duracaoEstimadaMinutos} min'),
          ] else TextButton(onPressed: () => p.carregarRota(active.pedidoId),
            child: Text(p.erroRota == null ? 'Carregar mapa da corrida' : '${p.erroRota} Tentar novamente')),
          const SizedBox(height: 16),
          OutlinedButton.icon(icon: const Icon(Icons.directions), label: const Text('Abrir navegação'),
            onPressed: () async {
              final lat = p.entregaColetada ? active.entregaLatitude : active.lojaLatitude;
              final lng = p.entregaColetada ? active.entregaLongitude : active.lojaLongitude;
              final address = p.entregaColetada ? active.enderecoEntrega?.formatado : active.lojaEndereco;
              if ((lat == null || lng == null) && (address == null || address.isEmpty)) return;
              final uri = Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': lat != null && lng != null ? '$lat,$lng' : address!});
              try {
                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) throw StateError('Navegação indisponível.');
              } catch (_) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível abrir a navegação.')));
              }
            }),
          if (active.lojaId != null) OutlinedButton.icon(key: const Key('chat-button'),
            icon: const Icon(Icons.chat_bubble_outline), label: const Text('Conversar com a loja'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(lojaId: active.lojaId!, lojaNome: active.lojaNome)))),
          const SizedBox(height: 16),
          if (!p.entregaColetada) FilledButton(key: const Key('corrida-coletar-button'),
            onPressed: p.podeColetar ? () => _confirm(context, p, true) : null, child: const Text('Confirmar retirada'))
          else FilledButton(key: const Key('corrida-entregar-button'),
            onPressed: p.podeConcluir ? () => _confirm(context, p, false) : null, child: const Text('Confirmar entrega')),
        ])),
    )));
  }
}