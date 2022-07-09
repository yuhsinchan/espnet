import os

base_path = (
    "/home/yuhsinchan/Documents/textless-SLU_ESPnet/espnet/egs2/textless_SLU/asr1/data"
)
modes = ["dev", "train", "test"]
files = ["spk2utt", "utt2spk", "text"]

for mode in modes:
    for file in files:
        with open(os.path.join(base_path, mode, file), "r") as f:
            lines = f.readlines()
            lines_no_duplicate = []
            for line in lines:
                if line not in lines_no_duplicate:
                    lines_no_duplicate.append(line)
                else:
                    print(f"{mode}/{file}", f"{line} is duplicated")
