import os
import tarfile
import requests
import subprocess
from pathlib import Path

# Modify this to the path of your URL list file
URL_LIST_FILE = 'matrix_urls.txt'

# Directory where everything will be downloaded and extracted
WORK_DIR = Path('./mtx')
WORK_DIR.mkdir(exist_ok=True)

# Example: replace this with your actual command
def run_command_on_mtx(mtx_path: Path):
    print(f"Running command on: {mtx_path}")
    # Example command: wc -l
    result = subprocess.run(["wc", "-l", str(mtx_path)], capture_output=True, text=True)
    print(result.stdout)

def download_and_process(url: str):
    filename = url.strip().split('/')[-1]
    archive_path = WORK_DIR / filename
    extract_dir = WORK_DIR / filename.replace('.tar.gz', '')

    if archive_path.exists():
        print(f"Already downloaded: {archive_path}")
    else:
        print(f"Downloading: {url}")
        response = requests.get(url)
        response.raise_for_status()
        with open(archive_path, 'wb') as f:
            f.write(response.content)

    if not extract_dir.exists():
        print(f"Extracting: {archive_path}")
        with tarfile.open(archive_path, "r:gz") as tar:
            tar.extractall(path=extract_dir)
    else:
        print(f"Already extracted: {extract_dir}")

    # Search for .mtx file
    mtx_files = list(extract_dir.rglob("*.mtx"))
    if not mtx_files:
        print(f"No .mtx file found in {extract_dir}")
    else:
        for mtx_path in mtx_files:
            run_command_on_mtx(mtx_path)

def main():
    with open(URL_LIST_FILE, 'r') as file:
        urls = [line.strip() for line in file if line.strip() and not line.startswith("#")]

    for url in urls:
        try:
            download_and_process(url)
        except Exception as e:
            print(f"Error processing {url}: {e}")

if __name__ == "__main__":
    main()

