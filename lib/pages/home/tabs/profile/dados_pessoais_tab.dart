import 'package:flutter/material.dart';
import 'package:nhac_motoboy/globals/theme_colors.dart';

class DadosPessoaisTab extends StatelessWidget {
  const DadosPessoaisTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados Pessoais'), centerTitle: true),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            Text(
              'Foto de Perfil',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
              
            ),
            Icon(Icons.arrow_right, ),
          ],
        ),
      ),
      backgroundColor: AppColors.primaria.withValues(alpha: 0.3),
    );
  }
}
