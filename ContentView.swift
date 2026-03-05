// ContentView.swift
// Tela principal — espelho fiel do protótipo React

import SwiftUI
import SwiftData

// MARK: - Tab item model (evita large_tuple)

private struct TabItem {
    let icon: String
    let label: String
    let active: Bool
}

// MARK: - ContentView

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Visita.dataHora, order: .forward) private var visitas: [Visita]

    @State private var filtro: FiltroVisitas = .todas
    @State private var search: String = ""
    @State private var showForm = false
    @State private var editVisita: Visita?
    @State private var toast: ToastData?

    private var filtradas: [Visita] {
        visitas
            .filter { visita in
                switch filtro {
                case .todas:    return true
                case .hoje:     return visita.isHoje
                case .proximas: return !visita.isPassado
                case .passadas: return visita.isPassado
                }
            }
            .filter { visita in
                guard !search.isEmpty else { return true }
                return visita.endereco.localizedCaseInsensitiveContains(search)
                    || visita.anotacoes.localizedCaseInsensitiveContains(search)
            }
    }

    private var totalHoje: Int { visitas.filter(\.isHoje).count }

    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        if filtradas.isEmpty {
                            emptyState
                        } else {
                            ForEach(filtradas) { visita in
                                VisitaCardView(
                                    visita: visita,
                                    onEdit: { editVisita = visita },
                                    onDelete: { deletar(visita) },
                                    onMap: { abrirMapa(visita) },
                                    onNotif: { toggleNotif(visita) }
                                )
                                .padding(.horizontal, 14)
                            }
                        }
                        Spacer().frame(height: 20)
                    }
                    .padding(.top, 16)
                }

                tabBar
            }

            // Toast
            if let toastData = toast {
                ToastView(data: toastData)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .sheet(isPresented: $showForm) {
            VisitaFormView(mode: .nova) { dados in
                salvar(dados: dados, editando: nil)
            }
        }
        .sheet(item: $editVisita) { visitaParaEditar in
            VisitaFormView(mode: .editar(visitaParaEditar)) { dados in
                salvar(dados: dados, editando: visitaParaEditar)
            }
        }
        .task { await NotificationManager.shared.checkAuthorizationStatus() }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: toast?.id)
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            // Status bar mock
            HStack {
                Text("9:41")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.label)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "wifi")
                    Image(systemName: "battery.100")
                }
                .font(.system(size: 13))
                .foregroundStyle(Color.label)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 8)

            // Nav
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Visitas")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.label)
                    let plural = visitas.count != 1
                    Text("\(visitas.count) imóvel\(plural ? "s" : "") agendado\(plural ? "s" : "")")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondaryLabel)
                }
                Spacer()
                Button { showForm = true } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.brandBlue,
                                        Color(red: 0, green: 0.333, blue: 0.831)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(color: Color.brandBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondaryLabel)
                TextField("Buscar por endereço...", text: $search)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.label)
                if !search.isEmpty {
                    Button { search = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.secondaryLabel)
                    }
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(Color.pillBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 14)
            .padding(.bottom, 10)

            // Filtros
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(FiltroVisitas.allCases, id: \.self) { opcao in
                        FilterPillView(
                            filtro: opcao,
                            selected: filtro == opcao,
                            badge: opcao == .hoje ? totalHoje : 0
                        ) {
                            withAnimation(.spring(response: 0.25)) { filtro = opcao }
                        }
                    }
                }
                .padding(.horizontal, 14)
            }
            .padding(.bottom, 14)
        }
        .background(Color.white)
        .overlay(alignment: .bottom) { Divider() }
    }

    // MARK: - Tab bar

    private var tabBar: some View {
        let tabs: [TabItem] = [
            TabItem(icon: "house.fill", label: "Visitas", active: true),
            TabItem(icon: "calendar", label: "Agenda", active: false),
            TabItem(icon: "map", label: "Mapa", active: false)
        ]
        return HStack {
            ForEach(tabs, id: \.label) { tab in
                Spacer()
                VStack(spacing: 3) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(tab.active ? Color.brandBlue : Color.secondaryLabel)
                    Text(tab.label)
                        .font(.system(size: 10, weight: tab.active ? .semibold : .regular))
                        .foregroundStyle(tab.active ? Color.brandBlue : Color.secondaryLabel)
                }
                Spacer()
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Divider() }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("🏠").font(.system(size: 48))
            Text(emptyTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(red: 0.235, green: 0.235, blue: 0.263))
            Text(emptySubtitle)
                .font(.system(size: 14))
                .foregroundStyle(Color.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, 40)
    }

    private var emptyTitle: String {
        switch filtro {
        case .hoje:     return "Nada para hoje"
        case .proximas: return "Sem visitas futuras"
        default:        return "Nenhuma visita encontrada"
        }
    }

    private var emptySubtitle: String {
        filtro == .todas
            ? "Toque em + para agendar sua primeira visita"
            : "Tente outro filtro ou agende uma nova visita"
    }

    // MARK: - Actions

    private func salvar(dados: VisitaDados, editando: Visita?) {
        if let visitaEditando = editando {
            NotificationManager.shared.cancelarNotificacao(para: visitaEditando.id)
            visitaEditando.endereco    = dados.endereco
            visitaEditando.bairro      = dados.bairro
            visitaEditando.cidade      = dados.cidade
            visitaEditando.dataHora    = dados.dataHora
            visitaEditando.precoImovel = dados.preco
            visitaEditando.anotacoes   = dados.anotacoes
            if dados.notificacao {
                visitaEditando.notificacaoAgendada =
                    NotificationManager.shared.agendarNotificacao(para: visitaEditando)
            } else {
                visitaEditando.notificacaoAgendada = false
            }
            showToast("✅ Visita atualizada!")
        } else {
            let novaVisita = Visita(
                endereco: dados.endereco,
                bairro: dados.bairro,
                cidade: dados.cidade,
                dataHora: dados.dataHora,
                precoImovel: dados.preco,
                anotacoes: dados.anotacoes,
                notificacaoAgendada: dados.notificacao
            )
            modelContext.insert(novaVisita)
            if dados.notificacao {
                novaVisita.notificacaoAgendada =
                    NotificationManager.shared.agendarNotificacao(para: novaVisita)
            }
            let msg = dados.notificacao
                ? "✅ Visita agendada! 🔔 Lembrete ativo"
                : "✅ Visita agendada!"
            showToast(msg)
        }
    }

    private func deletar(_ visita: Visita) {
        NotificationManager.shared.cancelarNotificacao(para: visita.id)
        modelContext.delete(visita)
        showToast("🗑️ Visita removida")
    }

    private func abrirMapa(_ visita: Visita) {
        guard let url = visita.mapsURL,
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
        showToast("📍 Abrindo Apple Maps...")
    }

    private func toggleNotif(_ visita: Visita) {
        if visita.notificacaoAgendada {
            NotificationManager.shared.cancelarNotificacao(para: visita.id)
            visita.notificacaoAgendada = false
            showToast("🔕 Lembrete desativado")
        } else {
            visita.notificacaoAgendada =
                NotificationManager.shared.agendarNotificacao(para: visita)
            showToast("🔔 Lembrete ativado para 1h antes!")
        }
    }

    private func showToast(_ message: String) {
        withAnimation { toast = ToastData(message: message) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { toast = nil }
        }
    }
}

// MARK: - Supporting types

enum FiltroVisitas: String, CaseIterable {
    case todas = "Todas"
    case hoje = "Hoje"
    case proximas = "Próximas"
    case passadas = "Passadas"
}

struct VisitaDados {
    var endereco: String
    var bairro: String
    var cidade: String
    var dataHora: Date
    var preco: Double
    var anotacoes: String
    var notificacao: Bool
}

struct ToastData: Identifiable, Equatable {
    let id = UUID()
    let message: String
}

// MARK: - FilterPillView

struct FilterPillView: View {
    let filtro: FiltroVisitas
    let selected: Bool
    let badge: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(filtro.rawValue)
                    .font(.system(size: 13, weight: selected ? .bold : .medium))

                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .heavy))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(selected ? Color.white.opacity(0.3) : Color.brandOrange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(selected ? Color.brandBlue : Color.pillBackground)
            .foregroundStyle(
                selected ? .white : Color(red: 0.388, green: 0.388, blue: 0.400)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ToastView

struct ToastView: View {
    let data: ToastData

    var body: some View {
        Text(data.message)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 90)
            .allowsHitTesting(false)
    }
}
