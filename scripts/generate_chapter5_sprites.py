from PIL import Image, ImageDraw
import math

def create_void_tileset():
    # 64x64 texture tiles for Abyssal Void
    img = Image.new('RGBA', (64, 64), (12, 8, 20, 255))
    draw = ImageDraw.Draw(img)

    # Cosmic grid & star specks
    for y in range(0, 64, 16):
        for x in range(0, 64, 16):
            draw.rectangle([x, y, x + 15, y + 15], outline=(25, 15, 38, 255))
    
    # Star specks & nebula dust
    stars = [
        (4, 5, (180, 150, 255, 200)),
        (12, 10, (255, 200, 255, 180)),
        (24, 4, (120, 220, 255, 220)),
        (45, 12, (255, 255, 255, 240)),
        (54, 25, (200, 100, 255, 190)),
        (8, 38, (150, 180, 255, 180)),
        (28, 44, (255, 180, 220, 200)),
        (42, 52, (180, 255, 220, 210)),
        (58, 48, (255, 255, 200, 220)),
    ]
    for x, y, c in stars:
        draw.point((x, y), fill=c)
        draw.point((x+1, y), fill=(c[0], c[1], c[2], 100))

    # Glowing ethereal rune circle in center
    draw.ellipse([20, 20, 44, 44], outline=(140, 50, 180, 120), width=1)

    img.save("assets/sprites/tileset_void.png")
    print("Saved assets/sprites/tileset_void.png")

def create_cabalis_sprites():
    # 64x64 pixel sprite for Demon God Cabalis
    size = (64, 64)
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Shadow
    draw.ellipse([14, 50, 50, 60], fill=(5, 0, 10, 160))

    # Cosmic Demonic Wings
    # Left Wing
    draw.polygon([(26, 26), (6, 8), (4, 28), (14, 42)], fill=(45, 10, 60, 240), outline=(180, 40, 140, 255))
    # Right Wing
    draw.polygon([(38, 26), (58, 8), (60, 28), (50, 42)], fill=(45, 10, 60, 240), outline=(180, 40, 140, 255))

    # Floating Cosmic Body / Robes of the Netherworld
    draw.polygon([(32, 20), (18, 52), (46, 52)], fill=(25, 8, 35, 255))
    draw.polygon([(32, 22), (22, 52), (42, 52)], fill=(40, 15, 55, 255))

    # Void Core (Heart of Chaos)
    draw.ellipse([27, 30, 37, 40], fill=(255, 30, 80, 255), outline=(255, 180, 220, 255))
    draw.ellipse([29, 32, 35, 38], fill=(255, 255, 255, 255))

    # Demonic Shoulders & Clawed Arms
    draw.ellipse([16, 22, 26, 32], fill=(60, 18, 80, 255))
    draw.ellipse([38, 22, 48, 32], fill=(60, 18, 80, 255))
    # Claws
    draw.polygon([(18, 32), (14, 40), (20, 36)], fill=(220, 200, 240, 255))
    draw.polygon([(46, 32), (50, 40), (44, 36)], fill=(220, 200, 240, 255))

    # Demonic Head & Crown of Horns
    draw.ellipse([24, 12, 40, 26], fill=(35, 10, 50, 255))
    # Left sweeping horn
    draw.line([(26, 14), (16, 4), (10, 8)], fill=(190, 40, 90, 255), width=3)
    # Right sweeping horn
    draw.line([(38, 14), (48, 4), (54, 8)], fill=(190, 40, 90, 255), width=3)

    # Glowing Triple Eyes of the Void
    draw.rectangle([27, 18, 30, 21], fill=(255, 30, 50, 255))
    draw.rectangle([34, 18, 37, 21], fill=(255, 30, 50, 255))
    draw.ellipse([30, 14, 34, 17], fill=(255, 220, 50, 255)) # Third eye

    # Halo of Chaos
    for deg in range(0, 360, 30):
        rad = math.radians(deg)
        hx = int(32 + 18 * math.cos(rad))
        hy = int(18 + 10 * math.sin(rad))
        draw.point((hx, hy), fill=(255, 100, 180, 200))

    img.save("assets/sprites/boss_cabalis.png")
    print("Saved assets/sprites/boss_cabalis.png")

def create_cabalis_portrait():
    # 48x48 portrait for dialogue
    size = (48, 48)
    img = Image.new('RGBA', size, (18, 6, 24, 255))
    draw = ImageDraw.Draw(img)

    # Frame
    draw.rectangle([0, 0, 47, 47], outline=(200, 40, 100, 255), width=2)
    draw.rectangle([2, 2, 45, 45], outline=(80, 20, 50, 255), width=1)

    # Horns
    draw.line([(18, 18), (8, 4), (4, 10)], fill=(210, 40, 80, 255), width=3)
    draw.line([(30, 18), (40, 4), (44, 10)], fill=(210, 40, 80, 255), width=3)

    # Demonic Face
    draw.ellipse([14, 12, 34, 38], fill=(45, 12, 60, 255))

    # Triple Eyes
    draw.rectangle([18, 22, 22, 26], fill=(255, 20, 40, 255))
    draw.rectangle([26, 22, 30, 26], fill=(255, 20, 40, 255))
    draw.ellipse([22, 16, 26, 20], fill=(255, 220, 50, 255))

    # Netherworld Crest
    draw.polygon([(18, 36), (24, 44), (30, 36)], fill=(200, 30, 70, 255))

    img.save("assets/ui/portrait_cabalis.png")
    print("Saved assets/ui/portrait_cabalis.png")

if __name__ == "__main__":
    create_void_tileset()
    create_cabalis_sprites()
    create_cabalis_portrait()
