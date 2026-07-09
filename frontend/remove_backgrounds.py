import os
import glob
from rembg import remove

def process_images():
    island_dir = os.path.join(os.getcwd(), 'assets', 'island')
    files = glob.glob(os.path.join(island_dir, "*.png"))
    total = len(files)
    
    print(f"Found {total} PNGs to process in {island_dir}")
    for idx, file in enumerate(files):
        print(f"[{idx+1}/{total}] Processing {os.path.basename(file)}...")
        try:
            with open(file, "rb") as i:
                input_data = i.read()
                
            output_data = remove(input_data)
            
            with open(file, "wb") as o:
                o.write(output_data)
        except Exception as e:
            print(f"Error on {file}: {e}")
            
    print("Background removal complete!")

if __name__ == "__main__":
    process_images()
