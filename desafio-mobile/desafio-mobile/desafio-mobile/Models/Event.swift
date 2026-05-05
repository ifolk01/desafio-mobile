//
//  Event.swift
//  desafio-mobile
//
//  Created by Filipe Pinto Cunha on 05/05/26.
//

import Foundation

// Representa a lista de filmes da API
struct EventResponse: Codable {
    let items: [Event]
}

// Representa cada filme de forma individual
struct Event: Codable, Identifiable {
    let id: String
    let title: String
    let premiereDate: String?
    let isPreSale: Bool
    let images: [EventImage]
    
    // Variável para pegar a URL do poster
    var posterURL: String? {
        return images.first(where: { $0.type == "Poster" })?.url
    }
}

struct EventImage: Codable {
    let url: String
    let type: String
}
