from PIL import Image, ImageDraw, ImageFilter, ImageFont

def create_epic_background():
    # 1024x512 Background for Login
    width, height = 1024, 512
    img = Image.new('RGB', (width, height), (20, 10, 5))
    draw = ImageDraw.Draw(img)

    # Sky Gradient (Dark Night to deep gold horizon)
    for y in range(height):
        r = int(10 + (40 - 10) * (y / height))
        g = int(5 + (25 - 5) * (y / height))
        b = int(2 + (10 - 2) * (y / height))
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    # Add distant mountains silhouette
    draw.polygon([(0, 400), (200, 300), (400, 450), (600, 250), (800, 400), (1024, 350), (1024, 512), (0, 512)], fill=(5, 5, 5))

    # Add a glowing horizon line
    for i in range(10):
        alpha = 100 - i * 10
        draw.line([(0, 350+i), (width, 350+i)], fill=(150, 100, 0))

    img.save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/background_epic_login.png')

def create_pro_logo():
    # 800x300 Logo Area
    width, height = 800, 300
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Since I don't have fancy fonts easily accessible in this env,
    # I will create a stylized shield/crown shape to go behind the text
    # Or just a very polished background plate for the text

    # Background Glow
    for i in range(50, 0, -1):
        size = i * 4
        draw.ellipse([width//2 - size, height//2 - size, width//2 + size, height//2 + size], fill=(218, 165, 32, 2))

    # Stylized Shield
    draw.polygon([(300, 50), (500, 50), (550, 150), (400, 250), (250, 150)], fill=(60, 30, 10), outline=(218, 165, 32), width=5)

    # Add a crown on top of shield
    draw.polygon([(350, 60), (450, 60), (470, 20), (420, 40), (400, 10), (380, 40), (330, 20)], fill=(255, 215, 0))

    img.save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/logo_graphic.png')

create_epic_background()
create_pro_logo()
print("Epic Login assets generated.")
