require 'csv'
require 'fileutils'

input_path = '_data/books_import_data.tsv'
output_path = '_data/books_import_data_new.tsv'

rows = []
CSV.foreach(input_path, col_sep: "\t") do |row|
  # 9th column is index 8
  row.delete_at(8)
  rows << row
end

CSV.open(output_path, "wb", col_sep: "\t") do |tsv|
  rows.each { |row| tsv << row }
end

FileUtils.mv(output_path, input_path, force: true)
puts "Ruby: Column removal successful."
