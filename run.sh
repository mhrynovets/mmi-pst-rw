#!/bin/ksh

# v.4
#   - added counter to fix the chain
#   - refactored directory management
#	- added writting multiple files
#   - making dumps of FS0, FS1, FS4
#   - added better logging
#   - added safety checks

# Script startup env from copie_scr.sh by drger
if [ "$1" != "" ]; then
    showScreen ${SDLIB}/scriptStart.png
fi

cd ${SDPATH} || exit
touch .started
rm -f .done


if [ -s counter.txt ]; then
	cat counter.txt
else 
	echo 0 > counter.txt
fi

typeset -Z5 R=`cat counter.txt`
R=$((R+1))
echo $R > counter.txt


df="+%Y%m%d_%H%M%S_%3N"
runstamp=`date $df`
uniqident=$R-$runstamp
xlogfile=run-$R-$runstamp.log
touch "${xlogfile}" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "${uniqident} > Log file not accessible, exit script" >> E_R_R_O_R.txt
    exit 1
fi
exec > "${xlogfile}" 2>&1


echo "[INFO] Start: $R; Timestamp: $runstamp; Train: $SWTRAIN"
echo "[INFO] Dump MMI DataPST.db"
echo "[DEBUG] Using card $SDPATH"

storePath=$SDPATH/DB_dump/${R}-${runstamp}
echo "[INFO] Prepare path fot the dump - $storePath"
mkdir -p "$storePath" && touch "$storePath/.test" && rm "$storePath/.test" || {
    echo "${uniqident} > Cannot create/write to $storePath" >> E_R_R_O_R.txt
    exit 1
}
mkdir -p "$storePath/dump"


echo "[INFO] Copy the dump"
cp -v /mnt/efs-persist/DataPST.db "$storePath/dump/efs-persist-DataPST.db" || {
    echo "${uniqident} > Failed to copy efs-persist dump" >> E_R_R_O_R.txt
    exit 1
}
cp -v /HBpersistence/DataPST.db "$storePath/dump/HBpersistence-DataPST.db" || {
    echo "${uniqident} > Failed to copy HBpersistence dump" >> E_R_R_O_R.txt
    exit 1
}
cp -v /mnt/hmisql/DataPST.db "$storePath/dump/hmisql-DataPST.db" || {
    echo "${uniqident} > Failed to copy hmisql dump" >> E_R_R_O_R.txt
    exit 1
}
cat /dev/fs0 > $storePath/dump/fs0.dump
cat /dev/fs1 > $storePath/dump/fs1.dump
cat /dev/fs4 > $storePath/dump/fs4.dump
echo "[INFO] Copy the dump - done"


if [ -s "$SDPATH/DB_write/efs-persist-DataPST.db" ]; then
    echo "[INFO] Encountered $SDPATH/DB_write/efs-persist-DataPST.db to write into MMI"

    echo "[DEBUG] Remount /mnt/efs-persist in writeable mode"
    mount -uw /mnt/efs-persist 
    true || {
        echo "${uniqident} > Failed to remount /mnt/efs-persist writable" >> E_R_R_O_R.txt
        exit 1
    }

    echo "[DEBUG] Write efs-persist-DataPST.db into MMI"
    cp -v "$SDPATH/DB_write/efs-persist-DataPST.db" /mnt/efs-persist/DataPST.db

    echo "[DEBUG] Move efs-persist-DataPST.db to $storePath/written/efs-persist-DataPST.db"
    mkdir -p "$storePath/written"
    mv -v "$SDPATH/DB_write/efs-persist-DataPST.db" "$storePath/written/efs-persist-DataPST.db"
	echo "efs-persist-DataPST.db" >> .written
    echo "[INFO] File ./DB_write/efs-persist-DataPST.db found to write - done"
fi

if [ -s "$SDPATH/DB_write/HBpersistence-DataPST.db" ]; then
    echo "[INFO] Encountered $SDPATH/DB_write/HBpersistence-DataPST.db to write into MMI"

    echo "[DEBUG] Write HBpersistence-DataPST.db into MMI"
    cp -v "$SDPATH/DB_write/HBpersistence-DataPST.db" /HBpersistence/DataPST.db

    echo "[DEBUG] Move HBpersistence-DataPST.db to $storePath/written/HBpersistence-DataPST.db"
    mkdir -p "$storePath/written"
    mv -v "$SDPATH/DB_write/HBpersistence-DataPST.db" "$storePath/written/HBpersistence-DataPST.db"
	echo "HBpersistence-DataPST.db" >> .written
    echo "[INFO] File ./DB_write/HBpersistence-DataPST.db found to write - done"
fi

if [ -s "$SDPATH/DB_write/hmisql-DataPST.db" ]; then
    echo "[INFO] Encountered $SDPATH/DB_write/hmisql-DataPST.db to write into MMI"

    echo "[DEBUG] Write hmisql-DataPST.db into MMI"
    cp -v "$SDPATH/DB_write/hmisql-DataPST.db" /mnt/hmisql/DataPST.db

    echo "[DEBUG] Move hmisql-DataPST.db to $storePath/written/hmisql-DataPST.db"
    mkdir -p "$storePath/written"
    mv -v "$SDPATH/DB_write/hmisql-DataPST.db" "$storePath/written/hmisql-DataPST.db"
	echo "hmisql-DataPST.db" >> .written
    echo "[INFO] File ./DB_write/hmisql-DataPST.db found to write - done"
fi

if [ -s .written ]; then

	echo "[INFO] Make an additional attempt to read DataPST.db from MMI after writing"
	echo "[INFO] Copy the dump"
    mkdir -p "$storePath/verify"
	cp -v /mnt/efs-persist/DataPST.db "$storePath/verify/efs-persist-DataPST.db"
	cp -v /HBpersistence/DataPST.db "$storePath/verify/HBpersistence-DataPST.db"
	cp -v /mnt/hmisql/DataPST.db "$storePath/verify/hmisql-DataPST.db"
	echo "[INFO] Copy the dump - done"

else 
    echo "[INFO] No files found to write into MMI, skipping"
fi


touch .done
rm -f .started
rm -f .written
echo "[INFO] End: $(date $df); Train: $SWTRAIN"

if [ "$1" != "" ]; then
    showScreen ${SDLIB}/scriptDone.png
fi
