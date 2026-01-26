require 'csv'
require 'fileutils'

INPUT_FILE = '_data/books_import_data.tsv'
OUTPUT_DIR = '_books'

# 출력 디렉토리 생성
FileUtils.mkdir_p(OUTPUT_DIR)

count_created = 0
count_skipped = 0

# TSV 파일 읽기 (헤더 있음, 탭 구분)
CSV.foreach(INPUT_FILE, col_sep: "\t", headers: true) do |row|
  # 데이터 매핑
  isbn = row['ISBN'].to_s.strip
  title = row['도서/상품명'].to_s.strip
  author = row['저자'].to_s.strip
  price = row['정가'].to_s.strip.gsub('"', '')
  page_count = row['페이지수'].to_s.strip
  publish_date = row['발행일'].to_s.strip
  width = row['가로'].to_s.strip
  height = row['세로'].to_s.strip
  review = row['출판사 서평'].to_s.strip
  
  # 판형 정보 조합
  size = (!width.empty? && !height.empty?) ? "#{width} × #{height}mm" : ""
  
  # "보수를 지켜라" 제외
  if title.include?("보수를 지켜라")
    count_skipped += 1
    next
  end

  # 연도 추출
  year = publish_date.length >= 4 ? publish_date[0, 4] : "2024"

  # 설명 생성
  description = "도서입니다. (#{page_count}쪽)"

  # 파일명 생성
  filename = "#{isbn}.md"
  filepath = File.join(OUTPUT_DIR, filename)

  # 마크다운 내용 생성
  content = <<~MARKDOWN
    ---
    layout: book
    title: "#{title}"
    author: "#{author}"
    date: #{publish_date}
    year: #{year}
    isbn: "#{isbn}"
    price: "#{price}"
    description: "#{description}"
    size: "#{size}"
    review: "#{review}"
    cover_image: ""
    ---
    
    # #{title}
    
    **#{author}** 저 | **#{year}**년 발행 | **#{price}**원
    
    ## 책 소개
    
    #{title} 관련 도서입니다.
    
    *   **ISBN**: #{isbn}
    *   **페이지**: #{page_count}쪽
  MARKDOWN

  # 파일 쓰기
  File.write(filepath, content)
  count_created += 1
end

puts "완료: #{count_created}권 등록됨, #{count_skipped}권 제외됨 ('보수를 지켜라')"
