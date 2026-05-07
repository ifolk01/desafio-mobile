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
                    
                    //Somente filmes de 2026 que NÃO estão em pré-venda
                    return year == "2026" && event.inPreSale == false
                }
                
            case "Em Breve":
                list = viewModel.events.filter { event in
                    let year = event.premiereDate?.year ?? String(event.premiereDate?.localDate?.prefix(4) ?? "")
                    
                    // Qualquer filme de 2027 pra frente OU qualquer filme em pré-venda
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
        
 
        let sortedKeys = dictionary.keys.sorted()
        
    
        return sortedKeys.map { key in
            let displayTitle = key == "9999-12" ? "Em breve" : key.formatToMonthYear()
            
            // Ordenamos os filmes deste mês específico por data de estreia
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
                        ZStack {
                           
                            LinearGradient(gradient: Gradient(colors: [.degradeDark, .black]),
                                           startPoint: .top,
                                           endPoint: .bottom)
                                .ignoresSafeArea()
                            
                       
                            ScrollView {
                               
                                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                                    
                                    // Busca
                                    SearchBar(text: $searchText, placeholder: "Buscar...")
                                        .padding(.top, 10)
                                        .padding(.bottom, 20)
                                    
                                    // Seções
                                    Section(header:
                                        VStack(spacing: 0) {
                                            HStack(spacing: 25) {
                                                FilterTabButton(title: "Últimas Estreias", current: $currentTab, animation: animation)
                                                FilterTabButton(title: "Em Breve", current: $currentTab, animation: animation)
                                                FilterTabButton(title: "Favoritos", current: $currentTab, animation: animation)
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.horizontal)
                                            .frame(maxWidth: .infinity)
                                            .glassEffect(.regular.interactive(), in: .capsule )
                                            
                                          
                                        }
                                    ) {
                                        // Conteúdo
                                        if viewModel.isLoading {
                                            ProgressView("Carregando filmes...")
                                                .padding(.top, 100)
                                        } else if filteredEvents.isEmpty {
                                            EmptyStateView(
                                                icon: searchText.isEmpty ? "star" : "magnifyingglass",
                                                message: searchText.isEmpty ?
                                                "Você ainda não tem filmes favoritos." :
                                                    "Não encontramos nenhum filme com o nome '\(searchText)'."
                                            )
                                            .padding(.top, 100)
                                        } else {
                                            
                                            // Espaçamento entre os meses
                                            LazyVStack(spacing: 30) {
                                                ForEach(groupedEvents, id: \.key) { group in
                                                    VStack(alignment: .leading, spacing: 14) {
                                                        Text(group.key)
                                                            .font(.title2)
                                                            .fontWeight(.bold)
                                                            .padding(.horizontal)
                                                        
                                                        MovieFlatCarossel(events: group.value, viewModel: viewModel)
                                                            .id("\(currentTab)-\(group.key)")
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 20)
                                        }
                                    }
                                }
                            }
                            .refreshable {
                                await viewModel.loadEvents()
                            }
                        }
                        .navigationTitle("Filmes")
                      
                        .navigationBarTitleDisplayMode(.inline)
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
