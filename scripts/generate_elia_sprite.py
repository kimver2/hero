from PIL import Image, ImageDraw

def generate_elia_sprite():
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 그림자
    draw.ellipse([(8, 25), (23, 29)], fill=(0, 0, 0, 90))

    # 하얀 신관 로브
    draw.polygon([(10, 14), (21, 14), (24, 26), (7, 26)], fill=(235, 238, 245))
    draw.polygon([(12, 15), (19, 15), (22, 25), (9, 25)], fill=(255, 255, 255))
    # 금빛 옷단
    draw.line([(7, 26), (24, 26)], fill=(220, 185, 50), width=1)
    draw.line([(10, 14), (8, 25)], fill=(220, 185, 50), width=1)
    draw.line([(21, 14), (23, 25)], fill=(220, 185, 50), width=1)

    # 푸른 브로치
    draw.point((15, 16), fill=(60, 160, 240))
    draw.point((16, 16), fill=(60, 160, 240))

    # 얼굴
    draw.rectangle([(11, 7), (20, 13)], fill=(255, 220, 205))

    # 은발 긴 머리카락
    draw.polygon([(8, 4), (23, 4), (24, 22), (21, 18), (19, 6), (12, 6), (10, 18), (7, 22)], fill=(210, 215, 225))
    draw.polygon([(10, 3), (21, 3), (21, 8), (10, 8)], fill=(245, 250, 255)) # 은빛 광택

    # 이마 황금 서클릿
    draw.line([(11, 7), (20, 7)], fill=(230, 190, 50), width=1)
    draw.point((15, 7), fill=(80, 210, 255))

    # 큰 에메랄드 눈망울
    draw.point((13, 10), fill=(40, 180, 140))
    draw.point((18, 10), fill=(40, 180, 140))

    img.save("assets/sprites/elia_sprite.png")
    print("elia_sprite.png created")

generate_elia_sprite()
