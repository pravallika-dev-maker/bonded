import os
import numpy as np
from PIL import Image

input_dir = r"c:\Users\prava\OneDrive\Desktop\bonding\frontend\assets\skyhavenassets\input"
output_dir = r"c:\Users\prava\OneDrive\Desktop\bonding\frontend\assets\skyhavenassets\output"

os.makedirs(output_dir, exist_ok=True)

def remove_white_bg(img_path, out_path, tolerance=25):
    try:
        img = Image.open(img_path).convert("RGBA")
        data = np.array(img)
        
        # data is H x W x 4
        # We want to find where R, G, B are all >= 255 - tolerance
        white_mask = (data[..., 0] >= 255 - tolerance) & \
                     (data[..., 1] >= 255 - tolerance) & \
                     (data[..., 2] >= 255 - tolerance)
        
        # Set alpha to 0 for those pixels
        data[..., 3][white_mask] = 0
        
        img2 = Image.fromarray(data)
        img2.save(out_path, "PNG")
        print(f"Processed {os.path.basename(img_path)}")
    except Exception as e:
        print(f"Error processing {os.path.basename(img_path)}: {e}")

for filename in os.listdir(input_dir):
    if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
        img_path = os.path.join(input_dir, filename)
        out_path = os.path.join(output_dir, os.path.splitext(filename)[0] + ".png")
        remove_white_bg(img_path, out_path, tolerance=25)
        
print("Done!")
