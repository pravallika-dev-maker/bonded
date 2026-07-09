import os
import sys
from pathlib import Path
from PIL import Image
from rembg import remove, new_session

def main():
    # Define paths based on the script's location
    script_dir = Path(__file__).parent.resolve()
    input_dir = script_dir / "input"
    output_dir = script_dir / "output"

    # Create input and output directories if they do not exist
    input_dir.mkdir(parents=True, exist_ok=True)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Supported image extensions (case-insensitive check later)
    supported_extensions = {".png", ".jpg", ".jpeg"}

    # Safely get all files from the input folder
    try:
        files = [f for f in input_dir.iterdir() if f.is_file()]
    except Exception as e:
        print(f"Error accessing input directory: {e}")
        return

    # Filter out unsupported file types
    image_files = [f for f in files if f.suffix.lower() in supported_extensions]

    if not image_files:
        print(f"No supported image files {supported_extensions} found in:")
        print(f"  {input_dir}")
        print("Please place your images in the 'input' folder and run the script again.")
        return

    print(f"Found {len(image_files)} image(s) to process.")
    print("Initializing rembg session with 'u2net' model...")
    
    # Initialize the session with the high-quality 'u2net' model.
    # This model is well-suited for general use and high quality.
    try:
        session = new_session("u2net")
    except Exception as e:
        print(f"Failed to initialize rembg session. Error: {e}")
        return

    # Process each image in the input directory
    for index, image_path in enumerate(image_files, start=1):
        # We save all outputs as .png to ensure alpha transparency is preserved
        output_path = output_dir / f"{image_path.stem}.png"
        
        print(f"[{index}/{len(image_files)}] Processing: {image_path.name} ... ", end="")
        sys.stdout.flush() # Ensure the progress text prints before processing starts

        try:
            # Open the image
            with Image.open(image_path) as img:
                # Remove the background using the loaded model.
                # We enable alpha_matting to preserve thin details like leaves, 
                # flowers, branches, and hair.
                result_img = remove(
                    img, 
                    session=session,
                    alpha_matting=True,
                    alpha_matting_foreground_threshold=240,
                    alpha_matting_background_threshold=10,
                    alpha_matting_erode_size=10
                )
                
                # Save as PNG without compression to preserve maximum quality.
                # Original dimensions are automatically retained by rembg.
                result_img.save(output_path, format="PNG", optimize=False)
                
            print("Done")
        except Exception as e:
            # Handle exception for a single file so others can continue
            print(f"Failed! Error: {e}")
            
    print("\nAll assets processed successfully!")
    print(f"Processed images are located in: {output_dir}")

if __name__ == "__main__":
    main()
