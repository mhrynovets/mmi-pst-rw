---
# Script Overview
This script handles the backup and writing DataPST.db in Audi MMI. 
It creates backups, writes new data when available, and verifies the process through logging.

**Credits to drger** (www.audizine.com, https://github.com/DrGER2/MMI3G-GEM-Enable)

Also used resouces from https://github.com/megusta1337/Copie_scr_Decoder/

---
## 1. Key Points of the Script
* **Backup and Write Operations**: The script backs up database files and dumps filesystem resources on each run. It can also write new database files if they are available.
* **Filesystem Dumps**: It dumps the contents of specific filesystem devices during each execution.
* **Logging**: Every action, as well as any errors, is logged in a timestamped log file for tracking purposes.
* **Safety Checks**: The script ensures that all directories are writable and all operations complete successfully.
---
## 2. Device Resources the Script Works With
The script processes the following resources on the device:
* **Database Files**:
  * `/mnt/efs-persist/DataPST.db`
  * `/HBpersistence/DataPST.db`
  * `/mnt/hmisql/DataPST.db`
* **Filesystem Resources**:
  * `/dev/fs0`
  * `/dev/fs1`
  * `/dev/fs4`

These files are copied to backup locations and can also be written to if necessary.
---
## 3. Directories the Script Works With
### Backup Directories:
* The script creates a timestamped backup directory for each run under:
  * `${SDPATH}/DB_dump/`
  The following files are copied to this directory:
  * **Database Dumps**:
    * `/mnt/efs-persist/DataPST.db`
    * `/HBpersistence/DataPST.db`
    * `/mnt/hmisql/DataPST.db`
  * **Filesystem Dumps**:
    * `/dev/fs0` → `fs0.dump`
    * `/dev/fs1` → `fs1.dump`
    * `/dev/fs4` → `fs4.dump`
### Files for Writing:
* **Source Directory for New Files**:
  * `$SDPATH/DB_write/` (contains new database files to be written)
* **Destination Paths** (where new data is written):
  * `$SDPATH/DB_write/efs-persist-DataPST.db` → `/mnt/efs-persist/DataPST.db`
  * `$SDPATH/DB_write/HBpersistence-DataPST.db` → `/HBpersistence/DataPST.db`
  * `$SDPATH/DB_write/hmisql-DataPST.db` → `/mnt/hmisql/DataPST.db`
---
## 4. How to Run the Script
### 1. **Required Utilities**
Before running the script, you need to download and install the following utilities from thematic forums or trusted sources:
* `DecodeScript`
* `hd`
* `pax`
* `reboot`
* `showScreen`
* `sysctl`

Make sure these utilities are available in your environment before proceeding.
### 2. **Prepare Files for Writing**
If you have new database files to write, place them in the following directory:
* `$SDPATH/DB_write/`
The script will look for the following files:
* `efs-persist-DataPST.db`
* `HBpersistence-DataPST.db`
* `hmisql-DataPST.db`
### 3. **Run the Script**
To run the script, copy all files with required binaries on a SD card, formatted in FAT32.
Then insert the SD card into MMI and follow instructions.

---
## Notes:
* Ensure the script has appropriate permissions to read, write, and modify files in the specified directories.
* Logs are created for every operation and error, which helps in troubleshooting and tracking.
---
