# Gestao Master

Aplicativo Flutter demonstrativo de organização financeira pessoal.
Atividade: **Splash Screen + Home Screen** — Prof.ª Andreza Quintas.

## Requisitos
- Flutter com Dart >= 3.4
- Android Studio ou VS Code com extensão Flutter
- Emulador Android ou dispositivo conectado

## Como executar
Abra um terminal na pasta `projeto_final_mobile` e execute:

```bash
flutter create . --project-name projeto_final_mobile --platforms android,web
flutter pub get
flutter run
```

> O comando `flutter create .` gera os arquivos nativos Android/Web, que não acompanham este pacote de código-fonte. Ele preserva `lib/main.dart`, assets e configurações fornecidos (confira o diff se sua versão do Flutter pedir substituições).

Para selecionar um emulador:
```bash
flutter devices
flutter run -d emulator-5554
```

## Funcionalidades
- Splash Screen com logo, animação e navegação automática após 2,6 segundos.
- Home Screen com saldo, receitas, despesas e movimentações demonstrativas.
- Navegação inferior para análises, extrato e perfil.
- Botão `+` para adicionar receitas e despesas na sessão atual.
- Tema escuro com identidade verde-esmeralda e logo PNG em assets.

**Importante:** os valores são ilustrativos e as alterações não persistem ao reiniciar. O aplicativo não acessa contas bancárias ou serviços externos.

## Entrega pelo GitHub
Crie um repositório público chamado `projeto_final_mobile`, faça commit do projeto (incluindo `lib/main.dart`, `assets/images/logo.png` e `pubspec.yaml`) e compartilhe o link com a professora.
