//
//  ContentView.swift
//  desafio-mobile
//
//  Created by Filipe Pinto Cunha on 05/05/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = EventViewModel()
    
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    
                    ProgressView("Carregando filmes...")
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Tentar novamente") {
                            Task { await viewModel.loadEvents() }
                        }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.events) { event in
                                MovieCardView(event: event)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadEvents()
                    }
                }
            }
            .navigationTitle("Filmes")
            .task {
                //Busca automática ao abrir a tela
                await viewModel.loadEvents()
            }
        }
    }
}
#Preview {
    ContentView()
}
