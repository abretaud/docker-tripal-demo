#!/bin/bash

set -e


# If there is a .venv/ directory, assume it contains a virtualenv that we
# should run this instance in.
VIRTUAL_ENV="${VIRTUAL_ENV:-.venv}"
if [ -d "$VIRTUAL_ENV" -a -z "$skip_venv" ];
then
    [ -n "$PYTHONPATH" ] && { echo 'Unsetting $PYTHONPATH'; unset PYTHONPATH; }
    printf "Activating virtualenv at $VIRTUAL_ENV\n"
    . "$VIRTUAL_ENV/bin/activate"
else
    # No .venv, create it
    if command -v virtualenv >/dev/null; then
        virtualenv -p python2.7 "$VIRTUAL_ENV"
    else
        vvers=13.1.2
        vurl="https://pypi.python.org/packages/source/v/virtualenv/virtualenv-${vvers}.tar.gz"
        vsha="aabc8ef18cddbd8a2a9c7f92bc43e2fea54b1147330d65db920ef3ce9812e3dc"
        vtmp=`mktemp -d -t galaxy-virtualenv-XXXXXX`
        vsrc="$vtmp/`basename $vurl`"
        # SSL certificates are not checked to prevent problems with messed
        # up client cert environments. We verify the download using a known
        # good sha256 sum instead.
        echo "Fetching $vurl"
        if command -v curl >/dev/null; then
            curl --insecure -L -o $vsrc $vurl
        elif command -v wget >/dev/null; then
            wget --no-check-certificate -O $vsrc $vurl
        else
            python -c "import urllib; urllib.urlretrieve('$vurl', '$vsrc')"
        fi
        echo "Verifying $vsrc checksum is $vsha"
        python -c "import hashlib; assert hashlib.sha256(open('$vsrc', 'rb').read()).hexdigest() == '$vsha', '$vsrc: invalid checksum'"
        tar zxf $vsrc -C $vtmp
        python $vtmp/virtualenv-$vvers/virtualenv.py "$VIRTUAL_ENV"
        rm -rf $vtmp
    fi

    [ -n "$PYTHONPATH" ] && { echo 'Unsetting $PYTHONPATH'; unset PYTHONPATH; }
    printf "Activating virtualenv at $VIRTUAL_ENV\n"
    . "$VIRTUAL_ENV/bin/activate"

    pip install tripal
fi

if [ ! -f Citrus_sinensis-orange1.1g015632m.g.gff3 ]; then
    wget "http://www.gmod.org/mediawiki/images/d/dc/Citrus_sinensis-orange1.1g015632m.g.gff3"
    sed -i 's/scaffold\t/supercontig\t/g' Citrus_sinensis-orange1.1g015632m.g.gff3
fi
if [ ! -f Citrus_sinensis-scaffold00001.fasta ]; then
    wget "http://www.gmod.org/mediawiki/images/8/87/Citrus_sinensis-scaffold00001.fasta"
fi
if [ ! -f Citrus_sinensis-orange1.1g015632m.g.fasta ]; then
    wget "http://www.gmod.org/mediawiki/images/9/90/Citrus_sinensis-orange1.1g015632m.g.fasta"
fi

if [ ! -f Citrus_sinensis-orange1.1g015632m.g.iprscan.xml ]; then
    wget "http://www.gmod.org/mediawiki/images/0/0c/Citrus_sinensis-orange1.1g015632m.g.iprscan.xml"
fi
if [ ! -f Citrus_sinensis-orange1.1g015632m.g.KEGG.heir.tar.gz ]; then
    wget "http://www.gmod.org/mediawiki/images/1/13/Citrus_sinensis-orange1.1g015632m.g.KEGG.heir.tar.gz"
fi
if [ ! -f Blastx_citrus_sinensis-orange1.1g015632m.g.fasta.0_vs_uniprot_sprot.fasta.out ]; then
    wget "http://www.gmod.org/mediawiki/images/e/e8/Blastx_citrus_sinensis-orange1.1g015632m.g.fasta.0_vs_uniprot_sprot.fasta.out"
fi
if [ ! -f Blastx_citrus_sinensis-orange1.1g015632m.g.fasta.0_vs_nr.out ]; then
    wget "http://www.gmod.org/mediawiki/images/2/24/Blastx_citrus_sinensis-orange1.1g015632m.g.fasta.0_vs_nr.out"
fi

# Create a specific auth yml file
TRIPAL_URL="http://localhost:3300/tripal/"
TRIPAL_USER="admin"
TRIPAL_PASS="changeme"

