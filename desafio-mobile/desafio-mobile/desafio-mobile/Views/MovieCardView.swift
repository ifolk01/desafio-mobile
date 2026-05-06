//
//  MovieCardView.swift
//  desafio-mobile
//
//  Created by Filipe Pinto Cunha on 05/05/26.
//

import SwiftUI

struct MovieCardView: View {
    let event: Event
    // Caso haja necessidade nesse serviço assincrono
    @State private var retryID = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                
                EventPosterImage(urlString: event.posterURL, retryID: $retryID)
                
                if let premiere = event.premiereDate, let dateText = premiere.dayAndMonth{
                    PremiereBadge(dateText: dateText)
                }
            }
            
            Text(event.title)
                .font(.caption)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 110, alignment: .leading)
        }
    }
}
