import 'dart:io';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _usuarioId;
  String? _nome;
  String? _email;
  String? _fotoPerfil;
  bool _isLoading = false;

  String? get usuarioId => _usuarioId;
  String? get nome => _nome;
  String? get email => _email;
  String? get fotoPerfil => _fotoPerfil;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setUsuario({String? id, String? nome, String? email, String? foto}) {
    _usuarioId = id;
    _nome = nome;
    _email = email;
    _fotoPerfil = foto;
    notifyListeners();
  }

  Future<void> atualizarFotoPerfil(File imagem) async {
    _fotoPerfil = imagem.path;
    notifyListeners();
  }

  void limparUsuario() {
    _usuarioId = null;
    _nome = null;
    _email = null;
    _fotoPerfil = null;
    notifyListeners();
  }
}
