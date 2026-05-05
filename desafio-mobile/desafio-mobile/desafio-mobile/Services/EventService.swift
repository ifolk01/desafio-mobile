//
//  EventService.swift
//  desafio-mobile
//
//  Created by Filipe Pinto Cunha on 05/05/26.
//

import Foundation

class EventService {
    // A URL da API
    private let urlString = "https://api-content.ingresso.com/v0/events/coming-soon/partnership/desafio"
    
    // Função que da um search nos filmes
    func fetchComingSoonEvents() async throws -> [Event] {
        // Validar a URL
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Fazer a requisição na internet
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Verificação do servidor
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decodificar o JSON usando o Model
        let decodedResponse = try JSONDecoder().decode(EventResponse.self, from: data)
        
       
        return decodedResponse.items
    }
}
