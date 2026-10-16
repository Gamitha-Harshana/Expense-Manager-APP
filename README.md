# 💰 Expense Management System

A modern, fast, and feature-rich personal finance & expense tracking application built with **Flutter**, **Provider**, and **Hive**.

---

## 📱 Features

### 1. 🏠 Interactive Dashboard
- **Current Month Focus**: Automatically highlights the current month's total expenses and transaction count.
- **Month Navigation**: Cycle backward/forward through months (`<` / `>`) or tap the month name to open a quick modal picker showing historical monthly totals.
- **Quick Reset**: One-tap "Back to Current Month" button when browsing past data.
- **Recent Transactions**: Quick view of recent transactions with category colors and icons.

### 2. 📋 All Expenses & Smart Search
- **Live Search**: Instant search by expense title and notes with a clear (`×`) button.
- **Multi-Select Category Filter**: Select one or more categories simultaneously using a dropdown bottom sheet.
- **Date Range Filter**: Filter expenses by *All Time*, *Today*, *This Week*, *This Month*, or pick a *Custom Date Range*.
- **Dynamic Stats**: Real-time filtered expense count and total amount calculation.
- **Swipe to Delete**: Dismiss transactions effortlessly with swipe gestures.

### 3. 📊 Statistics & Data Visualization
- **Interactive Pie Chart**: Visual breakdown of spending by category powered by `fl_chart`.
- **Monthly vs. Overall Toggle**: Switch effortlessly between single-month statistics and all-time overall stats.
- **Ranked Category Breakdown**: Categories ranked from highest to lowest spending with percentages and custom progress bars.

### 4. 📈 Monthly Comparison Report
- Compare current month spending with the previous month.
- Understand your savings or spending increase at a glance with color-coded comparison cards.
- Integrated directly into the main bottom navigation bar.

### 5. 🏷️ Custom Categories
- Create custom expense categories.
- Choose from **12 vibrant colors** and a collection of **20+ Material icons** (Food, Travel, Bills, Gaming, Gym, Shopping, etc.).
- Instantly available across all expense forms and filters.

### 6. ⚙️ Settings & Customization
- **Theme Modes**: Choose between **Light Mode**, **Dark Mode**, or follow your **System Default**.
- **Multi-Currency Support**: Select your preferred currency symbol:
  - USD (`$`), EUR (`€`), GBP (`£`), JPY (`¥`), INR (`₹`), LKR (`Rs`), KRW (`₩`), RUB (`₽`), AUD (`A$`), CAD (`C$`).
- Persistent storage for all preferences.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (SDK: `^3.11.5`)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider) (`^6.1.5+1`)
- **Local Storage**: [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter) (NoSQL, fast local persistence)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart) (`^1.2.0`)
- **Formatting**: [intl](https://pub.dev/packages/intl) (`^0.20.3`)
- **Identifiers**: [uuid](https://pub.dev/packages/uuid) (`^4.6.0`)
- **Code Generation**: [build_runner](https://pub.dev/packages/build_runner) & [hive_generator](https://pub.dev/packages/hive_generator)

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants.dart        # Hive box names and app constants
│   ├── theme.dart            # Material 3 light & dark theme definitions
│   └── utils.dart            # Currency, date formatting, and icon mappings
├── models/
│   ├── category.dart         # Hive ExpenseCategory model
│   ├── category.g.dart       # Generated Hive TypeAdapter for categories
│   ├── expense.dart          # Hive Expense model
│   └── expense.g.dart        # Generated Hive TypeAdapter for expenses
├── providers/
│   ├── expense_provider.dart # CRUD operations for expenses & categories
│   └── settings_provider.dart# Theme mode and currency preference management
├── services/
│   └── database_service.dart # Hive initialization, adapters, and default seeds
├── ui/
│   └── screens/
│       ├── add_category_screen.dart   # Create custom category
│       ├── add_expense_screen.dart    # Add new expense transaction
│       ├── dashboard_screen.dart       # Dashboard with month selector
│       ├── expense_list_screen.dart   # Filterable & searchable expense list
│       ├── main_screen.dart           # Bottom navigation bar root
│       ├── monthly_report_screen.dart # Monthly analysis & comparison
│       ├── settings_screen.dart       # Theme and currency settings
│       └── statistics_screen.dart     # Pie chart statistics
└── main.dart                          # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- An Android Emulator, iOS Simulator, or physical device connected.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/expense_management_system.git
   cd expense_management_system
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Hive Adapters (Optional / If models change):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---


