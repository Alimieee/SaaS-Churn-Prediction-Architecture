import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

print("Loading The Ultimate Master Dataset...\n")
df = pd.read_csv('data/master_dataset.csv')

# --- 1. FEATURE SELECTION (Picking the Clues) ---
# give the AI the columns that might mathematically predict a cancellation.
features = [
    'seats', 'mrr_amount', 'is_trial', 'usage_count', 
    'error_count', 'plan_tier', 'total_tickets', 'avg_satisfaction'
]

# 'X' represents the clues, 'y' represents the final answer (Did they churn?)
X = df[features]
y = df['churn_flag']

# --- 2. ENCODING (Translating Text to Math) ---
# AI only understands numbers. pd.get_dummies() converts text (like "Pro" plan) into 1s and 0s.
X = pd.get_dummies(X, columns=['plan_tier', 'is_trial'])

# --- 3. THE SPLIT (Teaching vs. Testing) ---
# hide 20% of the data (1,000 users) from the AI so can test if it actually learned, or just memorized the answers.
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

print(f"Teaching the AI with {len(X_train)} historical customers...")
print(f"Testing the AI on {len(X_test)} hidden customers...\n")

# --- 4. TRAINING THE AI ---
# summon the Random Forest and tell it to .fit() (learn) the patterns
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# --- 5. THE FINAL EXAM ---
#ask the AI to guess the answers for the hidden 20%
predictions = model.predict(X_test)
accuracy = accuracy_score(y_test, predictions)

print("--- 🏆 AI EXAM RESULTS ---")
print(f"Overall Accuracy: {accuracy * 100:.2f}%\n")

print("--- 🧠 WHAT DID THE AI LEARN? ---")
# peek inside the AI's brain and see what it thinks is the #1 cause of churn
feature_importances = pd.Series(model.feature_importances_, index=X.columns).sort_values(ascending=False)
print("Top 3 Biggest Warning Signs of Churn:")
print(feature_importances.head(3))


print("\n--- 🔮 CRYSTAL BALL: PREDICTING A NEW CUSTOMER ---")
# 1. copy the exact format of our clues (X) to make sure the AI understands it
fake_customer = pd.DataFrame([X.iloc[0].values], columns=X.columns) 

# 2. set the warning signs to maximum danger for this fake user:
fake_customer.loc[0, 'seats'] = 1              # Only a 1-person team
fake_customer.loc[0, 'total_tickets'] = 6      # They submitted 6 angry complaints
fake_customer.loc[0, 'avg_satisfaction'] = 1.0 # They rated support 1 out of 5 stars
fake_customer.loc[0, 'usage_count'] = 2        # They barely use the app

# 3. ask the AI to predict their future!
prediction = model.predict(fake_customer)

if prediction[0] == True:
    print("AI Prediction: YES, THIS CUSTOMER WILL CHURN! (Send a rescue email now!)")
else:
    print("AI Prediction: NO, they are safe.")