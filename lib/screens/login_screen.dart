import 'package:flutter/material.dart';
import 'selecao_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  void _entrar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelecaoScreen()),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: size.height * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo horizontal: ícone + QFLY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flight,
                        size: isLandscape ? size.height * 0.12 : 50,
                        color: Colors.white,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'QFLY',
                        style: TextStyle(
                          fontSize: isLandscape ? size.height * 0.12 : 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: size.height * 0.01),
                  
                  Text(
                    'Sistema de Instrução Aeronáutica',
                    style: TextStyle(
                      fontSize: isLandscape ? size.height * 0.03 : 12,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1,
                    ),
                  ),
                  
                  SizedBox(height: size.height * 0.04),
                  
                  // Card de login compacto
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: isLandscape ? size.width * 0.5 : size.width * 0.8,
                    ),
                    padding: EdgeInsets.all(size.height * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campos lado a lado
                        Row(
                          children: [
                            // Nome
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: Colors.blue.shade700,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Instrutor',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _nomeController,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: 'Nome',
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      isDense: true,
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(width: size.width * 0.02),
                            
                            // Senha
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: Colors.blue.shade700,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Senha (opcional)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _senhaController,
                                    obscureText: true,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: '••••••',
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      isDense: true,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _entrar(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: size.height * 0.02),
                        
                        // Botão minimalista centralizado
                        Center(
                          child: SizedBox(
                            width: isLandscape ? size.width * 0.15 : size.width * 0.4,
                            child: ElevatedButton(
                              onPressed: _entrar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.015,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'ENTRAR',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: size.height * 0.015),
                        
                        // Nota dev mode compacta
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.amber.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber.shade700,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Dev Mode: aceita qualquer nome',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}