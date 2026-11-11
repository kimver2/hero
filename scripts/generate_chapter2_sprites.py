from PIL import Image, ImageDraw

def generate_karad():
    # 32x32 카라드 스프라이트 (회색 망토, 낡은 흑철 갑옷, 덥수룩한 머리)
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 그림자
    draw.ellipse([(7, 26), (24, 30)], fill=(0, 0, 0, 100))

    # 등 뒤의 거대한 대검
    draw.line([(7, 4), (25, 27)], fill=(120, 125, 135), width=3)
    draw.line([(5, 2), (9, 6)], fill=(200, 160, 50), width=2) # 대검 자루

    # 낡은 회색 망토
    draw.polygon([(8, 12), (23, 12), (26, 27), (5, 27)], fill=(80, 85, 90))
    draw.polygon([(10, 14), (21, 14), (24, 26), (7, 26)], fill=(105, 110, 115))

    # 몸통 / 흑철 흉갑
    draw.rectangle([(11, 14), (20, 22)], fill=(45, 50, 55))
    draw.line([(11, 16), (20, 16)], fill=(85, 90, 95))

    # 다리 / 부츠
    draw.rectangle([(11, 23), (14, 27)], fill=(35, 38, 42))
    draw.rectangle([(17, 23), (20, 27)], fill=(35, 38, 42))

    # 얼굴 & 덥수룩한 턱수염
    draw.rectangle([(11, 7), (20, 13)], fill=(215, 175, 145))
    draw.polygon([(10, 11), (21, 11), (18, 15), (13, 15)], fill=(65, 55, 50)) # 턱수염

    # 짙은 흑발 & 흉터
    draw.polygon([(8, 4), (23, 4), (24, 11), (7, 11)], fill=(40, 35, 35))
    draw.line([(12, 8), (14, 11)], fill=(180, 70, 70)) # 뺨의 검흔 흉터
    # 날카로운 눈
    draw.point((13, 9), fill=(240, 240, 240))
    draw.point((18, 9), fill=(240, 240, 240))

    img.save("assets/sprites/karad_sprite.png")
    print("karad_sprite.png created")

    # 96x96 카라드 초상화 (Portrait)
    p_img = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    p_draw = ImageDraw.Draw(p_img)

    p_draw.ellipse([(8, 8), (88, 88)], fill=(35, 35, 40, 200), outline=(130, 135, 145, 220), width=2)

    # 낡은 흑철 갑옷 & 대검 자루
    p_draw.polygon([(16, 95), (32, 66), (64, 66), (80, 95)], fill=(55, 60, 65))
    p_draw.line([(12, 15), (34, 75)], fill=(180, 185, 195), width=4) # 어깨 너머 대검

    # 얼굴 & 수염
    p_draw.polygon([(34, 38), (62, 38), (58, 60), (48, 70), (38, 60)], fill=(225, 180, 150))
    p_draw.polygon([(34, 52), (62, 52), (56, 68), (48, 74), (40, 68)], fill=(60, 50, 45)) # 덥수룩한 턱수염

    # 흑갈색 흩날리는 머리카락
    p_draw.polygon([(26, 28), (70, 28), (76, 55), (66, 50), (62, 22), (48, 16), (34, 22), (28, 50), (20, 55)], fill=(45, 40, 40))

    # 깊은 눈매 & 뺨의 붉은 흉터
    p_draw.line([(36, 40), (45, 42)], fill=(20, 20, 20), width=2)
    p_draw.line([(51, 42), (60, 40)], fill=(20, 20, 20), width=2)
    p_draw.rectangle([(38, 44), (43, 47)], fill=(200, 170, 100)) # 호박색 눈동자
    p_draw.rectangle([(53, 44), (58, 47)], fill=(200, 170, 100))
    p_draw.line([(39, 42), (43, 56)], fill=(180, 60, 60), width=2) # 흉터

    p_img.save("assets/ui/portrait_karad.png")
    print("portrait_karad.png created")

def generate_cultist_knight():
    # 32x32 사교도 정예 기사 (강철 방패 + 보라빛 대검)
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 그림자
    draw.ellipse([(8, 25), (23, 29)], fill=(0, 0, 0, 100))

    # 검붉은 망토
    draw.polygon([(8, 13), (23, 13), (25, 26), (6, 26)], fill=(60, 20, 40))

    # 강철 중갑
    draw.rectangle([(10, 14), (21, 22)], fill=(80, 75, 90))
    draw.line([(10, 14), (21, 14)], fill=(130, 125, 145))

    # 다리
    draw.rectangle([(11, 23), (14, 27)], fill=(50, 48, 58))
    draw.rectangle([(17, 23), (20, 27)], fill=(50, 48, 58))

    # 투구 / 뿔 장식
    draw.polygon([(9, 5), (22, 5), (24, 14), (7, 14)], fill=(65, 60, 75))
    draw.line([(7, 8), (4, 3)], fill=(140, 130, 155), width=2) # 좌측 뿔
    draw.line([(24, 8), (27, 3)], fill=(140, 130, 155), width=2) # 우측 뿔
    # 바이저 속 붉은 눈빛
    draw.line([(12, 10), (19, 10)], fill=(255, 40, 40), width=2)

    # 왼손 대형 방패
    draw.polygon([(5, 15), (10, 13), (11, 25), (6, 27)], fill=(110, 105, 125))
    draw.polygon([(6, 16), (9, 14), (10, 24), (7, 25)], fill=(160, 50, 180)) # 방패 중앙 보랏빛 룬

    # 오른손 장검
    draw.line([(23, 12), (23, 26)], fill=(180, 190, 205), width=2)

    img.save("assets/sprites/cultist_knight.png")
    print("cultist_knight.png created")

generate_karad()
generate_cultist_knight()
