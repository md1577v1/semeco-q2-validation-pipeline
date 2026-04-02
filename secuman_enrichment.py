import sys


OUTPUT_FILE = 'secuman_enrichment_onto.ttl'

BASE_PREFIX = 'seclevel'
BASE_IRI = '<http://example.com/secuman/ontology#>'
SECUMAN_PREFIX = 'secuman'
OWL_PREFIX = 'owl'

PREFIXES = f'''
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix {OWL_PREFIX}: <http://www.w3.org/2002/07/owl#> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix ex: <http://example.org#> .
@prefix {SECUMAN_PREFIX}: <http://example.com/secuman/ontology#> .
@prefix schema: <https://schema.org/> .
@prefix {BASE_PREFIX}: {BASE_IRI} .
'''

NEWLINE = '\n'

GT = f'{BASE_PREFIX}:gt'
GT_PROPERTY = f'''{GT} rdf:type owl:ObjectProperty, owl:TransitiveProperty .'''

SECUMAN_ATTACKER_PROFILE = f'{SECUMAN_PREFIX}:AttackerProfile'
SECUMAN_VULNERABILITY_LEVEL = f'{SECUMAN_PREFIX}:VulnerabilityLevel'
#SECUMAN_LIKELIHOOD_FACTOR = f'{SECUMAN_PREFIX}:LikelihoodFactor'
SECUMAN_IMPACT_LEVEL = f'{SECUMAN_PREFIX}:ImpactLevel'

ATTACKER_PROFILE_NAME_BASE = 'ap'
VULNERABILITY_LEVEL_NAME_BASE = 'vl'
#LIKELIHOOD_FACTOR_NAME_BASE = 'lf'
IMPACT_LEVEL_NAME_BASE = 'il'


def get_individual_name(ordinal, base, prefix):
    return f'{prefix}:{base}{ordinal}'


def individual(ordinal, base, prefix, type_name, gt_prev=True):
    full_name = get_individual_name(ordinal, base, prefix)
    prev_name = get_individual_name(ordinal - 1, base, prefix)
    return f'''#{full_name}
{full_name} rdf:type owl:NamedIndividual , {type_name}''' + \
           (f''' ;
    {GT} {prev_name}''' if gt_prev else '') + ' .'


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(
            "Usage: python secuman_enrichment.py <attacker_profiles> <vulnerability_levels> <impact_levels>",
            file=sys.stderr
        )
        sys.exit(1)

    ap_max = int(sys.argv[1])
    vl_max = int(sys.argv[2])
#    lf_max = int(sys.argv[3])
    il_max = int(sys.argv[4])

    output_str = PREFIXES + NEWLINE * 2 + GT_PROPERTY + NEWLINE * 2

    for i in range(1, ap_max + 1):
        output_str += individual(i, ATTACKER_PROFILE_NAME_BASE, BASE_PREFIX, SECUMAN_ATTACKER_PROFILE, i > 1) + NEWLINE

    output_str += NEWLINE * 2

    for i in range(1, vl_max + 1):
        output_str += individual(i, VULNERABILITY_LEVEL_NAME_BASE, BASE_PREFIX, SECUMAN_VULNERABILITY_LEVEL, i > 1) + NEWLINE

    output_str += NEWLINE * 2

#    for i in range(1, lf_max + 1):
#        output_str += individual(i, LIKELIHOOD_FACTOR_NAME_BASE, BASE_PREFIX, SECUMAN_LIKELIHOOD_FACTOR, i > 1) + NEWLINE
#
#    output_str += NEWLINE * 2

    for i in range(1, il_max + 1):
        output_str += individual(i, IMPACT_LEVEL_NAME_BASE, BASE_PREFIX, SECUMAN_IMPACT_LEVEL, i > 1) + NEWLINE

    print(output_str)