export TRIPAILLE_GLOBAL_CONFIG_PATH=`pwd`/.tripaille_auth.yml
echo "__default: local" > $TRIPAILLE_GLOBAL_CONFIG_PATH
echo "" >> $TRIPAILLE_GLOBAL_CONFIG_PATH
echo "local:" >> $TRIPAILLE_GLOBAL_CONFIG_PATH
echo "    tripal_url: \"$TRIPAL_URL\"" >> $TRIPAILLE_GLOBAL_CONFIG_PATH
echo "    username: \"$TRIPAL_USER\"" >> $TRIPAILLE_GLOBAL_CONFIG_PATH
echo "    password: \"$TRIPAL_PASS\"" >> $TRIPAILLE_GLOBAL_CONFIG_PATH

# Create the organisms
tripaille organism add_organism \
    --common "fruitfly" \
    --abbr "D.melanogaster" \
    --comment "The genome of D. melanogaster (sequenced in 2000, and curated at the FlyBase database) contains four pairs of chromosomes: an X/Y pair, and three autosomes labeled 2, 3, and 4. The fourth chromosome is so tiny that it is often ignored, aside from its important eyeless gene. The D. melanogaster sequenced genome of 165 million base pairs has been annotated[17] and contains approximately 13,767 protein-coding genes, which comprise ~20% of the genome out of a total of an estimated 14,000 genes. More than 60% of the genome appears to be functional non-protein-coding DNA involved in gene expression control. Determination of sex in Drosophila occurs by the ratio of X chromosomes to autosomes, not because of the presence of a Y chromosome as in human sex determination. Although the Y chromosome is entirely heterochromatic, it contains at least 16 genes, many of which are thought to have male-related functions." \
    "Drosophila" \
    "melanogaster"

tripaille organism add_organism \
    --common "Sweet orange" \
    --abbr "C. sinensis" \
    --comment "Sweet orange is the No.1 citrus production in the world, accounting for about 70% of the total. Brazil, Flordia (USA), and China are the three largest sweet orange producers. Sweet orange fruits have very tight peel and are classified into the hard-to-peel group. They are often used for juice processing, rather than fresh consumption. Valencia, Navel, Blood, Acidless, and other subtypes are bud mutants of common sweet orange varieties. Sweet orange is considered as an introgression of a natural hybrid of mandarin and pummelo; some estimates shows more mandarin genomic background than pummelo. The genome size is estimated at 380Mb across 9 haploid chromosomes." \
    "Citrus" \
    "sinensis"

# Create analysis
tripaille analysis add_analysis \
    --sourceuri "http://www.phytozome.net/citrus.php" \
    --description "<p><strong><em>Note: </em>The following text comes from phytozome.org:</strong></p><p><u>Genome Size / Loci</u><br />This version (v.1) of the assembly is 319 Mb spread over 12,574 scaffolds. Half the genome is accounted for by 236 scaffolds 251 kb or longer. The current gene set (orange1.1) integrates 3.8 million ESTs with homology and ab initio-based gene predictions (see below). 25,376 protein-coding loci have been predicted, each with a primary transcript. An additional 20,771 alternative transcripts have been predicted, generating a total of 46,147 transcripts. 16,318 primary transcripts have EST support over at least 50% of their length. Two-fifths of the primary transcripts (10,813) have EST support over 100% of their length.</p><p><u>Sequencing Method</u><br />Genomic sequence was generated using a whole genome shotgun approach with 2Gb sequence coming from GS FLX Titanium; 2.4 Gb from FLX Standard; 440 Mb from Sanger paired-end libraries; 2.0 Gb from 454 paired-end libraries</p><p><u>Assembly Method</u><br />The 25.5 million 454 reads and 623k Sanger sequence reads were generated by a collaborative effort by 454 Life Sciences, University of Florida and JGI. The assembly was generated by Brian Desany at 454 Life Sciences using the Newbler assembler.</p><p><u>Identification of Repeats</u><br />A de novo repeat library was made by running RepeatModeler (Arian Smit, Robert Hubley) on the genome to produce a library of repeat sequences. Sequences with Pfam domains associated with non-TE functions were removed from the library of repeat sequences and the library was then used to mask 31% of the genome with RepeatMasker.</p><p><u>EST Alignments</u><br />We aligned the sweet orange EST sequences using Brian Haas's PASA pipeline which aligns ESTs to the best place in the genome via gmap, then filters hits to ensure proper splice boundaries.</p>" \
    --date_executed "2011-02-01" \
    "Whole Genome Assembly and Annotation of Citrus Sinensis (JGI)" \
    "Performed by JGI" \
    "v1.0" \
    "JGI Citrus sinensis assembly/annotation v1.0 (154)"

