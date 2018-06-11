import time
import numpy as np
import pandas as pd
import random
import copy, sys
from sklearn.neighbors import KNeighborsRegressor
from sklearn.neighbors import KNeighborsClassifier
from sklearn import linear_model
from sklearn import ensemble
from sklearn.metrics import roc_auc_score
from sklearn import preprocessing

from scipy import stats
from numpy import linalg as LA
import math

import re
import sys
from pyspark import SparkConf, SparkContext

conf = SparkConf()
sc = SparkContext(conf=conf)

import torch

#Function to load the data file to memeory.

#Input: File path to read.
#Output: A 2d numpy array with all loaded samples from the file to read in string.

def parseFile_raw(file):
    time_start = time.time()

    content = []
    count, count_incomplete,count_complete, count_part = 0, 0, 0, 0
    
    with open(file) as txtfile:
        for row in txtfile:
            
            row = row.split(',')
            row[-1] = row[-1].strip()
            #if count != 0:
            content.append([row[21]] + row[0:4] + [row[22]] + [row[32]] + row[24: 26] + [row[29]] + [row[6]] \
                           + [row[-5]] + [row[-4]] + [row[-3]] + [row[-2]] + [row[12].strip("'")])

            count += 1
            #if count == 1000:
                #break

    content_mat = np.array(content)

    time_end = time.time()
    print('Reading data is complete! Running time is ' + str(time_end - time_start) + 's!')

    return content_mat

#Function to load the data file to memeory, this is for the simulation hash data.

#Input: File path to read.
#Output: A 2d numpy array with all loaded samples from the file to read in string.

def parseFile_reference(file):
    time_start = time.time()

    content = []
    count, count_incomplete,count_complete, count_part = 0, 0, 0, 0
    
    with open(file) as txtfile:
        for row in txtfile:
            row = row.split(',')
            row[-1] = row[-1].strip().strip(']').strip('\n')
            row[0] = row[0][1:]
            row[0] = row[0].strip("'")
    
            content.append(row)

    reference_mat = np.array(content)

    time_end = time.time()
    print('Reading data is complete! Running time is ' + str(time_end - time_start) + 's!')

    return reference_mat

def parseFile_indi(file):

    with open(file, 'r') as csvfile:
        indi_list = []
        for line in csvfile:
            indi_list.append(line.strip().replace('-', ' ').split(','))

    indicator_array = np.array(indi_list)
    
    return indicator_array

def parseFile_hpi(file):

    with open(file, 'r') as csvfile:
        hpi_list = []
        for line in csvfile:
            hpi_list.append(line.strip().split(','))

    hpi_array = np.array(hpi_list)
    
    return hpi_array

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

#Function to split the fullset into training and test sets.
#Input: mat - 2d Numpy Array.
#Onput: train_mat: 2d Numpy Array, test_mat: 2d Numpy Array
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
            if rand >= 0.1:
                train_list.append(i)
            else:
                test_list.append(i)

    train_mat = mat[train_list, :]
    test_mat = mat[test_list, :]

    return train_mat, test_mat

#convert a probability into the coordinate of a zip code using population probability distritbuion
#prob: float between 0 and 1
#reference_array: a 2-d array contaning the coordinates of the reference zipcodes
#prob_dist: a 1-d array shows the accumulated population distribution as a percentage of the total population in the US.
def getzip(prob, reference_array, prob_dist):
    idx = np.where(prob_dist >= prob)
    idx = idx[0][0]
    coord = reference_array[idx, :]
    
    return coord, idx

#convert the index and probability from getzip() and get the gender of the simulation from a gender reference
#idx: the index returned from getzip()
#gender_ref: a 2-d Array that contains the gender distribution of each zip code.
# 1-male, 0-female.
def getgender(idx, gender_ref):
    prob = random.random()
    
    if prob >= gender_ref[idx]:
        gender = 0
    else:
        gender = 1
    
    return gender

