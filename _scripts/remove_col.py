import csv
import os

input_path = '_data/books_import_data.tsv'
output_path = '_data/books_import_data_new.tsv'

if not os.path.exists(input_path):
    print(f"Error: {input_path} not found.")
    exit(1)

with open(input_path, 'r', encoding='utf-8') as fin, open(output_path, 'w', encoding='utf-8', newline='') as fout:
    reader = csv.reader(fin, delimiter='\t')
    writer = csv.writer(fout, delimiter='\t')
    for row in reader:
        if row:
            # 9th column is '가격상태' (index 8)
            new_row = [val for i, val in enumerate(row) if i != 8]
            writer.writerow(new_row)

print("Column removal successful.")
