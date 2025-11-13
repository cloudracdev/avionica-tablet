// test/test_helper.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 Helper para testes com Riverpod
ProviderContainer createContainer() {
  return ProviderContainer();
}

/// 🎯 Dispose automático
void disposeContainer(ProviderContainer container) {
  container.dispose();
}