#convert the index, gender and a probability from getzip() and get the age of the simulation from an age reference
def getage(idx, age_ref, gender):
    age_ref_male = age_ref[:, :18]
    age_ref_female = age_ref[:, 18:]
    prob = random.random()
    
    if gender == 1:
        idx_age = np.where(age_ref_male[idx] >= prob)
        if idx_age[0].size != 0:
            idx_age = idx_age[0][0]
            delta = random.randint(0, 4)
        
            age = idx_age * 5 + delta
        else:
            age = 90
    else:
        idx_age = np.where(age_ref_female[idx] >= prob)
        if idx_age[0].size != 0:
            idx_age = idx_age[0][0]
            delta = random.randint(0, 4)
        
            age = idx_age * 5 + delta
        else:
            age = 90

    return age

#convert the index and a probability from getzip() and get the race of the simulation from a race reference
def getrace(idx, race_ref):
    prob = random.random()
    idx_race = np.where(race_ref[idx] >= prob)
    idx_race = idx_race[0][0]
    
    return idx_race + 1

#convert a zip code to its coresponding coordinate.
#zip_array: a 1-d array that is a list of zip_code
#reference_array: a 2-d array contaning the coordinates of the reference zipcodes
def zip_to_coordinate(zip_array, reference_array):
    count = 0
    coordinate_list = []
    full_list = []
    zip_ref = reference_array[:, 0].astype(np.int)
    for zip_c in zip_array:
        idx = np.argwhere(zip_ref == int(zip_c))
        if idx.size != 0:
            coordinate_pair = reference_array[idx[0][0], 1:3]
            full_list.append(count)
        else: #there are some zipcodes were P.O box addresses and not in our reference. So we look for the nearby zipcodes
            zip_c_back = int(zip_c) - 1
            zip_c_forward = int(zip_c) + 1
            idx_back = np.argwhere(zip_ref == zip_c_back)
            idx_forward = np.argwhere(zip_ref == zip_c_forward)
            if idx_back.size != 0:
                coordinate_pair = reference_array[idx_back[0][0], 1:3]
                full_list.append(count)
            elif idx_forward.size != 0:
                coordinate_pair = reference_array[idx_forward[0][0], 1:3]
                full_list.append(count)
            else:
                coordinate_pair = ['N/A', 'N/A']
                
        count += 1
        coordinate_list.append(coordinate_pair)
    return np.array(coordinate_list), full_list

def random_shuffle(array, upper_array, lower_array):
    element_counter = 0
    for element in array:
        prob = random.random()
        if prob <= 0.15:
            array[element_counter] = np.random.choice(np.arange(lower_array[element_counter], upper_array[element_counter]))  
        element_counter += 1
        
    return array

def convert_dummy(array):
    
    num_sample, num_feature = array.shape
    dummy_list = []
    
    combined_df = np.array(pd.get_dummies(array[:, 0]))
    for i in range(1, num_feature):
        dummy_df = pd.get_dummies(array[:, i])
        combined_df = np.concatenate((combined_df, np.array(dummy_df)), axis=1)
    
    return combined_df

def model_train(mat, label_location):
    #model = linear_model.LogisticRegression()
    poly = preprocessing.PolynomialFeatures(2)
    num_sam, num_var = mat.shape
    model = ensemble.RandomForestClassifier(n_estimators = 15,min_samples_split= 32, min_samples_leaf = 20)
    feature_mat = np.delete(mat, label_location, axis=1).astype(np.float)
    feature_mat = poly.fit_transform(feature_mat)
    #feature_mat = np.concatenate((feature_mat, (feature_mat[:, 41] * feature_mat[:, 41]).reshape((num_sam, 1))), axis=1)
    labels = mat[:, label_location].astype(np.int)
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
    num_sam, num_var = mat.shape
    poly = preprocessing.PolynomialFeatures(2)
    feature_mat = np.delete(mat, label_location, axis=1).astype(np.float)
    feature_mat = poly.fit_transform(feature_mat)
    #feature_mat = np.concatenate((feature_mat, (feature_mat[:, 41] * feature_mat[:, 41]).reshape((num_sam, 1))), axis=1)
    labels = mat[:, label_location].astype(np.int)

    predicted_lab = model.predict(feature_mat)
    corrected_pred = np.sum(labels == predicted_lab)
    
    label_score = model.predict_proba(feature_mat)
    
    print('The current model stands an AUC of ' + str(roc_auc_score(labels, label_score[:, 1])))
    
    np.savetxt('predicted_lab_RF.txt', predicted_lab.astype(np.int))
    np.savetxt('label_test_RF.txt', labels.astype(np.int))

    test_error = 1 - corrected_pred / labels.size
    return test_error

