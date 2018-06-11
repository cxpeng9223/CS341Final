"""Build vocabularies of words and tags from datasets"""

import argparse
from collections import Counter
import json
import os
import random
import numpy as np

parser = argparse.ArgumentParser()
#parser.add_argument('--min_count_word', default=1, help="Minimum count for words in the dataset", type=int)
#parser.add_argument('--min_count_tag', default=1, help="Minimum count for tags in the dataset", type=int)
parser.add_argument('--data_dir', default='data/raw_data', help="Directory containing the dataset")
parser.add_argument('--output_dir', default='data/split_GALLUP', help="Where to write the new data")


# Hyper parameters for the vocab
PAD_WORD = '<pad>'
PAD_TAG = 'O'
UNK_WORD = 'UNK'


#Function to load the data file to memeory.
#Input: File path to read.
#Output: A 2d numpy array with all loaded samples from the file to read in string.
def parseFile(file):
    #time_start = time.time()
    count = 0
    content = []
    with open(file) as txtfile:
        for row in txtfile:
            count += 1
            if count == 1:
                continue
            row = row.split(',')
            row[-1] = row[-1].strip()
            content.append(row[:4]+[row[6]]+row[21:23]+[row[29]]+[row[33]]+row[47:]) # feature 0-3, 22, 33, label 21
            #if count == 2000:
            #    break
    content_mat = np.array(content)
    
    #time_end = time.time()
    #print('Reading data is complete! Running time is ' + str(time_end - time_start) + 's!')
    return content_mat

#Function to filter the samples with no missing values. 
#Input: mat - 2d Numpy Array.
#Onput: mat - 2d Numpy Array with all samples that have no Missing values.
def filter_full_feature(mat):
    row_count = 0
    full_list = []
    for row in mat:
        if 'N/A' in row or 'NA' in row:
            pass
        else:
            full_list.append(row_count)

        row_count += 1
    print('There are a total of ' + str(len(full_list)) + ' samples fed into the model')
    mat = mat[full_list, :]
    return mat

def save_vocab_to_txt_file(vocab, txt_path):
    """Writes one token per line, 0-based line id corresponds to the id of the token.

    Args:
        vocab: (iterable object) yields token
        txt_path: (stirng) path to vocab file
    """
    with open(txt_path, "w") as f:
        for token in vocab:
            f.write(token + '\n')
            

def save_dict_to_json(d, json_path):
    """Saves dict to json file

    Args:
        d: (dict)
        json_path: (string) path to json file
    """
    with open(json_path, 'w') as f:
        d = {k: v for k, v in d.items()}
        json.dump(d, f, indent=4)


def update_vocab(txt_path, vocab):
    """Update word and tag vocabulary from dataset

    Args:
        txt_path: (string) path to file, one sentence per line
        vocab: (dict or Counter) with update method

    Returns:
        dataset_size: (int) number of elements in the dataset
    """
    with open(txt_path) as f:
        for i, line in enumerate(f):
            vocab.update(line.strip().split(' '))

    return i + 1


if __name__ == '__main__':
    args = parser.parse_args()

    assert os.path.isdir(args.data_dir), "Couldn't find the dataset at {}".format(args.data_dir)
    
    # Define the data directories
    data_dir = os.path.join(args.data_dir)
    
    # Get the filename in data directory
    print("Get data filename...")
    filenames = os.listdir(data_dir)
    filenames = [os.path.join(data_dir, f) for f in filenames if f.endswith('.txt')]
    filenames = filenames[0] # data/raw_data/gallup_sample.txt
    
    # parse file
    print("Parse and filter file...")
    mat = parseFile(filenames) #100,7 
    mat = filter_full_feature(mat).tolist()
    
    # split file
    print("Split file...")
    random.seed(230)
    random.shuffle(mat)
    split1 = int(0.9 * len(mat))
    split2 = (len(mat) - split1) // 2 + split1
    train_mat = mat[:split1]
    val_mat = mat[split1:split2]
    test_mat = mat[split2:]
    
    all_mats = {'train': train_mat,
                 'val': val_mat,
                 'test': test_mat}
     
    #mkdir
    if not os.path.exists(args.output_dir):
        os.mkdir(args.output_dir)
    else:
        print("Warning: output dir {} already exists".format(args.output_dir))
    
    # Preprocess train, val and test
    for split in ['train', 'val', 'test']:
        output_dir_split = os.path.join(args.output_dir, '{}'.format(split))
        if not os.path.exists(output_dir_split):
            os.mkdir(output_dir_split)
        else:
            print("Warning: dir {} already exists".format(output_dir_split))

        print("Processing {} data, saving preprocessed data to {}".format(split, output_dir_split))
        # write train, val, test mat to corresponding path
        
        # write features
        filetoWrite = open(output_dir_split + "/features.txt", "w+")
        for line in all_mats[split]:
            line = line[:5] + line[6:]
            filetoWrite.write(",".join(line) + "\n")

        filetoWrite.close()
        
        # write labels
        filetoWrite = open(output_dir_split + "/labels.txt", "w+")
        for line in all_mats[split]:
            line = line[5]
            filetoWrite.write(",".join(line) + "\n")

        filetoWrite.close()
        
    # Build word vocab with train and test datasets
    print("get features...")
    words = Counter()
    size_train_gallup = update_vocab(os.path.join(args.output_dir, 'train/features.txt'), words)
    size_dev_gallup = update_vocab(os.path.join(args.output_dir, 'val/features.txt'), words)
    size_test_gallup = update_vocab(os.path.join(args.output_dir, 'test/features.txt'), words)
    print("- done.")

    #print(size_train_gallup) #95
    #print(size_dev_gallup) #4
    #print(size_test_gallup) #1
    
    # Build tag vocab with train and test datasets
    print("get labels...")
    tags = Counter()
    size_train_tags = update_vocab(os.path.join(args.output_dir, 'train/labels.txt'), tags)
    size_dev_tags = update_vocab(os.path.join(args.output_dir, 'val/labels.txt'), tags)
    size_test_tags = update_vocab(os.path.join(args.output_dir, 'test/labels.txt'), tags)
    print("- done.")

    # Assert same number of examples in datasets
    assert size_train_gallup == size_train_tags
    assert size_dev_gallup == size_dev_tags
    assert size_test_gallup == size_test_tags
    
    # Save datasets properties in json file
    sizes = {
        'train_size': size_train_gallup,
        'dev_size': size_dev_gallup,
        'test_size': size_test_gallup,
        'label_size': 1
        #'vocab_size': len(words),
        #'number_of_tags': len(tags),
        #'pad_word': PAD_WORD,
        #'pad_tag': PAD_TAG,
        #'unk_word': UNK_WORD
    }
    save_dict_to_json(sizes, os.path.join(args.output_dir, 'dataset_params.json'))

    # Logging sizes
    to_print = "\n".join("- {}: {}".format(k, v) for k, v in sizes.items())
    print("Characteristics of the dataset:\n{}".format(to_print))
    
    print("build_dataset done!")