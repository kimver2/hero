from PIL import Image, ImageDraw

def create_cathedral_tileset():
    # 64x64 texture tiles for Cathedral: dark polished marble floor & crimson ceremonial carpet
    img = Image.new('RGBA', (64, 64), (28, 25, 35, 255))
    draw = ImageDraw.Draw(img)

    # Dark Gothic marble checker pattern
    for y in range(0, 64, 16):
        for x in range(0, 64, 16):
            c = (35, 32, 45, 255) if ((x // 16) + (y // 16)) % 2 == 0 else (25, 22, 32, 255)
            draw.rectangle([x, y, x + 15, y + 15], fill=c, outline=(18, 15, 22, 255))

    # Crimson ceremonial carpet in bottom half
    for y in range(32, 64):
        draw.line([(0, y), (63, y)], fill=(120, 20, 35, 255))
    # Gold trim borders on carpet
    draw.line([(0, 32), (63, 32)], fill=(215, 175, 50, 255), width=2)
    draw.line([(0, 62), (63, 62)], fill=(215, 175, 50, 255), width=2)

    img.save("assets/sprites/tileset_cathedral.png")
    print("Saved assets/sprites/tileset_cathedral.png")

def create_malakar_sprites():
    # 48x48 pixel sprite for Grand Inquisitor Malakar (Dark Archpriest with sinister horned hood & void scepter)
    size = (48, 48)
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Shadow
    draw.ellipse([12, 38, 36, 46], fill=(10, 5, 15, 150))

    # Dark purple flowing robes
    draw.polygon([(24, 18), (10, 42), (38, 42)], fill=(45, 20, 55, 255))
    draw.polygon([(24, 20), (14, 42), (34, 42)], fill=(60, 28, 75, 255))

    # Golden occult embroidery on robe
    draw.line([(24, 22), (24, 42)], fill=(215, 175, 50, 255), width=2)
    draw.line([(18, 34), (30, 34)], fill=(215, 175, 50, 255), width=2)

    # Inquisitor Cape & Shoulders
    draw.ellipse([14, 16, 34, 26], fill=(30, 12, 40, 255))

    # Hood & Mask
    draw.ellipse([16, 8, 32, 22], fill=(45, 20, 55, 255))
    draw.polygon([(18, 8), (14, 2), (22, 9)], fill=(30, 10, 40, 255)) # Left horn/crest
    draw.polygon([(30, 8), (34, 2), (26, 9)], fill=(30, 10, 40, 255)) # Right horn/crest

    # Pale masked face with glowing void eyes
    draw.rectangle([19, 13, 29, 19], fill=(210, 200, 215, 255))
    draw.point((21, 15), fill=(255, 30, 50, 255))
    draw.point((27, 15), fill=(255, 30, 50, 255))

    # Void Scepter (in right hand)
    draw.line([(35, 12), (35, 42)], fill=(160, 130, 40, 255), width=2)
    # Floating Dark Orb on top of scepter
    draw.ellipse([31, 8, 39, 16], fill=(180, 20, 60, 255), outline=(255, 100, 150, 255))
    draw.point((35, 12), fill=(255, 255, 255, 255))

    img.save("assets/sprites/boss_malakar.png")
    print("Saved assets/sprites/boss_malakar.png")

def create_malakar_portrait():
    # 48x48 portrait for dialogue
    size = (48, 48)
    img = Image.new('RGBA', size, (22, 12, 28, 255))
    draw = ImageDraw.Draw(img)

    # Frame
    draw.rectangle([0, 0, 47, 47], outline=(150, 60, 80, 255), width=2)
    draw.rectangle([2, 2, 45, 45], outline=(60, 25, 40, 255), width=1)

    # Hood & Horns
    draw.polygon([(14, 18), (6, 4), (20, 14)], fill=(40, 15, 50, 255))
    draw.polygon([(34, 18), (42, 4), (28, 14)], fill=(40, 15, 50, 255))
    draw.ellipse([10, 10, 38, 38], fill=(55, 22, 70, 255))

    # Face mask
    draw.rectangle([16, 20, 32, 34], fill=(200, 190, 205, 255))
    # Crimson glowing sinister eyes
    draw.rectangle([18, 23, 23, 27], fill=(255, 20, 40, 255))
    draw.rectangle([25, 23, 30, 27], fill=(255, 20, 40, 255))
    draw.point((20, 24), fill=(255, 220, 220, 255))
    draw.point((27, 24), fill=(255, 220, 220, 255))

    # Robe Collar & Gold Talisman
    draw.polygon([(12, 38), (24, 46), (36, 38)], fill=(35, 12, 45, 255))
    draw.ellipse([21, 40, 27, 46], fill=(230, 180, 40, 255))

    img.save("assets/ui/portrait_malakar.png")
    print("Saved assets/ui/portrait_malakar.png")

if __name__ == "__main__":
    create_cathedral_tileset()
    create_malakar_sprites()
    create_malakar_portrait()
