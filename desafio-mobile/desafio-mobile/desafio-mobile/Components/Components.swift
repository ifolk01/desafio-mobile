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
    
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var contentMode: ContentMode = .fill
    
    var body: some View {
        Group {
            if let urlString = urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    
                    case .failure(let error):
                        let isCancelled = (error as NSError).code == NSURLErrorCancelled
                        
                        Button {
                            retryID = UUID()
                        } label: {
                            VStack(spacing: 12) {
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
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(uiColor: .systemGray6))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.1)
                            ProgressView()
                        }
                        
                    @unknown default:
                        EmptyView()
                    }
                }
                .id(retryID)
            } else {
                PlaceholderCard(width: width, height: height)
            }
        }
        .frame(width: width, height: height) // Corrigido: Agora dentro do escopo da View
        .cornerRadius(8)
        .clipped()
    }
}
struct PlaceholderCard: View {
    var width: CGFloat?
    var height: CGFloat?
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .overlay(
                Image(systemName: "film")
                    .foregroundColor(.gray)
            )
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
struct GenreBadge: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.secondary.opacity(0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
            )
    }
}
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}
struct FilterTabButton: View {
    let title: String
    @Binding var current: String
    var animation: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                current = title
            }
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: current == title ? .bold : .medium))
                    .foregroundColor(current == title ? .blue : .gray)
                
                if current == title {
                    Capsule()
                        .fill(Color.blue)
                        .frame(height: 3)
                        .matchedGeometryEffect(id: "tab_underline", in: animation)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 3)
                }
            }
        }
    }
}
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Buscar..."

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
struct EmptyStateView: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
}
struct FavoriteButton: View {
    let event: Event
    @ObservedObject var viewModel: EventViewModel
    var size: Font = .body
    var padding: CGFloat = 8

    var body: some View {
        Button {
            viewModel.toggleFavorite(event: event)
        } label: {
            Image(systemName: viewModel.favoriteIDs.contains(event.id) ? "star.fill" : "star")
                .font(size)
                .foregroundColor(viewModel.favoriteIDs.contains(event.id) ? .yellow : .white)
                .padding(padding)
                .background(Color.black.opacity(0.3))
                .clipShape(Circle())
        }
    }
}
