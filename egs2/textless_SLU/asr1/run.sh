#!/usr/bin/env bash
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

./asr.sh \
    --lang en \
    --use_lm false \
    --ngpu 1 \
    --nbpe 512 \
    --asr_config conf/wav2vec_transformer.yaml \
    --inference_config conf/decode.yaml \
    --train_set train \
    --valid_set dev \
    --test_sets "dev test" \
    --bpe_train_text "dump/raw/train_nodev_sp/text" \
    --speed_perturb_factors "0.9 1.0 1.1" \
    --stage 1 \
    --bpe_train_text "dump/raw/train_sp/text" \
    --lm_train_text "data/train_sp/text" "$@"
