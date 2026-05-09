#  Desafio Mobile - Ingresso.com

1 - Tecnologias e Frameworks

 Swift / SwiftUI: Interface declarativa e moderna.  
 MVVM (Model-View-ViewModel): Arquitetura para separação de responsabilidades.  
 Async/Await: Gerenciamento de concorrência e chamadas de rede.  
 XCTest: Testes unitários para lógica de negócio.
 
2 - Desafios Técnicos & Soluções

 Durante o desenvolvimento, implementei soluções para cenários reais encontrados na API:  

* Resiliência no Carregamento de Imagens:
    Implementei uma lógica de fallback no Event.swift para buscar diferentes tipos de imagens (PosterPortrait, PosterHorizontal ou imageFeatured) caso o campo principal esteja ausente.  
    Tratei especificamente o erro NSURLErrorCancelled no AsyncImage. Isso evita que o usuário veja ícones de erro durante um scroll rápido no LazyVGrid, mantendo a fluidez visual.  

* Tratamento de Dados Inconsistentes:
   Identifiquei filmes na API com strings de imagem vazias (ex: Um Tio Quase Perfeito 3). O app trata isso exibindo um placeholder elegante com suporte a Glassmorphism (efeitos de material do iOS).  

* Botão de Recuperação (Retry):
   Criei um mecanismo de "identidade de view" usando .id(retryID) para permitir que o usuário recarregue imagens individualmente se houver falha de rede.

3 - Qualidade e Testes
    
  Para garantir a integridade da regra de negócio de ordenação cronológica, implementei testes unitários utilizando XCTest:
  
  * EventViewModelTests: 
     Valida se a lógica de ordenação por localDate funciona corretamente, garantindo que os filmes sejam exibidos do lançamento mais próximo para o mais distante.
  
  * Segurança: 
     Foco em garantir que datas inconsistentes não quebrem a experiência do usuário.
     
     Reset de Estado: Uso de identificadores únicos (.id) para garantir que os carrosséis resetem o índice ao alternar entre abas, evitando o bug de "cards invisíveis".

4 - Arquitetura e Organização
 
  Para manter o projeto escalável e as Views leves, utilizei a técnica de **Componentização**:
  
  * Pasta Components: 
     Centraliza elementos visuais reutilizáveis (como `EventPosterImage`, `GenreBadge`, `PrimaryButton`, entre outros)
     Extração de elementos de UI (SearchBar, FavoriteButton, EmptyState) para um catálogo de componentes, reduzindo a complexidade das Views principais.
  
  * Sincronização de Estado Reativa: 
     Utilização de `Set<String>` no ViewModel para gerenciamento global de favoritos, garantindo que a alteração de estado em uma tela (Detail) reflita instantaneamente em outras (Home/Card)
    
  * DRY: 
     Evita a duplicação de lógica visual complexa, como o tratamento de estados de carregamento e erro de imagens assíncronas.
  
  * Agrupamento Mensal Inteligente: 
     Lógica avançada para organizar filmes por Mês/Ano, com separação automática entre estreias de 2026 e lançamentos futuros (2027).

  * Ordenação Cronológica Estrita: 
     Garantia de que todos os carrosséis (incluindo a aba de Favoritos) respeitam a ordem crescente das datas de estreia.
    
  * Filtro Temporal Dinâmico: Refatoração completa da lógica de "Últimas Estreias" vs "Em Breve". O app agora realiza a extração exata do prefixo ISO (yyyy-MM-dd) e compara de forma nativa com a data do dispositivo, ignorando falsos positivos da flag inPreSale herdados do banco de dados do servidor.
  
  * Decodificação (JSON): Ajuste fino no modelo Event.swift para suportar inconsistências da API (como campos directors que trafegam como String em vez de Array, e durações que chegam como espaços em branco).

  * Gestão Segura de Concorrência: Implementação de locks (isFetching) no ViewModel para prevenir chamadas simultâneas à rede e tratamento amigável de interrupções de renderização do sistema (URLError.cancelled), limpando os logs de rede.

