//
//  CoraButton.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI

enum CoraButtonState {
    case `default`
    case disabled
    case loading
}

struct CoraButton: View {
    @SwiftUI.Environment(\.isEnabled) private var isEnabled: Bool

    private var _isDisabled: Bool?
    private var isDisabled: Bool {
        _isDisabled ?? !isEnabled
    }

    let text: LocalizedStringKey
    let action: () -> Void

    private var configuration: CoraButtonConfiguration

    private var currentState: CoraButtonState {
        isDisabled ? .disabled : .default
    }

    /// Creates a customizable CoraButton.
    ///
    /// - Parameters:
    ///   - text: The text displayed on the button.
    ///   - color: The background color of the button. Default is `.primary`.
    ///   - icon: An optional `CoraButtonIcon` enum value representing the button icon. Default is nil.
    ///   - size: The size of the button, default is `.medium`.
    ///   - variant: The style variant of the button, default is `.primary`.
    ///   - action: A closure to be executed when the button is pressed. Default is an empty closure.
    ///
    /// Example:
    /// ```swift
    /// CoraButton("Click me") {
    ///  // button pressed
    /// }
    ///
    /// CoraButton("Press me", color: .blue, icon: .arrowRight, size: .large, variant: .primary) {
    ///   // Code to be executed on button press
    /// }
    /// ```
    init(
        _ text: LocalizedStringKey,
        color: Color = .primary,
        icon: CoraButtonIcon? = nil,
        size: ButtonSize = .medium,
        variant: CoraButtonVariant = .primary,
        action: @escaping () -> Void = {}
    ) {
        self.text = text
        self.action = action
        configuration = .init(icon: icon, size: size, variant: variant, color: color)
    }

    @ViewBuilder
    private var iconView: some View {
        if let icon = configuration.icon {
            Image(systemName: icon.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundColor(configuration.iconColor)
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if configuration.icon == nil && configuration.variant != .text {
                    Spacer()
                }
                Text(text)
                    .font(.avenirBodyBold(size: configuration.size.fontSize))
                    .foregroundColor(configuration.textColor)
                if configuration.variant != .text {
                    Spacer()
                }
                iconView
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .frame(height: configuration.size.rawValue)
            .background(isDisabled ? Color.gray.opacity(0.5) : configuration.backgroundColor)
            .cornerRadius(configuration.size.rawValue / 4)
        }
        .disabled(currentState == .disabled || currentState == .loading)
    }

    func disabled(_ isDisabled: Bool) -> Self {
        var copy = self
        copy._isDisabled = isDisabled
        return copy
    }
}

struct CoraButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CoraButton(LocalizedStringKey("Quero fazer parte!"), color: .primary, icon: .arrowRight, size: .medium, variant: .primary) {
                print("Button pressed")
            }
            .padding()
            .environment(\.isEnabled, true)
            
            CoraButton("Já sou cliente", color: .clear, size: .small, variant: .text) {
                print("Button pressed")
            }
            .padding()
            .environment(\.isEnabled, false)
        }
    }
}
