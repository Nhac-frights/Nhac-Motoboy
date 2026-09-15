import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../globals/theme_colors.dart';
import '../../models/rota_model.dart';

class MapaRotaWidget extends StatelessWidget {
  final RotaModel rota;

  const MapaRotaWidget({super.key, required this.rota});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.bordaInativa, width: 1),
      ),
      child: Stack(
        children: [
          // Canvas do traçado da Polyline e pontos no mapa
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: SizedBox(
              height: 280.h,
              width: double.infinity,
              child: CustomPaint(
                painter: _RotaCanvasPainter(
                  waypoints: rota.waypoints.isNotEmpty
                      ? rota.waypoints
                      : [rota.origem, rota.destino],
                ),
              ),
            ),
          ),

          // Card flutuante superior com Distância e Tempo Estimado (ETA)
          Positioned(
            top: 14.h,
            left: 14.w,
            right: 14.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_bike_rounded, color: AppColors.primaria, size: 20.r),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distância',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 10.sp,
                              color: AppColors.desabilitado,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${rota.distanciaKm.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.texto,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(height: 24.h, width: 1.w, color: AppColors.bordaInativa),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Color(0xFF2E7D32), size: 20),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tempo Estimado',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 10.sp,
                              color: AppColors.desabilitado,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '~${rota.duracaoEstimadaMinutos} min',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Legenda inferior de Coleta e Entrega
          Positioned(
            bottom: 12.h,
            left: 14.w,
            right: 14.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPinLegenda(
                  cor: AppColors.primaria,
                  texto: 'Coleta: ${rota.lojaNome}',
                  icone: Icons.store_rounded,
                ),
                _buildPinLegenda(
                  cor: const Color(0xFF2E7D32),
                  texto: 'Destino: Cliente',
                  icone: Icons.location_on_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinLegenda({required Color cor, required String texto, required IconData icone}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: 14.r),
          SizedBox(width: 4.w),
          Text(
            texto,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.texto,
            ),
          ),
        ],
      ),
    );
  }
}

class _RotaCanvasPainter extends CustomPainter {
  final List<CoordenadaModel> waypoints;

  _RotaCanvasPainter({required this.waypoints});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fundo com grid sutil simulando mapa de ruas
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    const double step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (waypoints.isEmpty) return;

    // Normalização das coordenadas para os limites do Canvas com margem
    double minLat = waypoints.first.latitude;
    double maxLat = waypoints.first.latitude;
    double minLng = waypoints.first.longitude;
    double maxLng = waypoints.first.longitude;

    for (var p in waypoints) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    final latRange = (maxLat - minLat).abs() > 0.0001 ? (maxLat - minLat).abs() : 0.01;
    final lngRange = (maxLng - minLng).abs() > 0.0001 ? (maxLng - minLng).abs() : 0.01;

    const double margin = 45.0;
    final drawWidth = size.width - (margin * 2);
    final drawHeight = size.height - (margin * 2);

    Offset toCanvasOffset(CoordenadaModel coord) {
      final normX = (coord.longitude - minLng) / lngRange;
      final normY = (maxLat - coord.latitude) / latRange; // Inversão do eixo Y
      return Offset(
        margin + (normX * drawWidth),
        margin + (normY * drawHeight),
      );
    }

    // 2. Traçado da Polyline (Sombra e linha principal)
    final path = Path();
    final firstPoint = toCanvasOffset(waypoints.first);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < waypoints.length; i++) {
      final point = toCanvasOffset(waypoints[i]);
      path.lineTo(point.dx, point.dy);
    }

    // Linha de sombra / contorno
    final borderPaint = Paint()
      ..color = const Color(0xFF1E3A8A).withValues(alpha: 0.25)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // Linha principal do trajeto (Azul elétrico / rota)
    final routePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, routePaint);

    // 3. Marcador de Origem (Restaurante)
    final origemOffset = toCanvasOffset(waypoints.first);
    _drawMarkerPin(canvas, origemOffset, AppColors.primaria, 'A');

    // 4. Marcador de Destino (Cliente)
    final destinoOffset = toCanvasOffset(waypoints.last);
    _drawMarkerPin(canvas, destinoOffset, const Color(0xFF2E7D32), 'B');
  }

  void _drawMarkerPin(Canvas canvas, Offset offset, Color color, String label) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(offset.translate(0, 2), 12, shadowPaint);

    final circlePaint = Paint()..color = color;
    canvas.drawCircle(offset, 12, circlePaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(offset, 5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _RotaCanvasPainter oldDelegate) {
    return oldDelegate.waypoints != waypoints;
  }
}
