========================================================================
                      ★  Discord Unlock  ★
========================================================================

Este projeto é uma ferramenta desenvolvida por Stefy Stars para otimização
e estabilização de conexão durante transmissões de tela no Discord.

------------------------------------------------------------------------
✦ O que o programa faz?
------------------------------------------------------------------------
O Discord Unlock auxilia na inicialização do Discord de forma otimizada para
contornar instabilidades de rede durante chamadas e transmissões de vídeo.

Funcionalidades principais:
1. Localiza automaticamente a instalação do Discord no sistema.
2. Encerra com segurança qualquer instância ativa do Discord.
3. Valida sua chave de acesso em tempo real com o servidor online.
4. Carrega a lista de proxies atualizada diretamente do repositório no GitHub.
5. Inicia o Discord injetando as configurações de proxy apenas na fase de 
   autenticação de login (áudio, vídeo e fluxos de alta banda bypassam o 
   proxy automaticamente para garantir o menor ping possível).

------------------------------------------------------------------------
✦ Validação de Acesso (Chave de Ativação)
------------------------------------------------------------------------
O programa conta com um sistema de proteção e controle de licença:
* Na primeira execução, o programa solicitará uma Chave de Ativação.
* A chave digitada será validada contra a lista de chaves ativas em seu GitHub.
* Uma vez ativada, a licença é salva localmente, mas será obrigatoriamente 
  re-verificada online a cada inicialização para segurança do sistema.
* Se você estiver offline ou se a chave for revogada no GitHub, o acesso 
  será bloqueado.

------------------------------------------------------------------------
✦ Como Gerenciar Chaves e IPs (Administrador)
------------------------------------------------------------------------
Todas as informações de liberação são gerenciadas online através do repositório público:
https://github.com/stefystars-one/discord-unlock

1. Lista de Proxies ("proxies.txt"):
   * O programa carrega os IPs exclusivamente da internet através deste arquivo no GitHub. 
   * Digite um proxy por linha (exemplo: socks5://1.2.3.4:1080).

2. Chaves de Acesso e Bloqueio por Computador ("keys.txt"):
   * Salve as chaves autorizadas uma por linha.
   * Para vincular uma chave a um computador específico (impedindo que ela seja compartilhada com outras pessoas), escreva a chave no formato "CHAVE:HWID". Exemplo:
     STEFY-KEY-123:0E9F8A1B
   * Quando o programa for executado, ele exigirá que o ID de Hardware (HWID) do usuário seja exatamente o mesmo cadastrado ao lado da chave.
3. Sistema de Atualização Automática ("version.txt"):
   * O programa verifica se há novas versões disponíveis no arquivo "version.txt" no GitHub.
   * Para lançar uma atualização para todos os usuários:
     a) Suba o novo arquivo executável (".exe") no seu GitHub.
     b) Altere o número da versão no "version.txt" (ex: de 1.0 para 1.1).
   * Todos os clientes baixarão a nova versão e se reiniciarão automaticamente na próxima vez que abrirem o aplicativo, mantendo suas chaves salvas e limpando arquivos temporários!

------------------------------------------------------------------------
✦ Como Usar
------------------------------------------------------------------------
O diretório disponibiliza versões para o aplicativo Desktop e para o Navegador (Google Chrome / Edge):

1. Versões Desktop (Abre o aplicativo oficial do Discord instalado no Windows):
   * "DiscordUnlock.exe": Ícone padrão com cadeado dourado clássico.
   * "DiscordUnlock_Special.exe": Ícone especial gamer transparente.

2. Versões Web / Navegador (Abre o Discord Web diretamente no Navegador Padrão com o proxy configurado):
   * "DiscordUnlock_Web.exe": Versão navegador com ícone padrão.
   * "DiscordUnlock_Web_Special.exe": Versão navegador com ícone especial gamer.

Instruções para execução:
* Versão Desktop: Feche o aplicativo do Discord antes de abrir o DiscordUnlock.exe.
* Versão Web / Navegador: Apenas execute o DiscordUnlock_Web.exe (ele abrirá seu navegador padrão diretamente no Discord Web com o proxy injetado).
* Durante a execução, você pode pressionar ESPAÇO ou T no CMD a qualquer momento para trocar de servidor proxy instantaneamente.
* Na primeira execução, digite sua chave de ativação quando solicitado.
* O sistema envia notificações detalhadas no Discord informando status de ativação, HWID e motivo de qualquer erro caso ocorra.

========================================================================
                      Criado por ★ Stefy Stars
========================================================================
