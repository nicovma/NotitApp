//
//  ViewModelState.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

enum ViewModelState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}
