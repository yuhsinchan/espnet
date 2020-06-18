#!/bin/bash

# Copyright 2020  Shanghai Jiao Tong University (Authors: Chenda Li, Wangyou Zhang)
# Apache 2.0
set -e
set -u
set -o pipefail

min_or_max=min

. utils/parse_options.sh

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}

help_message=$(cat << EOF
Usage: $0
(No options)
EOF
)

if [ $# -ne 0 ]; then
    log "Error: invalid command line arguments"
    log "${help_message}"
    exit 1
fi

. ./db.sh

wsj_full_wav=$PWD/data/wsj0/wsj0_wav
wsj_2mix_wav=$PWD/data/wsj0_mix/2speakers
wsj_2mix_scripts=$PWD/data/wsj0_mix/scripts

train_set="tr"
train_dev="cv"
recog_set="tt"

other_text=data/local/other_text/text
nlsyms=data/nlsyms.txt

if [ ! -e "${WSJ0}" ]; then
    log "Fill the value of 'WSJ0' of db.sh"
    exit 1
fi
if [ ! -e "${WSJ1}" ]; then
    log "Fill the value of 'WSJ1' of db.sh"
    exit 1
fi


### This part is for WSJ0 mix
### Download mixture scripts and create mixtures for 2 speakers
local/wsj0_create_mixture.sh --min-or-max ${min_or_max} \
    ${wsj_2mix_scripts} ${WSJ0} ${wsj_full_wav} ${wsj_2mix_wav} || exit 1;
local/wsj0_2mix_data_prep.sh --min-or-max ${min_or_max} \
    ${wsj_2mix_wav}/wav16k/${min_or_max} ${wsj_2mix_scripts} ${wsj_full_wav} || exit 1;

### create .scp file for reference audio
for folder in tr cv tt;
do
    sed -e 's/\/mix\//\/s1\//g' ./data/$folder/wav.scp > ./data/$folder/spk1.scp
    sed -e 's/\/mix\//\/s2\//g' ./data/$folder/wav.scp > ./data/$folder/spk2.scp
done


### Also need wsj corpus to prepare language information
### This is from Kaldi WSJ recipe
log "local/wsj_data_prep.sh ${WSJ0}/??-{?,??}.? ${WSJ1}/??-{?,??}.?"
local/wsj_data_prep.sh ${WSJ0}/??-{?,??}.? ${WSJ1}/??-{?,??}.?
log "local/wsj_format_data.sh"
local/wsj_format_data.sh
log "mkdir -p data/wsj"
mkdir -p data/wsj
log "mv data/{dev_dt_*,local,test_dev*,test_eval*,train_si284} data/wsj"
mv data/{dev_dt_*,local,test_dev*,test_eval*,train_si284} data/wsj




log "Prepare text from lng_modl dir: ${WSJ1}/13-32.1/wsj1/doc/lng_modl/lm_train/np_data/{87,88,89}/*.z -> ${other_text}"
mkdir -p "$(dirname ${other_text})"

# NOTE(kamo): Give utterance id to each texts.
zcat ${WSJ1}/13-32.1/wsj1/doc/lng_modl/lm_train/np_data/{87,88,89}/*.z | \
    grep -v "<" | tr "[:lower:]" "[:upper:]" | \
    awk '{ printf("wsj1_lng_%07d %s\n",NR,$0) } ' > ${other_text}



log "Create non linguistic symbols: ${nlsyms}"
cut -f 2- data/wsj/train_si284/text | tr " " "\n" | sort | uniq | grep "<" > ${nlsyms}
cat ${nlsyms}
