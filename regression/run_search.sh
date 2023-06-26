#!/bin/sh -ex
QUERY="${DATADIR}/query.fasta"
TARGET="${DATADIR}/targetannotation.fasta"

QUERYDB="${RESULTS}/query"
"${PETASEARCH}" createdb "${QUERY}" "${QUERYDB}" --shuffle 0

TARGETDB="${RESULTS}/targetannotation"
"${PETASEARCH}" createdb "${TARGET}" "$RESULTS/target_sra_split_0_1"

SPLITS=1
# "${PETASEARCH}" createdb "${TARGET}" "${TARGETDB}"
# "${PETASEARCH}" splitdb "${TARGETDB}" "$RESULTS/target_sra_split" --split "${SPLITS}"


: > "$RESULTS/targetdbs"
: > "$RESULTS/resultlist"
for ((i=0; i<${SPLITS}; i++)); do
    "${PETASEARCH}" convert2sradb "$RESULTS/target_sra_split_${i}_${SPLITS}" "$RESULTS/target_sra_${i}_${SPLITS}"
    "${PETASEARCH}" createkmertable "$RESULTS/target_sra_${i}_${SPLITS}" "$RESULTS/target_kmer_${i}_${SPLITS}" -k 6 --spaced-kmer-mode 0 --seed-sub-mat PAM30.out
    printf "%s\t%s\n" "$RESULTS/target_kmer_${i}_${SPLITS}" "$RESULTS/target_sra_${i}_${SPLITS}" >> "$RESULTS/targetdbs"
    printf "%s\n" "$RESULTS/res_${i}_${SPLITS}" >> "$RESULTS/resultlist"
done

"${PETASEARCH}" petasearch "${QUERYDB}" "$RESULTS/targetdbs" "$RESULTS/resultlist" "$RESULTS/results_aln.m8" "$RESULTS/tmp" --comp-bias-corr 1 -e inf --mask 1 --k-score 0 --max-kmer-per-pos 20 -k 6 --spaced-kmer-mode 0 --exact-kmer-matching 0 --seed-sub-mat PAM30.out --req-kmer-matches 1
sort -k1,1 -k11,11g "$RESULTS/results_aln.m8" > "$RESULTS/results_aln_sorted.m8"

"${EVALUATE}" "$QUERY" "$TARGET" "$RESULTS/results_aln_sorted.m8" "${RESULTS}/evaluation_roc5.dat" 4000 1 > "${RESULTS}/evaluation.log"
ACTUAL=$(grep "^ROC5 AUC:" "${RESULTS}/evaluation.log" | cut -d" " -f3)
TARGET="0.124292"
awk -v actual="$ACTUAL" -v target="$TARGET" \
    'BEGIN { print (actual >= target) ? "GOOD" : "BAD"; print "Expected: ", target; print "Actual: ", actual; }' \
    > "${RESULTS}.report"
