//
//  Components.swift
//  desafio-mobile
//
//  Created by Filipe Pinto Cunha on 06/05/26.
//

import SwiftUI


struct EventPosterImage: View {
    let urlString: String?
    @Binding var retryID: UUID
    
    var body: some View {
        if let urlString = urlString, let url = URL(string: urlString) {
        
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    
                    case .failure(let error):
                        // Criamos uma constante para saber se foi apenas um cancelamento de scroll
                        let isCancelled = (error as NSError).code == NSURLErrorCancelled
                        
                        Button {
                                retryID = UUID()
                            } label: {
                                VStack(spacing: 12) {
                                    // Ícone dentro de um círculo para parecer mais com um botão de ação do iOS
                                    Image(systemName: isCancelled ? "arrow.clockwise" : "exclamationmark.triangle")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                    
                                    Text(isCancelled ? "Tentar carregar" : "Erro de conexão")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 8)
                                }
                                .frame(width: 110, height: 160)
                                
                                .background(Color(uiColor: .systemGray6))
                            }
                            .buttonStyle(PlainButtonStyle())
                    case .empty:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .overlay(ProgressView())
                            
                    @unknown default:
                        EmptyView()
                    }
                }
            .id(retryID)
            .frame(width: 110, height: 160)
            .cornerRadius(8)
            .clipped()
        } else {
            // Placeholder padronizado
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 110, height: 160)
                .overlay(Image(systemName: "film").foregroundColor(.gray))
        }
    }
}
struct PremiereBadge: View {
    let dateText: String
    
    var body: some View {
        Text(dateText)
            .font(.caption2)
            .bold()
            .padding(4)
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(4)
    }
}
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .padding(.top, 10)
    }
}
