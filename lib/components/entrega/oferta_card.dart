import 'package:flutter/material.dart';
import '../../models/oferta_entrega_model.dart';
class OfertaCard extends StatelessWidget {
  final OfertaEntregaModel oferta;
  final bool busy;
  final VoidCallback aceitar, recusar;
  const OfertaCard({super.key, required this.oferta, required this.busy, required this.aceitar, required this.recusar});
  @override
  Widget build(BuildContext context) {
    final seconds = oferta.segundosEm(DateTime.now());
    return Card(key: Key('oferta-card-${oferta.id}'), child: Padding(
      padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(oferta.lojaNome, style: Theme.of(context).textTheme.titleLarge),
        Text(oferta.lojaEndereco),
        const SizedBox(height: 12),
        Text('Destino: ${[oferta.clienteBairro, oferta.clienteCidade].whereType<String>().join(', ')}'),
        Text('Frete: R\$ ${oferta.taxaFrete.toStringAsFixed(2)}'),
        Text(seconds > 0 ? 'Expira em $seconds s' : 'Oferta expirada'),
        const SizedBox(height: 12),
        Wrap(spacing: 12, children: [
          FilledButton(key: Key('oferta-aceitar-${oferta.id}'), onPressed: busy || seconds == 0 ? null : aceitar, child: const Text('Aceitar')),
          OutlinedButton(key: Key('oferta-recusar-${oferta.id}'), onPressed: busy || seconds == 0 ? null : recusar, child: const Text('Recusar')),
        ]),
      ]),
    ));
  }
}