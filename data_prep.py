import pandas as pd

print("Loading RavenStack SaaS Data...\n")
accounts = pd.read_csv('data/ravenstack_accounts.csv')
subscriptions = pd.read_csv('data/ravenstack_subscriptions.csv')
usage = pd.read_csv('data/ravenstack_feature_usage.csv')
tickets = pd.read_csv('data/ravenstack_support_tickets.csv') # The Tickets are back!

# --- 1. CLEANING THE TICKETS ---
print("Patching the 825 missing satisfaction scores...")
# Calculate the average score from the people who voted
average_score = tickets['satisfaction_score'].mean()
# Fill the blanks with that average
tickets['satisfaction_score'] = tickets['satisfaction_score'].fillna(average_score)

print("Squashing the tickets by Account...")
# use .agg() to do two different math equations at the same time:
# 1. Count the number of tickets. 2. Find the average satisfaction per account.
ticket_summary = tickets.groupby('account_id').agg(
    total_tickets=('ticket_id', 'count'),
    avg_satisfaction=('satisfaction_score', 'mean')
).reset_index()

# --- 2. AGGREGATING USAGE ---
usage_summary = usage.groupby('subscription_id')[['usage_count', 'error_count']].sum().reset_index()

# --- 3. THE GRAND MERGE ---
master_data = pd.merge(accounts, subscriptions, on='account_id', how='left')
master_data = pd.merge(master_data, usage_summary, on='subscription_id', how='left')
# Bring in the tickets!
master_data = pd.merge(master_data, ticket_summary, on='account_id', how='left')

# --- 4. THE FINAL CLEANUP ---
columns_to_drop = ['plan_tier_y', 'seats_y', 'is_trial_y', 'churn_flag_y']
master_data = master_data.drop(columns=columns_to_drop)

master_data = master_data.rename(columns={
    'plan_tier_x': 'plan_tier',
    'seats_x': 'seats',
    'is_trial_x': 'is_trial',
    'churn_flag_x': 'churn_flag'
})

master_data['usage_count'] = master_data['usage_count'].fillna(0)
master_data['error_count'] = master_data['error_count'].fillna(0)

# If an account submitted ZERO tickets, they will be blank in new merged table. 
# need to fill those blanks with 0 tickets, and the neutral average score.
master_data['total_tickets'] = master_data['total_tickets'].fillna(0)
master_data['avg_satisfaction'] = master_data['avg_satisfaction'].fillna(average_score)

print(f"Final Boss Shape: {master_data.shape[0]} rows, {master_data.shape[1]} columns")
master_data.to_csv('data/master_dataset.csv', index=False)
print("\nSuccess! Saved The Ultimate Dataset!")