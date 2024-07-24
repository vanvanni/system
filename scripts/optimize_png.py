'''
Script: Optimize PNG
Description: Optimize and replace all png files in folder
Dependency: pngquant
Usage:
    - change 'folder_path' to your wanted folder
    - nohup python3 optimize_png.py > /dev/null 2>&1 &
    - watch -n 1 'cat optimize_png.log'
'''

import os
import subprocess

# Define the folder_path and maybe tweak quality
folder_path = 'optimized_uploads'
quality = '80-100'
log_file = 'optimize_png.log'

def count_files(folder_path, extension):
    result = subprocess.run(['find', folder_path, '-type', 'f', '-name', f'*.{extension}'], stdout=subprocess.PIPE)
    files = result.stdout.decode('utf-8').splitlines()
    return len(files)

def file_size(file_path):
    return os.path.getsize(file_path) / 1024

def file_compress(folder_path, quality, log_file):
    total_files = count_files(folder_path, 'png')
    
    if total_files == 0:
        print("No files to compress.")
        exit(1)

    processed_files = 0

    with open(log_file, 'w') as log:
        result = subprocess.run(['find', folder_path, '-type', 'f', '-name', '*.png'], stdout=subprocess.PIPE)
        files = result.stdout.decode('utf-8').splitlines()
        
        for file in files:
            subprocess.run(['pngquant', f'--quality={quality}', '--ext', '.png', '--force', file])
            file_size_kb = file_size(file)
            
            processed_files += 1

            log.seek(0)
            log.write(f'\rProcessed {processed_files}/{total_files} files - Last saved: {file_size_kb:.2f} KB')
            log.truncate()
            log.flush()
            
            print(f'\rProcessed {processed_files}/{total_files} files - Last saved: {file_size_kb:.2f} KB', end='')

if __name__ == '__main__':
    file_compress(folder_path, quality, log_file)