//
//  Event.swift
//  desafio-mobile
//
//  Created by Filipe Pinto Cunha on 05/05/26.
//

import Foundation
struct EventResponse: Codable {
    let items: [Event]
}

struct Event: Codable, Identifiable {
    let id: String
    let title: String
    let synopsis: String?           
    let contentRating: String?
    let duration: String?
    let genres: [String]?
    let inPreSale: Bool
    let imageFeatured: String?
    let images: [EventImage]
    let premiereDate: PremiereDate?
    
    // Mapeamento de nomes
    enum CodingKeys: String, CodingKey {
        case id, title, synopsis, contentRating, duration, genres
        case inPreSale, imageFeatured, images, premiereDate
    }
    
    // Lógica para o Poster
    var posterURL: String? {
        // 1. Tenta pegar o Portrait
        if let portrait = images.first(where: { $0.type == "PosterPortrait" })?.url, !portrait.isEmpty {
            return portrait
        }
        // 2. Tenta o Featured, mas só se não for uma string vazia, como tem em 3 titulos de filmes, sendo assim aciona o placeholder e não fica buscando um novo URL
        if let featured = imageFeatured, !featured.isEmpty {
            return featured
        }
        return nil
    }
    
    // Helper para exibir data e gênero na View
    var subtitle: String {
        let date = premiereDate?.dayAndMonth ?? "Em breve"
        let genre = genres?.first ?? ""
        return genre.isEmpty ? date : "\(date) • \(genre)"
    }
}

struct PremiereDate: Codable {
    let localDate: String?
    let dayAndMonth: String?
    let year: String?
}

struct EventImage: Codable {
    let url: String
    let type: String
}
