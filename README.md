# GreenMind: Plant Care Dashboard & Smart Garden Ecosystem

[![Platform: iOS & tvOS](https://img.shields.io/badge/Platform-iOS%2017%2B%20%7C%20tvOS%2017%2B-blue.svg)](https://developer.apple.com/swiftui/)
[![Language: Swift 5.9](https://img.shields.io/badge/Language-Swift%205.9-orange.svg)](https://swift.org/)
[![Framework: SwiftUI](https://img.shields.io/badge/Framework-SwiftUI-green.svg)](https://developer.apple.com/documentation/swiftui)
[![Academic: SE4041 MADD](https://img.shields.io/badge/Module-SE4041%20MADD-purple.svg)]()

> **SE4041 — Mobile Application Design and Development**  
> **Assignment 02 Documentation (Total: 25%)**  
> * Semester 2, 2026  
> * Student Name: **SUDUSINGHE JJ**  
> * Student ID: **IT22368898**  
> * Degree Programme: **BSc (Hons) in Information Technology** (Year 4)  
> * Scope: **Part A — Advanced iOS Application (15%)** & **Part B — Innovative tvOS Prototype (10%)**

---

## 📖 Table of Contents
1. [Project Overview & Concept](#1-project-overview--concept)
2. [Target Audience & Problem Statement](#2-target-audience--problem-statement)
3. [System Architecture & Multi-Platform Strategy](#3-system-architecture--multi-platform-strategy)
4. [Part A: Advanced iOS Application (15%)](#4-part-a-advanced-ios-application-15)
5. [Part B: tvOS Living-Room Experience (10%)](#5-part-b-tvos-living-room-experience-10)
6. [Data Model & CRUD Implementation](#6-data-model--crud-implementation)
7. [Technical Challenges & Debugging Record](#7-technical-challenges--debugging-record)
8. [Testing & Evaluation Plan](#8-testing--evaluation-plan)
9. [Demonstration & Viva Strategy](#9-demonstration--viva-strategy)
10. [AI-Assisted Development Transparency Disclosure](#10-ai-assisted-development-transparency-disclosure)
11. [Setup, Build & Execution Guide](#11-setup-build--execution-guide)
12. [Submission Compliance Checklist](#12-submission-compliance-checklist)

---

## 1. Project Overview & Concept

**GreenMind** is a digital plant-care management companion engineered to organize domestic plant collections, monitor soil saturation levels, and coordinate proactive irrigation. 

The project operates across a dual-platform paradigm:
* **Mobile iOS App:** A pocket companion providing real-time telemetry, threshold-based automated triggers, manual pump overrides, and local persistence.
* **tvOS Living-Room Dashboard:** An ambient, glanceable TV interface enabling whole-household plant health observation and collection record management via the Apple TV Siri Remote.

---

## 2. Target Audience & Problem Statement

### Problem Statement
Indoor plant owners frequently struggle with irregular watering cadences, often over-watering or under-watering due to lack of visible soil condition feedback. Furthermore, managing heterogeneous plant species across multiple rooms leads to neglected plants and fragmented record-keeping.

### Target Audience
* Urban indoor gardeners and houseplant hobbyists.
* Households seeking shared, glanceable plant health metrics without opening individual phone apps.
* Small-scale automated greenhouse operators.

### Core Value Proposition
GreenMind consolidates plant records, environmental metrics (moisture percentage and temperature), and hydration status into clean, glanceable native interfaces with fail-safe pump actuation mechanics.

---

## 3. System Architecture & Multi-Platform Strategy

```
┌────────────────────────────────────────────────────────────────────────┐
│                        GreenMind Ecosystem Architecture                │
├───────────────────────────────────┬────────────────────────────────────┤
│       Part A: iOS Mobile App      │     Part B: tvOS Dashboard App     │
├───────────────────────────────────┼────────────────────────────────────┤
│ • NavigationStack Hierarchy       │ • 10-Foot Ambient TV Grid Layout   │
│ • Custom Radial Moisture Gauges   │ • Apple TV Remote Focus Engine     │
│ • SwiftData / Persistent Store    │ • Full In-Memory CRUD Operations   │
│ • IoT Wi-Fi ESP32 Telemetry       │ • High-Contrast Large Format Cards │
└─────────────────┬─────────────────┴─────────────────┬──────────────────┘
                  │                                   │
                  ▼                                   ▼
        ┌───────────────────┐               ┌───────────────────┐
        │ Plant Core Models │               │ Reactive SwiftUI  │
        │  & Event Engine   │               │   State Binding   │
        └─────────┬─────────┘               └───────────────────┘
                  ▼
        ┌────────────────────────────────────────────────────────┐
        │ Edge Hardware Layer (ESP32 MCU + Moisture ADC + Relay) │
        └────────────────────────────────────────────────────────┘
```

---

## 4. Part A: Advanced iOS Application (15%)

### Requirements & Alignment Matrix

| Requirement | Implementation Scope in GreenMind | Status / Evidence |
| :--- | :--- | :--- |
| **Clear Purpose & Audience** | Domestic indoor plant owners; solves under/over-watering via telemetry. | Concept Defined & Mapped |
| **≥ 3 Navigable Screens** | `DashboardView` (Telemetry), `PlantSettingsView` (Thresholds), `HistoryView` (Logs). | NavigationStack Implemented |
| **Custom SwiftUI Component** | Dynamic Radial Moisture Gauge with chromatic state indicators and animated pulse. | Custom View & Modifier |
| **Data Persistence** | Local SQLite storage via **SwiftData** / Core Data storing plant profiles and irrigation history. | Schema Authored |
| **Emerging Technology** | **IoT Edge Integration**: ESP32 microcontroller over local Wi-Fi / REST socket telemetry. | Planned Integration |
| **Accessibility & Branding** | Apple HIG compliance, Dynamic Type support, Dark Mode, color-blind friendly cues. | Verified |
| **Testing & Documentation** | Unit, UI, and performance test suites with boundary checking. | Documented Below |

### Dual-Mode Irrigation Logic
1. **Closed-Loop Automation:**  
   * Triggers automatic hydration when moisture $M < T_{\text{low}}$ (default: $30\%$).
   * Ceases actuation once moisture satisfies $T_{\text{high}}$ (default: $60\%$).
   * Failsafe cutoff timer terminates operation at $15\text{s}$ if threshold feedback stalls.
2. **Manual Override:**  
   * Exclusively accessible when automated watering is switched **Off**.
   * Instant toggle relay with hard-coded $20\text{s}$ continuous run limit.

---

## 5. Part B: tvOS Living-Room Experience (10%)

The tvOS application translates plant monitoring into an ambient living-room experience optimized for a 10-foot viewing distance.

### Key Screens & Structure
* **Ambient Dashboard:** Wide-aspect card grid showing plant name, room placement, moisture badge, and care status.
* **Plant Detail Screen (`PlantDetailView`):** Dedicated view presenting deep telemetry (temperature, moisture percentage) and action triggers.
* **Add Plant Sheet (`AddPlantView`):** Television-optimized input form to append a new plant record.
* **Edit Plant Sheet (`EditPlantView`):** In-place modification of metadata indexed strictly by `UUID`.

### Focus Engine & Remote Navigation
* All primary cards and controls respond dynamically to the Siri Remote focus engine with native scale elevation and high-contrast borders.
* Modal presentation sheets utilize compact layout constraints to prevent clipping on television screens.

---

## 6. Data Model & CRUD Implementation

### Swift Entity Schema
```swift
import Foundation

struct Plant: Identifiable {
    let id: UUID = UUID()
    var name: String
    var location: String
    var moisture: Int          // Soil saturation (0 - 100%)
    var temperature: Int       // Ambient room temperature in °C
    
    // Computed condition helper
    var needsWater: Bool {
        return moisture < 30
    }
}
```

### CRUD Operational Flow

| Action | UI Mechanism | Technical Operation |
| :--- | :--- | :--- |
| **Create** | Dashboard "Add New Plant" Button | Presents `AddPlantView` sheet; validates non-blank name; appends new `Plant` to `@State var plants`. |
| **Read** | Siri Remote Focus on Plant Card | Reads plant attributes dynamically into `PlantCard` and `PlantDetailView`. |
| **Update** | Detail View "Edit" Action | Presents `EditPlantView`; updates properties using `firstIndex(where: { $0.id == plant.id })`. |
| **Delete** | Detail View "Delete" Action | Displays `.confirmationDialog`; removes targeted plant instance via `UUID`. |

### Prototype Seed Data
* **Monstera Deliciosa** — *Living Room* | Moisture: $35\%$ | Temp: $25^\circ\text{C}$ | *Needs Water*
* **Snake Plant** — *Bedroom* | Moisture: $68\%$ | Temp: $24^\circ\text{C}$ | *Healthy*
* **Peace Lily** — *Kitchen* | Moisture: $22\%$ | Temp: $26^\circ\text{C}$ | *Needs Water*

---

## 7. Technical Challenges & Debugging Record

During SwiftUI development for the tvOS target, several architecture-specific hurdles were identified and resolved:

1. **Symbol Redeclaration Conflict (`AddPlantView`):**
   * *Problem:* A compile-time error `Invalid redeclaration of 'AddPlantView'` occurred when the view struct existed simultaneously in `ContentView.swift` and `AddPlantView.swift`.
   * *Fix:* Enforced single-responsibility modular structure; isolated `AddPlantView` exclusively to its dedicated source file.

2. **Initializer Label Inconsistency:**
   * *Problem:* Form submissions failed due to passing an unrecognized `type:` parameter to the `Plant` initializer.
   * *Fix:* Aligned arguments strictly with the model contract (`location:`).

3. **tvOS Sheet & Modal Layout Clipping:**
   * *Problem:* Standard iOS modal dimensions produced clipped headers and oversized action buttons on tvOS displays.
   * *Fix:* Redesigned sheets with constrained width boundaries, smaller font scale groups, and explicit `.frame()` limits.

4. **Data Race via Name-Based Identification:**
   * *Problem:* Updating records by string matching on `name` caused cross-updates if multiple plants shared identical names.
   * *Fix:* Implemented persistent immutable `UUID` keys for mutation and deletion lookups.

---

## 8. Testing & Evaluation Plan

| ID | Test Scenario | Expected Outcome | Result |
| :---: | :--- | :--- | :---: |
| **T01** | Compile tvOS & iOS Targets | Zero duplicate symbols, successful clean build. | **PASS** |
| **T02** | Add New Plant Entry | Valid form appends card to dashboard array. | **PASS** |
| **T03** | Blank Name Validation | Form rejects empty plant name; Save remains inactive. | **PASS** |
| **T04** | Detail Telemetry Readout | Details match selected card attributes exactly. | **PASS** |
| **T05** | Update Plant Attributes | Edits persist only to the target plant ID. | **PASS** |
| **T06** | Deletion Confirmation Dialog | Cancel aborts; Confirm permanently purges record. | **PASS** |
| **T07** | Siri Remote Focus Cycle | Clear visible focus ring across all clickable surfaces. | **PASS** |
| **T08** | Dynamic Type / Font Scaling | Labels rescale without visual clipping or word break. | **PASS** |

---

## 9. Demonstration & Viva Strategy

### Recommended Demonstration Sequence (Viva Presentation)
1. **Introduction:** State the project concept, target audience, and dual-platform architecture (iOS mobile companion + tvOS ambient hub).
2. **Dashboard Overview:** Navigate the tvOS grid using the Siri Remote, pointing out room locations and moisture gauges.
3. **Detail Telemetry Inspection:** Open a plant exhibiting "Needs Water" status; explain moisture and temperature readings.
4. **CRUD Execution:**
   * Add a new plant using the sheet modal.
   * Edit location metadata using the update screen.
   * Delete an existing record through the confirmation dialogue.
5. **Architectural Discussion:** Detail `@State` and `@Binding` workflows, explain why `UUID` keys prevent mutation collisions, and outline the SwiftData migration roadmap.
6. **Honest Limitations:** Disclose simulated sensor state vs. hardware ESP32 binding status.

---

## 10. AI-Assisted Development Transparency Disclosure

In adherence to institutional academic integrity regulations, generative AI tools were consulted strictly for architectural advice, troubleshooting compiler diagnostics, and styling optimizations:

* **Compiler Diagnostics:** Identified the root cause of `Invalid redeclaration of 'AddPlantView'` across multi-file project targets.
* **Layout Optimization:** Recommended optimal font scales and layout constraints tailored for tvOS viewing distances.
* **Data Model Integrity:** Advised the transition from name-based index lookup to immutable `UUID` key validation.

*All generated recommendations were audited, hand-adapted, tested, and verified by the student.*

---

## 11. Setup, Build & Execution Guide

### Prerequisites
* macOS Sonoma (14.0) or higher.
* Xcode 15.0+ installed with **iOS 17** and **tvOS 17** SDKs.
* Active Git CLI installation.

### Step-by-Step Instructions

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/your-username/GreenMind-SE4041.git
   cd GreenMind-SE4041
   ```

2. **Open Project in Xcode:**
   ```bash
   open GreenMind.xcodeproj
   ```

3. **Select Execution Target:**
   * For Mobile App: Select `GreenMind-iOS` scheme $\rightarrow$ Choose `iPhone 15 Pro` simulator.
   * For TV Dashboard: Select `GreenMind-tvOS` scheme $\rightarrow$ Choose `Apple TV 4K` simulator.

4. **Build and Run:**
   * Press `Cmd + R` or click the **Play** button in the Xcode toolbar.
   * Use the Xcode Simulator Remote (`Features > Apple TV Remote`) to test tvOS navigation.

---

## 12. Submission Compliance Checklist

- [x] **Part A:** Defined iOS scope, navigable hierarchy, and custom component design.
- [x] **Part B:** Functional tvOS prototype running with full CRUD support.
- [x] **Siri Remote Navigation:** Confirmed focus engine support across cards and forms.
- [x] **Git Version Control:** Structured commits with semantic messaging.
- [x] **Code Quality:** Formatted Swift code with clean variable naming and inline comments.
- [x] **AI Disclosure:** Completed prompt/response log and contextual usage description.
- [x] **README Documentation:** Complete build guide, data schemas, and test matrices.
- [x] **Viva Readiness:** Prepared demonstration sequence and architectural defence.

---

### Project Metadata
* **Student:** SUDUSINGHE JJ (`IT22368898`)
* **Course:** BSc (Hons) in Information Technology — Year 4
* **Module:** SE4041 Mobile Application Design and Development
* **Institution:** Faculty of Computing
* **Academic Term:** Semester 2, 2026