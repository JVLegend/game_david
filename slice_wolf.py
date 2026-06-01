from PIL import Image, ImageChops
import os

def trim(im):
    bg = Image.new(im.mode, im.size, (255, 255, 255, 255))
    diff = ImageChops.difference(im, bg)
    diff = ImageChops.add(diff, diff, 2.0, -100)
    bbox = diff.getbbox()
    if bbox:
        return im.crop(bbox)
    return im

def slice_wolf(input_path, output_dir):
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size

    cols = 4
    rows = 1
    cell_w = width // cols
    cell_h = height // rows

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for c in range(cols):
        left = c * cell_w
        top = 0
        right = left + cell_w
        bottom = cell_h

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

        output_path = os.path.join(output_dir, f"wolf_walk_{c}.png")
        trimmed.save(output_path, "PNG")
        print(f"Saved {output_path}")

slice_wolf('/Users/iaparamedicos/Documents/GitHub/game_david/sprites/lobo4.png', 'DaviTheAnointed/DaviTheAnointed/Resources/Textures/')
