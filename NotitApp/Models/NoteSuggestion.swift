//
//  NoteSuggestion.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 16/9/2026.
//
import FoundationModels

@Generable
struct NoteSuggestion {
    @Guide(description: "Título corto que resume el CONTENIDO específico de la nota, máx 6 palabras. Nunca el nombre de una categoría")
    let title: String

    @Guide(description: "Nombre de la categoría TEMÁTICA de la nota (ej: Salud, Compras, Trabajo), reutilizando una existente cuando encaje. Siempre distinto de title")
    let categoryName: String

    @Guide(description: "True si categoryName no coincide con ninguna categoría existente")
    let isNewCategory: Bool
}
