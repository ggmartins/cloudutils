#/bin/bash
#author: gmartins
#make sure you copy assets css js to the right place
#use s3cmd sync or s3cmd put --recursive for dirs
#use for i in $(ls *.csv); do tar cvzf $i.tgz $i; done to generate compressed files

cd ../../
index=index.html
wgets=wgets.sh
d=$(date '+%Y%m%d%H%M%S')
SCRIPT_NAME=$(basename "$0")
function usage() {
        echo $1
	echo "usage: $SCRIPT_NAME <s3bucketname> <s3bucketlocation> <path>"
	exit 1
}
if [ -z "$1" ]; then
	usage "ERROR: missing S3 bucket name"
fi
if [ -z "$2" ]; then
	usage "ERROR: missing S3 bucket location eg. (us-east-1, us-east-2)."
fi
if [ -z "$3" ]; then
	usage "ERROR missing path example, eg. \"csv\\/2019\""
fi
BUCKET_NAME=$1
BUCKET_LOCA=$2
BUCKET_PATH=$3
#BUCKET_LOCA=us-east-2 
if [ -f $index ];then
	echo "INFO: Backup index.html to $index.$d.backup"
	mv $index $index.$d.backup
	mv $wgets $wgets.$d.backup
fi
touch $index
echo "#!/bin/bash" > $wgets
filelist=$(find . -type f | grep -v genS3html | sort)
echo "INFO: Generating index.html header"
cat cloudutils/genS3html/genS3html.head.txt >> $index
for i in  $filelist; do
        if echo $i | grep -v index | grep -v cloudutils |grep -v wgets | grep -v css >/dev/null 2>&1; then	
	  size=$(du -sh $i | awk '{print $1}')
          href=$(echo $i | sed 's/\.\//http\:\/\/'$BUCKET_NAME'.s3-website.'$BUCKET_LOCA'.amazonaws.com\/'$BUCKET_PATH'\//g')
          name=$(echo $i | sed 's/\.\///g')
          echo "INFO: generating entry for $href"
	  echo "<a href=\"$href\">$name $size</a><br>" >> $index
	  echo -e "wget -c -nc $href" >> $wgets
        fi
done
echo "<a href=\"http://"$BUCKET_NAME".s3-website."$BUCKET_LOCA".amazonaws.com/"$wgets"\">DOWNLOAD via script: wget.sh</a><br>" >> $index
echo "INFO: Generating index.html footer"
cat cloudutils/genS3html/genS3html.tail.txt >> $index
echo "INFO: written files [$index] and [$wgets]"
