import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Serviço responsável pelas operações de autenticação (login/cadastro)
/// Fluxos suportados:
/// - E-mail + senha (checar-email, enviar-codigo-cadastro, confirmar-email-cadastro, registrar, login)
/// - Telefone (passwordless): enviar-codigo, login-sms
class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Verifica se um e-mail já está cadastrado no sistema
  /// POST /api/v1/auth/checar-email
  /// Retorna true se o usuário existe, false caso contrário
  Future<bool> checarEmail(String email) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/checar-email');
    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados =
            jsonDecode(utf8.decode(response.bodyBytes));
        // Bug real: o backend devolve {"existe": bool} (ChecarEmailResponseDTO),
        // mas isto lia 'existeUsuario' — campo que nunca existiu na resposta.
        // Resultado: null cai no "?? false", então TODO e-mail (inclusive
        // contas já cadastradas) era tratado como novo, mandando quem só
        // queria logar direto pro fluxo de criar conta — que o backend então
        // rejeitava com "Este e-mail já está em uso."
        return dados['existe'] as bool? ?? false;
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> erro =
            jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(erro['message'] ?? 'Erro ao verificar e-mail');
      } else {
        throw Exception('Erro ao verificar e-mail: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao verificar e-mail: $e');
      rethrow;
    }
  }

  /// Envia código de verificação por e-mail para cadastro
  /// POST /api/v1/auth/enviar-codigo-cadastro
  Future<void> enviarCodigoCadastro(String email) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/enviar-codigo-cadastro');
    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final Map<String, dynamic> erro =
            jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(erro['message'] ?? 'Erro ao enviar código de verificação');
      }
    } catch (e) {
      debugPrint('Erro ao enviar código de cadastro: $e');
      rethrow;
    }
  }

  /// Confirma o código de verificação de e-mail
  /// POST /api/v1/auth/confirmar-email-cadastro
  Future<void> confirmarEmailCadastro(String email, String codigo) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/confirmar-email-cadastro');
    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email, 'codigo': codigo}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final Map<String, dynamic> erro =
            jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(erro['message'] ?? 'Código inválido ou expirado');
      }
    } catch (e) {
      debugPrint('Erro ao confirmar e-mail: $e');
      rethrow;
    }
  }

  /// Registra novo usuário com e-mail e senha
  /// POST /api/v1/auth/registrar
  /// Retorna o token JWT
  Future<String> registrar({
    required String id,
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/registrar');
    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'id': id,
          'nome': nome,
          'email': email,
          'telefone': telefone,
          'senha': senha,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> dados =
            jsonDecode(utf8.decode(response.bodyBytes));
        return dados['token'] as String;
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> erro =
            jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(erro['message'] ?? 'Erro ao registrar usuário');
      } else {
        throw Exception('Erro ao registrar usuário: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao registrar usuário: $e');
      rethrow;
    }
  }

  /// Realiza login com e-mail e senha
  /// POST /api/v1/auth/login
  /// Retorna o token JWT
  Future<String> login(String email, String senha) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login');
    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados =
            jsonDecode(utf8.decode(response.bodyBytes));
        return dados['token'] as String;
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> erro =
            jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(erro['message'] ?? 'E-mail ou senha inválidos');
      } else {
        throw Exception('Erro ao fazer login: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao fazer login: $e');
      rethrow;
    }
  }

  /// Envia código de verificação por SMS (telefone)
  /// POST /api/v1/verificacao-telefone/enviar-codigo
  Future<void> enviarCodigoTelefone(String telefone) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/verificacao-telefone/enviar-codigo');
    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'telefone': telefone}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final Map<String, dynamic> erro =
            jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(erro['message'] ?? 'Erro ao enviar código SMS');
      }
    } catch (e) {
      debugPrint('Erro ao enviar código SMS: $e');
      rethrow;
    }
  }

  /// Realiza login com SMS (telefone + código)
  /// POST /api/v1/auth/login-sms
  /// Se o telefone não existir, cadastra automaticamente
  /// Retorna o token JWT
  Future<String> loginComSms({
    required String telefone,
    required String codigo,
    String? nome,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login-sms');
    try {
      final body = <String, dynamic>{
        'telefone': telefone,
        'codigo': codigo,
      };
      if (nome != null && nome.isNotEmpty) {
        body['nome'] = nome;
      }

      final response = await _client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados =
            jsonDecode(utf8.decode(response.bodyBytes));
        return dados['token'] as String;
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final Map<String, dynamic> erro =
            jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(erro['message'] ?? 'Código inválido ou expirado');
      } else {
        throw Exception('Erro ao fazer login com SMS: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao fazer login com SMS: $e');
      rethrow;
    }
  }

  /// Realiza login social com Google
  /// POST /api/v1/auth/login-google
  /// Retorna o token JWT
  Future<String> loginGoogle(String idToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login-google');
    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados =
            jsonDecode(utf8.decode(response.bodyBytes));
        return dados['token'] as String;
      } else {
        throw Exception('Erro ao fazer login com Google: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao fazer login com Google: $e');
      rethrow;
    }
  }
}
