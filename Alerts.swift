//
//  Alerts.swift
//  tic_tac_toe
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    var title: Text
    var message: Text
    var buttonTitle: Text
}

struct AlertContext {
    static let humanWin = AlertItem(
        title: Text("You Win! 🏆"),
        message: Text("Brilliant tactical moves! You outsmarted the AI."),
        buttonTitle: Text("Play Again 🚀")
    )

    static let computerWin = AlertItem(
        title: Text("AI Victorious! 🤖"),
        message: Text("The AI predicted your moves. Can you beat it next time?"),
        buttonTitle: Text("Rematch ⚔️")
    )

    static let playerOneWin = AlertItem(
        title: Text("Player X Wins! 🏆"),
        message: Text("Congratulations to Player X on victory!"),
        buttonTitle: Text("Next Round 🔄")
    )

    static let playerTwoWin = AlertItem(
        title: Text("Player O Wins! 🏆"),
        message: Text("Congratulations to Player O on victory!"),
        buttonTitle: Text("Next Round 🔄")
    )

    static let draw = AlertItem(
        title: Text("It's a Draw! 🤝"),
        message: Text("A fiercely contested match with no victor."),
        buttonTitle: Text("Try Again 🔄")
    )
}
