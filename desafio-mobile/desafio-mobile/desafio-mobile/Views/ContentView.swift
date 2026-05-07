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
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var filteredEvents: [Event] {
        let list: [Event]
        
        switch currentTab {
        case "Últimas Estreias":
            list = viewModel.events.filter { $0.inPreSale == false }
        case "Em Breve":
            list = viewModel.events.filter { $0.inPreSale == true }
        case "Favoritos":
            list = viewModel.events.filter { viewModel.isFavorite($0) }
        default:
            list = viewModel.events
        }
        
        if searchText.isEmpty {
            return list
        } else {
            return list.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
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
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(filteredEvents) { event in
                                    NavigationLink(destination: EventDetailView(event: event, viewModel: viewModel)) {
                                        MovieCardView(event: event, viewModel: viewModel)
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
