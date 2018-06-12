import matplotlib.pyplot as plt
import numpy as np
import time

# index list: 0 - State_of_Economy(Sen): 4 - Excellent, 3 - Good, 2 - Only Fair, 1 - Poor, "-10" - Missing Value
# 1 - satis_future(Sen): 1 - Getting better, 0 - (The same), -1 - Getting worse, -10 - Missing Value, 0 - DK, 10 - Refused
# 2, 3 - lifeladder_now(Sen), lifeladder_future(Sen): Best Possible - 10, Worst Possible - 0, Missing Value - "-10"
# 4 - healthprob_days(Back): Zero days - 0, Missing Value - "-10"
# 5, 6 - time_commute(Back), time_social(Back): (DK/Does not apply/Work from home) - 0, Missing Value - "-10", None - 0, Less than one hour - 0.5, (DK) - "-2"
# 8 - polview(Back): Very Conservative - -2, Conservative - -1, Moderate - 0, Li

content = []
count_incomplete = 0
count_complete = 0
count_part = 0

count = 0

'''

with open('gallup_all_nocol8.txt') as txtfile:
    for row in txtfile:
        row = row.split(',')

        content.append(row)

        for ele in row[51:len(row) - 1]:
            if ele != 'NA' and ele != '""':
                # print(row[49])
                # print(row[len(row) - 1])
                count_part += 1
                break

        if 'NA' not in row[:51] and '""' not in row[:51]:
            count_complete += 1
            # print(row)
        else:
            count_incomplete += 1

        # break
        # if count_complete + count_incomplete > 100000:
        #    break

print("comple: ", count_complete)
print("comple_part: ", count_part)
print("incomple: ", count_incomplete)

'''


def parseFile(file):
    # initialize vari
    content = []
    count, count_incomplete,count_complete, count_part = 0, 0, 0, 0
    cut = 49
    
    filetoWrite = open("gallup_all_complete.txt","w+")
    
    with open(file) as txtfile:
        for line in txtfile:

            line = line.split(',')
            line[-1] = line[-1].strip()
            #print(line)
            
            if count == 0:
                line_cut = line[:5] + line[6:28] + line[31:48] + line[49:51] + line[54:]
            else:
                line_cut = line[1:6] + line[7:29] + line[32:49] + line[50:52] + line[55:]
                
            #content.append(np.array(line_cut))
            content.append(line_cut)
            count += 1
            
            filetoWrite.write(",".join(line_cut)+"\n")
            #break
            
    filetoWrite.close()
    
    #print(len(content[0]))
    #print(content)
    #print("initial content_mat")
    #content_mat = np.array(content)

    #print(content_mat[10])

    #num_sample, num_vari = content_mat.shape
    #print(num_sample)
    #print(num_vari)


time_start = time.time()

with open('gallup_all_nocol8.txt') as txtfile:
    for row in txtfile:

        row = row.split(',')
        row[-1] = row[-1].strip()

        if count == 0:
            content.append(row)
        else:
            content.append(row[1:])

        count += 1

content_mat = np.array(content)
num_sample, num_var = content_mat.shape

time_end = time.time()
print('Reading data is complete! Running time is ' + str(time_end - time_start) + 's!')


discrete_list = [0, 1, 2, 3, 4]
float_list = [12, 13, 14, 15, 16, 17, 21, 40, 59, 60, 61, 62]


def format_conv(mat, i):
    for j in range(1, len(mat[1:, i]) + 1):
        if mat[j, i] == '""' or mat[j, i] == 'NA':
            mat[j, i] = -10
        else:
            mat[j, i] = mat[j, i].strip('"')
            mat[j, i] = mat[j, i].strip('+')


