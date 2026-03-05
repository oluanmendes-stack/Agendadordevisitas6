// ImoveisApp.swift

import SwiftUI
import SwiftData

// MARK: - Sample data model (evita large_tuple)

private struct SampleVisita {
    let endereco: String
    let bairro: String
    let cidade: String
    let dataHora: Date
    let preco: Double
    let anotacoes: String
    let notificacao: Bool
}

// MARK: - App

@main
struct ImoveisApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Visita.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer error: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                    injectSampleDataIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    // Injeta dados de exemplo apenas no primeiro lançamento
    private func injectSampleDataIfNeeded() {
        let key = "sampleDataInjected_v2"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

        let ctx = sharedModelContainer.mainContext
        let now = Date()
        let cal = Calendar.current

        let manha = cal.startOfDay(for: now).addingTimeInterval(10 * 3_600)
        let tarde = cal.startOfDay(for: now).addingTimeInterval(14 * 3_600)

        let samples: [SampleVisita] = [
            SampleVisita(
                endereco: "Rua das Palmeiras, 340 — Apto 82",
                bairro: "Jardim Europa", cidade: "São Paulo - SP",
                dataHora: cal.date(byAdding: .hour, value: 2, to: now)!,
                preco: 1_250_000,
                anotacoes: "3 quartos, 2 suítes, varanda gourmet, 2 vagas cobertas.",
                notificacao: true
            ),
            SampleVisita(
                endereco: "Av. Brigadeiro Faria Lima, 1800",
                bairro: "Pinheiros", cidade: "São Paulo - SP",
                dataHora: cal.date(byAdding: .hour, value: 5, to: now)!,
                preco: 980_000,
                anotacoes: "Cobertura duplex com piscina privativa.",
                notificacao: true
            ),
            SampleVisita(
                endereco: "Rua Oscar Freire, 55",
                bairro: "Cerqueira César", cidade: "São Paulo - SP",
                dataHora: cal.date(byAdding: .day, value: 2, to: manha)!,
                preco: 750_000,
                anotacoes: "Studio reformado, 45m². Ideal para investimento.",
                notificacao: false
            ),
            SampleVisita(
                endereco: "Rua Haddock Lobo, 1000",
                bairro: "Higienópolis", cidade: "São Paulo - SP",
                dataHora: cal.date(byAdding: .day, value: -3, to: tarde)!,
                preco: 1_800_000,
                anotacoes: "Apartamento clássico, pé direito duplo.",
                notificacao: false
            )
        ]

        for sample in samples {
            let novaVisita = Visita(
                endereco: sample.endereco,
                bairro: sample.bairro,
                cidade: sample.cidade,
                dataHora: sample.dataHora,
                precoImovel: sample.preco,
                anotacoes: sample.anotacoes,
                notificacaoAgendada: sample.notificacao
            )
            ctx.insert(novaVisita)
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
