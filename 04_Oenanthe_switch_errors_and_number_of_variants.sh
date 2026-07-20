#!/bin/bash

cd /cluster/scratch/ldutoi/Oenanthe_switch_errors/phasing

OUT="combined_summary_all_groups.tsv"
printf "group\tsample\tphased_count\tground_truth_count\tswitch_error_rate_ALL_intersec\tswitch_error_rate_Largest_intersec\n" > "$OUT"

for GROUPDIR in */; do
  PREFIX=$(basename "$GROUPDIR")

  # skip if this dir has no phased files (e.g. stray/empty folders)
  shopt -s nullglob
  phased_files=("$GROUPDIR"*.phased.vcf.gz)
  shopt -u nullglob
  if [[ ${#phased_files[@]} -eq 0 ]]; then
    echo "Skipping $PREFIX (no phased files found)"
    continue
  fi

  cd "$GROUPDIR"

  # per-group counts table
  COUNTS_TSV="counts_table.tsv"
  printf "%-30s\t%12s\t%12s\n" "sample" "phased_count" "ground_truth_count" > "$COUNTS_TSV"

  for f in *.phased.vcf.gz; do
    sample=$(basename "$f" .phased.vcf.gz)
    gt_file="${sample}.ground_truth.vcf.gz"

    phased_n=$(zcat "$f"| grep -v "^#" | grep -c "|" )

    if [[ -f "$gt_file" ]]; then
      gt_n=$(zcat "$gt_file" | grep -v "^#" | grep -c "|" )
    else
      gt_n="NA"
    fi

    printf "%-30s\t%12s\t%12s\n" "$sample" "$phased_n" "$gt_n" >> "$COUNTS_TSV"
  done

  # combine switch error rates for this group's samples
  for f in ${PREFIX}.*.switch_errors.txt; do
    [[ -e "$f" ]] || continue
    sample=$(basename "$f" | sed -E "s/^${PREFIX}\.(.*)\.switch_errors\.txt\$/\1/")

    rates=($(grep "switch error rate" "$f" | sed -E 's/.*switch error rate:\s*([0-9.]+)%.*/\1/'))
    rate1="${rates[0]:-NA}"
    rate2="${rates[1]:-NA}"

    counts_line=$(awk -v s="$sample" '$1==s {print $2"\t"$3}' "$COUNTS_TSV")

    if [[ -z "$counts_line" ]]; then
      phased="NA"; gt="NA"
    else
      phased=$(echo "$counts_line" | cut -f1)
      gt=$(echo "$counts_line" | cut -f2)
    fi

    printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$PREFIX" "$sample" "$phased" "$gt" "$rate1" "$rate2" >> "../$OUT"
  done

  cd ..
done

column -t "$OUT"
cp "$OUT" ~/git/Oenanthe_switch_errors/