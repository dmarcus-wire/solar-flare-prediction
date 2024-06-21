
import requests
from bs4 import BeautifulSoup
import os
import time
from tqdm import tqdm

# The base URL of the directory is specified.
base_url = 'https://nispdata.nso.edu/ftp/oQR/zqa/202402/'

# Ensure the data is defined
data = '../data/raw'  # Define your data path here

# Downloads a file from a given URL and saves it to a specified folder.
def download_file(url, dest_folder):
    if not os.path.exists(dest_folder):
        os.makedirs(dest_folder)
    file_name = url.split('/')[-1]
    file_path = os.path.join(dest_folder, file_name)

    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(file_path, 'wb') as f:
            for chunk in response.iter_content(1024):
                f.write(chunk)
        return True
    return False

# Finds all subfolders in the base URL that contain the target file (dim-860.jpg)
def find_folders_with_file(url, target_file):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    folders = []
    
    for link in soup.find_all('a'):
        href = link.get('href')
        if href.endswith('/'):
            folder_url = url + href
            folder_response = requests.get(folder_url)
            folder_soup = BeautifulSoup(folder_response.text, 'html.parser')
            if any(target_file in a.get('href') for a in folder_soup.find_all('a')):
                folders.append(folder_url)
    return folders

# Downloads only the files containing 'dim-860.jpg' from the identified folders into a single folder
def download_files_from_folders(folders, target_file, dest_folder):
    file_count = 0
    for folder in tqdm(folders, desc="Processing folders"):
        response = requests.get(folder)
        soup = BeautifulSoup(response.text, 'html.parser')
        for link in soup.find_all('a'):
            file_href = link.get('href')
            if target_file in file_href and not file_href.endswith('/'):
                file_url = folder + file_href
                if download_file(file_url, dest_folder):
                    file_count += 1
    return file_count

# Starts by specifying the target file and then finds the relevant folders. Finally, it downloads all the files from these folders into a single folder
if __name__ == '__main__':
    start_time = time.time()
    target_file = 'dim-860.jpg'
    folders = find_folders_with_file(base_url, target_file)
    file_count = download_files_from_folders(folders, target_file, data)
    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"Total files downloaded: {file_count}")
    print(f"Time taken: {elapsed_time:.2f} seconds")
