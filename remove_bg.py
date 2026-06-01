from PIL import Image
import os

def remove_white_background(file_path):
    print(f"Processando: {file_path}")
    img = Image.open(file_path).convert("RGBA")
    datas = img.getdata()

    newData = []
    # Tolerância para o branco (200-255 para aceitar brancos não perfeitos)
    tolerance = 230

    for item in datas:
        # Se as cores R, G e B forem maiores que a tolerância, tornamos transparente
        if item[0] > tolerance and item[1] > tolerance and item[2] > tolerance:
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)

    img.putdata(newData)
    img.save(file_path, "PNG")

textures_dir = 'DaviTheAnointed/DaviTheAnointed/Resources/Textures/'
files_to_process = [
    '15_1_davi_com_funda.png',
    '15_1_davi_jovem.png',
    'botao_pedra.png',
    'davijovem.png',
    'davirei.png',
    'leao.png',
    'pergaminho.png'
]

for filename in files_to_process:
    path = os.path.join(textures_dir, filename)
    if os.path.exists(path):
        remove_white_background(path)

print("Processamento concluído.")
