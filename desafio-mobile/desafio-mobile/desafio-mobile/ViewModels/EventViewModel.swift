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
    @Published var favoriteIDs: Set<String> = []
    private var isFetching = false
    
    
    private let service = EventService()
    
  
    // Função para carregar os dados
    func loadEvents() async {
        guard !isFetching else { return }
        
        isFetching = true
        isLoading = true
        defer { isFetching = false
            isLoading = false}
        do {
            let fetchedEvents = try await service.fetchComingSoonEvents()
            
            // Ordenar os filmes pela data de estreia
            
            self.events = fetchedEvents.sorted { (event1, event2) -> Bool in
                guard let date1 = event1.premiereDate?.localDate else { return false }
                guard let date2 = event2.premiereDate?.localDate else { return true }
                return date1 < date2
            }
            
           
        } catch {
            // Ignora o log se for apenas um cancelamento de sistema
            if let urlError = error as? URLError, urlError.code == .cancelled {
                return
            }    }
    }
    
    func toggleFavorite(event: Event) {
            if favoriteIDs.contains(event.id) {
                favoriteIDs.remove(event.id)
            } else {
                favoriteIDs.insert(event.id)
            }
        objectWillChange.send()
        }
        
        func isFavorite(_ event: Event) -> Bool {
            favoriteIDs.contains(event.id)
        }
    
    
}

extension String {
    func formatToMonthYear() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM"
        
        if let date = inputFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "pt_BR")
            outputFormatter.dateFormat = "MMMM yyyy"
            return outputFormatter.string(from: date).capitalized
        }
        return "Em breve"
    }
}
