import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuração central de acesso à API.
///
/// Duas correções críticas em relação à versão anterior:
///
/// 1. baseUrl era hardcoded para localhost/10.0.2.2 — funcionava só no
///    emulador local. Agora é configurável via --dart-define=API_BASE_URL=...
///    no build de produção, com o hostname local como fallback de dev.
///
/// 2. O token vivia só num `static String?` em memória: fechar o app (ou o
///    processo ser morto em background, comum em Android) apagava a sessão e
///    forçava login de novo toda vez, mesmo o token JWT ainda sendo válido.
///    Agora é persistido com SharedPreferences e recarregado em init(),
///    chamado uma vez no main() antes do runApp().
class ApiConfig {
  static const _chaveToken = 'nhac_motoboy_auth_token';

  static String? _authToken;
  static bool _inicializado = false;

  /// URL base da API. Em produção, passe no build:
  ///   flutter build apk --dart-define=API_BASE_URL=https://SEU-BACKEND.onrender.com
  /// Sem isso, cai no fallback de desenvolvimento local (só funciona em
  /// emulador/simulador na mesma máquina do backend).
  static String get baseUrl {
    const configurada = String.fromEnvironment('API_BASE_URL');
    if (configurada.isNotEmpty) {
      return configurada;
    }
    return 'https://backend-nhac.onrender.com'; // <- direto aqui
  }


  /// Base do WebSocket (STOMP), derivada de baseUrl trocando o esquema
  /// http(s) por ws(s). Backend expõe o endpoint nativo em /ws-native.
  static String get wsUrl {
    final http = baseUrl;
    final semEsquema = http.replaceFirst(RegExp(r'^https?://'), '');
    final wss = http.startsWith('https://') ? 'wss://' : 'ws://';
    return '$wss$semEsquema/ws-native';
  }

  /// Deve ser chamado uma vez, com await, antes de runApp(). Recarrega o
  /// token persistido da sessão anterior, se existir.
  static Future<void> init() async {
    if (_inicializado) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(_chaveToken);
    } catch (e) {
      debugPrint('Erro ao restaurar sessão salva: $e');
    }
    _inicializado = true;
  }

  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chaveToken, token);
    } catch (e) {
      debugPrint('Erro ao persistir token de sessão: $e');
    }
  }

  static Future<void> limparSessao() async {
    _authToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chaveToken);
    } catch (e) {
      debugPrint('Erro ao limpar sessão salva: $e');
    }
  }

  static String? get authToken => _authToken;

  static bool get temSessaoSalva => _authToken != null && _authToken!.isNotEmpty;

  static Map<String, String> get headers {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Identifica pro backend que esta requisição vem do app do motoboy —
      // usado em AuthController.validarOrigemApp (backend) para bloquear
      // contas LOJISTA/FUNCIONARIO logando aqui, mesmo via Google (que
      // autentica automaticamente sem pedir confirmação de qual conta usar).
      'X-App-Origin': 'motoboy',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      map['Authorization'] = 'Bearer $_authToken';
    }
    return map;
  }
}
