from PIL import Image, ImageDraw

def create_menu_background():
    # 1024x512 Main Menu Background
    img = Image.new('RGB', (1024, 512), (40, 20, 10)) # Dark brown
    draw = ImageDraw.Draw(img)
    # Vignette/Gradient
    for i in range(256):
        c = int(40 - 20 * i / 256)
        draw.ellipse([512-i*4, 256-i*2, 512+i*4, 256+i*2], outline=(c, c//2, c//4), width=2)

    # Stylized harp or crown shape (very simple)
    draw.polygon([(480, 200), (544, 200), (560, 150), (512, 100), (464, 150)], fill=(218, 165, 32)) # Gold crown
    img.save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/background_menu.png')

def create_map_marker():
    # 64x64 Map Marker
    img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse([10, 10, 54, 54], fill=(139, 69, 19), outline=(218, 165, 32), width=3)
    draw.ellipse([20, 20, 44, 44], fill=(205, 133, 63))
    img.save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/map_marker.png')

def create_button_texture():
    # 128x64 Button Texture
    img = Image.new('RGBA', (128, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([2, 2, 126, 62], radius=10, fill=(101, 67, 33), outline=(218, 165, 32), width=3)
    # Glossy effect
    draw.rounded_rectangle([5, 5, 123, 25], radius=5, fill=(139, 90, 43, 100))
    img.save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/button_texture.png')

create_menu_background()
create_map_marker()
create_button_texture()
print("Additional assets generated.")
