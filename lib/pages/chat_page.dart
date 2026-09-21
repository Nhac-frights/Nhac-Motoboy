import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_provider.dart';
import '../controllers/user_provider.dart';
class ChatPage extends StatefulWidget {
  final String lojaId, lojaNome;
  const ChatPage({super.key, required this.lojaId, required this.lojaNome});
  @override
  State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final _provider = ChatProvider();
  final _text = TextEditingController();
  @override
  void initState() { super.initState(); _provider.abrir(widget.lojaId); }
  @override
  void dispose() { _provider.dispose(); _text.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: _provider, builder: (context, _) {
    final p = _provider;
    final id = context.read<UserProvider>().usuarioId;
    return Scaffold(appBar: AppBar(title: Text(widget.lojaNome)), body: SafeArea(child: Column(children: [
      if (p.loading) const LinearProgressIndicator(),
      if (!p.connected) const Text('Conectando ao chat…'),
      if (p.erro != null) TextButton(onPressed: () => p.conversaId == null ? p.abrir(widget.lojaId) : p.carregar(reset: true), child: Text('${p.erro} Tentar novamente')),
      Expanded(child: p.mensagens.isEmpty ? const Center(child: Text('Nenhuma mensagem. Converse com a loja sobre sua corrida.'))
        : ListView(padding: const EdgeInsets.all(16), children: [
          if (!p.ultima) TextButton(onPressed: p.carregar, child: const Text('Mensagens anteriores')),
          for (final m in p.mensagens) Align(alignment: m.remetenteUsuarioId == id ? Alignment.centerRight : Alignment.centerLeft,
            child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(m.conteudo)))),
        ])),
      Padding(padding: const EdgeInsets.all(12), child: Row(children: [
        Expanded(child: TextField(key: const Key('chat-message-input'), controller: _text, maxLength: 4000, maxLines: 3, minLines: 1,
          decoration: const InputDecoration(hintText: 'Sua mensagem'))),
        IconButton(key: const Key('chat-send-button'), onPressed: !p.connected || p.enviando ? null : () {
          if (p.enviar(_text.text)) _text.clear();
        }, icon: Icon(p.enviando ? Icons.hourglass_top : Icons.send)),
      ])),
    ])));
  });
}