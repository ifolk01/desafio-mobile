//
//  EventDetailView.swift
//  desafio-mobile
//
//  Created by Filipe Pinto Cunha on 06/05/26.
//

import SwiftUI

struct EventDetailView: View {
    let event: Event
    @State private var retryID = UUID()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // Poster Destaque
                GeometryReader { geometry in
                    EventPosterImage(
                        urlString: event.posterURL,
                        retryID: $retryID,
                        width: geometry.size.width, 
                        height: 400,
                        contentMode: .fit
                    )
                 
                }
                .frame(height: 400)
            
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Título e Categorias
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.system(.title, design: .rounded))
                            .bold()
                        
                        // Lista de Gêneros
                        if let genres = event.genres {
                            HStack {
                                ForEach(genres, id: \.self) { genre in
                                    GenreBadge(text: genre)
                                }
                            }
                        }
                    }
                    .padding(.top)

                    Divider()

                    // Sinopse
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Sinopse")
                        Text(event.synopsis ?? "Nenhuma descrição disponível para este evento.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary.opacity(0.8))
                    }

                    // Detalhes do Elenco
                    if let cast = event.cast, !cast.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Elenco e Direção")
                            Text(cast)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    
                    PrimaryButton(title: "Ver Ingressos") {
                        print("Fluxo de compra iniciado para: \(event.title)")
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemBackground))
    }
}


#Preview {
    NavigationStack {
        EventDetailView(event: Event(
            id: "1",
            title: "Batman",
            synopsis: "O Cavaleiro das Trevas enfrenta o Coringa em Gotham.", 
            cast: "Christian Bale, Heath Ledger",
            contentRating: "14",
            duration: "152 min",
            genres: ["Ação", "Drama"],
            inPreSale: false,
            imageFeatured: "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDp9QmSJJVIzYv9miv6.jpg",
            images: [],
            premiereDate: nil
        ))
    }
}
