# One Pace To Plex 

## Purpose
The bash script (`one_pace_to_plex.sh`) facilitates the organization of downloaded anime episodes from the "One Pace" series into a Plex-compatible directory structure by creating hardlinks from the download directory to the Plex directory. It will still match as One Piece, but everything should be linked accordingly via episode ranges.

## Key Features

- **No installation necessary** and it works with different file extensions such as .mp4, .avi, .mkv, .flv, .mov and .wmv.

- **Customizable Configuration:** Users can easily customize various parameters such as the source directory containing the downloaded One Pace episodes, the destination directory within the Plex library, and the title of the show.
  
- **Automatic Linking:** The script automatically creates hardlinks for downloaded episodes in the Plex directory, ensuring that the files remain accessible from both locations without consuming additional disk space.
  
- **Interactive Menu:** If multiple files are found in the destination directory, the script prompts the user to choose from the following options:

    [1] Re-doing all hardlinks
  
    [2] Starting from the latest arc found
  
    [3] Quitting
  
- **Logging:** The script provides optional logging functionality, allowing users to track the success or failure of hardlink creation along with relevant details like file paths and error messages.

## Requirements

- Bash shell environment.
- Linux-like operating system. It might be possible via WSL on Windows.
- Proper configuration of variables according to user preferences.
- Proper permissions to read from the source directory and write to the destination directory.

## Usage

### Configuration
Users need to configure variables at the beginning of the script, such as the source directory (`one_pace_dir`), the destination directory within the Plex library (`dst_dir`), and other options like enabling/disabling logging (`log_enabled`) and specifying the log file path (`log_file`).

### Execution
After configuring the script, users can run it using a bash-compatible shell. Upon execution, the script traverses the source directory, identifies One Pace episodes, creates hardlinks in the Plex directory, and logs relevant information if logging is enabled. 

### Interaction
In case of multiple files in the destination directory, the script presents an interactive menu to the user, allowing them to choose the desired action before proceeding with hardlink creation.

## Name Formatting

- **One Pace Episodes:** The filenames follow a specific format indicating various details about the episode such as project name, manga chapter(s), arc, arc number and resolution.
  - Example: `[One Pace][1060-1061] Egghead 03 [1080p][979285FE].mkv`

- **Plex:** Plex does not have a standard format to support non-contiguous episodes in a single file. The format that Plex allows is this: s01e45-e49. That means that this will be the season 1 episode 45 to 49.  

- **Hardlinks:** The script generates hardlinks for the episodes following a specific naming convention. This convention includes details such as the show title, season, episode number, arc, resolution, and extension.All episodes are categorized within season 1, which Plex recognizes.
  - Example: `One Piece 1999 (One Pace) - s01e155-e156 [Skypiea] [1080p].mkv`

## Logging

The script logs each hardlink creation attempt, recording the source file path, destination file path, result of the hardlink creation (success or fail), and any additional messages or error messages. The logs are cleared each time you run the script, ensuring a fresh start for each execution and preventing them from occupying unnecessary disk space. This also allows for quick reference when needed.

- **Log Format:** `<datetime> src_file="<source file path>" dst_file="<destination file path>" result="<success or fail>" msg="<message or error message>"`
  - Example: `2024-05-30T21:47:00 src_file="/downloads/animes/tv/One_Pace/[One Pace][241-242] Skypiea 03 [1080p][A50167E6].mkv" dst_file="/media/animes/tv/One Piece 1999 (One Pace)/One Piece 1999 (One Pace) - s01e155-e156 [Skypiea] [1080p].mkv" result="success" msg="Hardlink created successfully."`

## Acknowledgements & Thanks

- [One Pace](https://onepace.net/)
- [One Piece Arcs Spreadsheet](https://docs.google.com/spreadsheets/d/1HQRMJgu_zArp-sLnvFMDzOyjdsht87eFLECxMK858lA/edit#gid=0)

Users can further customize the script by modifying the array of One Piece arcs, video extensions, and other parameters to suit their specific requirements.

**Disclaimer:** This script is provided as-is and users are advised to review and test it thoroughly before deploying it in production environments. It is intended for legal and ethical use only and does not promote or condone any illegal activities related to piracy or copyright infringement.
