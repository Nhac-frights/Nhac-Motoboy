import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/auth/continuar_senha.dart';
import '../pages/auth/insira_telefone.dart';
import '../pages/auth/verificacao_numero.dart';
import '../pages/bem_vindo_motoca.dart';
import '../pages/email_motoca.dart';
import '../pages/home/home_motoca_page.dart';
import '../pages/home/tabs/profile/dados_pessoais_tab.dart';
import '../pages/home/tabs/profile/editar_dados_bancarios_page.dart';
import '../pages/home/tabs/profile/editar_documentos_page.dart';
import '../pages/home/tabs/profile/editar_email_page.dart';
import '../pages/home/tabs/profile/editar_foto_page.dart';
import '../pages/home/tabs/profile/editar_nome_page.dart';
import '../pages/home/tabs/profile/editar_senha_page.dart';
import '../pages/home/tabs/profile/editar_telefone_page.dart';
import '../pages/home/tabs/profile/editar_veiculo_page.dart';

class _SlideRightToLeftPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _SlideRightToLeftPageRoute({
    required this.child,
    required super.settings,
  });

  final Widget child;

  @override
  Widget buildContent(BuildContext context) => child;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 350);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInQuart,
    );
    final curvedSecondaryAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInQuart,
    );

    final enterTween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero);
    final exitTween = Tween(begin: Offset.zero, end: const Offset(-0.25, 0.0));

    final Widget page = SlideTransition(
      position: enterTween.animate(curvedAnimation),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D201C).withValues(alpha: 0.08),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
    );

    return SlideTransition(
      position: exitTween.animate(curvedSecondaryAnimation),
      child: page,
    );
  }
}

class SlideRightToLeftPage<T> extends Page<T> {
  const SlideRightToLeftPage({
    required super.key,
    required this.child,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return _SlideRightToLeftPageRoute<T>(
      child: child,
      settings: this,
    );
  }
}

Page _buildPage({required LocalKey key, required Widget child}) {
  return SlideRightToLeftPage(key: key, child: child);
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const BemVindoMotoca(),
      ),
    ),
    GoRoute(
      path: '/email-motoca',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const EmailMotocaPage(),
      ),
    ),
    GoRoute(
      path: '/continuar-senha',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const ContinuarSenhaPage(),
      ),
    ),
    GoRoute(
      path: '/insira-telefone',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const InsiraTelefonePage(),
      ),
    ),
    GoRoute(
      path: '/verificacao-numero',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const VerificacaoNumeroPage(),
      ),
    ),
    GoRoute(
      path: '/home-motoca',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const HomeMotocaPage(),
      ),
    ),
    GoRoute(
      path: '/home-page',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const HomeMotocaPage(),
      ),
    ),
    GoRoute(
      path: '/dados-pessoais',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const DadosPessoaisTab(),
      ),
    ),
    GoRoute(
      path: '/editar-foto',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const EditarFotoPage(),
      ),
    ),
    GoRoute(
      path: '/editar-nome',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const EditarNomePage(),
      ),
    ),
    GoRoute(
      path: '/editar-email',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const EditarEmailPage(),
      ),
    ),
    GoRoute(
      path: '/editar-telefone',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const EditarTelefonePage(),
      ),
    ),
    GoRoute(
      path: '/editar-documentos',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const EditarDocumentosPage(),
      ),
    ),
    GoRoute(
      path: '/editar-veiculo',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const EditarVeiculoPage(),
      ),
    ),
    GoRoute(
      path: '/editar-dados-bancarios',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const EditarDadosBancariosPage(),
      ),
    ),
    GoRoute(
      path: '/editar-senha',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const EditarSenhaPage(),
      ),
    ),
  ],
);
