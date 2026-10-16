//
//  GameViewModel.swift
//  tic_tac_toe
//

import SwiftUI

enum Player {
    case playerOne
    case playerTwo // Can be human friend or AI

    var symbol: String {
        switch self {
        case .playerOne: return "xmark"
        case .playerTwo: return "circle"
        }
    }

    var color: Color {
        switch self {
        case .playerOne: return Color.cyan
        case .playerTwo: return Color.pink
        }
    }

    var displayName: String {
        switch self {
        case .playerOne: return "Player X"
        case .playerTwo: return "Player O"
        }
    }
}

enum GameMode: String, CaseIterable, Identifiable {
    case vsComputer = "vs AI"
    case passAndPlay = "2 Players"
    var id: String { self.rawValue }
}

enum AIDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Master"
    var id: String { self.rawValue }
}

struct Move {
    let player: Player
    let boardIndex: Int
    var indicator: String {
        player.symbol
    }
}

final class GameViewModel: ObservableObject {
    @Published var moves: [Move?] = Array(repeating: nil, count: 9)
    @Published var isGameboardDisabled = false
    @Published var activePlayer: Player = .playerOne
    @Published var gameMode: GameMode = .vsComputer {
        didSet { resetGame(clearScores: false) }
    }
    @Published var aiDifficulty: AIDifficulty = .medium
    @Published var winningPattern: [Int]? = nil
    @Published var alertItem: AlertItem?

    // Scores
    @Published var p1Wins: Int = 0
    @Published var p2Wins: Int = 0
    @Published var draws: Int = 0

    let winPatterns: [[Int]] = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
        [0, 4, 8], [2, 4, 6]             // Diagonals
    ]

    var statusMessage: String {
        if winningPattern != nil {
            return "Round Over!"
        }
        if checkForDraw(in: moves) {
            return "It's a Draw!"
        }
        if gameMode == .vsComputer {
            return activePlayer == .playerOne ? "Your Turn (X)" : "AI is thinking..."
        } else {
            return "\(activePlayer.displayName)'s Turn (\(activePlayer == .playerOne ? "X" : "O"))"
        }
    }

    func processPlayerMove(for position: Int) {
        guard !isSquareOccupied(in: moves, forIndex: position) else { return }

        // Execute move
        moves[position] = Move(player: activePlayer, boardIndex: position)

        // Check for Win
        if let pattern = getWinningPattern(for: activePlayer, in: moves) {
            winningPattern = pattern
            recordWin(for: activePlayer)
            return
        }

        // Check for Draw
        if checkForDraw(in: moves) {
            draws += 1
            alertItem = AlertContext.draw
            return
        }

        if gameMode == .passAndPlay {
            // Switch turn to player two
            activePlayer = (activePlayer == .playerOne) ? .playerTwo : .playerOne
        } else {
            // Single Player mode: Switch to AI
            activePlayer = .playerTwo
            isGameboardDisabled = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.processAIMove()
            }
        }
    }

    private func processAIMove() {
        let aiPosition = determineAIMovePosition()
        moves[aiPosition] = Move(player: .playerTwo, boardIndex: aiPosition)
        isGameboardDisabled = false

        if let pattern = getWinningPattern(for: .playerTwo, in: moves) {
            winningPattern = pattern
            recordWin(for: .playerTwo)
            return
        }

        if checkForDraw(in: moves) {
            draws += 1
            alertItem = AlertContext.draw
            return
        }

        activePlayer = .playerOne
    }

    private func recordWin(for player: Player) {
        if player == .playerOne {
            p1Wins += 1
            alertItem = (gameMode == .vsComputer) ? AlertContext.humanWin : AlertContext.playerOneWin
        } else {
            p2Wins += 1
            alertItem = (gameMode == .vsComputer) ? AlertContext.computerWin : AlertContext.playerTwoWin
        }
    }

    // MARK: - AI Logic

    private func determineAIMovePosition() -> Int {
        switch aiDifficulty {
        case .easy:
            return getRandomMove()
        case .medium:
            return getMediumMove()
        case .hard:
            return getMinimaxMove()
        }
    }

    private func getRandomMove() -> Int {
        let availablePositions = moves.indices.filter { moves[$0] == nil }
        return availablePositions.randomElement() ?? 0
    }

    private func getMediumMove() -> Int {
        // 1. Can AI win on this turn?
        for pattern in winPatterns {
            let aiMoves = pattern.filter { moves[$0]?.player == .playerTwo }
            let emptySpots = pattern.filter { moves[$0] == nil }
            if aiMoves.count == 2 && emptySpots.count == 1 {
                return emptySpots[0]
            }
        }

        // 2. Can human win on next turn? Block them!
        for pattern in winPatterns {
            let humanMoves = pattern.filter { moves[$0]?.player == .playerOne }
            let emptySpots = pattern.filter { moves[$0] == nil }
            if humanMoves.count == 2 && emptySpots.count == 1 {
                return emptySpots[0]
            }
        }

        // 3. Take center if available
        let center = 4
        if moves[center] == nil {
            return center
        }

        // 4. Take corners if available
        let corners = [0, 2, 6, 8].filter { moves[$0] == nil }
        if let corner = corners.randomElement() {
            return corner
        }

        // 5. Otherwise take random open spot
        return getRandomMove()
    }

    // Unbeatable Minimax
    private func getMinimaxMove() -> Int {
        var bestScore = -Int.max
        var bestMove = getRandomMove()

        for i in 0..<9 where moves[i] == nil {
            moves[i] = Move(player: .playerTwo, boardIndex: i)
            let score = minimax(isMaximizing: false, depth: 0)
            moves[i] = nil

            if score > bestScore {
                bestScore = score
                bestMove = i
            }
        }
        return bestMove
    }

    private func minimax(isMaximizing: Bool, depth: Int) -> Int {
        if checkWinCondition(for: .playerTwo, in: moves) {
            return 10 - depth
        }
        if checkWinCondition(for: .playerOne, in: moves) {
            return depth - 10
        }
        if checkForDraw(in: moves) {
            return 0
        }

        if isMaximizing {
            var bestScore = -Int.max
            for i in 0..<9 where moves[i] == nil {
                moves[i] = Move(player: .playerTwo, boardIndex: i)
                let score = minimax(isMaximizing: false, depth: depth + 1)
                moves[i] = nil
                bestScore = max(bestScore, score)
            }
            return bestScore
        } else {
            var bestScore = Int.max
            for i in 0..<9 where moves[i] == nil {
                moves[i] = Move(player: .playerOne, boardIndex: i)
                let score = minimax(isMaximizing: true, depth: depth + 1)
                moves[i] = nil
                bestScore = min(bestScore, score)
            }
            return bestScore
        }
    }

    // MARK: - Validation Helpers

    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        return moves[index] != nil
    }

    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        return getWinningPattern(for: player, in: moves) != nil
    }

    func getWinningPattern(for player: Player, in moves: [Move?]) -> [Int]? {
        let playerPositions = Set(moves.compactMap { $0 }.filter { $0.player == player }.map { $0.boardIndex })
        for pattern in winPatterns {
            if Set(pattern).isSubset(of: playerPositions) {
                return pattern
            }
        }
        return nil
    }

    func checkForDraw(in moves: [Move?]) -> Bool {
        return moves.compactMap { $0 }.count == 9
    }

    func resetGame(clearScores: Bool = false) {
        moves = Array(repeating: nil, count: 9)
        winningPattern = nil
        activePlayer = .playerOne
        isGameboardDisabled = false
        if clearScores {
            p1Wins = 0
            p2Wins = 0
            draws = 0
        }
    }
}
