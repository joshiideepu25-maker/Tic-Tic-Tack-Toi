//
//  Alerts.swift
//  tic_tac_toe
//
//  Created by Akhil on 04/11/23.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id =  UUID()
    var title: Text
    var message: Text
    var buttonTitle: Text
    
}

struct AlertContext {
    
    static let humanWin = AlertItem(title: Text("You Win!"),
                                    message: Text("You are smart, you beat your own AI."),
                                    buttonTitle: Text("Hell Yeah!🤩"))
    
    static let computerWin = AlertItem(title: Text("Computer Win!😁"),
                                       message: Text("AI is better than you."),
                                       buttonTitle: Text("Rematch🤨"))
    
    static let draw = AlertItem(title: Text("Draw"),
                                message: Text("Nice Battle"),
                                buttonTitle: Text("Try again 😇"))
}

