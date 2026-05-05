//
//  EventViewModel.swift
//  desafio-mobile
//
//  Created by Filipe Pinto Cunha on 05/05/26.
//

import Foundation
import Combine

@MainActor
class EventViewModel: ObservableObject {

    @Published var events: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service = EventService()
    
    // Função para carregar os dados
    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedEvents = try await service.fetchComingSoonEvents()
            
            // Requisito 5: Ordenar os filmes pela data de estreia (premiereDate)
            // Filmes sem data (nil) ficam por último
            self.events = fetchedEvents.sorted { (event1, event2) -> Bool in
                guard let date1 = event1.premiereDate?.localDate else { return false }
                guard let date2 = event2.premiereDate?.localDate else { return true }
                return date1 < date2
            }
            
            isLoading = false
        } catch {
            self.errorMessage = "Não foi possível carregar os filmes: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
