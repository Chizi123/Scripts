#!/bin/bash

function test-comp() {
	#compress file
	$1 -$2 -c test.tar > "test.$2.$3" 2>/dev/null
	#write file size to temp file for csv formation
	printf "$(wc -c test.$2.$3 | awk '{print $1}')\n" >> $3
	#remove file
	rm -f "test.$2.$3"
}

function test-bzip2() {
	rm -f "bz2"
	for i in {1..9}; do
		test-comp bzip2 $i "bz2"
	done
}

function test-gzip() {
	rm -f "gz"
	for i in {1..9}; do
		test-comp gzip $i "gz"
	done
}

function test-lz4() {
	rm -f "lz4"
	for i in {1..12}; do
		test-comp lz4 $i "lz4"
	done
}

function test-xz() {
	rm -f "xz"
	for i in {1..9}; do
		test-comp xz $i "xz"
	done
}

function test-xz-e() {
	rm -f "xze"
	for i in {1..9}; do
		test-comp "xz -e" $i "xze"
	done
}

function test-lzma() {
	rm -f "lzma"
	for i in {1..9}; do
		test-comp lzma $i "lzma"
	done
}

function test-lzma-e() {
	rm -f "lzmae"
	for i in {1..9}; do
		test-comp "lzma -e" $i "lzmae"
	done
}

function test-zstd() {
	rm -f "zst"
	for i in {1..19}; do
		test-comp zstd $i "zst"
	done
	for i in {20..22}; do
		test-comp "zstd --ultra" $i "zst"
	done
}

if [ -z $1 ]; then
	echo "Usage: $0 FILES"
	exit
fi

# create a tar file to deal with directories
tar -cf test.tar "$@"

# run tests with all algorithms/programs
rm -f results.csv
ALGS=(bzip2 gzip lz4 xz xz-e lzma lzma-e zstd)
for i in ${ALGS[*]}; do
	test-$i
done
rm -f test.tar

# create csv with vertical columns
ALG_RES=`find . -maxdepth 1 -not -name '*.*' -type f`
printf "level" >> results.csv
for i in ${ALG_RES[*]}; do
	printf ",%s" $(echo $i | sed 's/\.\///') >> results.csv
done
printf "\n" >> results.csv

for i in {1..22}; do
	printf "$i" >> results.csv
	for j in $ALG_RES; do
		k=1;
		FOUND=0;
		while read LINE; do
			if [ $k == $i ]; then
				printf ",$LINE" >> results.csv
				FOUND=1
				break
			fi
			k=$((k+1))
		done < $j
		[ $FOUND == 0 ] && printf "," >> results.csv
	done
	printf "\n" >> results.csv
done
for i in ${ALG_RES[*]}; do
	rm -f $i
done

# generate plot using gnuplot
read -p "Generate plot? Y/n " PLOT
if [[ -z $PLOT || $PLOT == "y" || $PLOT == "Y" ]]; then
	gnuplot -e "set datafile separator \",\"; \
			    set term png; \
				set output 'results.png'; \
				plot for [col=2:$((${#ALGS[@]}+1))] 'results.csv' using 1:col with lines title columnheader"
fi
