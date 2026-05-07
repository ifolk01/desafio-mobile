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
        VStack(alignment: .center, spacing: 8) {
           
            ZStack(alignment: .topTrailing) {
                // O Poster
                EventPosterImage(urlString: event.posterURL, retryID: $retryID, width: 110, height: 170)
                
                // Botão de Favorito
                FavoriteButton(event: event, viewModel: viewModel, size: .body, padding: 8.0)
                .padding(3)
                
                if event.inPreSale {
                                   
                                    VStack {
                                        HStack {
                                            Text("Pre-sale")
                                                .font(.system(size: 8, weight: .heavy))
                                                .kerning(1.5)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 4)
                                        
                                                .glassEffect(.regular, in: .rect(cornerRadius: 6))
                                              
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                                )
                                            
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding(4) 
                                }
                
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
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 12)
        }
    }
}
