require 'csv'

TSV_FILE = '_data/books_import_data.tsv'
MD_DIR = '_books'

def compare
  tsv_isbns = []
  CSV.foreach(TSV_FILE, col_sep: "\t", headers: true) do |row|
    tsv_isbns << row['ISBN'].to_s.strip if row['ISBN']
  end
  
  md_files = Dir.entries(MD_DIR).select { |f| f.end_with?('.md') }.map { |f| f.sub('.md', '') }
  
  extra_files = md_files - tsv_isbns
  missing_files = tsv_isbns - md_files
  
  puts "TSV ISBNs: #{tsv_isbns.length}"
  puts "MD Files: #{md_files.length}"
  puts "Extra files (in folder but not in TSV): #{extra_files.join(', ')}"
  puts "Missing files (in TSV but not in folder): #{missing_files.join(', ')}"
end

compare
