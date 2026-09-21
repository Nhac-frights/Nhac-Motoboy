import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/entrega_provider.dart';
import '../utils/validators.dart';

class CadastroMotoboyPage extends StatefulWidget {
  const CadastroMotoboyPage({super.key});
  @override
  State<CadastroMotoboyPage> createState() => _CadastroMotoboyPageState();
}
class _CadastroMotoboyPageState extends State<CadastroMotoboyPage> {
  final _form = GlobalKey<FormState>();
  final _cpf = TextEditingController(), _cnh = TextEditingController(), _placa = TextEditingController();
  String _tipo = 'MOTO';
  String? _erro;
  bool _busy = false;
  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() { _busy = true; _erro = null; });
    try {
      await context.read<EntregaProvider>().cadastrarEntregador(
        cpf: _cpf.text.replaceAll(RegExp(r'\D'), ''), cnh: _cnh.text.trim(),
        placaVeiculo: _placa.text.trim().toUpperCase(), tipoVeiculo: _tipo);
      if (mounted) context.go('/home-motoca');
    } catch (e) { if (mounted) setState(() => _erro = e.toString()); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  void dispose() { _cpf.dispose(); _cnh.dispose(); _placa.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Seja parceiro Nhac')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600),
      child: Form(key: _form, child: ListView(padding: const EdgeInsets.all(24), children: [
        const Text('Cadastre seus documentos e veículo para começar. Após o cadastro, você ficará offline.'),
        const SizedBox(height: 24),
        TextFormField(key: const Key('cadastro-cpf'), controller: _cpf, decoration: const InputDecoration(labelText: 'CPF'),
          keyboardType: TextInputType.number, validator: Validators.validarCPF),
        TextFormField(key: const Key('cadastro-cnh'), controller: _cnh, decoration: const InputDecoration(labelText: 'CNH'),
          keyboardType: TextInputType.number, validator: Validators.validarCNH),
        TextFormField(key: const Key('cadastro-placa'), controller: _placa, decoration: const InputDecoration(labelText: 'Placa'),
          textCapitalization: TextCapitalization.characters, validator: Validators.validarPlaca),
        DropdownButtonFormField<String>(initialValue: _tipo, decoration: const InputDecoration(labelText: 'Tipo de veículo'),
          items: const [DropdownMenuItem(value: 'MOTO', child: Text('Moto')),
            DropdownMenuItem(value: 'CARRO', child: Text('Carro')), DropdownMenuItem(value: 'BICICLETA', child: Text('Bicicleta'))],
          onChanged: _busy ? null : (value) => setState(() => _tipo = value!)),
        if (_erro != null) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(_erro!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 24),
        FilledButton(key: const Key('cadastro-entregador-submit'), onPressed: _busy ? null : _save,
          child: Text(_busy ? 'Salvando…' : 'Concluir cadastro')),
      ]))),
    ),
  );
}