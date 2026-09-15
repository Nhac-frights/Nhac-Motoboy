import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/entrega_ativa_model.dart';
import '../models/oferta_entrega_model.dart';
import '../models/rota_model.dart';
import 'api_config.dart';

class EntregadorService {
  final http.Client _client;

  EntregadorService({http.Client? client}) : _client = client ?? http.Client();

  /// Altera o status operacional do motoboy no backend (ONLINE ou OFFLINE)
  Future<bool> atualizarStatus(bool estaOnline) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregador/status');
    try {
      final response = await _client.patch(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'statusOperacional': estaOnline ? 'ONLINE' : 'OFFLINE',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erro ao atualizar status do entregador: $e');
      return false;
    }
  }

  /// Heartbeat periódico de GPS (envia latitude e longitude atuais)
  Future<bool> enviarLocalizacao(double latitude, double longitude) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregador/localizacao');
    try {
      final response = await _client.patch(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erro ao enviar localização GPS: $e');
      return false;
    }
  }

  /// Consulta ofertas de corridas pendentes para o entregador logado
  Future<List<OfertaEntregaModel>> buscarOfertasPendentes() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregas/ofertas/pendentes');
    try {
      final response = await _client.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        return dados.map((item) => OfertaEntregaModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao buscar ofertas pendentes: $e');
      return [];
    }
  }

  /// Aceita uma oferta de entrega pendente
  Future<EntregaAtivaModel?> aceitarOferta(String ofertaId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregas/ofertas/$ofertaId/aceitar');
    try {
      final response = await _client.post(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        return EntregaAtivaModel.fromJson(dados);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao aceitar oferta: $e');
      return null;
    }
  }

  /// Recusa uma oferta de corrida
  Future<bool> recusarOferta(String ofertaId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregas/ofertas/$ofertaId/recusar');
    try {
      final response = await _client.post(url, headers: ApiConfig.headers);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Erro ao recusar oferta: $e');
      return false;
    }
  }

  /// Obtém a entrega que o motoboy está realizando no momento
  Future<EntregaAtivaModel?> obterEntregaAtiva() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregas/ativa');
    try {
      final response = await _client.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        return EntregaAtivaModel.fromJson(dados);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar entrega ativa: $e');
      return null;
    }
  }

  /// Consulta a rota traçada com Polyline para o mapa
  Future<RotaModel?> obterRota(String pedidoId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregas/$pedidoId/rota');
    try {
      final response = await _client.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        return RotaModel.fromJson(dados);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao obter rota de entrega: $e');
      return null;
    }
  }
}
