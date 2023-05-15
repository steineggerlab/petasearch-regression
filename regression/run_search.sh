#!/bin/sh -ex
QUERY="${DATADIR}/scop.fasta"
TARGET="${DATADIR}/scop.fasta"
SCOPANOTATION="${DATADIR}/scop_lookup_bench.tsv"

QUERYDB="${RESULTS}/query"
"${PETASEARCH}" createdb "${QUERY}" "${QUERYDB}"

"${PETASEARCH}" convert2sradb "${QUERYDB}" "$RESULTS/target_sra"
"${PETASEARCH}" createkmertable "$RESULTS/target_sra" "$RESULTS/target_kmer"
printf "%s\t%s\n" "$RESULTS/target_kmer" "$RESULTS/target_sra" > "$RESULTS/targetdbs"
printf "%s\n" "$RESULTS/res" > "$RESULTS/resultlist"

"${PETASEARCH}" petasearch "${QUERYDB}" "$RESULTS/targetdbs" "$RESULTS/resultlist" "$RESULTS/results_aln.m8" "$RESULTS/tmp"

"${EVALUATE}" "$SCOPANOTATION" "$RESULTS/results_aln.m8" > "${RESULTS}/evaluation.log"

ACTUAL=$(awk '{ famsum+=$3; supfamsum+=$4; foldsum+=$5}END{print famsum/NR,supfamsum/NR,foldsum/NR}' "${RESULTS}/evaluation.log")
TARGET="0.986667 0.77101 0.435409"
awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual >= target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"
