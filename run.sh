#!/bin/bash


#for i in $(find . -name "20*"); do
#   cp -R cloudutils $i/
#   cd $i/cloudutils/genS3html
#   d=$(echo $i| sed "s/\.\///g")
#   ./genS3html.sh projectbismark.net us-east-2 "csv\/$d"
#   cd -
#   rm -Rf $i/cloudutils
#   aws s3 sync $d/ s3://projectbismark.net/csv/$d --acl public-read
#done

for i in all samples; do
   cp -R cloudutils $i/
   cd $i/cloudutils/genS3html
   d=$(echo $i| sed "s/\.\///g")
   echo $d
   ./genS3html.sh projectbismark.net us-east-2 "csv\/$d"
   cd -
   rm -Rf $i/cloudutils
   aws s3 sync $d/ s3://projectbismark.net/csv/$d --acl public-read
done


