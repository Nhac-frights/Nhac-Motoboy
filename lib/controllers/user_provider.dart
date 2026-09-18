import 'dart:io';
import 'package:flutter/material.dart';

import '../services/entregador_service.dart';

class UserProvider with ChangeNotifier {
  final EntregadorService _service;

  String _usuarioId = '';
  String _nome = '';
  String _email = '';
  String _telefone = '';
  String _cpf = '';
  String _cnh = '';
  String _veiculoModelo = '';
  String _veiculoPlaca = '';
  String _veiculoCor = '';
  String _tipoChavePix = 'CPF';
  String _chavePix = '';
  String? _fotoPerfil;
  bool _isLoading = false;

  int _entregas = 0;
  double _avaliacao = 5.0;
  double _ganhos = 0.0;

  UserProvider({EntregadorService? service}) : _service = service ?? EntregadorService();

  String get usuarioId => _usuarioId;
  String get nome => _nome;
  String get email => _email;
  String get telefone => _telefone;
  String get cpf => _cpf;
  String get cnh => _cnh;
  String get veiculoModelo => _veiculoModelo;
  String get veiculoPlaca => _veiculoPlaca;
  String get veiculoCor => _veiculoCor;
  String get tipoChavePix => _tipoChavePix;
  String get chavePix => _chavePix;
  String? get fotoPerfil => _fotoPerfil;
  bool get isLoading => _isLoading;
  bool get hasPassword => true;

  int get entregas => _entregas;
  double get avaliacao => _avaliacao;
  double get ganhos => _ganhos;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Carrega nome/e-mail/telefone/veículo (GET /entregador/perfil) e o total
  /// de ganhos e entregas do período (GET /entregador/ganhos) reais.
  ///
  /// Antes desta chamada, TODOS esses campos eram constantes fixas no
  /// código-fonte ("Carlos da Silva", R$ 342,00, 28 entregas, nota 4.9) —
  /// aparecia igual pra qualquer motoboy, sempre, independente de ter feito
  /// alguma entrega ou não.
  ///
  /// cpf, cor do veículo, chave PIX e foto de perfil continuam sem endpoint
  /// no backend do entregador hoje (só existem no domínio do lojista) — os
  /// setters atualizarDadosBancarios/atualizarVeiculo/atualizarFotoPerfil
  /// abaixo continuam alterando só o estado local, sem persistir nada no
  /// servidor. Isso precisa de um endpoint novo (ex.: PUT /entregador/perfil)
  /// antes de ser corrigido de verdade — ver relatório.
  Future<void> carregarDadosReais() async {
    setLoading(true);
    try {
      final perfil = await _service.obterPerfil();
      if (perfil != null) {
        _usuarioId = perfil.usuarioId;
        _cnh = perfil.cnh ?? _cnh;
        _veiculoPlaca = perfil.placaVeiculo ?? _veiculoPlaca;
        _veiculoModelo = perfil.tipoVeiculo ?? _veiculoModelo;
      }

      final ganhosTotais = await _service.buscarGanhos(periodo: 'TRINTA_DIAS');
      if (ganhosTotais != null) {
        _ganhos = ganhosTotais.totalGanhos;
        _entregas = ganhosTotais.totalEntregas;
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados reais do motoboy: $e');
    } finally {
      setLoading(false);
    }
  }

  void atualizarNome(String novoNome) {
    _nome = novoNome.trim();
    notifyListeners();
  }

  void atualizarEmail(String novoEmail) {
    _email = novoEmail.trim();
    notifyListeners();
  }

  void atualizarTelefone(String novoTelefone) {
    _telefone = novoTelefone.trim();
    notifyListeners();
  }

  /// NÃO persiste no backend - ver nota em carregarDadosReais().
  void atualizarDocumentos({required String cpf, required String cnh}) {
    _cpf = cpf.trim();
    _cnh = cnh.trim();
    notifyListeners();
  }

  /// NÃO persiste no backend - ver nota em carregarDadosReais().
  void atualizarVeiculo({
    required String modelo,
    required String placa,
    required String cor,
  }) {
    _veiculoModelo = modelo.trim();
    _veiculoPlaca = placa.trim().toUpperCase();
    _veiculoCor = cor.trim();
    notifyListeners();
  }

  /// NÃO persiste no backend - ver nota em carregarDadosReais().
  void atualizarDadosBancarios({
    required String tipo,
    required String chave,
  }) {
    _tipoChavePix = tipo.trim();
    _chavePix = chave.trim();
    notifyListeners();
  }

  /// NÃO persiste no backend - ver nota em carregarDadosReais().
  Future<void> atualizarFotoPerfil(File imagem) async {
    _fotoPerfil = imagem.path;
    notifyListeners();
  }

  void removerFotoPerfil() {
    _fotoPerfil = null;
    notifyListeners();
  }

  /// NÃO persiste no backend - não existe endpoint de troca de senha para
  /// o entregador hoje.
  void atualizarSenha(String novaSenha) {
    notifyListeners();
  }

  void setUsuario({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    String? foto,
  }) {
    if (id != null) _usuarioId = id;
    if (nome != null) _nome = nome;
    if (email != null) _email = email;
    if (telefone != null) _telefone = telefone;
    if (foto != null) _fotoPerfil = foto;
    notifyListeners();
  }

  void limparUsuario() {
    _usuarioId = '';
    _nome = '';
    _email = '';
    _telefone = '';
    _cpf = '';
    _cnh = '';
    _veiculoModelo = '';
    _veiculoPlaca = '';
    _veiculoCor = '';
    _chavePix = '';
    _fotoPerfil = null;
    _entregas = 0;
    _ganhos = 0.0;
    notifyListeners();
  }
}