def model_sim(model, mat):
    poly = preprocessing.PolynomialFeatures(2)
    feature_mat = mat.astype(np.float)
    feature_mat = poly.fit_transform(feature_mat)
    num_sim, num_var = feature_mat.shape
    #feature_mat = np.concatenate((feature_mat, (feature_mat[:, 41] * feature_mat[:, 41]).reshape((num_sim, 1))), axis=1)
    predicted_lab = model.predict(feature_mat).reshape(num_sim, 1)
    full_mat = np.concatenate((feature_mat, predicted_lab), axis=1)
    return full_mat

def simulation(neigh_model, mat, zip_array ,coordinate_array, gender_array, age_array, race_array, prob_dist, daily_indicator, year, mat_norm):
    # generate a random probability prop to population distri. (use zip for now)
    prob = random.random() # 0.0~1.0
    #longi, lati = getcoord(zip)
    coordinate, idx = getzip(prob, coordinate_array, prob_dist)
    #zip_c = int(zip_array[idx])
    gender = getgender(idx, gender_array)
    x_knn = np.append(coordinate, gender)
    age = getage(idx, age_array, gender)
    x_knn = np.append(x_knn, age)
    race = getrace(idx, race_array)
    x_knn = np.append(x_knn, race)
    x_knn = np.append(x_knn, daily_indicator)
    return x_knn

def cf(sim_user, mat, feat, k, mat_norm):
# shapes (8,) and (16,856551) not aligned: 8 (dim 0) != 16 (dim 0)
    #print("start cf")
    sim_user = sim_user.reshape(1,16)
    cos_sim = sim_user.dot(mat.T) / LA.norm(sim_user) / mat_norm
    idx = np.flip( np.argsort(cos_sim).reshape(1,-1), 1)[:,:k]
    tmp = np.flip( np.sort(cos_sim).reshape(1,-1), 1)[:,:k]
    #print("sim_user: ", sim_user.shape)
    #print("mat[idx,:][0] ", mat[idx,:][0].shape)
    #print("stats.mode(mat[idx,:][0], axis = 0)[0][0]: ", stats.mode(mat[idx,:][0], axis = 0)[0][0])
    #print("stats.mode(mat[idx,:][0], axis = 0)[0][0][:8] ", stats.mode(mat[idx,:][0], axis = 0)[0][0][:8])
    sim_user = sim_user.reshape(16,)
    sim_user[:8] = stats.mode(mat[idx,:][0], axis = 0)[0][0][:8]
    sim_user[:8] = (sim_user - 0.0001)[:8].astype(int)
    # could not broadcast input array from shape (8) into shape (1,16)
    return sim_user

def main():
    file = "../CleanedData/gallup_clean_NA_determinant.txt"
    file_age = "../CleanedData/ppl_by_zip.txt"
    file_race = "../CleanedData/race_by_zip.txt"
    
    file_indi = "../CleanedData/daily_ind_1.csv"
    file_indi_oil = "../CleanedData/daily_ind_oil.csv"
    file_indi_S = "../CleanedData/daily_ind_SP500.csv"
    
