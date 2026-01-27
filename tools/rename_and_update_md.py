import os
import re

IMG_DIR = r'assets/images/books'
MD_DIR = r'_books'

# Mapping based on analysis
MAPPING = {
    '231019_TSOS_cover1.jpg': '979-11-89680-48-0.jpg',
    'metazoa_cover_1.jpg': '979-11-89680-39-8.jpg',
    'other minds_cover.jpg': '979-11-89680-05-3.jpg',
    'thought_experiment_cover_1.jpg': '979-11-89680-09-1.jpg',
    '생명의 여정_표1.jpg': '979-11-89680-58-9.jpg',
    '러닝클럽 표지_펼침면1.jpg': '979-11-89680-57-2.jpg',
    '과학자가 되는 방법_개정판_표지1.jpg': '979-11-89680-56-5.jpg',
    '김범준의 물리장난감_표1(띠).jpg': '979-11-89680-54-1.jpg',
    '닌텐도 다이어리_표지1.jpg': '979-11-89680-49-7.jpg',
    '쇼미더허니_표1.jpg': '979-11-89680-46-6.jpg',
    '뉴턴의 무정한 세계_표지1.jpg': '979-11-89680-44-2.jpg',
    '오송역_표1.jpg': '979-11-89680-43-5.jpg',
    '웹툰 내비게이션_표1.jpg': '979-11-89680-37-4.jpg',
    '레트로 마니아_표지_1.jpg': '979-11-89680-36-7.jpg',
    '양육가설.jpg': '979-11-89680-33-6.jpg',
    '오만과선량.jpg': '979-11-89680-32-9.jpg',
    '적색편이-표지1.jpg': '979-11-89680-28-2.jpg',
    '블루 노트-표지1.jpg': '979-11-89680-27-5.jpg',
    '푸드트렌드4.jpg': '979-11-89680-25-1.jpg',
    '화석이되고싶어_표지.jpg': '979-11-89680-24-4.jpg',
    '시간과 장의사_표1.jpg': '979-11-89680-21-3.jpg',
    '푸드트렌드3.jpg': '979-11-89680-15-2.jpg',
    '우울밥2.jpg': '979-11-89680-13-8.jpg',
    '우울밥1.jpg': '979-11-89680-12-1.jpg',
    '역마_표지1.jpg': '979-11-89680-06-0.jpg',
    '계획된 불평등_표1.jpg': '979-11-89680-04-6.jpg',
    '푸드트렌드2.jpg': '979-11-962831-9-3.jpg',
    '최저_표지1.jpg': '979-11-962831-1-7.jpg',
    '푸드트렌드1.jpg': '979-11-962831-0-0.jpg',
    '수학으로 만나는 세계_표1s.jpg': '979-11-956868-9-6.jpg',
    '사인과다면체와별과패턴_표1-300.jpg': '979-11-956868-5-8.jpg',
    '필리버스터_표1_200.jpg': '979-11-956868-0-3.jpg',
}

def rename_images():
    for old_name, new_name in MAPPING.items():
        old_path = os.path.join(IMG_DIR, old_name)
        new_path = os.path.join(IMG_DIR, new_name)
        if os.path.exists(old_path):
            try:
                os.rename(old_path, new_path)
                print(f"Renamed: {old_name} -> {new_name}")
            except Exception as e:
                print(f"Failed to rename {old_name}: {e}")
        else:
            print(f"File not found: {old_path}")

def update_markdowns():
    for filename in os.listdir(MD_DIR):
        if filename.endswith('.md'):
            isbn = filename.replace('.md', '')
            filepath = os.path.join(MD_DIR, filename)
            
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Update cover_image in front matter
            image_name = f"{isbn}.jpg"
            image_path = os.path.join(IMG_DIR, image_name)
            
            if os.path.exists(image_path):
                # Replace cover_image: "" or cover_image: "something"
                new_content = re.sub(r'cover_image: ".*"', f'cover_image: "/{IMG_DIR}/{image_name}"', content)
                # If not matched (maybe no quotes or different format)
                if new_content == content:
                     new_content = re.sub(r'cover_image: .*', f'cover_image: "/{IMG_DIR}/{image_name}"', content)
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Updated MD: {filename}")

if __name__ == "__main__":
    rename_images()
    update_markdowns()
