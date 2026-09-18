import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/entrega_ativa_model.dart';
import '../models/oferta_entrega_model.dart';
import '../models/rota_model.dart';
import '../models/entregador_cadastro_model.dart';
import '../services/entregador_service.dart';
import '../services/location_service.dart';

class EntregaProvider extends ChangeNotifier {
  final EntregadorService _service;
  final LocationService _locationService;

  bool _estaOnline = false;
  bool _isLoading = false;
  bool _isCadastrado = false;
  EntregadorCadastroModel? _perfilEntregador;
  OfertaEntregaModel? _ofertaAtual;
  EntregaAtivaModel? _entregaAtiva;
  RotaModel? _rotaAtual;

  /// Erro de GPS pronto pra exibir na UI (permissão negada, servico desligado
  /// etc). null quando esta tudo certo.
  String? _erroLocalizacao;

  int _segundosRestantes = 45;
  Timer? _heartbeatTimer;
  Timer? _ofertasTimer;
  Timer? _countdownTimer;
  StreamSubscription<Position>? _posicaoSubscription;

  // Posicao GPS. null ate a primeira leitura real chegar - sem fallback pra
  // coordenada fixa: preferimos nao enviar heartbeat a mandar uma posicao
  // falsa que quebra silenciosamente o calculo de distancia do despacho.
  double? _latitudeAtual;
  double? _longitudeAtual;

  EntregaProvider({EntregadorService? service, LocationService? locationService})
      : _service = service ?? EntregadorService(),
        _locationService = locationService ?? LocationService();

  bool get estaOnline => _estaOnline;
  bool get isLoading => _isLoading;
  bool get isCadastrado => _isCadastrado;
  EntregadorCadastroModel? get perfilEntregador => _perfilEntregador;
  OfertaEntregaModel? get ofertaAtual => _ofertaAtual;
  EntregaAtivaModel? get entregaAtiva => _entregaAtiva;
  RotaModel? get rotaAtual => _rotaAtual;
  int get segundosRestantes => _segundosRestantes;
  double? get latitudeAtual => _latitudeAtual;
  double? get longitudeAtual => _longitudeAtual;
  String? get erroLocalizacao => _erroLocalizacao;

  /// true quando a entrega ativa ja foi coletada na loja (SAIU_ENTREGA) -
  /// controla se a UI mostra "Confirmar retirada" ou "Concluir entrega".
  bool get entregaColetada => _entregaAtiva?.statusPedido == 'SAIU_ENTREGA';

