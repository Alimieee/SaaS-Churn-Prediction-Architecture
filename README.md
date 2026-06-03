# 📊 SaaS Churn Early Warning Architecture

An end-to-end Machine Learning pipeline and cross-platform Flutter dashboard engineered to predict, filter, and visualize software customer churn risk.

## 🚀 The Architecture

This project bridges a Python Data Science backend with a modern software frontend to solve a real-world business problem: identifying at-risk customers before they cancel their subscriptions.

### 1. Data Engineering & Machine Learning (Python)
* **Relational Data Merging:** Cleaned and merged multi-table CSV databases (Customer Accounts + Subscription History) using `pandas`, handling missing `NaN` values and deduplication.
* **Model Training:** Engineered a Random Forest Classification model using `scikit-learn` that achieved **94.3% accuracy** in predicting churn.
* **Business Logic Extraction:** The AI identified that high support ticket volume (>= 4) and low satisfaction scores (<= 2.5) were the primary mathematical indicators of flight risk.

### 2. Frontend Visualization (Flutter/Dart)
* **Cross-Platform UI:** Built a responsive, dark-mode dashboard compiled for macOS desktop and Web.
* **Dynamic State Management:** The UI automatically applies the AI's mathematical thresholds, visually flagging accounts as 'STABLE' (Green) or 'HIGH RISK' (Red).
* **Live Filtering:** Implemented a real-time Account ID search bar and custom category filter chips to instantly sort thousands of records.

## 🛠 Tech Stack
* **Backend Data Science:** Python, Pandas, Scikit-Learn
* **Frontend Engineering:** Flutter, Dart
* **Architecture Strategy:** Mock Data / Decoupled UI Prototyping