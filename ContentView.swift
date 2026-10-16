//
//  ContentView.swift
//  tic_tac_toe
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            // Elegant background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.07, green: 0.09, blue: 0.15),
                    Color(red: 0.03, green: 0.04, blue: 0.07)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                // MARK: - Header
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .font(.title2)
                        .foregroundColor(.cyan)

                    Text("Tic-Tac-Toe")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.resetGame(clearScores: false)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                // MARK: - Mode Picker
                Picker("Game Mode", selection: $viewModel.gameMode) {
                    ForEach(GameMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // MARK: - Difficulty Picker (Single Player)
                if viewModel.gameMode == .vsComputer {
                    HStack(spacing: 10) {
                        Text("AI Difficulty:")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)

                        ForEach(AIDifficulty.allCases) { diff in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.aiDifficulty = diff
                                }
                            }) {
                                Text(diff.rawValue)
                                    .font(.caption.bold())
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(
                                        viewModel.aiDifficulty == diff
                                            ? Color.cyan.opacity(0.85)
                                            : Color.white.opacity(0.08)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // MARK: - Scoreboard
                HStack(spacing: 12) {
                    ScoreCardView(
                        title: viewModel.gameMode == .vsComputer ? "YOU (X)" : "PLAYER X",
                        score: viewModel.p1Wins,
                        color: .cyan
                    )
                    ScoreCardView(
                        title: "DRAWS",
                        score: viewModel.draws,
                        color: .gray
                    )
                    ScoreCardView(
                        title: viewModel.gameMode == .vsComputer ? "AI (O)" : "PLAYER O",
                        score: viewModel.p2Wins,
                        color: .pink
                    )
                }
                .padding(.horizontal)

                // MARK: - Status Banner
                HStack(spacing: 8) {
                    if viewModel.isGameboardDisabled {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                            .scaleEffect(0.8)
                    }
                    Text(viewModel.statusMessage)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.white.opacity(0.07))
                .cornerRadius(20)

                Spacer()

                // MARK: - Game Board
                GeometryReader { geometry in
                    let boardWidth = min(geometry.size.width - 32, geometry.size.height)
                    let tileSize = (boardWidth - 28) / 3

                    VStack {
                        Spacer()
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(0..<9) { index in
                                let isWinningTile = viewModel.winningPattern?.contains(index) ?? false

                                ZStack {
                                    // Tile Background
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            isWinningTile
                                                ? Color.green.opacity(0.35)
                                                : Color.white.opacity(0.08)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(
                                                    isWinningTile
                                                        ? Color.green
                                                        : Color.white.opacity(0.12),
                                                    lineWidth: isWinningTile ? 3 : 1
                                                )
                                        )
                                        .shadow(
                                            color: isWinningTile
                                                ? Color.green.opacity(0.5)
                                                : Color.black.opacity(0.3),
                                            radius: isWinningTile ? 10 : 4,
                                            x: 0,
                                            y: 3
                                        )

                                    // Symbol (X or O)
                                    if let move = viewModel.moves[index] {
                                        Image(systemName: move.indicator)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: tileSize * 0.45, height: tileSize * 0.45)
                                            .foregroundColor(move.player.color)
                                            .shadow(color: move.player.color.opacity(0.6), radius: 8)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .frame(width: tileSize, height: tileSize)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                                        viewModel.processPlayerMove(for: index)
                                    }
                                }
                            }
                        }
                        .frame(width: boardWidth)
                        .padding(.horizontal, 16)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(viewModel.isGameboardDisabled)

                Spacer()

                // MARK: - Footer Controls
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.resetGame(clearScores: false)
                        }
                    }) {
                        Label("New Round", systemImage: "play.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.85), Color.blue.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.cyan.opacity(0.3), radius: 6, x: 0, y: 3)
                    }

                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.resetGame(clearScores: true)
                        }
                    }) {
                        Label("Reset Stats", systemImage: "trash")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
        }
        .alert(item: $viewModel.alertItem) { alert in
            Alert(
                title: alert.title,
                message: alert.message,
                dismissButton: .default(alert.buttonTitle) {
                    withAnimation(.spring()) {
                        viewModel.resetGame(clearScores: false)
                    }
                }
            )
        }
    }
}

// MARK: - Score Card Component
struct ScoreCardView: View {
    let title: String
    let score: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)

            Text("\(score)")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
        .cornerRadius(14)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
