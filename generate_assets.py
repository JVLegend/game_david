from PIL import Image, ImageDraw

def create_wolf():
    # 64x64 wolf sprite (stylized)
    img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Body
    draw.ellipse([10, 25, 50, 45], fill=(80, 80, 80))
    # Head
    draw.ellipse([40, 15, 60, 35], fill=(100, 100, 100))
    # Ears
    draw.polygon([(45, 15), (50, 5), (55, 15)], fill=(100, 100, 100))
    # Legs
    draw.rectangle([15, 40, 20, 55], fill=(60, 60, 60))
    draw.rectangle([25, 40, 30, 55], fill=(60, 60, 60))
    draw.rectangle([35, 40, 40, 55], fill=(60, 60, 60))
    draw.rectangle([45, 40, 50, 55], fill=(60, 60, 60))
    # Tail
    draw.polygon([(10, 30), (0, 20), (10, 35)], fill=(70, 70, 70))
    img.save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/wolf.png')

def create_background():
    # Forest Background (gradient + trees)
    img = Image.new('RGB', (1024, 512), (135, 206, 235)) # Sky Blue
    draw = ImageDraw.Draw(img)
    # Sky gradient
    for y in range(256):
        r = int(135 + (30 - 135) * y / 256)
        g = int(206 + (60 - 206) * y / 256)
        b = int(235 + (40 - 235) * y / 256)
        draw.line([(0, y), (1024, y)], fill=(r, g, b))

    # Simple mountains/hills
    draw.ellipse([-200, 200, 600, 600], fill=(34, 139, 34))
    draw.ellipse([400, 250, 1200, 650], fill=(0, 100, 0))

    # Stylized trees
    import random
    for _ in range(20):
        x = random.randint(0, 1024)
        y = random.randint(250, 400)
        h = random.randint(40, 80)
        draw.rectangle([x-5, y, x+5, y+h], fill=(101, 67, 33)) # Trunk
        draw.polygon([(x-20, y), (x+20, y), (x, y-40)], fill=(0, random.randint(100, 200), 0)) # Leaves

    img.save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/background_forest.png')

def create_ground():
    # Grass/Dirt ground
    img = Image.new('RGB', (512, 128), (101, 67, 33)) # Dirt
    draw = ImageDraw.Draw(img)
    # Grass top
    draw.rectangle([0, 0, 512, 20], fill=(34, 139, 34))
    # Texture
    import random
    for _ in range(500):
        x = random.randint(0, 511)
        y = random.randint(0, 127)
        c = random.randint(20, 50)
        draw.point((x, y), fill=(34+c, 139+c, 34+c) if y < 20 else (101+c, 67+c, 33+c))

    img.save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/ground_grass.png')

create_wolf()
create_background()
create_ground()
print("Assets generated successfully.")
