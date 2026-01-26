# ISO-8859-1 (Latin-1) or UTF-8? Let's assume UTF-8 as it's common for Korean text.
import csv
import os

input_path = r'c:\Users\mailt\OneDrive\문서\Git\lkph_kr\_data\books_import_data.tsv'
output_path = r'c:\Users\mailt\OneDrive\문서\Git\lkph_kr\_data\books_import_data_new.tsv'

try:
    with open(input_path, 'r', encoding='utf-8') as fin, open(output_path, 'w', encoding='utf-8', newline='') as fout:
        reader = csv.reader(fin, delimiter='\t')
        writer = csv.writer(fout, delimiter='\t')
        for row in reader:
            if row:
                # 9th column is '가격상태' (index 8)
                new_row = [val for i, val in enumerate(row) if i != 8]
                writer.writerow(new_row)
    
    # Overwrite original with new
    import shutil
    shutil.move(output_path, input_path)
    print("Column removal successful.")
except Exception as e:
    print(f"Error: {e}")
