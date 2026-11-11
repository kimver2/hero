from PIL import Image, ImageDraw

def create_guardian_beast_sprite():
    # 64x64 pixel sprite for Corrupted Ancient Guardian Beast
    size = (64, 64)
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Dark shadow
    draw.ellipse([10, 48, 54, 62], fill=(10, 20, 10, 140))

    # Fur / Body (Dark emerald-moss & deep charcoal chimera beast)
    # Hind legs
    draw.ellipse([8, 34, 24, 52], fill=(25, 45, 35, 255))
    draw.ellipse([40, 34, 56, 52], fill=(25, 45, 35, 255))
    # Claws
    draw.rectangle([10, 48, 20, 54], fill=(180, 190, 180, 255))
    draw.rectangle([44, 48, 54, 54], fill=(180, 190, 180, 255))

    # Massive Torso
    draw.ellipse([14, 20, 50, 48], fill=(35, 60, 45, 255))
    draw.ellipse([18, 24, 46, 44], fill=(45, 75, 55, 255))

    # Corrupted Runic Spikes / Dark Crimson Crystals on Back
    spikes = [
        [(22, 22), (20, 10), (27, 20)],
        [(30, 18), (32, 6), (36, 18)],
        [(39, 20), (44, 10), (42, 22)],
    ]
    for s in spikes:
        draw.polygon(s, fill=(190, 30, 60, 255), outline=(255, 90, 120, 255))

    # Beast Head
    draw.ellipse([20, 16, 44, 38], fill=(40, 70, 50, 255))
    # Snout / Jaw
    draw.rectangle([25, 28, 39, 38], fill=(25, 45, 35, 255))
    # Fangs
    draw.polygon([(26, 34), (28, 40), (30, 34)], fill=(240, 240, 240, 255))
    draw.polygon([(34, 34), (36, 40), (38, 34)], fill=(240, 240, 240, 255))

    # Corrupted Horns (Curling ancient antlers)
    draw.line([(24, 18), (14, 8), (12, 14)], fill=(90, 110, 80, 255), width=3)
    draw.line([(40, 18), (50, 8), (52, 14)], fill=(90, 110, 80, 255), width=3)

    # Glowing Red Corrupted Eyes
    draw.rectangle([25, 23, 29, 26], fill=(255, 40, 40, 255))
    draw.rectangle([35, 23, 39, 26], fill=(255, 40, 40, 255))
    draw.point((27, 24), fill=(255, 220, 220, 255))
    draw.point((37, 24), fill=(255, 220, 220, 255))

    # Golden Ancient Collar (The tainted sacred seal)
    draw.rectangle([24, 38, 40, 42], fill=(220, 180, 50, 255))
    draw.ellipse([30, 39, 34, 43], fill=(255, 50, 50, 255))

    img.save("assets/sprites/boss_guardian.png")
    print("Saved assets/sprites/boss_guardian.png")

def create_guardian_portrait():
    # 48x48 portrait for dialogue
    size = (48, 48)
    img = Image.new('RGBA', size, (25, 35, 30, 255))
    draw = ImageDraw.Draw(img)

    # Frame
    draw.rectangle([0, 0, 47, 47], outline=(80, 110, 90, 255), width=2)
    draw.rectangle([2, 2, 45, 45], outline=(40, 60, 50, 255), width=1)

    # Beast Face Closeup
    # Horns
    draw.line([(15, 14), (6, 4), (4, 10)], fill=(100, 120, 90, 255), width=3)
    draw.line([(32, 14), (41, 4), (43, 10)], fill=(100, 120, 90, 255), width=3)

    # Crimson Spikes background
    draw.polygon([(20, 10), (24, 2), (28, 10)], fill=(210, 40, 70, 255))

    # Head & Mane
    draw.ellipse([10, 12, 37, 42], fill=(40, 70, 55, 255))
    draw.ellipse([13, 15, 34, 39], fill=(50, 85, 65, 255))

    # Snout
    draw.rectangle([17, 26, 30, 38], fill=(30, 50, 40, 255))
    # Fangs
    draw.polygon([(18, 32), (20, 38), (22, 32)], fill=(240, 240, 240, 255))
    draw.polygon([(25, 32), (27, 38), (29, 32)], fill=(240, 240, 240, 255))

    # Corrupted Piercing Eyes
    draw.rectangle([16, 20, 21, 24], fill=(255, 40, 40, 255))
    draw.rectangle([26, 20, 31, 24], fill=(255, 40, 40, 255))
    draw.point((18, 22), fill=(255, 255, 200, 255))
    draw.point((28, 22), fill=(255, 255, 200, 255))

    img.save("assets/ui/portrait_guardian.png")
    print("Saved assets/ui/portrait_guardian.png")

def create_forest_tileset():
    # 64x64 texture tiles for forest sanctuary floor and ancient stone
    img = Image.new('RGBA', (64, 64), (35, 55, 35, 255))
    draw = ImageDraw.Draw(img)

    # Moss stone tile pattern
    for y in range(0, 64, 16):
        for x in range(0, 64, 16):
            draw.rectangle([x, y, x + 15, y + 15], outline=(28, 45, 28, 255))
            # subtle grass/moss specks
            draw.point((x + 4, y + 4), fill=(50, 80, 45, 255))
            draw.point((x + 10, y + 7), fill=(60, 95, 50, 255))
            draw.point((x + 7, y + 12), fill=(40, 65, 38, 255))

    # Ancient rune emblem in bottom right 32x32
    draw.ellipse([36, 36, 60, 60], outline=(65, 120, 95, 255), width=2)
    draw.rectangle([44, 44, 52, 52], outline=(90, 160, 120, 255), width=1)

    img.save("assets/sprites/tileset_forest.png")
    print("Saved assets/sprites/tileset_forest.png")

if __name__ == "__main__":
    create_guardian_beast_sprite()
    create_guardian_portrait()
    create_forest_tileset()
