#!/bin/sh

outDir="/home/pi/Desktop/out/"
truckname="hydraFL"
automateDir="/home/badr/Desktop/automateRBPtransfer/"

# change port and ip address if necessary

#####################################################
# Transfer MD5-copy from rbp

rsync -arvz -e 'ssh -p 65019' pi@76.70.196.62:${outDir}${truckname}_listRBPlog.* ${automateDir}.

#####################################################

listF=${automateDir}${truckname}_listRBPlog.MD5
IFS=''
while read line
do
    md5copy=$(echo "$line" | awk -F" " '{print $1}')
    pathF=$(echo "$line" | awk -F" " '{print $2}')
    curFname=$(echo "$pathF" | awk -F"/" '{print $NF}')

    # if log file does not exist on computer then download
    if [ ! -f ${automateDir}${curFname} ]; then
        # rsync
        rsync -arvz -e 'ssh -p 65019' pi@76.70.196.62:${outDir}${curFname} ${automateDir}.
    fi
    
    # generate the md5 of file - if file was transferred
    if [ -f ${automateDir}${curFname} ]; then
        md5V=$(md5sum ${automateDir}${curFname} | awk -F" " '{print $1}')
	# compare md5copy (raspberry pi) with md5 (computer) to see if transfer happened correctly
        if [ $md5copy != $md5V ]; then
            # make note of failed downloads
            echo ${automateDir}${curFname} >> ${automateDir}${truckname}_failedDownloads.txt
            rm ${automateDir}${curFname}
        else
            #echo "MD5 match: ${curFname}"
            echo ${automateDir}${curFname} >> ${automateDir}${truckname}_successfulDownloads.txt
        fi
    fi


done <$listF



