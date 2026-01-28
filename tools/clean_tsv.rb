require 'csv'

input_file = '_data/books_import_data.tsv'

def smart_quotes(text)
  return text if text.nil? || text.empty?
  # Standard directional quotes for single quoted sections
  text.gsub(/'([^']*)'/, '‘\1’')
end

def apply_brackets(text, terms, open_b = '『', close_b = '』')
  return text if text.nil? || text.empty?
  
  # Group of bracket/quote characters to handle
  # We include standard ones and their variations
  open_chars = "‘'\"『「〈《［[("
  close_chars = "’'\"』」〉》］])"
  all_chars = Regexp.escape(open_chars + close_chars)
  
  # Sort terms by length descending to correctly handle nested titles (e.g., "A B" vs "A")
  terms.sort_by(&:length).reverse.each do |term|
    esc_term = Regexp.escape(term)
    
    # 1. Normalize existing bracketed/quoted versions
    # Pattern: [any_open]term[any_close]
    text.gsub!(/[#{all_chars}]#{esc_term}[#{all_chars}]/, "#{open_b}#{term}#{close_b}")
    
    # 2. Add brackets to bare terms if they are reasonably long (to avoid false positives)
    # or if they are very specific. For the curated list, we trust the terms.
    # We use negative lookahead/lookbehind to avoid double-bracketing.
    if term.length >= 2
      # Negative lookahead/lookbehind for any bracket character
      text.gsub!(/(?<![#{all_chars}])#{esc_term}(?![#{all_chars}])/, "#{open_b}#{term}#{close_b}")
    end
  end
  text
end

# Read current messy file
raw_content = File.read(input_file, encoding: 'utf-8')
lines = raw_content.split("\n").map(&:strip).reject(&:empty?)

# Join back for CSV parsing (to handle tabs)
clean_raw = lines.join("\n")

# Parse clean rows
puts "First 100 chars of clean_raw: [#{clean_raw[0..100]}]"
table = CSV.parse(clean_raw, col_sep: "\t", headers: true)
header = table.headers
puts "Detected headers: #{header.inspect}"

rows = []
table.each_with_index do |row, idx|
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

  # 3. Specific Brackets for Books (Refined Rules)
  isbn = row['ISBN'].to_s.strip
  puts "Processing ISBN: [#{isbn}]" if idx < 5 # Debug first 5
  
  # Normalize standard variations before applying rules
  header.each do |col_name|
    val = row[col_name]
    if val && val.is_a?(String)
      # Re-apply smart quotes to normalize the direction
      row[col_name] = smart_quotes(row[col_name])
    end
  end

  if isbn == '979-11-89680-57-2' # 러닝클럽
    books = ['러닝클럽', '레트로 마니아', '신들린 게임과 개발자들', '원스 어폰 어 타임 인 판교', '적색편이']
    short_stories = ['녹색 갈증', '모양새', '역마', '시간과 장의사', '모두가 회전목마를 탄다', '막 너머에 신이 있다면', '빛의 구역', '0번 버스는 2번 지구로 향한다', '악어의 맛', '유미의 연인', '낮은 곳으로 임하소서']
    terms_brackets = ['러닝클럽 크루 미팅']
    
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], books, '『', '』')
      row[col_name] = apply_brackets(row[col_name], short_stories, '｢', '｣')
      row[col_name] = apply_brackets(row[col_name], terms_brackets, '『', '』')
    end
  elsif isbn == '979-11-89680-54-1' # 김범준의 물리 장난감
    books = ['세상물정의 물리학', '관계의 과학', '보이지 않아도 존재하고 있습니다', '김범준의 물리 장난감']
    media = ['과학을 보다', '범준에 물리다'] # YouTube channels/Artistic?
    
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], books, '『', '』')
      row[col_name] = apply_brackets(row[col_name], media, '〈', '〉')
    end
  elsif isbn == '979-11-89680-49-7' # 닌텐도 다이어리
    books = ['닌텐도 다이어리', '액세스가 거부되었습니다', '아무튼, 후드티', '웹툰 내비게이션', '웹툰 입문']
    games = ['슈퍼마리오 오디세이', '동물의 숲', '루이지 맨션 3', '별의 커비', '마인크래프트', '젤다의 전설: 브레스 오브 더 와일드', '페이퍼 마리오 종이접기 킹', '바람의 나라', '괴혼 ~굴려라 돌아온 왕자님~', '링피트 어드벤처', '토카월드', '로블록스', '젤다의 전설: 티어스 오브 더 킹덤', '엉덩이 탐정']
    
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], books, '『', '』')
      row[col_name] = apply_brackets(row[col_name], games, '〈', '〉')
    end
  elsif isbn == '979-11-89680-48-0' # 과학의 과학
    books = ['과학의 과학', '링크: 21세기를 지배하는 네트워크 과학', '네트워크 사이언스']
    periodicals = ['네이처', '사이언스', 'PNAS', '뉴욕 타임스']
    terms_brackets = ['척도 없는 네트워크', '바라바시-앨버트 모형', '스콜라원', '거인의 어깨에 올라섰기 때문이다']
    
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], books, '『', '』')
      row[col_name] = apply_brackets(row[col_name], periodicals, '《', '》')
      row[col_name] = apply_brackets(row[col_name], terms_brackets, '『', '』')
    end
  elsif isbn == '979-11-89680-46-6' # 쇼 미 더 허니
    books = ['쇼 미 더 허니', '힐튼호텔옆 쪽방촌 이야기', '숨을 참다', '파울루 프레이리 읽기']
    art = ['맨 인 모션 월드 투어']
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], books, '『', '』')
      row[col_name] = apply_brackets(row[col_name], art, '〈', '〉')
    end
  elsif isbn == '979-11-89680-44-2' # 뉴턴의 무정한 세계
    books = ['뉴턴의 무정한 세계', '모든 이의 과학사 강의', '통통한 과학책', '과학을 읽다', '내 생의 중력에 맞서', '과학사', '종의 기원', '무정']
    shorts = ['표본실의 청개구리', '선에 관한 각서', '오감도']
    periodicals = ['한겨레신문']
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], books, '『', '』')
      row[col_name] = apply_brackets(row[col_name], shorts, '｢', '｣')
      row[col_name] = apply_brackets(row[col_name], periodicals, '《', '》')
    end
  elsif isbn == '979-11-89680-43-5' # 오송역
    books = [
      '오송역', '거대도시 서울 철도', '거대도시 서울 철도: 기후위기 시대의 미래 환승법', 
      '미래를 여는 길, 한국철도', '납치된 도시에서 길찾기', '그리드', '사고실험', 
      '증거기반의학의 철학', '역학의 철학', '숫자에 속아 위험한 선택을 하는 사람들'
    ]
    art = ['용의 눈물']
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], books, '『', '』')
      row[col_name] = apply_brackets(row[col_name], art, '〈', '〉')
    end
  elsif isbn == '979-11-89680-39-8' # 후생동물
    books = [
      '후생동물', '아더 마인즈', '이론과 실재: 과학철학 입문', 'Darwinian Populations and Natural Selection', 
      '현대 한국사회의 언어문화', '사랑하면 사랑한다고 말해야지', '봄날의 가사집 - 생각의 여름'
    ]
    periodicals = [
      '뉴욕 타임스', '가디언', '사이언스', '보스턴 글로브', '내셔널 지오그래픽', 
      '뉴 사이언티스트', '뉴요커', '퍼블리셔스 위클리'
    ]
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], books, '『', '』')
      row[col_name] = apply_brackets(row[col_name], periodicals, '《', '》')
    end
  elsif isbn == '979-11-89680-37-4' # 웹툰 내비게이션
    books = ['웹툰 내비게이션', '웹툰 입문', '아무튼 후드티', '지금, 독립만화']
    shorts = ['아마추어 웹툰 작가의 생산 노동의 성격에 대한 연구']
    webtoons = [
      '샌프란시스코 화랑관', '계룡선녀전', '닥터 프로스트', '순정만화', '1001', '마음의 소리', 
      '무림수사대', '퍼펙트 게임', '어서오세요 305호에!', '우월한 하루', '이말년씨리즈', 
      '신과 함께', '키스우드', '신의 탑', '살인자ㅇ난감', '은밀하게 위대하게', '치즈인더트랩', 
      '쌉니다 천리마마트', '어쿠스틱 라이프', '김철수씨 이야기', '미생', '카산드라', '모두에게 완자가', 
      '방과 후 전쟁활동', '용이 산다', '아만자', '먹는 존재', '송곳', '칼부림', '미쳐 날뛰는 생활툰', 
      '멀리서 보면 푸른 봄', '데미지 오버 타임', '좋아하면 울리는', '전자오락수호대', 'Ho!', '시동', 
      '조선왕조실톡', '여중생A', '아 지갑놓고나왔다', '호랑이 형님', '유미의 세포들', '죽어도 좋아♡', 
      '잠자는 공주와 꿈꾸는 악마', '나는 귀머거리다', '고수', '조국과 민족', '오민혁 단편선', 
      '혼자를 기르는 법', '가담항설', '공대생 너무만화', '쌍갑포차', '환관제조일기', '여자친구', 
      '구름의 이동속도', '불멸의 날들', '안녕 커뮤니티', '야채호빵의 봄방학', '며느라기', '지옥사원', 
      '프레너미', '그녀의 심청', '환생동물학교', '다리 위 차차', '아기 낳는 만화', '아비무쌍', 
      '안녕은하세요', '나 혼자만 레벨업', '우두커니', '익명의 독서 중독자들', '모지리', '새벽날개', 
      '아티스트', '연의 편지', '좀비딸', '극락왕생', '어둠이 걷힌 자리엔', '황제와 여기사', '안녕, 엄마', 
      '정년이', 'ONE', '위대한 방옥숙', '고래별', '이대로 멈출 순 없다', '그날 죽은 나는', 
      '유색의 멜랑꼴리', '조숙의 맛', '남남', '더 복서', '도롱이', '민간인 통제구역', '신의 태궁', 
      '여왕 쎄시아의 반바지', '오늘을 살아본 게 아니잖아', '하루만 네가 되고 싶어', 
      '미래의 골동품 가게', '데이빗', '동트는 로맨스', '각자의 디데이', '살아남은 로맨스', 
      '붉고 푸른 눈', '난 슬플 땐 봉춤을 춰'
    ]
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], books, '『', '』')
      row[col_name] = apply_brackets(row[col_name], shorts, '｢', '｣')
      row[col_name] = apply_brackets(row[col_name], webtoons, '〈', '〉')
    end
  elsif isbn == '979-11-89680-36-7' # 레트로 마니아
    books = ['레트로 마니아', '2022 제5회 한국과학문학상 수상작품집', '에픽']
    shorts = [
      '옛날 옛적 판교에서는', '장우산이 드리운 주일', '라틴화첩기행', '천박하고 문제적인 쇼와 프로레스', 
      'Roman de La Pistoche', '도무지, 대머리독수리와는 대화를 나눌 수가 없습니다', 
      '제임슨의 두 번째 주인', '안주의 맛'
    ]
    header.each do |col_name|
      row[col_name] = apply_brackets(row[col_name], books, '『', '』')
      row[col_name] = apply_brackets(row[col_name], shorts, '｢', '｣')
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
