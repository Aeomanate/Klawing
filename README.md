# Klawing

A turn-based multiplayer networked tactical duel for Windows where players manipulate multi-window spatial boundaries, 
throw color blots across a movable central canvas, capture territory, and execute ricochet attacks against hidden opponents.

---

## 1. Game Overview & Mechanics

*Klawing* shifts spatial control into the operating system's windowing space, 
taking inspiration from dynamic multi-window game layouts. 
Two players engage in alternating rounds of tactical positioning, territorial capture, and trajectory calculation.

### Five-Window Spatial Layout
The gameplay environment is partitioned across five coordinated window frames:
- **Central Field Window:** Contains the shared territory canvas that can be shifted by the active player during their turn.
- **Player Windows (Left & Right):** Represent each player's avatar and firing origin.
- **Movement Zone Windows (Left & Right Cones):** Display valid spatial bounds for window positioning, geometrically constrained by the position of the central field.

### Turn Lifecycle & Core Mechanics
1. **Preparation & Shift:** The active player adjusts the position of the central field window and repositions their own avatar window within the resulting valid movement cone.
2. **Aiming & Trajectory Estimation:** The player designates a target coordinate on the central field. Visual guidelines indicate potential trajectory paths.
3. **Execution & Impact (First Strike):** A blot is launched, impacting the central canvas and instantly recoloring the covered area with the player's ink.
4. **Ricochet & Opponent Threat:** The blot bounces off the canvas surface, propagating outward toward the opponent's territory.
5. **Consequences & Turn Transfer:**
   - **Direct Hit:** Contaminates the victim's avatar, injecting a 25% foreign color penalty into their next two shots.
   - **Miss / Area Denial:** Creates a temporary hazard zone that restricts future window placement in that sector for two turns.
   - **Turn Transfer:** Scores update based on percentage of territory controlled; the turn passes to the opponent.

---

## 2. Technology Stack

The project leverages modern C++26 and purpose-built modular libraries managed seamlessly via CMake `FetchContent`:

| Component | Library / Tool | Purpose & Justification |
| :--- | :--- | :--- |
| **Language Standard** | **C++26** | Delivers maximal language expressiveness, safety, compile-time computation, and modern concurrency primitives. |
| **Compiler & Platform** | **MinGW-w64 (GCC 15.1+) on Windows** | Native Windows target support with high-performance modern code generation (`-Wa,-mbig-obj`). |
| **Build System** | **CMake 3.28+ & Ninja** | Fast, reproducible, and deterministic cross-environment compilation pipeline. |
| **Windowing & Graphics** | **SFML 3 (v3.1.0)** | Native multi-window management, 2D hardware-accelerated rendering, audio, and OS event handling. |
| **Networking** | **Boost.Asio (Standalone v1.92.0)** | Asynchronous, low-latency, event-driven network I/O across client and server. |
| **Serialization & Protocol**| **Google Protocol Buffers (v36.2)** | Compact, type-safe, version-resilient binary wire protocol for match states and action events. |
| **Reflection & JSON** | **reflect-cpp (v0.26.2)** | Zero-boilerplate compile-time reflection for configuration files and state snapshots. |
| **Structured Logging** | **spdlog (v1.17.0)** | High-throughput, thread-safe asynchronous diagnostic logging. |
| **CLI Argument Parsing** | **CLI11 (v2.7.2)** | Header-only command-line interface parsing for client and dedicated server runtime options. |
| **Testing Framework** | **Google Test (v1.18.0)** | Comprehensive unit, simulation, and integration test coverage. |

---

## 3. System Architecture

To ensure determinism, maintainability, and clean separation of concerns, the system is divided into decoupled architectural layers:

```
┌─────────────────────────────────────────────────────────────┐
│                      Client Layer                           │
│  ┌────────────────────────┐    ┌─────────────────────────┐  │
│  │  SFML Window Manager   │    │     UI & Visual FX      │  │
│  │   (5-Window System)    │    │ (Ink splatters/trails)  │  │
│  └───────────┬────────────┘    └────────────┬────────────┘  │
└──────────────┼──────────────────────────────┼───────────────┘
               │                              │
┌──────────────▼──────────────────────────────▼───────────────┐
│                 Deterministic Core Simulation               │
│  ┌───────────────────────┐    ┌──────────────────────────┐  │
│  │   Physics & Trajectory│    │    Territory Canvas      │  │
│  │   (Ricochet Solver)   │    │  (Coverage Mask / Score) │  │
│  └───────────────────────┘    └──────────────────────────┘  │
│  ┌───────────────────────┐    ┌──────────────────────────┐  │
│  │ Cone Constraint Model │    │ Game Rules State Machine │  │
│  └───────────────────────┘    └──────────────────────────┘  │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                  Networking & Protocol Layer                │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Boost.Asio Async Engine + Protobuf Binary Messaging   │  │
│  └───────────────────────────────────────────────────────┘  │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                    Authoritative Server                     │
│  ┌────────────────────────┐    ┌─────────────────────────┐  │
│  │ Session & Matchmaker   │    │ Action Validation Loop  │  │
│  └────────────────────────┘    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Architectural Subsystems
- **Client (`Game/src`):** Coordinates five distinct SFML render windows, maps desktop coordinates, captures user input for aiming and field displacement, and renders ink splatters and trajectory hints.
- **Simulation Engine (`Game/src` / `Game/src`):** Pure deterministic state container containing:
  - *Territory Canvas Grid:* Binary/pixel coverage masks calculating fractional ownership and contamination.
  - *Ricochet Solver:* Elastic reflection physics computing blot trajectories post-impact.
  - *Cone Boundary Calculator:* Real-time parametric math calculating movement cones based on field coordinates.
- **Authoritative Server (`Game/src`):** Validates all moves, verifies positional legality, executes authoritative turn resolution, and broadcasts serialized delta updates.
- **Network Protocol (`Game/src`):** Houses `.proto` schema definitions generating strongly-typed messages for match pairing, turn intents, shot resolutions, and disconnect handling.

---

## 4. Build & Environment Instructions

### Prerequisites
- **Operating System:** Windows 10/11 (64-bit)
- **Compiler:** MinGW-w64 with GCC 15+ (supporting `-std=c++26`)
- **Build Tools:** CMake 3.28+ and Ninja
- **Git:** Installed and available in system `PATH` (used by CMake `FetchContent` to retrieve dependencies)

### Configuration & Compilation

1. **Clone the Repository:**
   ```powershell
   git clone https://github.com/your-username/Klawing.git
   cd Klawing
   ```

2. **Configure the Project with CMake & Ninja:**
   Ensure your MinGW compiler is accessible in your environment, then run:
   ```powershell
   cmake -B cmake-build-debug -S . -G Ninja -DCMAKE_C_COMPILER="gcc" -DCMAKE_CXX_COMPILER="g++"
   ```

3. **Build the Binary:**
   ```powershell
   cmake --build cmake-build-debug --config Debug
   ```

4. **Run the Executable:**
   ```powershell
   .\cmake-build-debug\Klawing.exe --help
   ```

5. **Run Test Suites:**
   ```powershell
   ctest --test-dir cmake-build-debug --output-on-failure
   ```
