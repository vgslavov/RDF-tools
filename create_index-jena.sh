#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Usage: $0 [list file]|[nt dir] [idx dir] [log dir] (loader: 1, 2, 3)"
    exit 1;
fi

SRC=$1
OUTPUTDIR=$2
LOGDIR=$3
VERSION=$4
JENADIR="/home/vsfgd/Jena/apache-jena-2.11.1/bin"
TIME="/usr/bin/time -v"

# use tdbloader2 (fastest) by default
if [ $# -eq 3 ]; then
    $VERSION = 2
fi

if [ $VERSION = 1 ]; then
    LOADER=$JENADIR/tdbloader
elif [ $VERSION = 2 ]; then
    LOADER=$JENADIR/tdbloader2
elif [ $VERSION = 3 ]; then
    LOADER=$JENADIR/tdbloader3
else
    echo "invalid version"
    exit 1;
fi

if [[ -d ${SRC} ]]; then
    NFILES=`ls $SRC | wc -l`
    n=0
    for i in `ls $SRC`; do
        n=`expr $n + 1`
        outfile=`basename $i .nt`
        echo "$outfile ($n/$NFILES)"
        mkdir $OUTPUTDIR/$outfile
        $TIME -o $LOGDIR/time-$outfile.log $LOADER --loc=$OUTPUTDIR/$outfile $SRC/$i &> $LOGDIR/$outfile.log
    done
elif [[ -f ${SRC} ]]; then
    NFILES=`wc -l $SRC | awk '{print $1}'`
    n=0
    while read line; do
        n=`expr $n + 1`
        outfile=`basename $line .nt`
        echo "$line: ($n/$NFILES)"
        mkdir $OUTPUTDIR/$outfile
        $TIME -o $LOGDIR/time-$outfile.log $LOADER --loc=$OUTPUTDIR/$outfile $line &> $LOGDIR/$outfile.log
    done < "$SRC"
else
    echo "invalid input"
fi

echo "# of files processed: $n"
