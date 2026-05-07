//
//  ContentView.swift
//  desafio-mobile
//
//  Created by Filipe Pinto Cunha on 05/05/26.
//
import SwiftUI
struct ContentView: View {
    @StateObject private var viewModel = EventViewModel()
    @State private var searchText = ""
    @State private var currentTab = "Últimas Estreias"
    @Namespace var animation
    var filteredEvents: [Event] {
            let list: [Event]
            
            switch currentTab {
            case "Últimas Estreias":
                list = viewModel.events.filter { event in
                    // Extrai o ano da data
                    let year = event.premiereDate?.year ?? String(event.premiereDate?.localDate?.prefix(4) ?? "")
                    
                    // Regra: Somente filmes de 2026 que NÃO estão em pré-venda
                    return year == "2026" && event.inPreSale == false
                }
                
            case "Em Breve":
                list = viewModel.events.filter { event in
                    let year = event.premiereDate?.year ?? String(event.premiereDate?.localDate?.prefix(4) ?? "")
                    
                    // Regra: Qualquer filme de 2027 pra frente OU qualquer filme em pré-venda
                    return year >= "2027" || event.inPreSale
                }
                
            case "Favoritos":
                list = viewModel.events.filter { viewModel.isFavorite($0) }
                
            default:
                list = viewModel.events
            }
            
            // Filtro da barra de busca
            if searchText.isEmpty {
                return list
            } else {
                return list.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            }
        }
    var groupedEvents: [(key: String, value: [Event])] {
        //Filmes filtrados em Estreias ou Favoritos
        let dictionary = Dictionary(grouping: filteredEvents) { event -> String in
            if let localDate = event.premiereDate?.localDate, localDate.count >= 7 {
                return String(localDate.prefix(7)) // Ex: "2026-05"
            }
            return "9999-12"
        }
        
        //Ordenamos os meses na sua ordem cronologica
        let sortedKeys = dictionary.keys.sorted()
        
        // Mapeamos para o formato da View, garantindo a ordem interna dos filmes
        return sortedKeys.map { key in
            let displayTitle = key == "9999-12" ? "Em breve" : key.formatToMonthYear()
            
            // CORREÇÃO: Ordenamos os filmes deste mês específico por data de estreia
            let sortedMoviesForMonth = (dictionary[key] ?? []).sorted {
                let date1 = $0.premiereDate?.localDate ?? ""
                let date2 = $1.premiereDate?.localDate ?? ""
                return date1 < date2 // Ordem Crescente
            }
            
            return (key: displayTitle, value: sortedMoviesForMonth)
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
   
    
    var body: some View {
        TabView {
            
            NavigationStack {
                VStack(spacing: 0) {
                    
                    SearchBar(text: $searchText, placeholder: "Buscar...")
                    
                    //Filtros
                    HStack(spacing: 25) {
                        FilterTabButton(title: "Últimas Estreias", current: $currentTab, animation: animation)
                        FilterTabButton(title: "Em Breve", current: $currentTab, animation: animation)
                        FilterTabButton(title: "Favoritos", current: $currentTab, animation: animation)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    
                    Divider().padding(.top, 10)
                    
                    // O Grid de Filmes
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Carregando filmes...")
                        Spacer()
                    } else if filteredEvents.isEmpty {
                      
                        EmptyStateView(
                            icon: searchText.isEmpty ? "star" : "magnifyingglass",
                            message: searchText.isEmpty ?
                            "Você ainda não tem filmes favoritos." :
                                "Não encontramos nenhum filme com o nome '\(searchText)'."
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) { // Espaçamento vertical entre os meses
                                
                                if viewModel.isLoading {
                                    ProgressView("Buscando filmes...")
                                        .padding(.top, 50)
                                } else if groupedEvents.isEmpty {
                                    // Estado vazio para busca ou favoritos vazios
                                    EmptyStateView(
                                        icon: currentTab == "Favoritos" ? "star" : "film",
                                        message: currentTab == "Favoritos" ?
                                            "Você ainda não favoritou nenhum filme." :
                                            "Nenhum filme encontrado para '\(searchText)'."
                                    )
                                } else {
                                    // Esta estrutura unifica a exibição de Estreias, Em Breve e Favoritos
                                    ForEach(groupedEvents, id: \.key) { group in
                                        VStack(alignment: .leading, spacing: 40) {
                                            
                                            // TÍTULO DO MÊS
                                            Text(group.key)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .padding(.horizontal)
                                            
                                            // Carrossel na esquerda
                                            MovieFlatCarousel(events: group.value, viewModel: viewModel)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        .refreshable {
                            await viewModel.loadEvents()
                        }
                    }
                }
                .navigationTitle("Filmes")
                .task {
                    
                    if viewModel.events.isEmpty {
                        await viewModel.loadEvents()
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .tabItem { Label("Filmes", systemImage: "film.fill") }
            
            // TabBar
            NavigationStack { Text("Destaques") }.tabItem { Label("Destaques", systemImage: "star") }
            NavigationStack { Text("Cinemas") }.tabItem { Label("Cinemas", systemImage: "mappin.and.ellipse") }
            NavigationStack { Text("Notícias") }.tabItem { Label("Notícias", systemImage: "newspaper") }
            NavigationStack { Text("Prevenções") }.tabItem { Label("Prevenções", systemImage: "shield.checkerboard") }
        }
        .accentColor(.blue)
    }
}



#Preview {
    ContentView()
}
