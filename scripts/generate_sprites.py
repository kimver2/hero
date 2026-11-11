import os
from PIL import Image, ImageDraw

def generate_player_sprite():
    # 32x32 플레이어 (기사 레온)
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 그림자 (타원)
    draw.ellipse([(8, 25), (23, 29)], fill=(0, 0, 0, 90))
    
    # 망토 (파란색)
    draw.polygon([(9, 13), (22, 13), (24, 25), (7, 25)], fill=(28, 55, 115))
    draw.polygon([(10, 14), (21, 14), (23, 24), (8, 24)], fill=(40, 80, 160))
    
    # 몸통 / 은빛 흉갑
    draw.rectangle([(11, 14), (20, 21)], fill=(170, 180, 195)) # 갑옷 베이스
    draw.line([(11, 14), (20, 14)], fill=(220, 230, 245)) # 하이라이트
    draw.rectangle([(11, 20), (20, 22)], fill=(90, 60, 35)) # 벨트
    draw.point((15, 21), fill=(230, 190, 40)) # 금색 버클
    draw.point((16, 21), fill=(230, 190, 40))
    
    # 다리 / 부츠
    draw.rectangle([(11, 22), (14, 26)], fill=(50, 55, 65))
    draw.rectangle([(17, 22), (20, 26)], fill=(50, 55, 65))
    draw.point((11, 26), fill=(30, 32, 40))
    draw.point((20, 26), fill=(30, 32, 40))
    
    # 머리 / 얼굴
    draw.rectangle([(11, 6), (20, 13)], fill=(245, 205, 170)) # 살구색 얼굴
    # 금발 머리카락
    draw.polygon([(9, 4), (22, 4), (23, 9), (8, 9)], fill=(235, 185, 45))
    draw.polygon([(10, 3), (21, 3), (21, 7), (10, 7)], fill=(255, 220, 75)) # 하이라이트
    draw.point((9, 10), fill=(235, 185, 45)) # 옆머리
    draw.point((22, 10), fill=(235, 185, 45))
    
    # 눈 (벽안/푸른 눈)
    draw.point((13, 10), fill=(40, 100, 180))
    draw.point((18, 10), fill=(40, 100, 180))
    
    # 손 & 건틀릿
    draw.rectangle([(8, 16), (10, 18)], fill=(160, 170, 185))
    draw.rectangle([(21, 16), (23, 18)], fill=(160, 170, 185))
    
    img.save("assets/sprites/player_knight.png")
    print("player_knight.png created")

def generate_cultist_sprite():
    # 32x32 사교도 적
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 그림자
    draw.ellipse([(8, 25), (23, 29)], fill=(0, 0, 0, 90))
    
    # 보라색 로브 몸통
    draw.polygon([(9, 11), (22, 11), (25, 26), (6, 26)], fill=(55, 30, 75))
    draw.polygon([(11, 13), (20, 13), (22, 25), (9, 25)], fill=(75, 45, 105)) # 안쪽 음영
    
    # 후드
    draw.polygon([(8, 4), (23, 4), (24, 13), (7, 13)], fill=(45, 22, 60))
    draw.polygon([(10, 3), (21, 3), (22, 10), (9, 10)], fill=(65, 35, 90))
    
    # 짙은 어둠 속 번뜩이는 붉은 눈
    draw.rectangle([(11, 8), (20, 12)], fill=(25, 15, 35)) # 후드 속 어둠
    draw.point((13, 10), fill=(255, 50, 50))
    draw.point((14, 10), fill=(255, 80, 80))
    draw.point((17, 10), fill=(255, 80, 80))
    draw.point((18, 10), fill=(255, 50, 50))
    
    # 암살용 단검을 쥔 손
    draw.rectangle([(6, 17), (8, 19)], fill=(45, 25, 60))
    draw.line([(5, 15), (5, 21)], fill=(180, 190, 205)) # 단검 날
    draw.point((5, 14), fill=(240, 245, 255))
    
    img.save("assets/sprites/enemy_cultist.png")
    print("enemy_cultist.png created")

def generate_slash_effect():
    # 32x32 호선형 검기 궤적
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 반월형 검기
    for r in range(12, 15):
        draw.arc([(4, 4), (28, 28)], start=-60, end=60, fill=(120, 200, 255, 220), width=2)
    draw.arc([(5, 5), (27, 27)], start=-45, end=45, fill=(240, 250, 255, 255), width=2)
    
    img.save("assets/sprites/sword_slash.png")
    print("sword_slash.png created")

generate_player_sprite()
generate_cultist_sprite()
generate_slash_effect()
