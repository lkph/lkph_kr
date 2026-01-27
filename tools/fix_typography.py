import csv
import re

input_file = '_data/books_import_data.tsv'

def smart_quotes(text):
    if not text:
        return text
    # Standard straight quotes to curly quotes logic
    # Regex for a quoted string: '([^']*)' -> ‘$1’
    # This is a bit simplistic, but covers quoted sections.
    # We should avoid replacing single apostrophes like "it's" -> "it‘s" (bad) or "it’s" (good)
    # But in Korean text, single quotes are mostly for emphasis/title, so less ambiguity.
    # Let's use a regex that looks for pairs.
    return re.sub(r"'([^']*)'", r"‘\1’", text)

def main():
    rows = []
    
    # Read TSV (Use UTF-8 for reading)
    with open(input_file, 'r', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter='\t')
        try:
            header = next(reader)
        except StopIteration:
            print("Empty file")
            return
        
        try:
            title_idx = header.index('제목')
        except ValueError:
            print("Error: '제목' column not found")
            return

        for row in reader:
            new_row = list(row)
            
            # 1. Revert Title Column (remove 『』)
            if len(new_row) > title_idx:
                title = new_row[title_idx].strip()
                if title.startswith('『') and title.endswith('』'):
                    new_row[title_idx] = title[1:-1]
            
            # 2. Process all text columns for Smart Quotes
            for i in range(len(new_row)):
                if "'" in new_row[i]:
                    new_row[i] = smart_quotes(new_row[i])
            
            rows.append(new_row)
            
    # Write output (Use UTF-8 for writing)
    with open(input_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f, delimiter='\t')
        writer.writerow(header)
        writer.writerows(rows)
        
    print(f"Processed typography for {len(rows)} rows.")

if __name__ == "__main__":
    main()
