import 'dart:async';
import 'package:flutter/material.dart';

import '../models/entrega_ativa_model.dart';
import '../models/oferta_entrega_model.dart';
import '../models/rota_model.dart';
import '../services/entregador_service.dart';

class EntregaProvider extends ChangeNotifier {
  final EntregadorService _service;

  bool _estaOnline = false;
  bool _isLoading = false;
  OfertaEntregaModel? _ofertaAtual;
  EntregaAtivaModel? _entregaAtiva;
  RotaModel? _rotaAtual;

  int _segundosRestantes = 45;
  Timer? _heartbeatTimer;
  Timer? _ofertasTimer;
  Timer? _countdownTimer;

  // Posição GPS inicial (Marco Zero / Centro)
  double _latitudeAtual = -23.55052;
  double _longitudeAtual = -46.63330;

  EntregaProvider({EntregadorService? service}) : _service = service ?? EntregadorService();

  bool get estaOnline => _estaOnline;
  bool get isLoading => _isLoading;
  OfertaEntregaModel? get ofertaAtual => _ofertaAtual;
  EntregaAtivaModel? get entregaAtiva => _entregaAtiva;
  RotaModel? get rotaAtual => _rotaAtual;
  int get segundosRestantes => _segundosRestantes;
  double get latitudeAtual => _latitudeAtual;
  double get longitudeAtual => _longitudeAtual;

  Future<void> alternarStatusOnline(bool novoStatus) async {
    _isLoading = true;
    notifyListeners();

    final sucesso = await _service.atualizarStatus(novoStatus);
    _isLoading = false;

    if (sucesso || !novoStatus) {
      _estaOnline = novoStatus;
      if (_estaOnline) {
        _iniciarCicloOnline();
      } else {
        _pararCicloOnline();
      }
    }
    notifyListeners();
  }

  void _iniciarCicloOnline() {
    // 1. Envio imediato da localização
    _enviarLocalizacaoAtual();

    // 2. Heartbeat de GPS a cada 15 segundos
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _enviarLocalizacaoAtual();
    });

    // 3. Verificação de novas ofertas de despacho a cada 5 segundos
    _ofertasTimer?.cancel();
    _ofertasTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _verificarNovasOfertas();
    });

    // 4. Checa se já tem entrega ativa pendente
    carregarEntregaAtiva();
  }

  void _pararCicloOnline() {
    _heartbeatTimer?.cancel();
    _ofertasTimer?.cancel();
    _countdownTimer?.cancel();
    _ofertaAtual = null;
  }

  Future<void> _enviarLocalizacaoAtual() async {
    if (!_estaOnline) return;
    await _service.enviarLocalizacao(_latitudeAtual, _longitudeAtual);
  }

  void atualizarCoordenadas(double lat, double lng) {
    _latitudeAtual = lat;
    _longitudeAtual = lng;
    if (_estaOnline) {
      _enviarLocalizacaoAtual();
    }
    notifyListeners();
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

  void concluirEntrega() {
    _entregaAtiva = null;
    _rotaAtual = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _ofertasTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
