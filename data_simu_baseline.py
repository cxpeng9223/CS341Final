import time
import numpy as np
import random
from sklearn.neighbors import KNeighborsRegressor
from sklearn.neighbors import KNeighborsClassifier

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
            #if count != 0:
            content.append(row[0:4] + [row[22]] + [row[32]] + [row[12].strip("'")])

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

def parseFile1(file):
    time_start = time.time()

    content = []
    count, count_incomplete,count_complete, count_part = 0, 0, 0, 0
    
    with open(file) as txtfile:
        for row in txtfile:
            row = row.split(',')
            row[-1] = row[-1].strip().strip(']')
            row[0] = row[0][1:]
            row[0] = row[0].strip("'")
            content.append(row)

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
    #print(full_list)
    mat = mat[full_list, :]
    return mat

def model(x_mat):
    return np.array([1,1,0])

#convert a probability into the coordinate of a zip code using population probability distritbuion
#prob: float between 0 and 1
#reference_array: a 2-d array contaning the coordinates of the reference zipcodes
#prob_dist: a 1-d array shows the accumulated population distribution as a percentage of the total population in the US.
def getzip(prob, reference_array, prob_dist):
    idx = np.where(prob_dist >= prob)
    idx = idx[0][0]
    coord = reference_array[idx, :]
    return coord


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
    

def simulation(neigh, reference_array, prob_dist):
    
    # generate a random probability prop to population distri. (use zip for now)
    prob = random.random() # 0.0~1.0
    
    #longi, lati = getcoord(zip)
    x_knn = getzip(prob, reference_array, prob_dist)
    
    # generate sentiment features (use knn for now)
    senti_feature = neigh.predict([x_knn])
    
    return senti_feature, x_knn


def main():
    '''
    Perform simulation by hashing background info (w/ fixed date), 
    Calculate unemployment rate
    Testing
        Gallup collects new 1000 surveys with (label 1/0)
        Update classification and CF/KNN model with the newly collected data (RNN)
        Perform simulation by hashing background info (w/ fixed date)
        Calculate new unemployment rate
    '''
    
    file = "CleanedData/gallup_clean_NA_determinant.txt"
    file1 = "CleanedData/ppl_by_zip.txt"
    simu_iter = 100         #327500000 is current US population
    data = filter_full_feature(parseFile(file))[1:,:]
    data2 = filter_full_feature(parseFile1(file1))[1:,:]
    coordinate = data2[:,2:4].astype(np.float) # (longi,alti)
    index = data2[:,-1].astype(float) # prob
    
    #tmp = tmp.astype(np.float)
    zipcode = data2[:,:1]
    print(index.shape)
    print(np.where(index > 0.99999))
    
    combined_zip_ref = np.concatenate((zipcode, coordinate), axis=1)
    
    zip_code_ind = data[:, 6] 
    ind_coordinate, full_list = zip_to_coordinate(zip_code_ind, combined_zip_ref) # coreponding coordinate of the samples.
    
    content_mat = np.concatenate((data,ind_coordinate),axis=1)
    content_mat = content_mat[full_list, :]
    
    num_sam, num_var = content_mat.shape
    
    X_knn = content_mat[:, -2:num_var + 1].astype(np.float) # zip vec
    y_knn = content_mat[:,:6].astype(np.int) # senti mat
    print(X_knn.shape)
    print(y_knn.shape)
    
    sim_prob_ref = data2[:, 4].astype(np.float)
    
    neigh = KNeighborsClassifier(n_neighbors=10)
    neigh.fit(X_knn, y_knn)
    
    # simu n times
    X_classify = []
    coord_list = []
    for i in range(simu_iter):
        for i %100000 == 0:
            print("iter",i)
        senti_fea, coord = simulation(neigh, coordinate, sim_prob_ref)
        coord_list.append(coord)
        X_classify.append(senti_fea[0])
    
    # throw simulated data into the model, predict their unemplotment rate
    X_classify = np.array(X_classify)
    coord_list = np.array(coord_list)
    output_array = np.concatenate((X_classify, coord_list), axis=1)
    print(output_array.astype(np.float))
    
    # for loop, use knn for prediction, would be straight since no time features
    neigh = KNeighborsClassifier(n_neighbors=10)
    neigh.fit(X_knn, y_knn)
    
    y = neigh.predict([[1.1]])
    
    # calculate the rate
    rate = y[i] / y[j] # wrong
    print(rate)
    #save simulation to txt output 
    np.savetxt('sim_out.txt', output_array, delimiter=',',fmt='%1i,%1i,%1i,%1i,%1i,%1i,%10f, %10f')
    
    #pred_classify = model(X_classify) # [0/1  ...]
    
    #daily_rate = pred_classify[pred_classify > 0].shape[0] / pred_classify.shape[0]
    #print("daily_rate: ", daily_rate)

if __name__ == "__main__":    
    main()