5 - Funcionalidades e Melhorias de UI

  * Navegação Fluida:
     Implementação de `NavigationLink` para transição entre lista e detalhes.
  
  * Layout Responsivo:
     Uso de `GeometryReader` em substituição ao `UIScreen.main` (depreciado no iOS 26.0) para garantir adaptação a diferentes tamanhos de tela.

  * Tratamento de Strings Longas:
     Utilização de `lineLimit` com reserva de espaço e `minimumScaleFactor` para evitar quebra de layout em títulos extensos.

  * Otimização de Imagens: 
     Implementação de estados de carregamento (Shimmer/ProgressView) e tratamento de erros de rede com botão de re-tentativa (Retry) integrado ao componente `AsyncImage`.

  * Apple Guidelines - Design for iOS "Liquid Glass"

     Efeitos Nativos: Integração do novo modificador .glassEffect e materials translúcidos para botões de favorito e etiquetas de data.
     
     Icone: Personalizado e já feito aderindo o Liquid Glass no tinted, default e dark moods 

    Clean Design: Otimização de espaçamentos e remoção de contentores visuais desnecessários, permitindo que a arte dos pósteres seja a protagonista da interface.
    
  * Gestão de Usuário e Persistência Local

     Sistema de Perfil sem Fricção: Implementação de um fluxo de registro focado na experiência do usuário, exigindo apenas o nome para personalização do ambiente.

     Armazenamento Nativo e Seguro: Utilização do property wrapper @AppStorage para salvar os dados localmente no UserDefaults. Isso garante persistência de estado (Login/Logout) com zero latência, sem a necessidade de requisições de rede ou frameworks complexos de backend.

     Privacidade: Como não há tráfego de dados para servidores de terceiros, a aplicação respeita integralmente a privacidade local do dispositivo.
    
  * Localização e Inteligência de Contexto

    Gestão de Permissões Proativa: 
      O aplicativo solicita acesso à localização apenas quando necessário, utilizando o framework CoreLocation.

    Botão de Localização Inteligente: 
      Um botão minimalista na NavigationStack que altera seu estado em tempo real. Se autorizado, exibe o ícone de localização ativa; se não, permite que o usuário seja redirecionado diretamente para os Ajustes do iOS para gerir as permissões.

    Geocodificação Reversa Moderna: 
      Implementação do MKReverseGeocodingRequest (padrão iOS 26.0+) com processamento assíncrono para converter coordenadas em nomes de cidades sem impactar a performance da Main Thread.

    Critério de Segurança e Não Confirmação: 
      O app não armazena histórico de localização após a revogação do acesso, pois isso impactaria na EventDetailView e os "ingressos disponíveis na sua localização". Implementamos um listener de autorização que limpa imediatamente qualquer dado de cidade (currentCity = nil) caso o usuário desative a permissão nos Ajustes, garantindo que mensagens de conveniência não apareçam indevidamente.

    Match de Disponibilidade: 
      Verificação dinâmica entre a localização do utilizador e os metadados da API (event.city). O aviso "ingresso disponível na sua localização" só é exibido se houver um match positivo e permissão ativa.
    
  * Carrossel Premium:

     Efeito Leque Horizontal: Implementação de um sistema de carrossel ancorado à esquerda, com sobreposição inteligente de cartões.

     Destaque Dinâmico: O filme em foco recebe um aumento de escala automático (focusScale: 1.2) e sombras profundas.

     Blur: Uso de desfoque progressivo nos filmes em segundo plano para criar uma sensação de profundidade de campo profissional.

     Física de Molas: Navegação fluida utilizando interactiveSpring, garantindo que os gestos de arrasto sejam responsivos e naturais.

     Aritmética Modular: Implementação de lógica de loop infinito para meses com mais de 5 filmes, permitindo navegação contínua sem "paredes".

     Modo Híbrido: O sistema detecta automaticamente listas pequenas (como Favoritos) e desativa a repetição para evitar duplicatas visuais.
 
     Centralização Absoluta: Transição do layout ancorado à esquerda para um sistema de Cover Flow centralizado usando coordenadas absolutas (GeometryReader + .position).

     Segurança de Gesto: Uso de highPriorityGesture e bloqueio de interação em cards laterais para garantir que o arrasto do carrossel nunca entre em conflito com a navegação de detalhes.
     
    * Otimização de Performance e UX
     
       Optimização do favorite: Implementação de estado local e DispatchQueue para garantir que a animação da estrela seja instantânea, movendo o recálculo pesado da lista para o background.

       Feedback Háptico: Integração do UISelectionFeedbackGenerator para fornecer um "tique" tátil a cada troca de filme, simulando o peso físico dos componentes.

       Sticky Tabs: Cabeçalho de categorias fixado no topo (pinnedViews) com efeito .ultraThinMaterial, maximizando a área de visualização durante o scroll.


       Implementação de `hideKeyboard()` via `UIApplication` para melhorar a navegabilidade durante a busca.
       
       Feedback visual de "Empty State" customizado para buscas sem resultados.
       
       Transições suaves entre filtros utilizando `matchedGeometryEffect`.
       
       "Management Pattern". Isso significa que minha UI reage de forma inteligente a três estados: Loading (Carregando), Empty (Vazio) e Content (Conteúdo).
    
       Launch Screen: Implementação de uma tela de abertura customizada (LaunchScreenView) com AnimatedGradient pulsante, animações de escala/opacidade e transição suave (fade-out) para a tela principal, mascarando o tempo de carregamento inicial.
    
       Componentização de Badges: 
          Criação de componentes visuais reaproveitáveis, incluindo: AgeRatingBadge: Converte cores Hexadecimais da API (ex: #e33493) dinamicamente para SwiftUI, exibido tanto nos cards (MovieCardView) quanto nos detalhes.
       
       Banner de Pré-Venda Imersivo: Redesign da tag de pré-venda nos pôsteres para uma barra inferior de ponta a ponta (maxWidth: .infinity), utilizando glassEffect e contornos translúcidos para chamar a atenção sem quebrar a estética. 
       
       Empty States Inteligentes: Telas de estado vazio dinâmicas e amigáveis, com mensagens e ícones que se adaptam perfeitamente à aba atual (Busca, Favoritos, Estreias ou Em Breve).
       
       Tratamento Visual de Fallbacks: A interface agora reage elegantemente à falta de dados da API (ex: exibindo "- min" para durações nulas e "Informação indisponível" para elencos não listados), evitando que a UI quebre ou fique vazia.
       
       Animação de Toolbar Dinâmica: A barra de busca foi construída do zero para "sequestrar" a Navigation Bar de forma elegante. Ao ser acionada, os ícones laterais e o título realizam um fade out, permitindo que o campo de texto assuma o placement: .principal centralizado.

       Gestão de Foco Inteligente: Integração do @FocusState acoplado à animação da barra, garantindo que o teclado suba instantaneamente no momento em que a lupa é tocada, removendo a necessidade de um segundo clique pelo usuário.

6 - Integrações Nativas do iOS

 * ShareLink Integrado: Uso da API moderna do SwiftUI para compartilhamento nativo. O sistema detecta automaticamente se deve gerar um Preview de URL (para links do cinema) ou enviar um fallback em texto formatado (contendo a sinopse do filme).

 * Deep Links Acionáveis: Componentes TrailerButton e "Ver Ingressos" configurados com @Environment(\.openURL), abrindo URLs do YouTube e do site de forma fluida fora do aplicativo.