# Load annotation GFF3
tripaille analysis load_gff3 \
    --organism "C. sinensis" \
    --analysis "Whole Genome Assembly and Annotation of Citrus Sinensis (JGI)" \
    /data/Citrus_sinensis-orange1.1g015632m.g.gff3

# Load genome FASTA
tripaille analysis load_fasta \
    --organism "C. sinensis" \
    --analysis "Whole Genome Assembly and Annotation of Citrus Sinensis (JGI)" \
    --sequence_type supercontig \
    --method 'update' \
    --match_type 'name' \
    /data/Citrus_sinensis-scaffold00001.fasta

# Load genes FASTA
tripaille analysis load_fasta \
    --organism "C. sinensis" \
    --analysis "Whole Genome Assembly and Annotation of Citrus Sinensis (JGI)" \
    --sequence_type mRNA \
    --method 'update' \
    --match_type 'name' \
    /data/Citrus_sinensis-orange1.1g015632m.g.fasta

# Sync the features
tripaille feature sync \
    --types gene \
    --types mRNA \
    --organism "C. sinensis"

# Load Blast results
tripaille analysis load_blast \
    --date_executed "2016-11-14" \
    --algorithm "blastx" \
    --description "C. sinensis mRNA sequences were BLAST'ed against the ExPASy SwissProt protein database using a local installation of BLAST on in-house linux server. Expectation value was set at 1e-6" \
    --blastdb "swissprot:display" \
    --search_keywords \
    --query_type "mRNA" \
    --blast_parameters "-p blastx -e 1e-6 -m 7" \
    "blastx Citrus sinensis v1.0 genes vs ExPASy SwissProt" \
    "blastall" \
    "2.2.25" \
    "C. sinensis mRNA vs ExPASy SwissProt" \
    /data/Blastx_citrus_sinensis-orange1.1g015632m.g.fasta.0_vs_uniprot_sprot.fasta.out

# Load Blast results
tripaille analysis load_blast \
    --date_executed "2016-11-14" \
    --algorithm "blastx" \
    --description "C. sinensis mRNA sequences were BLAST'ed against the NCBI nr protein database using a local installation of BLAST on in-house linux server. Expectation value was set at 1e-6" \
    --blastdb "genbank:protein" \
    --search_keywords \
    --query_type "mRNA" \
    --blast_parameters "-p blastx -e 1e-6 -m 7" \
    "blastx Citrus sinensis v1.0 genes vs NCBI nr" \
    "blastall" \
    "2.2.25" \
    "C. sinensis mRNA vs NCBI nr" \
    /data/Blastx_citrus_sinensis-orange1.1g015632m.g.fasta.0_vs_uniprot_sprot.fasta.out

# Load Interproscan results
tripaille analysis load_interpro \
    --date_executed "2016-11-14" \
    --algorithm "iprscan" \
    --description "C. sinensis mRNA sequences were mapped to IPR domains and GO terms using a local installation of InterProScan executed on a computational cluster. InterProScan date files used were MATCH_DATA_v32, DATA_v32.0 and PTHR_DATA v31.0." \
    --interpro_parameters "iprscan -cli -goterms -ipr -format xml" \
    --parse_go \
    --query_type "mRNA" \
    "InterPro Annotations of C. sinensis v1.0" \
    "InterProScan" \
    "4.8" \
    "C. sinensis v1.0 mRNA" \
    /data/Citrus_sinensis-orange1.1g015632m.g.iprscan.xml

# Load Blast2go results
# These results are not part of the Tripal tutorial, but were added to demonstrate the use of load_go
tripaille analysis load_go \
    --date_executed "2016-11-14" \
    --query_type polypeptide \
    --organism "C. sinensis" \
    "Blast2GO Annotation of C. sinensis v1.0" \
    "Blast2GO" \
    "2.5" \
    "C. sinensis Blast2GO" \
    /data/blast2go.gaf

# Create analysis
tripaille analysis add_analysis \
    --date_executed "2011-02-01" \
    "Expression data" \
    "Some demo values" \
    "v1.0" \
    "Expression data"

tripaille expression add_expression \
    --match_type 'uniquename' \
    '3' \
    '6' \
    /data/expression.tsv

# Populate all materialized views
tripaille db populate_mviews

# Index everything
tripaille db index

# Create an index for organism table
tripaille db index --mode table --table chado.organism --index_name organisms --fields "genus|string" --fields "species|string" --links 'species|http://localhost:8500/tripal/organism/[genus]/[species]'
