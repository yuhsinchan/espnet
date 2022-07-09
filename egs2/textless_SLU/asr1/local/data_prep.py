import os
import sys
import csv
import random

atis_path = "/home/yuhsinchan/Documents/textless-SLU/atis"

train_BIO = os.path.join(atis_path, "sv_BIO_train.csv")
dev_BIO = os.path.join(atis_path, "sv_BIO_dev.csv")
test_BIO = os.path.join(atis_path, "sv_BIO_test.csv")

data_dir = "../data"

speakers = [
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
]

for i in ["train", "dev", "test"]:
    with open(os.path.join(data_dir, i, "text"), "w") as text_f, open(
        os.path.join(data_dir, i, "wav.scp"), "w"
    ) as wav_scp_f, open(os.path.join(data_dir, i, "utt2spk"), "w") as utt2spk_f:

        text_f.truncate()
        wav_scp_f.truncate()
        utt2spk_f.truncate()

        wav_dir = os.listdir(os.path.join(atis_path, i))
        if i == "train":
            with open(train_BIO) as f:
                reader = csv.reader(f)
                BIO_list = list(reader)
        elif i == "dev":
            with open(dev_BIO) as f:
                reader = csv.reader(f)
                BIO_list = list(reader)
        elif i == "test":
            with open(test_BIO) as f:
                reader = csv.reader(f)
                BIO_list = list(reader)

        uids = []
        for line in BIO_list[1:]:
            spk = speakers[random.randint(0, len(speakers) - 1)]
            if line[1] + ".wav" not in wav_dir:
                print(line[1] + ".wav", "missed")
                continue
            if line[1] in uids:
                print(line[1], "is duplicated")
                continue
            uids.append(line[1])
            text_f.write(f"{spk}-{line[1]}" + " " + line[2] + "\n")
            wav_scp_f.write(
                f"{spk}-{line[1]}"
                + " "
                + os.path.join(atis_path, i, line[1] + ".wav")
                + "\n"
            )
            utt2spk_f.write(f"{spk}-{line[1]}" + " " + spk + "\n")
