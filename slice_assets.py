from PIL import Image, ImageChops

def trim(im):
    bg = Image.new(im.mode, im.size, (255, 255, 255, 255))
    diff = ImageChops.difference(im, bg)
    diff = ImageChops.add(diff, diff, 2.0, -100)
    bbox = diff.getbbox()
    if bbox:
        return im.crop(bbox)
    return im

def slice_spritesheet(input_path, output_dir):
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size

    # Let's try to detect cells. Assuming it might be a grid.
    # But a better way for AI generated "all-in-one" is often a regular grid.
    # Let's try 4 columns and 2 rows as a guess for (2816, 1536) -> 704x768 cells.
    cols = 4
    rows = 2
    cell_w = width // cols
    cell_h = height // rows

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    assets = [
        "icon_sling", "icon_staff", "icon_gold", "icon_ruby",
        "icon_heart", "icon_shield", "icon_map_battle", "icon_map_boss"
    ]

    idx = 0
    for r in range(rows):
        for c in range(cols):
            if idx >= len(assets): break

            left = c * cell_w
            top = r * cell_h
            right = left + cell_w
            bottom = top + cell_h

            cell = img.crop((left, top, right, bottom))

            # Remove white background
            datas = cell.getdata()
            newData = []
            tolerance = 220
            for item in datas:
                if item[0] > tolerance and item[1] > tolerance and item[2] > tolerance:
                    newData.append((255, 255, 255, 0))
                else:
                    newData.append(item)
            cell.putdata(newData)

            # Trim extra space
            trimmed = trim(cell)

            output_path = os.path.join(output_dir, f"{assets[idx]}.png")
            trimmed.save(output_path, "PNG")
            print(f"Saved {output_path}")
            idx += 1

import os
slice_spritesheet('/Users/iaparamedicos/Documents/GitHub/game_david/sprites/Gemini_Generated_Image_hpe4lehpe4lehpe4.png', 'DaviTheAnointed/DaviTheAnointed/Resources/Textures/')
