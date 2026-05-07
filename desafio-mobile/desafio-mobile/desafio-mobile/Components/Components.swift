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
            .padding(.horizontal, 8) // Um pouco mais largo nas laterais
            .padding(.vertical, 4)
            .glassEffect(.regular.interactive(), in: .capsule )
           
            .cornerRadius(6)
         
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
            .glassEffect(.regular.interactive().tint(.blue), in: .capsule )
            .foregroundColor(.white)
            
            .cornerRadius(12)
//            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
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
                .glassEffect(.regular.interactive(), in: .circle )
                .clipShape(Circle())
        }
    }
}
struct MovieMonthCarousel: View {
    let monthTitle: String
    let events: [Event]
    @ObservedObject var viewModel: EventViewModel
    @State private var scrollOffset: CGFloat = 0
    @State private var currentIndex: Int = 0
    
    let cardWidth: CGFloat = 150
    let spacing: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(monthTitle)
                .font(.title3)
                .bold()
                .padding(.horizontal)
            
            ZStack {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    NavigationLink(destination: EventDetailView(event: event, viewModel: viewModel)) {
                        MovieCardView(event: event, viewModel: viewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                    // EFEITOS VISUAIS IGUAL AO SEU CÓDIGO DE INSPIRAÇÃO
                    .scaleEffect(currentIndex == index ? 1.0 : 0.8)
                    .blur(radius: currentIndex == index ? 0 : 1)
                    .offset(x: CGFloat(index - currentIndex) * (cardWidth + spacing) + scrollOffset)
                }
            }
            .frame(height: 250) // Altura do carrossel
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        scrollOffset = gesture.translation.width
                    }
                    .onEnded { gesture in
                        let threshold: CGFloat = 50
                        if gesture.translation.width < -threshold && currentIndex < events.count - 1 {
                            currentIndex += 1
                        } else if gesture.translation.width > threshold && currentIndex > 0 {
                            currentIndex -= 1
                        }
                        withAnimation(.spring()) {
                            scrollOffset = 0
                        }
                    }
            )
        }
        .padding(.vertical)
    }
}
struct MovieFlatCarousel: View {
    let events: [Event]
    @ObservedObject var viewModel: EventViewModel
    
    // Estado para controlar o índice e o arrasto
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    
    // MARK: - Configurações Visuais UPGRADED
    // Aumentei os tamanhos e o espaçamento para caber o destaque maior
    let cardWidth: CGFloat = 110 // Base maior (+30)
    let cardHeight: CGFloat = 230 // Base maior (+40)
    let spacing: CGFloat = 80 // Espaçamento entre as bases (maior sobreposição)
    
    // Fatores de Destaque
    let focusScale: CGFloat = 1.25 // O do meio fica 20% MAIOR que o normal
    let scaleSpread: CGFloat = 0.25 // Quanto os de trás diminuem (mais agressivo)
    let focusBlur: CGFloat = 4.0 // Máximo de desfoque nos cards de trás

    var body: some View {
        GeometryReader { geo in
            // Alinhado na esquerda para respeitar o design "prateleira"
            ZStack(alignment: .leading) {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    
                    let diff = CGFloat(index - currentIndex)
                    let dragFactor = dragOffset / spacing
                    let effectiveDiff = diff - dragFactor
                    let absEffectiveDiff = abs(effectiveDiff)
                    
                    // ⬇️ MUDANÇA AQUI: Só renderiza o card se ele estiver perto do centro visível
                    if absEffectiveDiff <= 4.5 {
                        
                        let scale = max(focusScale - (absEffectiveDiff * scaleSpread), 0.75)
                        let blurRadius = min(absEffectiveDiff * 1.5, focusBlur)
                        let zIndex = Double(events.count) - absEffectiveDiff
                        let offset = (diff * spacing) + dragOffset
                        let shadowOpacity = max(0.4 - (absEffectiveDiff * 0.1), 0.1)

                        NavigationLink(destination: EventDetailView(event: event, viewModel: viewModel)) {
                            MovieCardView(event: event, viewModel: viewModel)
                                .blur(radius: blurRadius)
                                .shadow(color: .black.opacity(shadowOpacity), radius: scale == focusScale ? 15 : 6, y: 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: cardWidth, height: cardHeight)
                        .scaleEffect(scale)
                        .offset(x: offset)
                        .zIndex(zIndex)
                        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentIndex)
                    }
                }
            }
            // Alinhamento base para bater com o padding do mês
            .offset(x: 16)
            
            // Container do gesto (cobre a área do carrossel)
            .background(Color.clear.contentShape(Rectangle()))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragOffset = gesture.translation.width
                    }
                    .onEnded { gesture in
                        // Lógica de SNAP ajustada para ser mais responsiva
                        let velocity = gesture.predictedEndTranslation.width / spacing
                        let threshold: CGFloat = velocity > 0.5 ? 0.3 : 0.7 // Facilita a troca se tiver velocidade
                        
                        // ANIMAÇÃO DE FINALIZAÇÃO (SNAP)
                        // Spring com dampingfraction menor para um efeito elástico e fluido
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                            if gesture.translation.width < -spacing * threshold && currentIndex < events.count - 1 {
                                currentIndex += 1
                            } else if gesture.translation.width > spacing * threshold && currentIndex > 0 {
                                currentIndex -= 1
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
        // Altura total reservada para os cards maiores e escalas
        .frame(height: (cardHeight * focusScale) + 40)
    }
}
