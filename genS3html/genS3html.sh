#/bin/bash
#author: gmartins
#make sure you copy assets css js to the right place
#use s3cmd sync or s3cmd put --recursive for dirs

cd ../../
index=index.html
wgets=wgets.sh
d=$(date '+%Y%m%d%H%M%S')
SCRIPT_NAME=$(basename "$0")
if [ -z "$1" ]; then
	echo "usage: $SCRIPT_NAME <s3bucketname> <s3bucketlocation>"
	exit 1
fi
if [ -z "$2" ]; then
	echo "usage: $SCRIPT_NAME <s3bucketname> <s3bucketlocation>"
	exit 1
fi
BUCKET_NAME=$1
BUCKET_LOCA=$2
#BUCKET_LOCA=us-east-2 
if [ -f $index ];then
	echo "INFO: Backup index.html to $index.$d.backup"
	mv $index $index.$d.backup
	mv $wgets $wgets.$d.backup
fi
touch $index
echo "#!/bin/bash" > $wgets
filelist=$(find . -type f | grep -v genS3html)
echo "INFO: Generating index.html header"
cat cloudutils/genS3html/genS3html.head.txt >> $index
for i in  $filelist; do
        if echo $i | grep -v index | grep -v cloudutils |grep -v wgets | grep -v css >/dev/null 2>&1; then	
	  size=$(du -sh $i | awk '{print $1}')
          href=$(echo $i | sed 's/\.\//http\:\/\/'$BUCKET_NAME'.s3-website.'$BUCKET_LOCA'.amazonaws.com\//g')
          name=$(echo $i | sed 's/\.\///g')
          echo "INFO: generating entry for $href"
	  echo "<a href=\"$href\">$name $size</a><br>" >> $index
	  echo -e "wget -c -nc $href" >> $wgets
        fi
done
echo "<a href=\"http://"$BUCKET_NAME".s3-website."$BUCKET_LOCA".amazonaws.com/"$wgets"\">WGET DOWNLOAD: wget.sh</a><br>" >> $index
echo "INFO: Generating index.html footer"
cat cloudutils/genS3html/genS3html.tail.txt >> $index
echo "INFO: written files [$index] and [$wgets]"