for i in range (0, num_var):
    # state_of_econ cleaning
    if i == 0:
        for j in range(1, len(content_mat[1:, i]) + 1):
            if content_mat[j, i] == '""' or content_mat[j, i] == 'NA':
                content_mat[j, i] = -10
            else:
                content_mat[j, i] = content_mat[j, i].strip('"')
                content_mat[j, i] = content_mat[j, i].strip('+')

                if content_mat[j, i] == 'Excellent':
                    content_mat[j, i] = 4
                elif content_mat[j, i] == 'Good':
                    content_mat[j, i] = 3
                elif content_mat[j, i] == 'Only Fair':
                    content_mat[j, i] = 2
                elif content_mat[j, i] == 'Poor':
                    content_mat[j, i] = 1

    # satis_future cleaning
    elif i == 1:
        for j in range(1, len(content_mat[1:, i]) + 1):
            if content_mat[j, i] == '""' or content_mat[j, i] == 'NA':
                content_mat[j, i] = -10
            else:
                content_mat[j, i] = content_mat[j, i].strip('"')
                content_mat[j, i] = content_mat[j, i].strip('+')

                if content_mat[j, i] == 'Getting better':
                    content_mat[j, i] = 1
                elif content_mat[j, i] == '(The same)':
                    content_mat[j, i] = 0
                elif content_mat[j, i] == 'Getting worse':
                    content_mat[j, i] = -1
                elif content_mat[j, i] == '(DK)':
                    content_mat[j, i] = 0
                elif content_mat[j, i] == '(Refused)':
                    content_mat[j, i] = 10

    #lifeladder_now/future
    elif i == 2 or i == 3:
        for j in range(1, len(content_mat[1:, i]) + 1):
            if content_mat[j, i] == '""' or content_mat[j, i] == 'NA':
                content_mat[j, i] = -10
            else:
                content_mat[j, i] = content_mat[j, i].strip('"')
                content_mat[j, i] = content_mat[j, i].strip('+')

                if content_mat[j, i] == 'Best Possible':
                    content_mat[j, i] = 10
                elif content_mat[j, i] == 'Worst Possible':
                    content_mat[j, i] = 0

    #healthprob_days:
    elif i == 4:
        for j in range(1, len(content_mat[1:, i]) + 1):
            if content_mat[j, i] == '""' or content_mat[j, i] == 'NA':
                content_mat[j, i] = -10
            else:
                content_mat[j, i] = content_mat[j, i].strip('"')
                content_mat[j, i] = content_mat[j, i].strip('+')

                if content_mat[j, i] == 'Zero days':
                    content_mat[j, i] = 0

    # time_commute & time_social:
    elif i == 5 or i == 6:
        for j in range(1, len(content_mat[1:, i]) + 1):
            if content_mat[j, i] == '""' or content_mat[j, i] == 'NA':
                content_mat[j, i] = -10
            else:
                content_mat[j, i] = content_mat[j, i].strip('"')
                content_mat[j, i] = content_mat[j, i].strip('+')

                if content_mat[j, i] == '(DK/Does not apply/Work from home)':
                    content_mat[j, i] = 0
                elif content_mat[j, i] == 'None':
                    content_mat[j, i] = 0
                elif content_mat[j, i] == 'Less than one hour':
                    content_mat[j, i] = 0.5
                elif content_mat[j, i] == '(DK)':
                    content_mat[j, i] = -2

    elif i == 8:




#print(content_mat[1:, 7])
#a = np.histogram(content_mat[1:, 7].astype(np.int))
#plt.hist(a, bins= 20)
#plt.show()


def hist_plot(mat, i, location_str):
    plt.hist(mat[1:, i].astype(np.int))
    plt.gca().set_xlim(mat[1:, i].astype(np.int).min(), mat[1:, i].astype(np.int).max())

    plt.savefig(location_str + str(mat[0, i]))
    plt.close()
    print("Histogram for " + str(mat[0, i]) + " is now completed!")


# for i in range(0, num_var):
#     if i not in float_list:
#         hist_plot(content_mat, i, 'hist_ppl_dist/', num_sample)

#print(type(content_mat[2, 7]))
#hist_plot(content_mat, 7, 'hist_ppl_dist/')


def main():
    path = 'gallup_all_nocol8.txt'
    parseFile(path)
    
    '''
    filetoWrite = open("gallup_all_test.txt","w+")
    filetoWrite.write("1,2,3\n")
    filetoWrite.write("4,5,6")
    filetoWrite.close()
    '''

if __name__ == "__main__":
    main()
