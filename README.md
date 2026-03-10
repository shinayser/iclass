# iClass

Aplicação Flutter multi-módulo para criação e resolução de lições (exercícios de múltipla escolha), com suporte offline e sincronização automática.

## Como rodar

### Pré-requisitos

- **Flutter 3.41.3** — o projeto usa [FVM](https://fvm.app/) para gerenciar a versão. Se tiver o FVM instalado, basta rodar `fvm use` na raiz do projeto.
- **Melos** — usado para orquestrar o monorepo. Instalado como dev dependency do workspace.

### Passos

```bash
# 1. Instalar dependências (na raiz do projeto)
flutter pub get

# 2. Rodar o app
flutter run -d <device> --project packages/app

# 3. Rodar todos os testes unitários
melos run test --no-select
# ou individualmente:
flutter test packages/common
flutter test packages/teacher
flutter test packages/student
```

### Login
O app tem uma tela de login simples (sem autenticação real) para diferenciar as experiências de professor e aluno. 
* Para logar como professor, o usuário é `teacher` e a senha é `teacher123`.
* Para logar como aluno, o usuário é `student` e a senha é `student123`.

Após o login, o usuário será redirecionado automaticamente para a tela correspondente (home do professor ou do aluno).

## Architetura

O projeto é um **monorepo** gerenciado com Dart workspaces + Melos, dividido em cinco packages:

```
packages/
├── app/             # Entry-point do Flutter — inicializa módulos e rotas
├── common/          # Código compartilhado (entities, repositories, services, DI)
├── auth/            # Feature de autenticação (login)
├── teacher/         # Features do professor (home, criação e deleção de lições)
├── student/         # Features do aluno (home, responder lição)
└── design_system/   # Tema e componentes visuais reutilizáveis
```

### Camadas dentro de cada feature

O projeto segue **Clean Architecture** simplificada:

- **Domain** — Entities, Repository interfaces, Use Cases (ex: `FetchLessons`, `DeleteLesson`, `PersistLesson`).
- **Data** — Implementações de Repository e DataSources (ex: `SyncAwareLessonsRepository`, `FakeRemoteLessonsDataSource`).
- **Presentation** — Pages (widgets) e Controllers (BLoC/Cubit com `flutter_bloc`).

### Injeção de dependências

Usa **GetIt** encapsulado na classe `Injection`. Cada package expõe um `Module` que registra suas dependências no `init()`. O `main.dart` do app inicializa todos os módulos em sequência.

## Offline + Sync approach

A estratégia é **offline-first**: toda operação de escrita é persistida localmente antes de qualquer chamada remota.

### Componentes-chave

- **`LocalDatabase`** — abstração sobre `SharedPreferences` para persistência local (JSON serializado).
- **`RemoteLessonsDataSource`** — interface para o servidor remoto (atualmente simulado por `FakeRemoteLessonsDataSource` com delay artificial).
- **`ConnectivityService`** — monitora o estado de conexão via `connectivity_plus`.
- **`SyncService`** — observa mudanças de conectividade e dispara sincronização automática.

### Fluxo de escrita (save/delete)

1. A operação é gravada no banco local imediatamente (com `syncStatus: pending` no caso de save).
2. Se o dispositivo está online, tenta enviar ao servidor remoto.
   - **Sucesso** → marca como `synced` localmente.
   - **Falha** → mantém como `pending` (ou, no caso de delete, a remoção local já está aplicada).
3. Se o dispositivo está offline, a operação fica pendente.

### Fluxo de reconexão

1. `ConnectivityService` emite evento de que o dispositivo voltou a ficar online.
2. `SyncService` escuta esse evento e chama `syncPending()` no repository.
3. `syncPending()` busca todas as lições com `syncStatus: pending` e tenta enviá-las ao servidor uma a uma.
4. A UI reflete o estado de sincronização em tempo real (indicador "Sincronizando…" no AppBar + ícone de nuvem por lição pendente).

## Deep Links

O app suporta deep links para abrir lições diretamente. A URL de produção segue o formato:

```
https://iclass.com.br/student/home/lesson/{lessonId}/answer
```

Porém, deep links com scheme `https` exigem verificação de domínio (arquivo `assetlinks.json` hospedado no servidor). Como não há um domínio online configurado para esse projeto, foi registrado um **custom URL scheme** `iclass://` que funciona sem verificação de domínio.

### Testando no Android

1. Instale o app no emulador ou dispositivo:
   ```bash
   flutter run -d <device> --project packages/app
   ```

2. Em outro terminal, invoque o deep link via `adb`:
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "iclass:///student/home/lesson/16/answer"
   ```
   Substitua `16` pelo ID da lição desejada. O app abrirá diretamente na tela de resposta da lição.

### Compartilhamento

Na home do professor, cada lição possui um botão de compartilhamento (ícone de share) que gera a URL `https://iclass.com.br/student/home/lesson/{id}/answer`

## O que eu faria como melhorias futuras
Devido ao meu curto tempo para desenvolver o projeto (questões pessoais) e o meu desejo de fazê-lo sem auxílio de Agentes de IA, eu precisei fazer alguns trade offs para a entrega:
* Toda a persistência foi feita utilizando `SharedPreferences` por questão de simplicidade. Mas em um ambiente de produção real eu provavelmente usaria a biblioteca Hive (hive_ce) para persistência local, e para a camada de dados remotos, utilizaria uma API REST real ou GRPC.
* Outras simplificações foram feitas como por exemplo o login, que ao invés de retornar um token real apenas retorna o tipo do login do usuário. 

A feature de sincronização é funcional mas não está com a melhor experiência, pois está toda todando na thread principal. O que eu faria primeiro seria encapsular as chamadas do `SyncService` em um isolate, isso permitiria que a sincronização acontecesse em background sem travar a UI, e também permitiria que o usuário continuasse usando o app normalmente enquanto a sincronização acontece sem causar pausas na interface do usuário.

Sobre o uso de IA: 
* A maioria do app foi escrito manualmente, utilizando o copilot apenas para auto complete de boilerplate.
* A única funncionalidade escrita com Agente foi a da sincronização dos dados.