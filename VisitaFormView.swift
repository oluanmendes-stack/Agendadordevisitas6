// VisitaFormView.swift
// Formulário bottom-sheet — espelho fiel do protótipo React

import SwiftUI

// MARK: - Mode

enum FormMode {
    case nova
    case editar(Visita)

    var titulo: String {
        switch self {
        case .nova:   return "Nova Visita"
        case .editar: return "Editar Visita"
        }
    }

    var botao: String {
        switch self {
        case .nova:   return "🏠 Agendar Visita"
        case .editar: return "💾 Salvar Alterações"
        }
    }
}

// MARK: - VisitaFormView

struct VisitaFormView: View {

    let mode: FormMode
    let onSave: (VisitaDados) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var endereco = ""
    @State private var bairro   = ""
    @State private var cidade   = "São Paulo - SP"
    @State private var dataHora = Date().nextHour
    @State private var precoRaw = ""
    @State private var anotacoes = ""
    @State private var notificacao = true

    @State private var errors: [String: String] = [:]
    @FocusState private var focus: Campo?
    enum Campo: Hashable { case endereco, bairro, cidade, preco, notas }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Localização
                    FormSection(
                        title: "📍 LOCALIZAÇÃO",
                        color: .brandBlue,
                        bgColor: Color(red: 0.973, green: 0.976, blue: 1.0)
                    ) {
                        VStack(spacing: 10) {
                            FormField(label: "Endereço", required: true, placeholder: "Ex: Rua das Flores, 123",
                                      text: $endereco, error: errors["endereco"])
                                .focused($focus, equals: .endereco)
                                .submitLabel(.next).onSubmit { focus = .bairro }

                            HStack(spacing: 8) {
                                FormField(label: "Bairro", placeholder: "Jardim Europa", text: $bairro)
                                    .focused($focus, equals: .bairro)
                                    .submitLabel(.next).onSubmit { focus = .cidade }
                                FormField(label: "Cidade", placeholder: "São Paulo - SP", text: $cidade)
                                    .focused($focus, equals: .cidade)
                                    .submitLabel(.done).onSubmit { focus = nil }
                            }
                        }
                    }

                    // Data e Hora
                    FormSection(
                        title: "🗓 DATA E HORA",
                        color: Color.brandGreen,
                        bgColor: Color(red: 0.973, green: 1.0, blue: 0.973)
                    ) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Quando será a visita?")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.secondaryLabel)

                            DatePicker("", selection: $dataHora, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.graphical)
                                .tint(Color.brandGreen)
                                .environment(\.locale, Locale(identifier: "pt_BR"))
                                .labelsHidden()

                            if let dateError = errors["data"] {
                                ErrorLabel(text: dateError)
                            }
                        }
                    }

                    // Valor
                    FormSection(
                        title: "💰 VALOR DO IMÓVEL",
                        color: Color.brandYellow,
                        bgColor: Color(red: 1.0, green: 0.996, blue: 0.941)
                    ) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Preço (R$)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.secondaryLabel)

                            HStack(spacing: 0) {
                                Text("R$  ")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.secondaryLabel)
                                    .padding(.leading, 13)

                                TextField("0,00", text: $precoRaw)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.label)
                                    .focused($focus, equals: .preco)
                                    .onChange(of: precoRaw) { _, newValue in precoRaw = formatInput(newValue) }
                            }
                            .frame(height: 48)
                            .background(Color.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        errors["preco"] != nil ? Color.brandRed : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )

                            if let precoValue = precoDouble, precoValue > 0 {
                                Text(formatBRL(precoValue))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.brandGreen)
                            }
                            if let precoError = errors["preco"] { ErrorLabel(text: precoError) }
                        }
                    }

                    // Anotações
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Anotações")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.label)

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $anotacoes)
                                .frame(minHeight: 90, maxHeight: 160)
                                .focused($focus, equals: .notas)
                                .padding(8)
                                .background(Color.inputBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .font(.system(size: 14))
                                .foregroundStyle(Color.label)

                            if anotacoes.isEmpty {
                                Text("Características do imóvel, observações...")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.tertiaryLabel.opacity(0.6))
                                    .padding(.top, 16)
                                    .padding(.leading, 12)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Notificação
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🔔 Lembrete 1h antes")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.label)
                            Text("Notificação push com o endereço")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.secondaryLabel)
                        }
                        Spacer()
                        Toggle("", isOn: $notificacao)
                            .labelsHidden()
                            .tint(Color.brandOrange)
                    }
                    .padding(14)
                    .background(Color(red: 1.0, green: 0.969, blue: 0.941))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Save button
                    Button(action: handleSave) {
                        Text(mode.botao)
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [Color.brandBlue, Color(red: 0, green: 0.333, blue: 0.831)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.brandBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .background(Color.appBackground)
            .navigationTitle(mode.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.secondaryLabel)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Pronto") { focus = nil }
                }
            }
        }
        .onAppear { loadIfEditing() }
    }

    // MARK: - Helpers

    private var precoDouble: Double? {
        let rawString = precoRaw
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(rawString)
    }

    private func formatInput(_ text: String) -> String {
        let nums = text.filter(\.isNumber)
        guard !nums.isEmpty else { return "" }
        let value = (Double(nums) ?? 0) / 100
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? text
    }

    private func formatBRL(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
    }

    private func loadIfEditing() {
        guard case .editar(let visitaEditando) = mode else { return }
        endereco = visitaEditando.endereco
        bairro = visitaEditando.bairro
        cidade = visitaEditando.cidade
        dataHora = visitaEditando.dataHora
        anotacoes = visitaEditando.anotacoes
        notificacao = visitaEditando.notificacaoAgendada
        precoRaw = formatInput(String(Int(visitaEditando.precoImovel * 100)))
    }

    private func handleSave() {
        focus = nil
        errors = [:]
        if endereco.trimmingCharacters(in: .whitespaces).isEmpty { errors["endereco"] = "Endereço obrigatório" }
        guard let preco = precoDouble, preco > 0 else { errors["preco"] = "Informe um preço válido"; return }
        guard errors.isEmpty else { return }

        onSave(VisitaDados(
            endereco: endereco.trimmingCharacters(in: .whitespaces),
            bairro: bairro.trimmingCharacters(in: .whitespaces),
            cidade: cidade.trimmingCharacters(in: .whitespaces),
            dataHora: dataHora, preco: preco,
            anotacoes: anotacoes.trimmingCharacters(in: .whitespaces),
            notificacao: notificacao
        ))
        dismiss()
    }
}

// MARK: - FormSection

struct FormSection<Content: View>: View {
    let title: String
    let color: Color
    let bgColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(color)

            content
        }
        .padding(14)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - FormField

struct FormField: View {
    let label: String
    var required: Bool = false
    let placeholder: String
    @Binding var text: String
    var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondaryLabel)
                if required { Text("*").foregroundStyle(Color.brandRed).font(.system(size: 12)) }
            }
            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .foregroundStyle(Color.label)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(Color.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(error != nil ? Color.brandRed : Color.clear, lineWidth: 1.5)
                )

            if let errorMessage = error { ErrorLabel(text: errorMessage) }
        }
    }
}

// MARK: - ErrorLabel

struct ErrorLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(Color.brandRed)
    }
}

// MARK: - Date extension

extension Date {
    var nextHour: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        components.hour = (components.hour ?? 0) + 1
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components) ?? self
    }
}
