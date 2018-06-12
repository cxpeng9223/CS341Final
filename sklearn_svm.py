import time
import numpy as np
import random
from sklearn import svm

#Function to load the data file to memeory.

#Input: File path to read.
#Output: A 2d numpy array with all loaded samples from the file to read in string.

def parseFile(file):
    time_start = time.time()

    content = []
    count, count_incomplete,count_complete, count_part = 0, 0, 0, 0

    with open(file) as txtfile:
        for row in txtfile:

            row = row.split(',')
            row[-1] = row[-1].strip()

            content.append(row)

            count += 1

    content_mat = np.array(content)

    time_end = time.time()
    print('Reading data is complete! Running time is ' + str(time_end - time_start) + 's!')

    return content_mat

#Function to filter the samples with no missing values. 
#Input: mat - 2d Numpy Array.
#Onput: mat - 2d Numpy Array with all samples that have no Missing values.

def filter_full_feature(mat):
    row_count = 0
    full_list = []
    for row in mat:
        if 'N/A' in row:
            pass
        else:
            full_list.append(row_count)

        row_count += 1
    print('There are a total of ' + str(len(full_list)) + ' samples fed into the model')
    mat = mat[full_list, :]
    return mat

#Function to split up the full dataset into a training and testing set in 80:20 ratio.
#Input: mat - A 2d Numpy array
#Output: train_mat, test_mat - 2 deperate Numpy arrays each as a subset of the full mat set, 
#        with a rough ratio of 80:20

def train_test_split(mat):
    train_list = []
    test_list = []
    num_sample, num_var = mat.shape

    for i in range(0, num_sample):
        if i == 0:
            train_list.append(i)
            test_list.append(i)
        else:
            rand = random.random()
            if rand >= 0.2:
                train_list.append(i)
            else:
                test_list.append(i)

    train_mat = mat[train_list, :]
    test_mat = mat[test_list, :]

    return train_mat, test_mat


def svm_model_train(mat, label_location):
    model = svm.SVC()
    feature_mat = np.delete(mat, label_location, axis=1)[1:, :].astype(np.int)
    labels = mat[1:, label_location].astype(np.int)
    print('Model training - Started!')
    time_start = time.time()
    model.fit(feature_mat, labels)
    time_end = time.time()
    print('Model training - Completed! Training time: ' + str(time_end - time_start) + 's')

    predicted_lab = model.predict(feature_mat)
    corrected_pred = np.sum(labels == predicted_lab)

    training_error = 1 - corrected_pred/labels.size

    return model, training_error

def model_test(model, mat, label_location):
    feature_mat = np.delete(mat, label_location, axis=1)[1:, :].astype(np.int)
    labels = mat[1:, label_location].astype(np.int)

    predicted_lab = model.predict(feature_mat)
    corrected_pred = np.sum(labels == predicted_lab)

    test_error = 1 - corrected_pred / labels.size
    return test_error

def main():
    content_mat = parseFile('CleanedData/gallup_clean_NA_determinant.txt')
    #content_mat = parseFile('CleanedData/gallup_mean_filled_cleaned.txt')
    num_sample, num_var = content_mat.shape
    
    sentiment_list = [0, 1, 2, 3, 21, 22, 32] #sentiment & label(21)

    #sentiment_list = [0, 1, 2, 3, 4, 6, 8, 21, 22, 24, 25, 27, 28, 32, 33, 45] #sentiment & background & label(21)
    full_list = list(range(0, num_var))

    delete_list = list(set(full_list) - set(sentiment_list))

    content_mat = np.delete(content_mat, delete_list, axis=1)

    content_mat = filter_full_feature(content_mat)

    train_mat, test_mat = train_test_split(content_mat)

    model, train_error = svm_model_train(train_mat, 4)

    test_error = model_test(model, test_mat, 4)

    print('The training error for this trail is: ' + str(train_error))
    print('The testing error for this trail is: ' + str(test_error))


if __name__ == "__main__":
    main()