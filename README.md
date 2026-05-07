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

4 - Arquitetura e Organização
 
  Para manter o projeto escalável e as Views leves, utilizei a técnica de **Componentização**:
  
  * Pasta Components: 
     Centraliza elementos visuais reutilizáveis (como `EventPosterImage`, `GenreBadge`, `PrimaryButton`, entre outros)
     Extração de elementos de UI (SearchBar, FavoriteButton, EmptyState) para um catálogo de componentes, reduzindo a complexidade das Views principais.
  
  *Sincronização de Estado Reativa: 
    Utilização de `Set<String>` no ViewModel para gerenciamento global de favoritos, garantindo que a alteração de estado em uma tela (Detail) reflita instantaneamente em outras (Home/Card)
  
  *User Experience (UX): 
    Implementação de `hideKeyboard()` via `UIApplication` para melhorar a navegabilidade durante a busca.
    Feedback visual de "Empty State" customizado para buscas sem resultados.
    Transições suaves entre filtros utilizando `matchedGeometryEffect`.
    "Management Pattern". Isso significa que minha UI reage de forma inteligente a três estados: Loading (Carregando), Empty (Vazio) e Content (Conteúdo).
    
  * Responsabilidade única:
     Cada componente foca em uma única tarefa visual, facilitando a manutenção e garantindo a consistência estética em todo o app.
    
  * DRY: 
     Evita a duplicação de lógica visual complexa, como o tratamento de estados de carregamento e erro de imagens assíncronas.
  
  *Agrupamento Mensal Inteligente: 
     Lógica avançada para organizar filmes por Mês/Ano, com separação automática entre estreias de 2026 e lançamentos futuros (2027).

  *Ordenação Cronológica Estrita: 
    Garantia de que todos os carrosséis (incluindo a aba de Favoritos) respeitam a ordem crescente das datas de estreia.

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

    Clean Design: Otimização de espaçamentos e remoção de contentores visuais desnecessários, permitindo que a arte dos pósteres seja a protagonista da interface.
    
  * Carrossel Premium:

     Efeito Leque Horizontal: Implementação de um sistema de carrossel ancorado à esquerda, com sobreposição inteligente de cartões.

     Destaque Dinâmico: O filme em foco recebe um aumento de escala automático (focusScale: 1.2) e sombras profundas.

     Blur: Uso de desfoque progressivo nos filmes em segundo plano para criar uma sensação de profundidade de campo profissional.

     Física de Molas: Navegação fluida utilizando interactiveSpring, garantindo que os gestos de arrasto sejam responsivos e naturais.
