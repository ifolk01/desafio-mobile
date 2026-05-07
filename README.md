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
  
  * Responsabilidade única:
     Cada componente foca em uma única tarefa visual, facilitando a manutenção e garantindo a consistência estética em todo o app.
    
  * DRY: 
     Evita a duplicação de lógica visual complexa, como o tratamento de estados de carregamento e erro de imagens assíncronas.

5 - Funcionalidades e Melhorias de UI

  * Navegação Fluida:
     Implementação de `NavigationLink` para transição entre lista e detalhes.
  
  * Layout Responsivo:
     Uso de `GeometryReader` em substituição ao `UIScreen.main` (depreciado no iOS 26.0) para garantir adaptação a diferentes tamanhos de tela.

  * Tratamento de Strings Longas:
     Utilização de `lineLimit` com reserva de espaço e `minimumScaleFactor` para evitar quebra de layout em títulos extensos.

  * Otimização de Imagens: 
     Implementação de estados de carregamento (Shimmer/ProgressView) e tratamento de erros de rede com botão de re-tentativa (Retry) integrado ao componente `AsyncImage`.
