import sys
from pyspark import SparkConf, SparkContext
import numpy as np
from scipy import stats
from numpy import linalg as LA
import math
import time

conf = SparkConf()
sc = SparkContext(conf=conf)

def cf(sim_user, mat, feat, k, mat_norm):
    
    #print("start cf")
    cos_sim = sim_user.dot(mat.T) / LA.norm(sim_user) / mat_norm
    idx = np.flip( np.argsort(cos_sim).reshape(1,-1), 1)[:,:k]
    #print("after idx")
    tmp = np.flip( np.sort(cos_sim).reshape(1,-1), 1)[:,:k]
    #print("assign feat")
#     print("sim_user: ", sim_user.shape)
    
#     print("mat mode: ", stats.mode(mat[idx,:][0], axis = 0)[0][0][:8])
    sim_user[:8] = stats.mode(mat[idx,:][0], axis = 0)[0][0][:8]
    
#     for i in range(feat):
#         sim_user[i] = stats.mode(mat[idx,i], axis = 1)[0].T[0]
    #print("to int")
#     sim_user[:,:8] = sim_user[:,:8].astype(int)
    
    return sim_user

# sc = SparkContext(conf=conf)
mat = np.ones((856551, 16)) * 2
sim_user = np.ones((10, 8))
sim_user = np.concatenate((np.zeros((10,8)), sim_user), axis=1)
sim_user += 0.0001
print(sim_user.shape)
time_start = time.time()

data = sc.parallelize(sim_user)
# data.take(2)
# data.collect()

feat, k = 8, 10
mat += 0.0001
mat_norm = LA.norm(mat)
data.take(2)
data = data.map(lambda user: cf(user, mat, feat, k, mat_norm) )
mat -= 0.0001

print(data.count())
sim_user = np.array(data.collect())
sim_user -= 0.0001
print(sim_user.shape)
time_end = time.time()
print('cf is complete! Running time is ' + str(time_end - time_start) + 's!')