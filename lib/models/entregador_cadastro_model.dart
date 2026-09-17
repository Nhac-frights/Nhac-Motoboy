/// Modelo que representa a resposta do cadastro de entregador
class EntregadorCadastroModel {
  final String id;
  final String usuarioId;
  final String? cnh;
  final String? placaVeiculo;
  final String? tipoVeiculo; // MOTO | BICICLETA | CARRO
  final String statusOperacional; // OFFLINE | ONLINE | EM_ENTREGA
  final DateTime? dataCadastro;

  EntregadorCadastroModel({
    required this.id,
    required this.usuarioId,
    this.cnh,
    this.placaVeiculo,
    this.tipoVeiculo,
    required this.statusOperacional,
    this.dataCadastro,
  });

  factory EntregadorCadastroModel.fromJson(Map<String, dynamic> json) {
    return EntregadorCadastroModel(
      id: json['id']?.toString() ?? '',
      usuarioId: json['usuarioId']?.toString() ?? '',
      cnh: json['cnh']?.toString(),
      placaVeiculo: json['placaVeiculo']?.toString(),
      tipoVeiculo: json['tipoVeiculo']?.toString(),
      statusOperacional: json['statusOperacional']?.toString() ?? 'OFFLINE',
      dataCadastro: json['dataCadastro'] != null
          ? DateTime.parse(json['dataCadastro'].toString())
          : null,
    );
  }
}

/// Modelo que representa um erro de negócio retornado pela API
class ErroPadraoDTO {
  final int status;
  final String mensagem;
  final String? caminho;
  final DateTime? timestamp;

  ErroPadraoDTO({
    required this.status,
    required this.mensagem,
    this.caminho,
    this.timestamp,
  });

  factory ErroPadraoDTO.fromJson(Map<String, dynamic> json) {
    return ErroPadraoDTO(
      status: json['status'] as int? ?? 0,
      mensagem: json['mensagem']?.toString() ?? 'Erro desconhecido',
      caminho: json['caminho']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : null,
    );
  }
}
