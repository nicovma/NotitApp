//
//  InteractivePopGestureEnabler.swift
//  NotitApp
//
import SwiftUI

/// `.navigationBarHidden(true)` leaves `interactivePopGestureRecognizer`
/// unreliable on some iOS versions, since its default delegate checks the
/// bar's visibility state. Clearing the delegate restores swipe-to-go-back
/// without touching the custom Liquid Glass back button these screens use
/// instead of a system nav bar item.
private struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Controller()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }
}

extension View {
    func enablesInteractivePopGesture() -> some View {
        background(InteractivePopGestureEnabler())
    }
}
