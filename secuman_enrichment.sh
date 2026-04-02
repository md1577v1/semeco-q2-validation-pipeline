#!/bin/bash

python_path="kimeds_env/bin/python3.11"

attacker_profiles=""
vulnerability_levels=""
#likelihood_factors=""
impact_levels=""

#while getopts "A:V:L:I:" opt; do
while getopts "A:V:I:" opt; do
  case ${opt} in
    A)
      attacker_profiles=$OPTARG
      ;;
    V)
      vulnerability_levels=$OPTARG
      ;;
#    L)
#      likelihood_factors=$OPTARG
#      ;;
    I)
      impact_levels=$OPTARG
      ;;
    *)
#      echo "Usage: $0 -A N1 -V N2 -L N3 -I N4" >&2
      echo "Usage: $0 -A N1 -V N2 -I N3" >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

if [ -z "$attacker_profiles" ]; then
  echo "No attacker profile count given" >&2
  exit 1
fi

if [ -z "$vulnerability_levels" ]; then
  echo "No vulnerability level count given" >&2
  exit 1
fi

#if [ -z "$likelihood_factors" ]; then
#  echo "No likelihood factor count given" >&2
#  exit 1
#fi

if [ -z "$impact_levels" ]; then
  echo "No impact level count given" >&2
  exit 1
fi

input_triples=$(cat)

output="$($python_path secuman_enrichment.py \
  "$attacker_profiles" \
  "$vulnerability_levels" \
#  "$likelihood_factors" \
  "$impact_levels")"

echo -e "$input_triples\n\n$output"