  /// Realiza o cadastro do entregador (Fase 5)
  Future<EntregadorCadastroModel> cadastrarEntregador({
    required String cnh,
    required String placaVeiculo,
    required String tipoVeiculo,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final resultado = await _service.cadastrarEntregador(
        cnh: cnh,
        placaVeiculo: placaVeiculo,
        tipoVeiculo: tipoVeiculo,
      );
      _perfilEntregador = resultado;
      _isCadastrado = true;
      return resultado;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifica se o usuario ja tem cadastro como entregador
  Future<void> verificarCadastro() async {
    try {
      _perfilEntregador = await _service.obterPerfil();
      _isCadastrado = _perfilEntregador != null;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao verificar cadastro: $e');
      _isCadastrado = false;
      notifyListeners();
    }
  }

  Future<void> alternarStatusOnline(bool novoStatus) async {
    if (novoStatus) {
      // Nao faz sentido ficar ONLINE sem GPS: o despacho no backend calcula
      // distancia pela posicao enviada, e sem heartbeat o motoboy nunca
      // aparece como candidato a nenhuma oferta.
      final erro = await _locationService.solicitarPermissao();
      if (erro != null) {
        _erroLocalizacao = erro;
        notifyListeners();
        return;
      }
      _erroLocalizacao = null;
    }

    _isLoading = true;
    notifyListeners();

    final statusOperacional = novoStatus ? 'ONLINE' : 'OFFLINE';
    final sucesso = await _service.atualizarStatus(statusOperacional);
    _isLoading = false;

    if (sucesso || !novoStatus) {
      _estaOnline = novoStatus;
      if (_estaOnline) {
        await _iniciarCicloOnline();
      } else {
        _pararCicloOnline();
      }
    }
    notifyListeners();
  }

  Future<void> _iniciarCicloOnline() async {
    // 1. Leitura pontual imediata, pra nao esperar o stream continuo estabilizar.
    final posicaoInicial = await _locationService.obterPosicaoAtual();
    if (posicaoInicial != null) {
      _latitudeAtual = posicaoInicial.latitude;
      _longitudeAtual = posicaoInicial.longitude;
      await _enviarLocalizacaoAtual();
    }

    // 2. Stream continuo de GPS: atualiza a posicao local e reenvia sempre
    // que o motoboy se move (ver distanceFilter no LocationService).
    _posicaoSubscription?.cancel();
    _posicaoSubscription = _locationService.streamDePosicao().listen((posicao) {
      _latitudeAtual = posicao.latitude;
      _longitudeAtual = posicao.longitude;
      notifyListeners();
      _enviarLocalizacaoAtual();
    }, onError: (e) {
      debugPrint('Erro no stream de GPS: $e');
    });

    // 3. Heartbeat de seguranca a cada 15s, mesmo parado (distanceFilter do
    // stream nao dispara se o motoboy estiver esperando ofertas sem se mover).
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _enviarLocalizacaoAtual();
    });

    // 4. Verificacao de novas ofertas de despacho a cada 5 segundos
    _ofertasTimer?.cancel();
    _ofertasTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _verificarNovasOfertas();
    });

    // 5. Checa se ja tem entrega ativa pendente
    await carregarEntregaAtiva();
  }

  void _pararCicloOnline() {
    _heartbeatTimer?.cancel();
    _ofertasTimer?.cancel();
    _countdownTimer?.cancel();
    _posicaoSubscription?.cancel();
    _ofertaAtual = null;
  }

  Future<void> _enviarLocalizacaoAtual() async {
    if (!_estaOnline) return;
    if (_latitudeAtual == null || _longitudeAtual == null) return;
    await _service.enviarLocalizacao(_latitudeAtual!, _longitudeAtual!);
  }

  Future<void> _verificarNovasOfertas() async {
    if (!_estaOnline || _entregaAtiva != null || _ofertaAtual != null) return;

    final ofertas = await _service.buscarOfertasPendentes();
    if (ofertas.isNotEmpty) {
      _definirNovaOferta(ofertas.first);
    }
  }

  void _definirNovaOferta(OfertaEntregaModel oferta) {
    _ofertaAtual = oferta;
    _segundosRestantes = oferta.tempoRestanteSegundos > 0 ? oferta.tempoRestanteSegundos : 45;
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 0) {
        _segundosRestantes--;
        notifyListeners();
      } else {
        timer.cancel();
        recusarOfertaAtual();
      }
    });
  }

  Future<bool> aceitarOfertaAtual() async {
    if (_ofertaAtual == null) return false;

    _countdownTimer?.cancel();
    _isLoading = true;
    notifyListeners();

    final entrega = await _service.aceitarOferta(_ofertaAtual!.id);
    _isLoading = false;

    if (entrega != null) {
      _entregaAtiva = entrega;
      _ofertaAtual = null;
      notifyListeners();

      // Carrega a rota calculada para o mapa
      await carregarRota(entrega.pedidoId);
      return true;
    } else {
      _ofertaAtual = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> recusarOfertaAtual() async {
    if (_ofertaAtual == null) return;

    _countdownTimer?.cancel();
    final ofertaId = _ofertaAtual!.id;
    _ofertaAtual = null;
    notifyListeners();

    await _service.recusarOferta(ofertaId);
  }

  Future<void> carregarEntregaAtiva() async {
    final entrega = await _service.obterEntregaAtiva();
    if (entrega != null) {
      _entregaAtiva = entrega;
      notifyListeners();
      await carregarRota(entrega.pedidoId);
    }
  }

  Future<void> carregarRota(String pedidoId) async {
    _rotaAtual = await _service.obterRota(pedidoId);
    notifyListeners();
  }

  /// Confirma a retirada do pedido na loja. Chamar quando o motoboy chega no
  /// restaurante e aperta "Confirmar retirada" - move PREPARANDO -> SAIU_ENTREGA
  /// no backend (ver EntregaAtivaModel.statusPedido / entregaColetada acima).
  Future<bool> confirmarColeta() async {
    if (_entregaAtiva == null) return false;

    _isLoading = true;
    notifyListeners();

    final atualizado = await _service.coletarPedido(_entregaAtiva!.pedidoId);
    _isLoading = false;

    if (atualizado != null) {
      _entregaAtiva = atualizado;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  /// Da baixa na entrega. Antes, isto so limpava o estado local e nunca
  /// chamava o backend - o pedido nunca virava ENTREGUE e o entregador ficava
  /// travado em EM_ENTREGA, sem receber novas ofertas nunca mais.
  Future<bool> concluirEntregaAtual() async {
    if (_entregaAtiva == null) return false;

    _isLoading = true;
    notifyListeners();

    final sucesso = await _service.concluirEntrega(_entregaAtiva!.pedidoId);
    _isLoading = false;

    if (sucesso) {
      _entregaAtiva = null;
      _rotaAtual = null;
    }
    notifyListeners();
    return sucesso;
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _ofertasTimer?.cancel();
    _countdownTimer?.cancel();
    _posicaoSubscription?.cancel();
    super.dispose();
  }
}
