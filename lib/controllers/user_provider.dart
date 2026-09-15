import 'dart:io';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _usuarioId = 'motoca_001';
  String _nome = 'Carlos da Silva';
  String _email = 'carlos.motoca@nhac.com';
  String _telefone = '(11) 98765-4321';
  String _cpf = '123.456.789-00';
  String _cnh = '12345678900';
  String _veiculoModelo = 'Honda CG 160 Fan';
  String _veiculoPlaca = 'ABC-1234';
  String _veiculoCor = 'Vermelha';
  String _tipoChavePix = 'CPF';
  String _chavePix = '123.456.789-00';
  String? _fotoPerfil;
  bool _isLoading = false;

  final int _entregas = 28;
  final double _avaliacao = 4.9;
  final double _ganhos = 342.00;

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

  void atualizarDocumentos({required String cpf, required String cnh}) {
    _cpf = cpf.trim();
    _cnh = cnh.trim();
    notifyListeners();
  }

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

  void atualizarDadosBancarios({
    required String tipo,
    required String chave,
  }) {
    _tipoChavePix = tipo.trim();
    _chavePix = chave.trim();
    notifyListeners();
  }

  Future<void> atualizarFotoPerfil(File imagem) async {
    _fotoPerfil = imagem.path;
    notifyListeners();
  }

  void removerFotoPerfil() {
    _fotoPerfil = null;
    notifyListeners();
  }

  void atualizarSenha(String novaSenha) {
    // Simula atualização de senha
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
    _fotoPerfil = null;
    notifyListeners();
  }
}
