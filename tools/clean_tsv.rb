require 'csv'

input_file = '_data/books_import_data.tsv'

def smart_quotes(text)
  return text if text.nil? || text.empty?
  # Standard directional quotes for single quoted sections
  text.gsub(/'([^']*)'/, '‘\1’')
end

def apply_brackets(text, terms)
  return text if text.nil? || text.empty?
  terms.each do |term|
    # Replace directional quotes with brackets for specific terms
    text.gsub!(/‘#{Regexp.escape(term)}’/, "『#{term}』")
    # Also handle straight quotes just in case
    text.gsub!(/'#{Regexp.escape(term)}'/, "『#{term}』")
  end
  text
end

# Read current messy file
raw_content = File.read(input_file, encoding: 'utf-8')
lines = raw_content.split("\n").map(&:strip).reject(&:empty?)

# Join back for CSV parsing (to handle tabs)
clean_raw = lines.join("\n")

# Parse clean rows
table = CSV.parse(clean_raw, col_sep: "\t", headers: true)
header = table.headers

rows = []
table.each_with_index do |row, idx|
  # Row index in CSV is 0-based, so line 2 in file is index 0 (header is handled)
  # BUT splitting raw lines might shift things if there were empty lines.
  # Let's use the ISBN or Title to identify the line instead of index if possible,
  # but user specifically said "Line 3" and "Line 5" in the *original* context.
  # Let's check headers to find the right rows or use index.
  
  # 1. Revert Title Column (remove 『』 if present)
  if row['제목']
    title = row['제목'].to_s.strip
    if title.start_with?('『') && title.end_with?('』')
      row['제목'] = title[1...-1]
    end
  end

  # 2. General Formatting (Smart Quotes and Separator Slashes)
  header.each do |col_name|
    val = row[col_name]
    if val && val.is_a?(String)
      # Apply smart quotes
      row[col_name] = smart_quotes(val) if val.include?("'")
      # Replace " / " with "<br>" (lone slashes used as separators)
      row[col_name] = row[col_name].gsub(/ \/ /, '<br>') if row[col_name].include?(' / ')
    end
  end

  # 3. Specific Brackets for Line 3 and Line 5 (identified by ISBN)
  isbn = row['ISBN'].to_s.strip
  if isbn == '979-11-89680-57-2' # Line 5 (러닝클럽)
    # Normalize other brackets
    header.each do |col_name|
      val = row[col_name]
      if val && val.is_a?(String)
        row[col_name] = val.gsub(/[《「]/, '『').gsub(/[》」]/, '』').gsub('〈', '｢').gsub('〉', '｣')
      end
    end

    terms = [
      '러닝클럽', '치유', '러닝클럽 크루 미팅', 
      '레트로 마니아', '신들린 게임과 개발자들', '원스 어폰 어 타임 인 판교',
      '녹색 갈증', '모양새', '역마', '시간과 장의사', '적색편이',
      '모두가 회전목마를 탄다', '막 너머에 신이 있다면', '빛의 구역',
      '0번 버스는 2번 지구로 향한다', '악어의 맛', '유미의 연인', '낮은 곳으로 임하소서'
    ]
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], terms)
    end
  elsif isbn == '979-11-89680-54-1' # Line 5 (김범준의 물리 장난감)
    terms = ['세상물정의 물리학', '과학을 보다', '범준에 물리다', '관계의 과학', '보이지 않아도 존재하고 있습니다']
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], terms)
    end
  end

  rows << row
end

# Write back with blank lines for readability
File.open(input_file, "w", encoding: 'utf-8') do |f|
  # Write header
  f.puts header.to_csv(col_sep: "\t")
  
  rows.each_with_index do |row, idx|
    f.puts row.to_csv(col_sep: "\t")
    # Add blank lines after each record except the last one
    # The user said "a few lines of blank space", so let's use 3.
    f.puts "\n\n" if idx < rows.length - 1
  end
end

puts "Cleaned and formatted #{rows.length} rows."