#     simu_iter = 10000        #327500000 is current US population
    simu_iter = 1000
    
    raw_data = parseFile_raw(file) #raw_data from Gallup daily survey
    header = raw_data[0,:]
    cleaned_data_input = filter_full_feature(raw_data)[1:,:]  #cleaned_data input from Gallup
    
    label = cleaned_data_input[:, :1] #employmed label
    cleaned_data = cleaned_data_input[:, 1:]
    
    age_data = parseFile_reference(file_age)
    age_data = filter_full_feature(age_data)[1:,:]
    coordinate = age_data[:,2:4].astype(np.float) # (longi,lati)
    index = age_data[:,-1].astype(np.float) # prob
    age_dist = age_data[:, 5:-2].astype(np.float)
    
    race_data = parseFile_reference(file_race)
    race_data = filter_full_feature(race_data)[1:,:]
    race_dist = race_data[:, 2:].astype(np.float)
    
    zipcode = age_data[:,:1]
    gender_distribution = age_data[:, 4:5].astype(np.float)
    
    combined_zip_ref = np.concatenate((zipcode, coordinate), axis=1)
    
    zip_code_ind = cleaned_data[:, -1] 
    ind_coordinate, full_list = zip_to_coordinate(zip_code_ind, combined_zip_ref) # coreponding coordinate of the samples.
    
    content_mat = np.concatenate((cleaned_data,ind_coordinate),axis=1)
    content_mat = content_mat[full_list, :]
    label = label[full_list, :]
    
    num_sam, num_var = content_mat.shape
    
    X_knn = content_mat[:, -2:num_var + 1].astype(np.float)# zip vec
    gender = content_mat[:, 8].astype(np.int)
    age = content_mat[:, 9].astype(np.int)
    race = content_mat[:, 10].astype(np.int)
    daily_ind =  content_mat[:, 11:14].astype(np.float)
    X_knn = np.concatenate((X_knn, gender.reshape((num_sam, 1)), age.reshape((num_sam, 1)), race.reshape((num_sam, 1)),daily_ind.reshape((num_sam, 3))),axis=1)
    y_knn = content_mat[:,:8].astype(np.int) # senti mat
    
#     print("get X_knn and y_knn: ")
#     print(X_knn.shape) # (856551, 8)
#     print(y_knn.shape) # (856551, 8)
    mat = np.concatenate((y_knn,X_knn), axis=1)
    
    sim_prob_ref = age_data[:, -1].astype(np.float)
    
    neigh = None 
    dummy_y = convert_dummy(y_knn)
    
    content_mat = np.concatenate((label, dummy_y, X_knn), axis=1)
    train_mat, test_mat = train_test_split(content_mat)
    
    model, train_error = model_train(train_mat, 0)
    test_error = model_test(model, test_mat, 0)
    
    print('The training error for this trail is: ' + str(train_error))
    print('The testing error for this trail is: ' + str(test_error))
    
    indi_array = parseFile_indi(file_indi)
    year_list = indi_array[:, 0]
    indi_list = indi_array[:, 1].astype(np.float)
    oil_array = parseFile_indi(file_indi_oil)
    ind_oil_list = oil_array[:,1].astype(np.float)
    S_array = parseFile_indi(file_indi_S)
    ind_S_list = S_array[:,1].astype(np.float)
    
    num_sim_r = indi_list.shape
    
    employment_rate_16 = []
    employment_rate_25_54 = []
    
    #employment_rate_18.append('>18')
    #employment_rate_25_54.append('25 - 54')
    count = 0
    mat += 0.0001
    mat_norm = LA.norm(mat,axis = 1)
    index = 951
    while index < num_sim_r[0]:
#     for index in range(0, num_sim_r[0]):
#     for index in range(720):
        time_start = time.time()
        print('Started simulation cycle ' + str(count))
        
        ind_list = [indi_list[index], ind_oil_list[index], ind_S_list[index]]
        year = int(year_list[index][-2:])
        X_classify = []
        coord_list = []
        sim_user = []
        for i in range(simu_iter):
            single_sim_user = simulation(neigh, mat, zipcode, coordinate, gender_distribution, age_dist, race_dist, sim_prob_ref, ind_list, year, mat_norm)
            sim_user.append(single_sim_user)
        
        sim_user = np.array(sim_user).astype(float)
        feat, k = 8, 10
        sim_user = np.concatenate((np.zeros((simu_iter,8)), sim_user), axis=1)
        sim_user += 0.0001
        #print("before cf: ", sim_user.shape) # (10000, 8)
        data = sc.parallelize(sim_user)
        #print("before map data.collect: ", data.take(1))
        data = data.map(lambda user: cf(user, mat, feat, k, mat_norm) )
        #print("after map data.collect: ", data.take(1))
        #print("data.collect: ", data.collect())
        #print("data.count: ", data.count())
        
