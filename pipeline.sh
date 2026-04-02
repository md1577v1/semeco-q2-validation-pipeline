containerPath="/app/input"
containerName="riskman-pipeline:latest"

#
htmlTarget="submission.html"
aboxTarget="abox.ttl"
ontologyTarget="ontology.ttl"
shapesTarget="shapes.ttl"
#
html=""
abox=""
ontology=""
shapes=""
#

#Riskman enrichement options
prob=5
sev=5

#Secuman enrichement option (attacker-profile, vulnerability-level, impact-level)
ap=5
vl=5
il=5

mode="html" # html or abox, default html
enrichment="plain"   # plain, riskman, secuman - default plain

# ./pipeline.sh -h /home/piotr/Dresden/kimeds/riskman-reasoning-pipeline/riskman-validation-pipeline/test-cases/submission_giip.html -o /home/piotr/Dresden/kimeds/riskman-reasoning-pipeline/riskman-validation-pipeline/ontology.ttl -c /home/piotr/Dresden/kimeds/riskman-reasoning-pipeline/riskman-validation-pipeline/shapes.ttl -p 5 -s 5 -m html

# ./pipeline.sh -h test-cases/submission_giip.html -o ontology.ttl -c shapes.ttl -p 5 -s 5 -m html

# ./pipeline.sh -a /home/piotr/Dresden/kimeds/riskman-reasoning-pipeline/riskman-validation-pipeline/test-cases/1missing-im.ttl -o /home/piotr/Dresden/kimeds/riskman-reasoning-pipeline/riskman-validation-pipeline/ontology.ttl -c /home/piotr/Dresden/kimeds/riskman-reasoning-pipeline/riskman-validation-pipeline/shapes.ttl -p 5 -s 5 -m abox

# ./pipeline.sh -a test-cases/1missing-im.ttl -o ontology.ttl -c shapes.ttl -p 5 -s 5 -m abox



while getopts "h:a:o:c:p:s:A:V:I:m:e:" opt; do
    case "$opt" in
        h) html="$OPTARG" ;;
        a) abox="$OPTARG" ;;
        o) ontology="$OPTARG" ;;
        c) shapes="$OPTARG" ;;
        p) prob="$OPTARG" ;;
        s) sev="$OPTARG" ;;
        m) mode="$OPTARG" ;;
        e) enrichment="$OPTARG" ;;
        A) ap="$OPTARG" ;;
        V) vl="$OPTARG" ;;
        I) il="$OPTARG" ;;
        *)
            echo "Usage: $0 [-h html] [-a abox] -o ontology -c shapes -m [html|abox] -e [plain|riskman|secuman] [-p prob] [-s sev] [-A ap] [-V vl] [-I il]" >&2
            exit 1
            ;;
    esac
done


# option 1 
# HTML file with RDF encoding
modeHtml() {
    if [ -z "$html" ] || [ -z "$ontology" ] || [ -z "$shapes" ]; then
        echo "HTML mode requires -h, -o, and -c" >&2
        exit 1
    fi

    if [ "$enrichment" = "riskman" ]; then
        docker run \
            -v "$(realpath "$html")":"$containerPath/$htmlTarget" \
            -v "$(realpath "$ontology")":"$containerPath/$ontologyTarget" \
            -v "$(realpath "$shapes")":"$containerPath/$shapesTarget" \
            -t "$containerName" -p "$prob" -s "$sev" -m html -e "$enrichment"
    elif [ "$enrichment" = "secuman" ]; then
        docker run \
            -v "$(realpath "$html")":"$containerPath/$htmlTarget" \
            -v "$(realpath "$ontology")":"$containerPath/$ontologyTarget" \
            -v "$(realpath "$shapes")":"$containerPath/$shapesTarget" \
            -t "$containerName" -A "$ap" -V "$vl" -I "$il" -m html -e "$enrichment"
    else
        docker run \
            -v "$(realpath "$html")":"$containerPath/$htmlTarget" \
            -v "$(realpath "$ontology")":"$containerPath/$ontologyTarget" \
            -v "$(realpath "$shapes")":"$containerPath/$shapesTarget" \
            -t "$containerName" -m html -e "$enrichment"
    fi
}

# option 2
# directly providing ABox 
modeAbox() {
    if [ -z "$abox" ] || [ -z "$ontology" ] || [ -z "$shapes" ]; then
        echo "ABox mode requires -a, -o, and -c" >&2
        exit 1
    fi

    if [ "$enrichment" = "riskman" ]; then
        docker run \
            -v "$(realpath "$abox")":"$containerPath/$aboxTarget" \
            -v "$(realpath "$ontology")":"$containerPath/$ontologyTarget" \
            -v "$(realpath "$shapes")":"$containerPath/$shapesTarget" \
            -t "$containerName" -p "$prob" -s "$sev" -m abox -e "$enrichment"
    elif [ "$enrichment" = "secuman" ]; then
        docker run \
            -v "$(realpath "$abox")":"$containerPath/$aboxTarget" \
            -v "$(realpath "$ontology")":"$containerPath/$ontologyTarget" \
            -v "$(realpath "$shapes")":"$containerPath/$shapesTarget" \
            -t "$containerName" -A "$ap" -V "$vl" -I "$il" -m abox -e "$enrichment"
    else
        docker run \
            -v "$(realpath "$abox")":"$containerPath/$aboxTarget" \
            -v "$(realpath "$ontology")":"$containerPath/$ontologyTarget" \
            -v "$(realpath "$shapes")":"$containerPath/$shapesTarget" \
            -t "$containerName" -m abox -e "$enrichment"
    fi
}

if [ "$mode" == "html" ]; then
    modeHtml
elif [ "$mode" == "abox" ]; then
    modeAbox
else
    echo "Unknown mode: $mode" >&2
    echo "Usage: $0 [-h html] [-a abox] -o ontology -c shapes -m [html|abox] -e [plain|riskman|secuman] [-p prob] [-s sev] [-A ap] [-V vl] [-I il]" >&2
    exit 1
fi

