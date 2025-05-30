import os
import re
import argparse

def pad_filenames(directory, pad_length=3):
    files = os.listdir(directory)
    
    for filename in files:
        match = re.match(r'^([a-zA-Z]+)(\d+)\.png$', filename)


        if match:
            prefix = match.group(1)
            number = match.group(2)
            
            padded_number = number.zfill(pad_length)
            new_filename = f"{prefix}{padded_number}.png"
            
            # Rename the file
            if filename != new_filename:  # Avoid unnecessary rename operations
                old_path = os.path.join(directory, filename)
                new_path = os.path.join(directory, new_filename)
                print(f"Renaming: {filename} -> {new_filename}")
                os.rename(old_path, new_path)



# parser = argparse.ArgumentParser(description='Pads numbers in all image files in a folder to make it appropriate for video creation ')
# parser.add_argument('-p', dest='padding', action='store_const',
#                     const=True, default=False, help='show longer version of the output')
# args = parser.parse_args()


if __name__ == "__main__":
    current_directory = os.getcwd()
    pad_filenames(current_directory)