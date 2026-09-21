import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../controllers/entrega_provider.dart';
import '../../../models/historico_entrega_model.dart';
import '../../../services/entregador_service.dart';

class PedidosTab extends StatefulWidget {
  const PedidosTab({super.key});
  @override
  State<PedidosTab> createState() => _PedidosTabState();
}
class _PedidosTabState extends State<PedidosTab> {
  final _service = EntregadorService();
  final List<HistoricoEntregaModel> _items = [];
  bool _loading = false, _last = false;
  int _page = 0;
  String? _error;
  @override
  void initState() { super.initState(); _load(reset: true); }
  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final page = await _service.buscarHistorico(page: reset ? 0 : _page);
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page.itens); _page = page.paginaAtual + 1; _last = page.ultima;
      });
    } catch (e) { if (mounted) setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) {
    final p = context.watch<EntregaProvider>();
    if (!p.isCadastrado) {
      return Center(child: TextButton(onPressed: () => context.push('/cadastro-motoboy'),
      child: const Text('Complete seu cadastro para acompanhar suas corridas.')));
    }
    return RefreshIndicator(onRefresh: () => _load(reset: true), child: ListView(
      padding: const EdgeInsets.all(20), physics: const AlwaysScrollableScrollPhysics(), children: [
        Text('Suas corridas', style: Theme.of(context).textTheme.headlineSmall),
        if (p.entregaAtiva != null) Card(child: ListTile(title: const Text('Corrida ativa'),
          subtitle: Text(p.entregaAtiva!.statusPedido.label), onTap: () => context.push('/rota-entrega'))),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) TextButton(onPressed: () => _load(reset: _items.isEmpty), child: Text('$_error Tentar novamente')),
        if (!_loading && _error == null && _items.isEmpty) const Padding(padding: EdgeInsets.all(24),
          child: Text('Você ainda não tem corridas no histórico.', key: Key('historico-empty'))),
        for (final item in _items) Card(child: ListTile(
          title: Text(item.lojaNome ?? 'Loja'),
          subtitle: Text('${item.status.label}\n${[item.bairroEntrega, item.cidadeEntrega].whereType<String>().join(', ')}\n${item.entregueEm?.toLocal() ?? item.criadoEm?.toLocal() ?? ''}'),
          trailing: Text(item.taxaFrete == null ? '—' : 'R\$ ${item.taxaFrete!.toStringAsFixed(2)}'))),
        if (!_last && !_loading && _error == null) TextButton(onPressed: _load, child: const Text('Carregar mais')),
      ]));
  }
}