from PIL import Image, ImageDraw

def create_app_icon():
    # 1024x1024 App Icon
    size = 1024
    img = Image.new('RGB', (size, size), (40, 20, 10)) # Dark brown/gold theme
    draw = ImageDraw.Draw(img)

    # Background gradient-like circle
    draw.ellipse([50, 50, 974, 974], fill=(60, 30, 15), outline=(218, 165, 32), width=40)

    # Stylized Crown (Gold)
    crown_points = [
        (300, 600), (724, 600), (800, 400), (650, 500), (512, 300), (374, 500), (224, 400)
    ]
    draw.polygon(crown_points, fill=(218, 165, 32))

    # Stylized Sling (Funda) - crossing the crown
    draw.arc([300, 400, 724, 800], start=0, end=180, fill=(255, 255, 255), width=20)
    draw.ellipse([482, 750, 542, 810], fill=(200, 200, 200), outline=(0,0,0), width=5) # The stone

    img.save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/AppIcon.png')
    # Generate smaller sizes for iOS
    img.resize((180, 180)).save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/AppIcon60x60@3x.png')
    img.resize((120, 120)).save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/AppIcon60x60@2x.png')

create_app_icon()
print("App Icons generated.")
