//
//  MovieCardView.swift
//  desafio-mobile
//
//  Created by Filipe Pinto Cunha on 05/05/26.
//

import SwiftUI

struct MovieCardView: View {
    let event: Event
    @ObservedObject var viewModel: EventViewModel
    @State private var retryID = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
           
            ZStack(alignment: .topTrailing) {
                // O Poster
                EventPosterImage(urlString: event.posterURL, retryID: $retryID, width: 110, height: 170)
                
                // Botão de Favorito
                FavoriteButton(event: event, viewModel: viewModel, size: .body, padding: 8.0)
                .padding(3)
                
                //Badge de Estreia
                if let premiere = event.premiereDate, let dateText = premiere.dayAndMonth {
                    VStack {
                        Spacer()
                        HStack {
                            PremiereBadge(dateText: dateText)
                            Spacer()
                        }
                    }
                    .padding(4)
                }
            }
            .frame(width: 110, height: 170)
            
           
            Text(event.title)
                            .font(.caption)
                            .bold()
                            .lineLimit(3, reservesSpace: true)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(.primary)
                            // 1. Garante que o texto ocupe a largura toda do card
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            // 2. O SEGREDO: Margens para o texto não colar nas bordas do fundo branco!
                            .padding(.horizontal, 10)
                            .padding(.bottom, 12)
        }
    }
}
