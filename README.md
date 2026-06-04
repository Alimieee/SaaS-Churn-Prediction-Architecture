<![CDATA[# 📊 SaaS Churn Early Warning Architecture

> An end-to-end Machine Learning pipeline and cross-platform Flutter dashboard engineered to predict, filter, and visualize SaaS customer churn risk.

![Python](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![scikit-learn](https://img.shields.io/badge/scikit--learn-Random_Forest-F7931E?logo=scikit-learn&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-Data_Pipeline-150458?logo=pandas&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🧠 The Problem

SaaS businesses lose revenue when customers churn silently. By the time a cancellation hits, it's too late. This project builds a **predictive early-warning system** that identifies at-risk customers *before* they leave — and presents those insights through a real-time dashboard.

---

## 🏗️ Architecture Overview

This project bridges a **Python Data Science backend** with a **modern Flutter frontend** to solve a real-world business problem.

```
┌─────────────────────────────────────────────────────────────────┐
│                     DATA LAYER (Python)                         │
│                                                                 │
│   5 Raw CSV Tables ──► data_prep.py ──► master_dataset.csv      │
│   (33,000+ rows)       (Clean, Merge,    (Single Source         │
│                         Impute NaNs)      of Truth)             │
│                              │                                  │
│                              ▼                                  │
│                       train_model.py                            │
│                    (Random Forest Classifier)                   │
│                     94.3% Accuracy ✅                            │
│                              │                                  │
│              Business Rules: tickets ≥ 4 OR                     │
│              satisfaction ≤ 2.5 → HIGH RISK                     │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                  FRONTEND LAYER (Flutter/Dart)                  │
│                                                                 │
│   churn_radar/  ──► Dark-Mode Dashboard (macOS + Web)           │
│                     • Live Account Search                       │
│                     • Risk Filter Chips (All / High Risk / Stable) │
│                     • Color-Coded Risk Badges                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
SaaS-Churn-Prediction-Architecture/
│
├── data/                              # Raw relational datasets
│   ├── ravenstack_accounts.csv        # 500 customer accounts
│   ├── ravenstack_subscriptions.csv   # 5,000 subscription records
│   ├── ravenstack_feature_usage.csv   # 25,000 feature usage logs
│   ├── ravenstack_support_tickets.csv # 2,000 support tickets
│   └── ravenstack_churn_events.csv    # 600 churn event records
│
├── data_prep.py                       # Data cleaning & merging pipeline
├── train_model.py                     # ML model training & evaluation
│
├── churn_radar/                       # Flutter dashboard app
│   ├── lib/
│   │   └── main.dart                  # Dashboard UI & business logic
│   ├── assets/
│   │   └── master_dataset.csv         # Processed data for the frontend
│   └── pubspec.yaml                   # Flutter dependencies
│
├── .gitignore
└── README.md
```

---

## ⚙️ How It Works

### 1. Data Engineering — `data_prep.py`

Cleans and merges **5 relational CSV tables** into a single master dataset:

- **Imputation** — Fills 825 missing satisfaction scores with the column mean
- **Aggregation** — Summarizes support tickets (count + avg satisfaction) per account
- **Usage Rollup** — Sums `usage_count` and `error_count` per subscription
- **Multi-Table Join** — Left-merges accounts → subscriptions → usage → tickets
- **Deduplication** — Drops redundant columns from overlapping schemas

**Output:** `data/master_dataset.csv` — a clean, analysis-ready dataset

### 2. Machine Learning — `train_model.py`

Trains a **Random Forest Classifier** to predict customer churn:

| Step | Detail |
|---|---|
| **Features** | `seats`, `mrr_amount`, `is_trial`, `usage_count`, `error_count`, `plan_tier`, `total_tickets`, `avg_satisfaction` |
| **Encoding** | One-hot encoding via `pd.get_dummies()` for categorical variables |
| **Split** | 80/20 train-test split (`random_state=42`) |
| **Model** | `RandomForestClassifier(n_estimators=100)` |
| **Accuracy** | **94.3%** on the held-out test set |

**Top 3 Churn Indicators Discovered by the Model:**
1. 🎫 `total_tickets` — High support ticket volume
2. 😞 `avg_satisfaction` — Low satisfaction scores
3. ⚠️ `error_count` — Frequent product errors

### 3. Frontend Dashboard — `churn_radar/`

A cross-platform **Flutter** app (macOS + Web) that visualizes churn risk in real time:

- **Dark Mode UI** — Sleek `#121212` dark theme
- **Real-Time Search** — Filter accounts instantly by Account ID
- **Risk Classification** — Applies the ML model's business rules directly in the UI:
  - 🔴 **HIGH RISK** → `tickets ≥ 4` OR `satisfaction ≤ 2.5`
  - 🟢 **STABLE** → All other accounts
- **Filter Chips** — Toggle between `All`, `High Risk`, and `Stable` views
- **CSV Parsing** — Loads and deduplicates the master dataset at runtime via the `csv` package

---

## 🚀 Getting Started

### Prerequisites

- **Python 3.x** with `pip`
- **Flutter SDK** (3.x+)

### Run the ML Pipeline

```bash
# Clone the repository
git clone https://github.com/Alimieee/SaaS-Churn-Prediction-Architecture.git
cd SaaS-Churn-Prediction-Architecture

# Create a virtual environment (optional but recommended)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install Python dependencies
pip install pandas scikit-learn

# Step 1: Clean and merge the raw data
python data_prep.py

# Step 2: Train the model and see results
python train_model.py
```

### Run the Flutter Dashboard

```bash
cd churn_radar

# Get Flutter dependencies
flutter pub get

# Run on macOS
flutter run -d macos

# Or run on Chrome
flutter run -d chrome
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Data Engineering** | Python, Pandas |
| **Machine Learning** | scikit-learn (Random Forest) |
| **Frontend** | Flutter, Dart |
| **Data Format** | CSV (parsed at runtime) |
| **Architecture** | Decoupled ML Pipeline → Dashboard UI |

---

## 📊 Dataset: RavenStack SaaS

A synthetic multi-table relational dataset simulating a B2B SaaS platform:

| Table | Records | Description |
|---|---|---|
| `ravenstack_accounts.csv` | 500 | Customer profiles (industry, country, plan tier) |
| `ravenstack_subscriptions.csv` | 5,000 | Subscription history (MRR, seats, trial status) |
| `ravenstack_feature_usage.csv` | 25,000 | Feature-level usage and error counts |
| `ravenstack_support_tickets.csv` | 2,000 | Support tickets with satisfaction scores |
| `ravenstack_churn_events.csv` | 600 | Labeled churn events with reasons |

---

## 🔑 Key Takeaways

- A Random Forest model can predict churn with **94.3% accuracy** using behavioral and support data
- **Support ticket volume** and **satisfaction scores** are the strongest predictors of churn — more so than plan tier or seat count
- Translating ML thresholds directly into a UI creates an actionable tool that non-technical teams can use daily

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<p align="center">
  Built with 🐍 Python & 💙 Flutter
</p>
]]>