#         mat -= 0.0001
        sim_user = np.array(data.collect())
        coord_list = sim_user[:,8:]
        senti_feature = sc.parallelize(sim_user[:,:8])
        
        upper_limit = [5, 2, 11, 11, 2, 4, 2, 2]
        lower_limit = [1, -1, 0, 0, 0, 1, 0, 0]
        X_classify = senti_feature.map(lambda user: random_shuffle(user, upper_limit, lower_limit) )
        
#         sim_user = cf(mat, sim_user, feat, k, mat_norm)
        #print("after cf: ", sim_user)
        
        
        print ("throw simulated data into the model")
    # throw simulated data into the model, predict their unemplotment rate
        X_classify = np.array(X_classify.collect()).astype(int)
#         coord_list = np.array(coord_list.collect())
        
        #print("get all X_classify and coord_list")
        #print(X_classify.shape) # (2, 8)
        #print(coord_list.shape) # (2, 8)
        
        #print(X_classify[:10,:]) # (2, 8)
        #print(coord_list[:10,:]) # (2, 8)
        
        dummy_classified = convert_dummy(X_classify)
        
        output_array = np.concatenate((dummy_classified, coord_list), axis=1)
        print("get output_array: ", output_array.shape) # (2, 17) # need (n,1128)
        
        # get bad output
        if output_array.shape[1] != 46:
            continue
        
        sim_result = model_sim(model, output_array)
        
        age_array = output_array[:, 41].reshape((simu_iter, 1))
#         print("age_array: ", age_array)
        employment_array = sim_result[:, -1].reshape((simu_iter, 1))
        
        over_16_list = np.argwhere(age_array >= 16)
        age_25_54_list = np.argwhere((age_array >= 25) & (age_array <= 54))
        #over_18_population = over_18_list.shape
        num_over_16, dim = over_16_list.shape
        num_25_54, dim = age_25_54_list.shape
        
        employment_array_16 = employment_array[over_16_list[:,0]]
        employment_array_25_54 = employment_array[age_25_54_list[:,0]]
        
        employment_rate_16.append(np.sum(employment_array_16)/num_over_16)
        employment_rate_25_54.append(np.sum(employment_array_25_54)/num_25_54)
        
        time_end = time.time()
        print('Simulation Cycle ' + str(count) + ' finished in ' + str(time_end - time_start) + 's!')
        count += 1
        
        # save tmp file
        if count % 10 == 0:
            t_age_16 = np.array(employment_rate_16).reshape((count, 1))
            t_age_25_54 = np.array(employment_rate_25_54).reshape((count, 1))

            #ind_list_out = ind_list.reshape(num_sim, 1)

            t_output_array = np.concatenate((t_age_16, t_age_25_54), axis=1)
            np.savetxt('sim_out_daily_RF_CF_spark_optim'+ str(index) + '.txt', t_output_array, delimiter=',', fmt='%1.4f,%1.4f')
#         #if count == 10:
#             #break
        index += 1
        
    age_16 = np.array(employment_rate_16).reshape((count, 1))
    age_25_54 = np.array(employment_rate_25_54).reshape((count, 1))
    
    #ind_list_out = ind_list.reshape(num_sim, 1)
    
    output_array = np.concatenate((age_16, age_25_54), axis=1)
    np.savetxt('sim_out_daily_RF_CF_spark_optim'+ str(simu_iter) + '.txt', output_array, delimiter=',', fmt='%1.4f,%1.4f')
    
    print("all simulation done !")
    
if __name__ == "__main__":    
    main()