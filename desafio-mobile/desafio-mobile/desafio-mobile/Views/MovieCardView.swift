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
                
                EventPosterImage(urlString: event.posterURL, retryID: $retryID, width: 110, height: 160)
                
                if let premiere = event.premiereDate, let dateText = premiere.dayAndMonth{
                    PremiereBadge(dateText: dateText)
                }
            }
            
            Text(event.title)
                .font(.caption)
                .bold()
                .lineLimit(3, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.8) 
                .frame(width: 110, alignment: .topLeading)
        }
    }
}
