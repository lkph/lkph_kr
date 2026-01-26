import csv
import os
import re

# 설정
INPUT_FILE = '_data/books_import_data.tsv'
OUTPUT_DIR = '_books'

def slugify(value):
    """
    한글 제목을 파일명으로 쓰기엔 URL 문제가 있을 수 있으므로 단순화하거나 
    여기서는 안전하게 ISBN을 파일명으로 사용합니다.
    """
    return value.strip()

def create_markdown(row):
    # TSV 컬럼 매핑 (0-based index)
    # 발행일: 14, 정가: 7, 페이지수: 11
    publish_date = row[14].strip()
    year = publish_date[:4] if len(publish_date) >= 4 else "2024"

    # 설명 생성 (주제어 삭제됨)
    page_count = row[11].strip()
    price = row[7].strip().replace('"', '')
    
    description = f"도서입니다. ({page_count}쪽)"
    
    # 파일명: ISBN 활용
    filename = f"{isbn}.md"
    filepath = os.path.join(OUTPUT_DIR, filename)
    
    # Front Matter 작성
    content = f"""---
layout: book
title: "{title}"
author: "{author}"
year: {year}
isbn: "{isbn}"
price: "{price}"
description: "{description}"
cover_image: ""
---

# {title}

**{author}** 저 | **{year}**년 발행 | **{price}**원

## 책 소개

{title} 관련 도서입니다.

*   **ISBN**: {isbn}
*   **페이지**: {page_count}쪽
"""
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return 'CREATED'

def main():
    # 출력 디렉토리 확인
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    count_created = 0
    count_skipped = 0

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        # 탭으로 분리, csv 모듈 사용
        reader = csv.reader(f, delimiter='\t')
        
        # 헤더 스킵
        next(reader, None)
        
        for row in reader:
            if not row or len(row) < 5:  # 빈 줄이나 데이터 부족
                continue
                
            result = create_markdown(row)
            if result == 'CREATED':
                count_created += 1
            elif result == 'SKIPPED':
                count_skipped += 1
    
    print(f"완료: {count_created}권 등록됨, {count_skipped}권 제외됨 ('보수를 지켜라')")

if __name__ == "__main__":
    main()
