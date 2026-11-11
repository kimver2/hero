from PIL import Image, ImageDraw

def generate_boss_sprite():
    img = Image.new("RGBA", (40, 40), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 그림자
    draw.ellipse([(9, 31), (30, 37)], fill=(0, 0, 0, 100))

    # 붉은/검은 제사장 로브
    draw.polygon([(10, 14), (29, 14), (33, 33), (6, 33)], fill=(70, 15, 25))
    draw.polygon([(13, 16), (26, 16), (29, 32), (10, 32)], fill=(95, 25, 40)) # 하이라이트
    # 금빛 로브 테두리 장식
    draw.line([(10, 14), (6, 33)], fill=(220, 180, 50), width=2)
    draw.line([(29, 14), (33, 33)], fill=(220, 180, 50), width=2)
    draw.line([(10, 33), (29, 33)], fill=(220, 180, 50), width=1)

    # 어깨 숄더 아머
    draw.polygon([(6, 13), (12, 13), (11, 20), (5, 18)], fill=(130, 100, 30))
    draw.polygon([(27, 13), (33, 13), (34, 18), (28, 20)], fill=(130, 100, 30))

    # 머리 / 흑마법 후드 & 해골 가면
    draw.polygon([(11, 4), (28, 4), (30, 15), (9, 15)], fill=(45, 10, 20))
    draw.polygon([(13, 7), (26, 7), (25, 15), (14, 15)], fill=(220, 215, 205)) # 창백한 해골 가면
    # 가면의 붉은 눈구멍
    draw.rectangle([(15, 10), (17, 12)], fill=(255, 30, 30))
    draw.rectangle([(22, 10), (24, 12)], fill=(255, 30, 30))

    # 마법 지팡이
    draw.line([(32, 8), (32, 34)], fill=(110, 75, 40), width=2) # 지팡이 축
    # 지팡이 상단 보랏빛 오브
    draw.ellipse([(29, 3), (35, 9)], fill=(180, 60, 240), outline=(230, 160, 255))
    draw.point((32, 6), fill=(255, 255, 255))

    img.save("assets/sprites/boss_priest.png")
    print("boss_priest.png created")

generate_boss_sprite()
