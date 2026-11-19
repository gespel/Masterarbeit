from sklearn.ensemble import RandomForestClassifier
import argparse

def train_test_split(X, y, test_size=0.2, random_state=42):
    from sklearn.model_selection import train_test_split as tts
    return tts(X, y, test_size=test_size, random_state=random_state)

def main():
    args = argparse.ArgumentParser(description="Random Forest Classifier")
    args.add_argument("--n_estimators", type=int, default=10, help="Number of trees in the forest")
    args.add_argument("--max_depth", type=int, default=10, help="Maximum depth of the tree")
    args.add_argument("--feature_csv", type=str, required=True, help="Path to the CSV file containing features")
    args = args.parse_args()

    with open(args.feature_csv, 'r') as f:
        import pandas as pd
        data = pd.read_csv(f)
        
        X = data.drop(["Flow Hash", "Source IP", "Destination IP", "Label", "Attack Type"], axis=1)
        y = (data["Label"] == "malicious").astype(int)  # benign=0, malicious=1

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

        rf = RandomForestClassifier(n_estimators=args.n_estimators, max_depth=args.max_depth)
        rf.fit(X_train, y_train)

        # test
        accuracy = rf.score(X_test, y_test)
        print(f"Accuracy: {accuracy * 100:.2f}%")

        from sklearn.metrics import confusion_matrix
        y_pred = rf.predict(X_test)
        num_correct = (y_pred == y_test).sum()
        print(f"Number of correct predictions: {num_correct} out of {len(y_test)}")
        tn, fp, fn, tp = confusion_matrix(y_test, y_pred, labels=[0, 1]).ravel()
        print(f"TP: {tp}, FP: {fp}, TN: {tn}, FN: {fn}")
        precision = tp / (tp + fp) if (tp + fp) > 0 else 0
        recall = tp / (tp + fn) if (tp + fn) > 0 else 0
        f1_score = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
        print(f"Precision: {precision*100:.2f}, Recall: {recall*100:.2f}, F1 Score: {f1_score*100:.2f}")

        for est in rf.estimators_:
            print(f"Tree depth: {est.get_depth()}, Number of leaves: {est.get_n_leaves()}")
            t = est.tree_
            print(f"{t.threshold.tolist()}")

        #for test_sample, label in zip(X_test.values, y_test.values):
        #    prediction = rf.predict([test_sample])[0]
        #    print(f"True Label: {label}, Predicted Label: {prediction}")

if __name__ == "__main__":
    main()