import SwiftUI

struct EventDetailView: View {
    let event: Event
    @State private var retryID = UUID()
    @ObservedObject var viewModel: EventViewModel
    
    // Variável de ambiente nativa da Apple para abrir links no Safari/YouTube
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                //Poster Destaque
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
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    if let premiere = event.premiereDate, let dateText = premiere.dayAndMonth {
                                                PremiereBadge(dateText: dateText).padding(.top, 12)
                    }
                    
                    // Cabeçalho
                    HStack(alignment: .top) {
                        Text(event.title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                        
                      
                      
                        
                        Spacer()
                        FavoriteButton(event: event, viewModel: viewModel, size: .body, padding: 7.5)
                    }
                    .padding(.top)
                    
                   
                                    
                    
                    //(Classificação + Duração + Origem)
                    HStack(spacing: 12) {
                        if let rating = event.ratingDetails {
                            AgeRatingBadge(rating: rating)
                        }
                        
                        // Removi espaços em branco "perdidos" que a API possa mandar
                        let rawDuration = event.duration?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        
                        // Se for vazio OU se for "0", mostramos o traço "-"
                        let durationStr = (rawDuration.isEmpty || rawDuration == "0") ? "-" : rawDuration
                        
                        Text("\(durationStr) min")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let country = event.countryOrigin {
                            Text("•  \(country)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                       
                    }
                    
                    // Lista de Gêneros
                    if let genres = event.genres {
                        HStack {
                            ForEach(genres, id: \.self) { genre in
                                GenreBadge(text: genre)
                            }
                        }
                    }
                    
                    // Botões de Trailer e Ingressos
                   
                    
                    Divider()
                    
                    // Sinopse
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Sinopse")
                        let synopsis = (event.synopsis ?? "").isEmpty ? "Nenhuma descrição disponível para este filme" : event.synopsis!
                        
                        Text(synopsis)
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary.opacity(0.9))
                    }
                    
                    // Elenco e Direção
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Elenco e Direção")
                        
                        // Verifica direção
                        let directorsStr = (event.directors ?? "").isEmpty ? "Informação indisponível" : event.directors!
                        Text("**Direção:** \(directorsStr)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        // Verifica elenco
                        let castStr = (event.cast ?? "").isEmpty ? "Informação indisponível" : event.cast!
                        Text("**Elenco:** \(castStr)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(4)
                    }
                    
                    // Informações Técnicas 
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Detalhes Técnicos")
                        
                        if let distributor = event.distributor {
                            Text("**Distribuição:** \(distributor)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        if let descriptors = event.ratingDescriptors, !descriptors.isEmpty {
                            Text("**Conteúdo:** \(descriptors.joined(separator: ", "))")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    HStack(spacing: 15) {
                        // Botão de Trailer (Só aparece se tiver trailer do YouTube na API)
                        if let trailer = event.trailers?.first(where: { $0.type == "YouTube" }),
                           let urlString = trailer.url,
                           let url = URL(string: urlString) {
                            
                            TrailerButton(url: url)
                        }
                        
                        
                        
                        // Botão de Ingressos (Só funciona se tiver siteURL)
                        PrimaryButton(title: "Ver Ingressos", icon: "ticket.fill") {
                            if let site = event.siteURL, let url = URL(string: site) {
                                openURL(url)
                            } else {
                                print("Site não disponível na API")
                            }
                        }
                        // Deixa o botão cinza caso não tenha URL de ingresso
                        .opacity(event.siteURL != nil ? 1.0 : 0.5)
                        .disabled(event.siteURL == nil)
                    }
                    .padding(.vertical, 2)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("") // Deixei em branco para não duplicar o título gigante da página
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        
                        // Verifica se a API mandou a URL do filme
                        if let siteURL = event.siteURL, let url = URL(string: siteURL) {
                            
                            // LLink nativo de share
                            ShareLink(
                                item: url,
                                subject: Text(event.title),
                                message: Text("Bora assistir \(event.title) no cinema? 🍿")
                            ) {
                                Image(systemName: "square.and.arrow.up")
                                    .fontWeight(.semibold)
                            }
                            
                        } else {
                            
                            // Dar share só do texto, se não tiver URL
                            let fallbackText = """
                            Bora assistir \(event.title) no cinema? 🍿
                            
                            Sinopse:
                            \(event.synopsis ?? "Filme imperdível!")
                            """
                            
                            ShareLink(
                                item: fallbackText,
                                subject: Text(event.title)
                            ) {
                                Image(systemName: "square.and.arrow.up")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
        .background(
            // Um fundo combinando com a home
            LinearGradient(gradient: Gradient(colors: [.degradeDark, .black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

// MARK: - Componente de Classificação Indicativa

