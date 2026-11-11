import os
from PIL import Image, ImageDraw

os.makedirs("assets/sprites", exist_ok=True)
os.makedirs("assets/ui", exist_ok=True)

# 1. 고대 유적 타일셋 (32x32 타일 4x4 그리드 = 128x128)
# 타일 0: 고대 돌바닥, 타일 1: 이끼 낀 돌바닥, 타일 2: 잔디/흙, 타일 3: 유적 벽돌벽
# 타일 4: 고대 기둥 상단, 타일 5: 고대 기둥 하단, 타일 6: 제단 바닥 룬 문자, 타일 7: 꽃/잡초
def generate_tileset():
    img = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 타일 0 (0,0): 고대 돌바닥
    for y in range(32):
        for x in range(32):
            base_col = (55, 62, 60)
            if (x in [0, 31] or y in [0, 31]) or (x == 16 or y == 16):
                base_col = (38, 42, 40)
            elif (x + y) % 7 == 0:
                base_col = (65, 74, 72)
            draw.point((x, y), fill=base_col)

    # 타일 1 (32,0): 이끼 낀 돌바닥
    for y in range(32):
        for x in range(32):
            base_col = (50, 60, 52)
            if (x in [0, 31] or y in [0, 31]):
                base_col = (35, 42, 36)
            elif (x * 3 + y * 5) % 11 < 3:
                base_col = (42, 75, 48) # 이끼
            draw.point((x + 32, y), fill=base_col)

    # 타일 2 (64,0): 숲 잔디/풀밭
    for y in range(32):
        for x in range(32):
            base_col = (35, 58, 40)
            if (x * 7 + y * 13) % 9 == 0:
                base_col = (45, 78, 50)
            elif (x * 3 + y * 11) % 17 == 0:
                base_col = (28, 48, 32)
            draw.point((x + 64, y), fill=base_col)

    # 타일 3 (96,0): 유적 돌벽
    for y in range(32):
        for x in range(32):
            base_col = (75, 82, 85)
            if y % 8 == 0 or (y // 8 % 2 == 0 and x % 16 == 0) or (y // 8 % 2 == 1 and (x + 8) % 16 == 0):
                base_col = (35, 38, 40)
            elif y % 8 == 1:
                base_col = (95, 105, 110)
            draw.point((x + 96, y), fill=base_col)

    # 타일 4 (0,32): 고대 룬 문자 제단
    for y in range(32):
        for x in range(32):
            base_col = (48, 52, 60)
            if (x-16)**2 + (y-16)**2 in range(100, 140):
                base_col = (80, 180, 240) # 푸른 룬 빛
            elif (x-16)**2 + (y-16)**2 in range(20, 45):
                base_col = (120, 210, 255)
            draw.point((x, y + 32), fill=base_col)

    # 타일 5 (32,32): 돌기둥 베이스
    for y in range(32):
        for x in range(32):
            if 6 <= x <= 25 and 4 <= y <= 27:
                col = (110, 115, 120)
                if x in [6, 25] or y in [4, 27]:
                    col = (40, 42, 45)
                elif x in [7, 8]:
                    col = (145, 150, 155)
                draw.point((x + 32, y + 32), fill=col)

    img.save("assets/sprites/tileset_ruins.png")
    print("tileset_ruins.png created")

generate_tileset()
