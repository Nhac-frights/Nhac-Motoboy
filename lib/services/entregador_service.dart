import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/entrega_ativa_model.dart';
import '../models/oferta_entrega_model.dart';
import '../models/rota_model.dart';
import '../models/entregador_cadastro_model.dart';
import '../models/historico_entrega_model.dart';
import '../models/ganhos_entregador_model.dart';
import 'api_config.dart';

class EntregadorService {
  final http.Client _client;

  EntregadorService({http.Client? client}) : _client = client ?? http.Client();

  /// Realiza o cadastro do entregador (Fase 5 - Contrato frontend/mobile)
  /// POST /api/v1/entregador/cadastro
  /// Retorna 201 com EntregadorCadastroModel ou lança exceção com ErroPadraoDTO
  Future<EntregadorCadastroModel> cadastrarEntregador({
    required String cnh,
    required String placaVeiculo,
    required String tipoVeiculo, // MOTO | BICICLETA | CARRO
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregador/cadastro');
    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'cnh': cnh,
          'placaVeiculo': placaVeiculo,
          'tipoVeiculo': tipoVeiculo,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> dados =
            jsonDecode(utf8.decode(response.bodyBytes));
        return EntregadorCadastroModel.fromJson(dados);
      } else if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 409) {
        // 400: dados inválidos; 401: sessão expirada/token inválido;
        // 409: CNH/placa já cadastrada em outro entregador.
        try {
          final Map<String, dynamic> erro =
              jsonDecode(utf8.decode(response.bodyBytes));
          final erroDto = ErroPadraoDTO.fromJson(erro);
          throw Exception(erroDto.mensagem);
        } on FormatException {
          // Corpo não veio em JSON (ex.: página de erro do servidor) - loga
          // o corpo bruto pra facilitar o diagnóstico em vez de mascarar
          // tudo como "Erro desconhecido".
          debugPrint(
              'Corpo de erro não era JSON (status ${response.statusCode}): ${response.body}');
          throw Exception('Não foi possível completar o cadastro (${response.statusCode}).');
        }
      } else {
        debugPrint(
            'Erro ao cadastrar entregador: status ${response.statusCode}, corpo: ${response.body}');
        throw Exception('Erro ao cadastrar entregador: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao cadastrar entregador: $e');
      rethrow;
    }
  }

  /// Obtém o perfil do entregador logado
  /// GET /api/v1/entregador/perfil
  /// Retorna 404 se o usuário não tiver cadastro como entregador
  Future<EntregadorCadastroModel?> obterPerfil() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregador/perfil');
    try {
      final response = await _client.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados =
            jsonDecode(utf8.decode(response.bodyBytes));
        return EntregadorCadastroModel.fromJson(dados);
      } else if (response.statusCode == 404) {
        // Usuário ainda não tem cadastro como entregador
        return null;
      } else {
        debugPrint('Erro ao obter perfil: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao obter perfil do entregador: $e');
      rethrow;
    }
  }

  /// Altera o status operacional do motoboy no backend (ONLINE ou OFFLINE)
  /// PATCH /api/v1/entregador/status
  Future<bool> atualizarStatus(String statusOperacional) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregador/status');
    try {
      final response = await _client.patch(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'statusOperacional': statusOperacional,
        }),
      );

      return response.statusCode == 200;
    } on http.ClientException catch (e) {
      // Trata erro 404 (IdNaoEncontradoException) - usuário não tem cadastro
      if (e is http.ClientException && e.toString().contains('404')) {
        debugPrint('Usuário não possui cadastro como entregador');
        rethrow;
      }
      debugPrint('Erro ao atualizar status do entregador: $e');
      return false;
    } catch (e) {
      debugPrint('Erro ao atualizar status do entregador: $e');
      return false;
    }
  }

  /// Heartbeat periódico de GPS (envia latitude e longitude atuais)
  /// PATCH /api/v1/entregador/localizacao
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

  /// Confirma a retirada do pedido na loja.
  /// POST /api/v1/entregas/{pedidoId}/coletar
  /// Move PREPARANDO -> SAIU_ENTREGA no backend. Sem chamar isto, a corrida
  /// nunca aparecia como "saiu para entrega" de verdade para cliente/loja.
  Future<EntregaAtivaModel?> coletarPedido(String pedidoId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregas/$pedidoId/coletar');
    try {
      final response = await _client.post(url, headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        return EntregaAtivaModel.fromJson(dados);
      }
      debugPrint('Erro ao coletar pedido: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Erro ao coletar pedido: $e');
      return null;
    }
  }

  /// Dá baixa na entrega (SAIU_ENTREGA -> ENTREGUE) e libera o entregador
  /// para voltar a receber ofertas.
  /// POST /api/v1/entregas/{pedidoId}/concluir
  ///
  /// Antes desta chamada existir, EntregaProvider.concluirEntrega() só
  /// limpava o estado local — o pedido nunca terminava no backend e o
  /// entregador ficava travado em EM_ENTREGA, sem receber novas corridas.
  Future<bool> concluirEntrega(String pedidoId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregas/$pedidoId/concluir');
    try {
      final response = await _client.post(url, headers: ApiConfig.headers);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Erro ao concluir entrega: $e');
      return false;
    }
  }

  /// Histórico paginado de corridas do entregador logado.
  /// GET /api/v1/entregador/entregas?status=&page=&size=
  /// status é opcional (ex.: 'ENTREGUE' para ver só as concluídas).
  Future<HistoricoEntregasPagina> buscarHistorico({String? status, int page = 0, int size = 20}) async {
    final query = {
      'page': '$page',
      'size': '$size',
      if (status != null) 'status': status,
    };
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregador/entregas').replace(queryParameters: query);
    try {
      final response = await _client.get(url, headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        return HistoricoEntregasPagina.fromJson(dados);
      }
      return HistoricoEntregasPagina.vazia();
    } catch (e) {
      debugPrint('Erro ao buscar histórico de entregas: $e');
      return HistoricoEntregasPagina.vazia();
    }
  }

  /// Resumo de ganhos por período.
  /// GET /api/v1/entregador/ganhos?periodo=HOJE|SETE_DIAS|TRINTA_DIAS
  Future<GanhosEntregadorModel?> buscarGanhos({String periodo = 'HOJE'}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/entregador/ganhos')
        .replace(queryParameters: {'periodo': periodo});
    try {
      final response = await _client.get(url, headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        return GanhosEntregadorModel.fromJson(dados);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar ganhos: $e');
      return null;
    }
  }
}
