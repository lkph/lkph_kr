import os
import csv

TSV_FILE = '_data/books_import_data.tsv'
MD_DIR = '_books'

def compare():
    tsv_isbns = set()
    with open(TSV_FILE, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            if row['ISBN']:
                tsv_isbns.add(row['ISBN'].strip())
                
    md_files = {f.replace('.md', '') for f in os.listdir(MD_DIR) if f.endswith('.md')}
    
    extra_files = md_files - tsv_isbns
    missing_files = tsv_isbns - md_files
    
    print(f"TSV ISBNs: {len(tsv_isbns)}")
    print(f"MD Files: {len(md_files)}")
    print(f"Extra files (in folder but not in TSV): {extra_files}")
    print(f"Missing files (in TSV but not in folder): {missing_files}")

if __name__ == "__main__":
    compare()
