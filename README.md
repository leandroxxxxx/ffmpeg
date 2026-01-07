***

# FFmpeg Media Toolkit

A collection of powerful, user-friendly Windows Batch scripts designed to automate complex **FFmpeg** operations. This toolkit simplifies tasks such as frame extraction, format conversion, and media manipulation without the need to manually type long commands.

## 📋 Prerequisites

To run these scripts, ensure you have the following installed on your Windows system:

1.  **FFmpeg**: Must be installed and added to your system's **PATH**.
    *   To check, open CMD and type: `ffmpeg -version`
2.  **PowerShell**: (Built-in on Windows 10/11) Used by the scripts for high-precision mathematical calculations.

## 🚀 Installation

1.  Download or clone this repository.
2.  Place the `.bat` files in a folder of your choice.
3.  Run any script by double-clicking it or dragging a video file onto it.

---
## 📄 License
This project is open-source. Feel free to modify and distribute.

## 🤝 Contributing
Suggestions and improvements are welcome! Feel free to open an issue or submit a pull request.

---
*Developed with the power of FFmpeg and Batch Scripting.*

---

## Script Extract-frames

This specific script is designed for users who need to extract frames with scientific or editing precision. Unlike standard extraction, this tool labels every image with its **absolute frame number** and its **exact timestamp** in the video timeline.

### Key Features
*   **Automatic FPS Detection**: Uses `ffprobe` to detect the source video's frame rate automatically.
*   **Absolute Numbering**: Frames are numbered based on their real position in the video (e.g., if you start at 10s on a 30fps video, the first frame is #300).
*   **High-Precision Timestamps**: Every filename includes the time in seconds with **3 decimal places** (milliseconds).
*   **Smart Output**: Automatically creates an output folder in the **same directory as the source video**.
*   **Custom Naming**: Option to use the original video name or a custom prefix for the frames.

### How It Works
The script follows a two-step process:
1.  **Extraction**: FFmpeg extracts the frames from the specified time range using Variable Frame Rate (`-vsync vfr`) to ensure no frames are skipped or duplicated.
2.  **Renaming**: A PowerShell routine calculates the exact time for each frame using the formula:  
    `Timestamp = Frame Number / FPS`

### Filename Format
The resulting files will be named as follows:
`[BaseName]_[Timestamp]s_[FrameNumber].jpg`

**Example:**
If you extract a video named `ActionShot.mp4`, the frames will look like:
*   `ActionShot_1.125s_34.jpg`
*   `ActionShot_1.158s_35.jpg`
*   `ActionShot_1.192s_36.jpg`

### Usage
1.  Run the script.
2.  Drag and drop your video file into the window.
3.  Enter the **Start Time** and **End Time** (supports `SS` or `HH:MM:SS` formats).
4.  Choose whether to rename the files or keep the video's original name.
5.  Find your frames in the new folder created next to your video.

---
Here is the **English version** of the README section for the **Multi Trim Merge** script, fully aligned with the existing style of your document:

---

## Script Multi Trim Merge

This script is designed to **cut multiple segments from a single video and merge them into one final file**, using stream copy to preserve the original quality and ensure fast processing.

It is ideal for removing unwanted sections, selecting only specific moments, or assembling a continuous video from multiple time intervals.

### Key Features

* **Multiple Interactive Trims**: Define as many trim segments as needed in a single run.
* **Stream Copy (`-c copy`)**: No re-encoding — fast execution with no quality loss.
* **Automatic Concatenation**: Automatically creates the file list and performs the final merge.
* **Guided Workflow**: Step-by-step prompts for start and end times of each segment.
* **Automatic Cleanup**: Removes all temporary files after completion.

### How It Works

The script follows a three-step process:

1. **Trim Collection**
   The user repeatedly enters the start and end timestamps (`HH:MM:SS`) for each desired segment.

2. **Segment Extraction**
   Each interval is trimmed individually using:

   ```
   ffmpeg -ss [start] -to [end] -c copy
   ```

   Temporary files are created (`part1.mp4`, `part2.mp4`, etc.).

3. **Final Merge**
   All segments are concatenated using FFmpeg’s `concat` demuxer, producing a single final output file.

### Usage

1. Run the script.
2. Type or drag and drop the video file into the window.
3. Enter the **start** and **end** times for each trim.
4. Choose whether to add another trim.
5. Enter the final output file name.
6. The merged video will be created in the script directory.

### Notes

* All trimmed segments must share the **same codec, resolution, and encoding parameters** (required for `-c copy`).
* For frame-accurate cuts, re-encoding may be necessary (not implemented in this script).
* Supported time format: `HH:MM:SS`.