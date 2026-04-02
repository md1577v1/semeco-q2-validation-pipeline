#!/bin/bash

#
html="input/submission.html"
abox="input/abox.ttl"
ontology="input/ontology.ttl"
shapes="input/shapes.ttl"
#

mode="html" # html or abox, default html
enrichment="plain" # plain, riskman, secuman, default plain

# RiskMan parameters
prob=""
sev=""

#Secuman parameters (attacker profile, vulnerability level, impact level)
ap=""
vl=""
il=""

while getopts "m:e:p:s:A:V:I:" opt; do
    case "$opt" in
        m) mode="$OPTARG" ;;
        e) enrichment="$OPTARG" ;;
        p) prob="$OPTARG" ;;
        s) sev="$OPTARG" ;;
        A) ap="$OPTARG" ;;
        V) vl="$OPTARG" ;;
        I) il="$OPTARG" ;;
        *)
            echo "Usage: $0 -m [html|abox] -e [plain|riskman|secuman] [-p prob] [-s sev] [-A ap] [-V vl] [-I il]" >&2
            exit 1
            ;;
    esac
done


#(?)
# Shift off the options and optional --
shift $((OPTIND-1))


run_enrichment() {
    case "$enrichment" in
        plain)
            cat
            ;;
        riskman)
            if [ -z "$prob" ] || [ -z "$sev" ]; then
                echo "RiskMan enrichment requires -p and -s" >&2
                exit 1
            fi
            ./prob_sev.sh -p "$prob" -s "$sev"
            ;;
        secuman)
            if [ -z "$ap" ] || [ -z "$vl" ] || [ -z "$il" ]; then
                echo "SecuMan enrichment requires -A, -V, and -I" >&2
                exit 1
            fi
            ./secuman_enrichment.sh -A "$ap" -V "$vl" -I "$il"
            ;;
        *)
            echo "Unknown enrichment: $enrichment" >&2
            echo "Usage: $0 -m [html|abox] -e [plain|riskman|secuman] [-p prob] [-s sev] [-A ap] [-V vl] [-I il]" >&2
            exit 1
            ;;
    esac
}


# option 1 
# HTML file with RDF encoding
modeHtml() {
    cat "$html" | ./rdf_distiller.sh | cat - "$ontology" | run_enrichment | ./reasoner.sh | ./validator.sh "$shapes"
}


# option 2
# directly providing ABox 
modeAbox() {
     cat "$abox" "$ontology" | run_enrichment | ./reasoner.sh | ./validator.sh "$shapes"
}

if [ "$mode" == "html" ]; then
    modeHtml
elif [ "$mode" == "abox" ]; then
    modeAbox
else
    echo "Unknown mode: $mode" >&2
    echo "Usage: $0 -m [html|abox] -e [plain|riskman|secuman] [-p prob] [-s sev] [-A ap] [-V vl] [-I il]" >&2
    exit 1
fi





