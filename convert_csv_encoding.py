import os


csv_folder = r"C:\Users\Nari\hyper-sql-analysis\data"


csv_files = [
    "patients.csv",
    "conditions.csv",
    "medications.csv",
    "observations.csv",
    "encounters.csv"
]

for filename in csv_files:
    input_path = os.path.join(csv_folder, filename)
    output_path = os.path.join(csv_folder, filename.replace(".csv", "_utf8.csv"))
    
    try:
        with open(input_path, "r", encoding="cp1252") as f_in:
            content = f_in.read()
        
        with open(output_path, "w", encoding="utf-8") as f_out:
            f_out.write(content)
        
        print(f"Converted {filename} to UTF-8 and saved as {output_path}")
    except Exception as e:
        print(f"Error processing {filename}: {e}")
