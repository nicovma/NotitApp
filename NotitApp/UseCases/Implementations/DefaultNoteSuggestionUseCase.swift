//
//  DefaultNoteSuggestionUseCase.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 16/9/2026.
//
import Foundation
import FoundationModels

@MainActor
final class DefaultNoteSuggestionUseCase: NoteSuggestionUseCase {

    var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available: true
        case .unavailable: false
        }
    }

    var unavailableReason: String? {
        guard case .unavailable(let reason) = SystemLanguageModel.default.availability else { return nil }
        switch reason {
        case .deviceNotEligible:
            return String(localized: "Este dispositivo no es compatible con Apple Intelligence")
        case .appleIntelligenceNotEnabled:
            return String(localized: "Activá Apple Intelligence en Ajustes para ver sugerencias con IA")
        case .modelNotReady:
            return String(localized: "El modelo de IA se está preparando, probá en unos minutos")
        @unknown default:
            return String(localized: "Sugerencias con IA no disponibles en este dispositivo")
        }
    }

    func suggest(for text: String, existingCategories: [Category], previousSuggestion: NoteSuggestion?) async throws -> NoteSuggestion {
        let categoryNames = existingCategories.map(\.name).joined(separator: ", ")
        let languageCode = Bundle.main.preferredLocalizations.first ?? "es"
        let languageName = Locale(identifier: "en_US").localizedString(forLanguageCode: languageCode) ?? "Spanish"
        let session = LanguageModelSession(
            instructions: """
            Respondé siempre en \(languageName), de forma breve y directa, sin importar \
            en qué idioma esté escrito el contenido de la nota.
            Tu tarea es leer el CONTENIDO de una nota personal y sugerir:
            1. Un título que resuma específicamente ese contenido. Nunca uses el nombre \
            de una categoría como título.
            2. El nombre de la categoría temática a la que pertenece la nota (ej: Salud, \
            Compras, Trabajo, Viajes, Ideas), reutilizando una categoría existente cuando \
            encaje en vez de inventar una nueva.

            El título y la categoría nunca deben ser el mismo texto. Basate estrictamente \
            en lo que dice la nota, no inventes contenido que no está.

            Ejemplo: para la nota "Quiero jugar al sol porque hace bien a la piel", un \
            buen resultado es título="Tomar sol" y categoría="Salud" — no repitas el \
            título como categoría ni sugieras algo sin relación con el texto.
            """
        )
        var prompt = """
        Categorías existentes: \(categoryNames.isEmpty ? "ninguna" : categoryNames)

        Contenido de la nota:
        \(text)
        """
        if let previousSuggestion {
            prompt += """


            Ya sugeriste título="\(previousSuggestion.title)" y categoría="\(previousSuggestion.categoryName)" \
            y no le sirvió al usuario. Dale una alternativa distinta, no repitas ese título ni esa categoría.
            """
        }
        let response = try await session.respond(
            to: prompt,
            generating: NoteSuggestion.self,
            options: GenerationOptions(sampling: .random(probabilityThreshold: 0.9), temperature: 0.9)
        )
        return response.content
    }
}
