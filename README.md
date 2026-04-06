# Semeco Q2 Validation Pipeline

A lightweight validation pipeline for **OWL (EL++ profile) ontologies**, **SHACL shapes**, and optional **ontology-specific enrichment**.

It is designed for the **Secuman** and **Riskman** ontologies and builds on the Riskman validation pipeline.

## What it does

Depending on the selected mode, the pipeline can:

- extract RDF from an HTML submission,
- combine it with the ontology,
- optionally enrich the graph,
- run OWL reasoning,
- validate the result against SHACL shapes.

Two container variants are included:

- **full pipeline** -- reasoning + SHACL validation
- **reasoner-only** -- reasoning only, returning inferred RDF

## Supported inputs

### Modes

- `html` -- expects an RDF-annotated HTML submission at `/app/input/submission.html`
- `abox` -- expects an RDF/Turtle ABox at `/app/input/abox.ttl`

### Enrichment options

- `plain` -- no enrichment
- `riskman` -- adds Riskman probability/severity enrichment
- `secuman` -- adds Secuman attacker/vulnerability/impact enrichment

## Project structure

```text
.
├── Dockerfile
├── Dockerfile.reasoner
├── main.sh
├── main-reasoner.sh
├── rdf_distiller.py
├── reasoner.sh
├── validator.sh
├── prob_sev.py
├── secuman_enrichment.py
└── test-cases/
    ├── riskman/
    └── secuman/
```

## Build

Build the full pipeline:

```bash
docker build -t semeco-q2-pipeline .
```

Build the reasoner-only image:

```bash
docker build -t semeco-q2-pipeline:reasoner -f Dockerfile.reasoner .
```

## Full pipeline usage

The default entrypoint is `./main.sh`.

### General form

```bash
docker run \
  -v /path/to/input:/app/input/... \
  -t semeco-q2-pipeline \
  [options]
```

### Options

```text
-m  [html|abox]                 Input mode
-e  [plain|riskman|secuman]     Enrichment mode
-p  <int>                       Riskman: probability levels
-s  <int>                       Riskman: severity levels
-A  <int>                       Secuman: attacker profile levels
-V  <int>                       Secuman: vulnerability levels
-I  <int>                       Secuman: impact levels
```

## Examples

### Secuman -- Turtle ABox, no enrichment

```bash
docker run \
  -v /home/me/semeco-q2-validation-pipeline/test-cases/secuman/example.ttl:/app/input/abox.ttl \
  -v /home/me/secuman-ontology.ttl:/app/input/ontology.ttl \
  -v /home/me/secuman-shapes.ttl:/app/input/shapes.ttl \
  -t semeco-q2-pipeline \
  -m abox -e plain
```

### Secuman -- Turtle ABox with enrichment

`A` = attacker profile levels, `V` = vulnerability levels, `I` = impact levels.

```bash
docker run \
  -v /home/me/semeco-q2-validation-pipeline/test-cases/secuman/example.ttl:/app/input/abox.ttl \
  -v /home/me/secuman-ontology.ttl:/app/input/ontology.ttl \
  -v /home/me/secuman-shapes.ttl:/app/input/shapes.ttl \
  -t semeco-q2-pipeline \
  -m abox -e secuman -A 3 -V 4 -I 2
```

### Secuman -- HTML input with enrichment

```bash
docker run \
  -v /home/me/semeco-q2-validation-pipeline/test-cases/secuman/example.html:/app/input/submission.html \
  -v /home/me/secuman-ontology.ttl:/app/input/ontology.ttl \
  -v /home/me/secuman-shapes.ttl:/app/input/shapes.ttl \
  -t semeco-q2-pipeline \
  -m html -e secuman -A 3 -V 4 -I 2
```

### Riskman -- HTML input with enrichment

`p` = probability levels, `s` = severity levels.

```bash
docker run \
  -v /home/me/semeco-q2-validation-pipeline/test-cases/riskman/submission_giip.html:/app/input/submission.html \
  -v /home/me/riskman-ontology-1.0.0.ttl:/app/input/ontology.ttl \
  -v /home/me/riskman-shapes-1.0.0.ttl:/app/input/shapes.ttl \
  -t semeco-q2-pipeline \
  -m html -e riskman -p 5 -s 5
```

## Reasoner-only usage

The reasoner-only image uses `./main-reasoner.sh` and stops after OWL reasoning.

### Secuman -- Turtle ABox with enrichment

```bash
docker run \
  -v /home/me/semeco-q2-validation-pipeline/test-cases/secuman/example.ttl:/app/input/abox.ttl \
  -v /home/me/secuman-ontology.ttl:/app/input/ontology.ttl \
  -t semeco-q2-pipeline:reasoner \
  -m abox -e secuman -A 3 -V 4 -I 2
```

### Riskman -- HTML input with enrichment

```bash
docker run \
  -v /home/me/semeco-q2-validation-pipeline/test-cases/riskman/submission_giip.html:/app/input/submission.html \
  -v /home/me/riskman-ontology-1.0.0.ttl:/app/input/ontology.ttl \
  -t semeco-q2-pipeline:reasoner \
  -m html -e riskman -p 5 -s 5
```

## Output

Both images write their result to **stdout**:

- **full pipeline** -- SHACL validation output (`json-ld` via `pyshacl`)
- **reasoner-only** -- inferred RDF/Turtle

To save the result, redirect stdout on the host:

```bash
docker run \
  -v /home/me/semeco-q2-validation-pipeline/test-cases/secuman/example.ttl:/app/input/abox.ttl \
  -v /home/me/secuman-ontology.ttl:/app/input/ontology.ttl \
  -v /home/me/secuman-shapes.ttl:/app/input/shapes.ttl \
  -t semeco-q2-pipeline \
  -m abox -e plain > output.jsonld
```

## Notes

- Java 18 and Python 3.11 are installed inside the container.
- The full pipeline validates with `pyshacl`.
- HTML mode first extracts RDF using `rdf_distiller.py`.
- Example inputs are included under `test-cases/`.

## Related projects

- Secuman: `https://github.com/cl-tud/secuman`
- Riskman documentation: `https://cl-tud.github.io/riskman-documentation/`
- Upstream pipeline: `https://github.com/cl-tud/riskman-validation-pipeline`
