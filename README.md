# 🎮 Tic-Tac-Toe (SwiftUI)

A modern, beautifully designed **Tic-Tac-Toe** game built using **SwiftUI** for iOS with full MVVM architecture, smart AI (including unbeatable Minimax), and multiplayer support.

---

## ✨ Features

- 🤖 **Smart AI Opponent**:
  - **Easy**: Fast, casual random moves.
  - **Medium**: Tactical play (detects wins & blocks player).
  - **Master**: Unbeatable AI powered by the **Minimax Algorithm**.
- 👥 **2-Player Mode**: Pass & Play with a friend on the same device.
- 📊 **Real-time Scoreboard**: Tracks Player X wins, Player O wins, and Draws across rounds.
- 🎨 **Modern Cyber Aesthetic**:
  - Dark mode glassmorphic UI with vibrant neon accents (Cyan & Coral Pink).
  - Interactive spring animations on tap.
  - Winning row highlighting with glowing effects.
- 🏗️ **Clean Architecture**: Built strictly following the **MVVM (Model-View-ViewModel)** design pattern.

---

## 🛠️ Project Structure

```
tic_tac_toe/
├── tic_tac_toeApp.swift    # App entry point
├── ContentView.swift       # Modern UI with responsive grid, scoreboard & controls
├── GameViewModel.swift     # Core game logic, state machine & Minimax AI
├── Alerts.swift            # Alert dialog definitions for game outcomes
├── Assets.xcassets         # App icons & color sets
└── README.md               # Documentation
```

---

## 📱 Requirements

- **iOS**: 15.0+
- **Xcode**: 13.0+
- **Swift**: 5.5+

---

## 🚀 How to Run in Xcode

1. Clone the repository:
   ```bash
   git clone https://github.com/joshiideepu25-maker/Tic-Tic-Tack-Toi.git
   ```
2. Open the project folder or `.xcodeproj` in **Xcode**.
3. Select an iOS Simulator or connected device.
4. Press `Cmd + R` to build and run!
