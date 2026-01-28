require 'csv'

input_file = '_data/books_import_data.tsv'

# Read everything
content = File.read(input_file, encoding: 'utf-8')

# The current content is missing the header.
# We need to prepend it.
header = "ISBN\t부가기호\t제목\t부제목\t저자\t번역\t가로\t세로\t페이지\t가격\t상태\t발행일\t임프린트\t책 소개\t목차\t출판사 서평\t본문 인용"

# But wait, maybe the first line IS the header but it's corrupted?
# No, we saw it starts with 979... (an ISBN).

new_content = header + "\n" + content

File.write(input_file, new_content, encoding: 'utf-8')
puts "Restored header to #{input_file}"
