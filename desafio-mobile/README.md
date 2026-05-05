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
 
 
