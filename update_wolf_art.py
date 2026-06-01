from PIL import Image, ImageDraw

def create_detailed_wolf():
    # 128x128 wolf sprite para mais detalhes
    size = 128
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Cores
    dark_gray = (40, 40, 40)
    mid_gray = (70, 70, 70)
    light_gray = (120, 120, 120)
    eye_red = (255, 0, 0)

    # Cauda
    draw.polygon([(10, 70), (40, 80), (10, 90)], fill=dark_gray)

    # Corpo (base)
    draw.ellipse([30, 50, 100, 95], fill=mid_gray)
    # Sombreamento corpo
    draw.ellipse([35, 75, 95, 90], fill=dark_gray)

    # Patas traseiras
    draw.rectangle([35, 80, 45, 115], fill=dark_gray)
    draw.rectangle([50, 85, 60, 115], fill=mid_gray)

    # Patas dianteiras
    draw.rectangle([75, 80, 85, 115], fill=dark_gray)
    draw.rectangle([85, 85, 95, 115], fill=mid_gray)

    # Pescoço/Juba (detalhada)
    draw.polygon([(80, 50), (110, 40), (115, 80), (80, 90)], fill=mid_gray)

    # Cabeça
    draw.ellipse([95, 30, 125, 65], fill=mid_gray)
    # Focinho
    draw.polygon([(115, 45), (125, 55), (115, 65)], fill=mid_gray)
    # Nariz
    draw.point((125, 55), fill=(0,0,0))

    # Orelhas
    draw.polygon([(100, 35), (105, 10), (110, 35)], fill=dark_gray)
    draw.polygon([(110, 35), (115, 15), (120, 35)], fill=mid_gray)

    # Olho Maligno (Brilhante)
    draw.ellipse([110, 45, 114, 49], fill=eye_red)
    # Brilho do olho
    draw.point((112, 47), fill=(255, 255, 255))

    # Detalhes de pelos (textura)
    for i in range(0, 100, 10):
        draw.line([(40+i, 55), (35+i, 60)], fill=light_gray, width=1)

    img.save('DaviTheAnointed/DaviTheAnointed/Resources/Textures/wolf.png')

create_detailed_wolf()
print("Nova arte do lobo gerada com sucesso.")
