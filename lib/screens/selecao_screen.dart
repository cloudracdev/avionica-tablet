import 'package:flutter/material.dart';

class SelecaoScreen extends StatefulWidget {
  const SelecaoScreen({Key? key}) : super(key: key);

  @override
  State<SelecaoScreen> createState() => _SelecaoScreenState();
}

class _SelecaoScreenState extends State<SelecaoScreen> {
  final TextEditingController _aviaoController = TextEditingController();
  final TextEditingController _alunoController = TextEditingController();
  final TextEditingController _aulaController = TextEditingController();

  void _avancar() {
    // TODO: Navegar para próxima tela (ConnectionScreen)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Seleção confirmada! (Próxima tela em breve)'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _aviaoController.dispose();
    _alunoController.dispose();
    _aulaController.dispose();
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.teal.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header com título e botão voltar
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.02,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      iconSize: isLandscape ? size.height * 0.05 : 24,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Icon(
                      Icons.checklist_rtl,
                      color: Colors.white,
                      size: isLandscape ? size.height * 0.08 : 32,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'Seleção de Voo',
                      style: TextStyle(
                        fontSize: isLandscape ? size.height * 0.06 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Card central com campos
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isLandscape ? size.width * 0.7 : size.width * 0.9,
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
                          // Linha 1: Avião + Aluno
                          Row(
                            children: [
                              // Avião
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flight,
                                          color: Colors.orange.shade700,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Aeronave',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _aviaoController,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'PT-XXX ou deixe vazio',
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

                              SizedBox(width: size.width * 0.03),

                              // Aluno
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.school,
                                          color: Colors.green.shade700,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Aluno',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _alunoController,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'Nome ou deixe vazio',
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
                            ],
                          ),

                          SizedBox(height: size.height * 0.025),

                          // Linha 2: Tipo de Aula (campo único centralizado)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.menu_book,
                                    color: Colors.purple.shade700,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tipo de Aula',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _aulaController,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Ex: Voo Local, Navegação, etc ou vazio',
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
                                onSubmitted: (_) => _avancar(),
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.025),

                          // Botão avançar
                          Center(
                            child: SizedBox(
                              width: isLandscape ? size.width * 0.2 : size.width * 0.5,
                              child: ElevatedButton(
                                onPressed: _avancar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.018,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'AVANÇAR',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: isLandscape ? size.height * 0.03 : 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: size.height * 0.015),

                          // Info dev mode
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
                                    'Dev Mode: todos os campos podem ficar vazios',
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}