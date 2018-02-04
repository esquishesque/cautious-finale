### THIS IS FOR EX5 ###

from decimal import Decimal, ROUND_HALF_UP
import csv
import random
from random import shuffle
import copy
import os.path

#####setup


###options

#definitions
divisor = 5 #divisor in combining the 1d distributions
numLists = 32 #total lists
len_matrix = 11 #how many rows and columns; not actually robust
blocks = 3 #distinct blocks in the experiment; not actually robust
numSubLists = 8 #not actually robust
numSubBlocks = 2 #not actually robust
numPhases = blocks*numSubBlocks
numListSets = int(numLists/numSubLists)
random.seed(0.7623330311662739)
slash = '/'
folder = ['','Users','emcee','Documents','school','dissertation','ex5','stimuli_lists','temp_stimuli_lists','']
folder = slash.join(map(str,folder))


###the rest

#functions
def createMatrixFrom1D(vector,len_matrix):
    return [vector for i in range(len_matrix)]

def t(matrix):
    return [list(x) for x in zip(*matrix)]

def createMatrixFrom2D(h_vector,v_vector,divisor):
    output = [row[:] for row in h_vector]
    for i in range(len(output)):
        for j in range(len(output[i])):
            output[i][j] = int(Decimal((h_vector[i][j] * v_vector[i][j])/divisor).quantize(0, ROUND_HALF_UP))
    return output

def getTotalTrials(matrix,blocks):
    return(sum(sum(x) for x in matrix)*2*blocks)

def flip(x):
    df = list(zip(*x[::-1]))
    df = list(zip(*df[::-1]))
    return(df)

def add(matrix1,matrix2):
    output = [row[:] for row in matrix1]
    for i in range(len(output)):
        for j in range(len(output[i])):
            output[i][j] = matrix1[i][j] + matrix2[i][j]
    return output

def printMatrix(matrix):
    print("matrix:")
    [print(row) for row in matrix]

def createPointLists(reps_matrix,names_matrix):
    output = []
    for i in range(len(names_matrix)):
        output.append([])
        for j in range(len(names_matrix[i])):
            output[i].append([])
            for rep in range(reps_matrix[i][j]):
                output[i][j].append(names_matrix[i][j])
    return output

def getPointGroupsFromIndices(indices,pointlists):
    x=0
    y=1
    output = []
    for i in range(len(indices)):
        output.append([])
        for j in range(len(indices[i])):
            for stimulus in pointlists[indices[i][j][x]][indices[i][j][y]]:
                output[i].append(stimulus)
    return output

def integrateLists(s_list,z_list):
    tempNum = len(s_list+z_list)//4 + 1
    insertS = []
    [insertS.append([True, True, False, False]) for i in range(tempNum)]
    [shuffle(list) for list in insertS]
    insertS = [item for sublist in insertS for item in sublist]
    output = []
    while(len(s_list)>0 and len(z_list)>0):
        if(insertS.pop()):
            output.append("s"+s_list.pop())
        else:
            output.append("z"+z_list.pop())
    while(len(s_list)>0):
        output.append("s"+s_list.pop())
    while(len(z_list)>0):
        output.append("z"+z_list.pop())
    return output

#establish d = distribution
d_narrow = [1,1,5,10,5,1,1,0,0,0,0]
d_wide = [2,3,4,6,4,3,2,0,0,0,0]
d_canon = [1,2,5,8,5,2,1,0,0,0,0]

#establish h = horizonal matrix ; v = vertical matrix
v_narrow = createMatrixFrom1D(d_narrow,len_matrix)
v_wide = createMatrixFrom1D(d_wide,len_matrix)
v_canon = createMatrixFrom1D(d_canon,len_matrix)
h_narrow = t(v_narrow)
h_wide = t(v_wide)
h_canon = t(v_canon)

#establish m = 2d matrix
m_widenarrow = createMatrixFrom2D(v_wide,h_narrow,divisor)
print(getTotalTrials(m_widenarrow,blocks))
m_canoncanon = createMatrixFrom2D(v_canon,h_canon,divisor)
print(getTotalTrials(m_canoncanon,blocks))

#establish s = /s/ matrix ; z = /z/ matrix
s_widenarrow = [row[:] for row in m_widenarrow]
z_widenarrow = flip(m_widenarrow)
s_canoncanon = [row[:] for row in m_canoncanon]
z_canoncanon = flip(m_canoncanon)

#establish c = combined matrix
c_widenarrow = add(s_widenarrow,z_widenarrow)
c_canoncanon = add(s_canoncanon,z_canoncanon)

#create matrix with the names of points
names = [["{}-{}".format(5+(i*9),5+(j*9)) for i in range(len_matrix)] for j in range(len_matrix)]

#establist spl = /s/ pointlists ; zpl = /z/ point lists
spl_widenarrow = createPointLists(s_widenarrow,names)
zpl_widenarrow = createPointLists(z_widenarrow,names)
spl_canoncanon = createPointLists(s_canoncanon,names)
zpl_canoncanon = createPointLists(z_canoncanon,names)

#establish spgi = /s/ point group indices ; zpgi = /z/ point group indices
#HIGHEST FREQ ONE MUST BE FIRST ON THE LIST
spgi_widenarrow = [[[3, 3]],
    [[3, 2]],
    [[4, 2]],
    [[2, 3]],
    [[2, 2]],
    [[4, 3]],
    [[2, 4]],
    [[3, 4]],
    [[4, 4]],
    [[0, 0], [1, 0], [0, 1], [1, 1]],
    [[2, 0], [4, 0]],
    [[3, 0], [3, 1]],
    [[4, 1], [5, 2]],
    [[5, 0], [6, 0], [5, 1], [6, 1]],
    [[5, 3], [6, 3]],
    [[6, 2], [6, 4]],
    [[5, 4], [4, 5]],
    [[5, 5], [6, 5], [5, 6], [6, 6]],
    [[4, 6], [2, 6]],
    [[3, 5], [3, 6]],
    [[1, 4], [2, 5]],
    [[0, 5], [1, 5], [0, 6], [1, 6]],
    [[0, 2], [0, 4]],
    [[0, 3], [1, 3]],
    [[1, 2], [2, 1]]]

zpgi_widenarrow = [[[i+4 for i in j] for j in k] for k in spgi_widenarrow]

spgi_canoncanon = [[[3, 3]],
    [[3, 0]],
    [[4, 0],[6, 4]],
    [[1, 1],[2, 2]],
    [[2, 1]],
    [[4, 1]],
    [[5, 1],[4, 2]],
    [[1, 2]],
    [[3, 2]],
    [[5, 2]],
    [[6, 2],[5, 3]],
    [[0, 3]],
    [[1, 3],[0, 4]],
    [[2, 3]],
    [[2, 0],[3, 1]],
    [[4, 3]],
    [[6, 3]],
    [[1, 4]],
    [[2, 4],[1, 5]],
    [[3, 4]],
    [[4, 4],[5, 5]],
    [[5, 4]],
    [[2, 5]],
    [[3, 5],[4, 6]],
    [[4, 5]]]

zpgi_canoncanon= [[[i+4 for i in j] for j in k] for k in spgi_canoncanon]


#establish spg = /s/ point groups ; zpg = /z/ point groups
spg_widenarrow = getPointGroupsFromIndices(spgi_widenarrow,spl_widenarrow)
zpg_widenarrow = getPointGroupsFromIndices(zpgi_widenarrow,zpl_widenarrow)
spg_canoncanon = getPointGroupsFromIndices(spgi_canoncanon,spl_canoncanon)
zpg_canoncanon = getPointGroupsFromIndices(zpgi_canoncanon,zpl_canoncanon)

#establish point groups for test list
test_pgi = ["t{}-{}".format(i,j) for i in range(len_matrix//2-1,len_matrix//2+2) for j in range(len_matrix//2-1,len_matrix//2+2)]

##### loop to create lists

# loop twice
finalLists = []
finalNames = []

for i in range(numListSets):

    #set up blank lists for the generated lists to go in
    szAwn_phases = []
    zsBwn_phases = []
    szAnw_phases = []
    zsBnw_phases = []
    szAcc_phases = []
    zsBcc_phases = []

    for j in range(numSubBlocks):

    # for each of s and z:
    # create randomisation of each list
        [shuffle(list) for list in spg_widenarrow]
        [shuffle(list) for list in zpg_widenarrow]

    # pop one instance of the most frequent s/z off to use later
        s = spg_widenarrow[0].pop()
        z = zpg_widenarrow[0].pop()

    # cut each of those randomisations in half
        sA_widenarrow = [list[:(len(list)//2)] for list in spg_widenarrow]
        sB_widenarrow = [list[(len(list)//2):] for list in spg_widenarrow]
        zA_widenarrow = [list[:(len(list)//2)] for list in zpg_widenarrow]
        zB_widenarrow = [list[(len(list)//2):] for list in zpg_widenarrow]

    # flatten lists and randomise
        sA_widenarrow = [item for sublist in sA_widenarrow for item in sublist]
        zA_widenarrow = [item for sublist in zA_widenarrow for item in sublist]
        sB_widenarrow = [item for sublist in sB_widenarrow for item in sublist]
        zB_widenarrow = [item for sublist in zB_widenarrow for item in sublist]
        shuffle(sA_widenarrow)
        shuffle(zA_widenarrow)
        shuffle(sB_widenarrow)
        shuffle(zB_widenarrow)

    # integrate s and z lists
        szA_widenarrow = integrateLists(sA_widenarrow[:],zA_widenarrow[:])
        zsB_widenarrow = integrateLists(sB_widenarrow[:],zB_widenarrow[:])
        szA_narrowwide = [s[::-1] for s in szA_widenarrow]
        zsB_narrowwide = [z[::-1] for z in zsB_widenarrow]

    # put most frequent s at the beginning and most frequent z at the end - this is 12 on first and 34 on second
        szA_widenarrow.insert(0,"s"+s)
        zsB_widenarrow.append("z"+z)
        szA_narrowwide.insert(0,"s"+s)
        zsB_narrowwide.append("z"+z)

    # add them to lists of lists
        szAwn_phases.append(szA_widenarrow)
        zsBwn_phases.append(zsB_widenarrow)
        szAnw_phases.append(szA_narrowwide)
        zsBnw_phases.append(zsB_narrowwide)

    #create canon lists
    [shuffle(list) for list in spg_canoncanon]
    [shuffle(list) for list in zpg_canoncanon]
    s = spg_canoncanon[0].pop()
    z = zpg_canoncanon[0].pop()
    sA_canoncanon = [list[:(len(list)//2)] for list in spg_canoncanon]
    sB_canoncanon = [list[(len(list)//2):] for list in spg_canoncanon]
    zA_canoncanon = [list[:(len(list)//2)] for list in zpg_canoncanon]
    zB_canoncanon = [list[(len(list)//2):] for list in zpg_canoncanon]
    sA_canoncanon = [item for sublist in sA_canoncanon for item in sublist]
    zA_canoncanon = [item for sublist in zA_canoncanon for item in sublist]
    sB_canoncanon = [item for sublist in sB_canoncanon for item in sublist]
    zB_canoncanon = [item for sublist in zB_canoncanon for item in sublist]
    shuffle(sA_canoncanon)
    shuffle(zA_canoncanon)
    shuffle(sB_canoncanon)
    shuffle(zB_canoncanon)
    szA_canoncanon = integrateLists(sA_canoncanon[:],zA_canoncanon[:])
    zsB_canoncanon = integrateLists(sB_canoncanon[:],zB_canoncanon[:])
    szA_canoncanon.insert(0,"s"+s)
    zsB_canoncanon.append("z"+z)
    szAcc_phases.append(szA_canoncanon)
    zsBcc_phases.append(zsB_canoncanon)

    # create test phases
    test_phases = []
    for point in range(numPhases):
        shuffle(test_pgi)
        test_phases.append([test_pgi[:] for x in range(numSubLists)])

    # create exp phases
    finalNames.extend(["12wn34nw", "12nw34wn", "21wn43nw", "21nw43wn", "34wn12nw", "34nw12wn", "43wn21nw", "43nw21wn"])
    exp_phases = []
    for point in range(numPhases):
        exp_phases.append([])
    #doing manually and hacky-ly
    exp_phases[0].extend([szAwn_phases[0][:],    # Fwna1
                         szAnw_phases[0][:],    # Fnwa1
                         zsBwn_phases[0][::-1],    # Rwnb1
                         zsBnw_phases[0][::-1],    # Rnwb1
                         szAwn_phases[1][:],    # Fwna2
                         szAnw_phases[1][:],    # Fnwa2
                         zsBwn_phases[1][::-1],    # Rwnb2
                         zsBnw_phases[1][::-1]])    # Rnwa2
    exp_phases[1].extend([zsBwn_phases[0][:],    # Fwnb1
                         zsBnw_phases[0][:],    # Fnwb1
                         szAwn_phases[0][::-1],    # Rwna1
                         szAnw_phases[0][::-1],    # Rnwa1
                         zsBwn_phases[1][:],    # Fwnb2
                         zsBnw_phases[1][:],    # Fnwb2
                         szAwn_phases[1][::-1],    # Rwna2
                         szAnw_phases[1][::-1]])    # Rwna2
    exp_phases[2].extend([szAcc_phases[0][:],     # Fcca
                         szAcc_phases[0][:],     # Fcca
                         zsBcc_phases[0][::-1],     # Rccb
                         zsBcc_phases[0][::-1],     # Rccb
                         szAcc_phases[0][:],     # Fcca
                         szAcc_phases[0][:],     # Fcca
                         zsBcc_phases[0][::-1],     # Rccb
                         zsBcc_phases[0][::-1]])     # Rccb
    exp_phases[3].extend([zsBcc_phases[0][:],     # Fccb
                         zsBcc_phases[0][:],     # Fccb
                         szAcc_phases[0][::-1],     # Rcca
                         szAcc_phases[0][::-1],     # Rcca
                         zsBcc_phases[0][:],     # Fccb
                         zsBcc_phases[0][:],     # Fccb
                         szAcc_phases[0][::-1],     # Rcca
                         szAcc_phases[0][::-1]])     # Rcca
    exp_phases[4].extend([szAnw_phases[1][:],    # Fnwa2
                         szAwn_phases[1][:],    # Fwna2
                         zsBnw_phases[1][::-1],    # Rnwb2
                         zsBwn_phases[1][::-1],    # Rwnb2
                         szAnw_phases[0][:],    # Fnwa1
                         szAwn_phases[0][:],    # Fwna1
                         zsBnw_phases[0][::-1],    # Rnwb1
                         zsBwn_phases[0][::-1]])    # Rwna1
    exp_phases[5].extend([zsBnw_phases[1][:],    # Fnwb2
                         zsBwn_phases[1][:],    # Fwnb2
                         szAnw_phases[1][::-1],    # Rnwa2
                         szAwn_phases[1][::-1],    # Rwna2
                         zsBnw_phases[0][:],    # Fnwb1
                         zsBwn_phases[0][:],    # Fwnb1
                         szAnw_phases[0][::-1],    # Rnwa1
                         szAwn_phases[0][::-1]])    # Rnwa1

    for sublist in range(numSubLists):
        current_list = []
        for phase in range(numPhases):
            current_list.append([])
            current_list[phase].extend(exp_phases[phase][sublist])
            current_list[phase].extend(test_phases[phase][sublist])
        finalLists.append(current_list)



[print(name) for name in finalNames]
[print(l[:5]) for l in finalLists]


#####print lists
for i in range(len(finalLists)): #for each list, create output folder
    outputFolder = "{}P{}{}".format(folder,i+1,slash)
    if not os.path.exists(outputFolder):
        os.makedirs(outputFolder)

    metaStim = ['file']
    metaStimFile = "{}P{}.csv".format(folder,i+1) #name file
    ifile = open(metaStimFile, 'w', newline='') #create file
    iwriter = csv.writer(ifile, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL) #create writer
    for j in range(numPhases): #for each phase
        stimFile = "{}P{}-block{}.csv".format(outputFolder,i+1,j+1) #make a file for that block
        metaStim.append("stimuli_lists{}P{}{}P{}-block{}.csv".format(slash,i+1,slash,i+1,j+1)) #write the name of the file in the directory file
        jfile = open(stimFile, 'w', newline='') #create file
        jwriter = csv.writer(jfile, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL) #create writer
        headers = "stimulus,left,right" #create column names
        jwriter.writerow([headers]) #write column names
        if j % 2 == 0:
            first = finalLists[i][j][0][0]
        else:
            first = finalLists[i][j-1][0][0]
        if first == "s":
            hands = ",SA,ZA"
        else:
            hands = ",ZA,SA"
        for k in range(len(finalLists[i][j])): #for lines from beginning of phase to end
           jwriter.writerow([finalLists[i][j][k]+hands]) #write the line from the list
        jfile.close() #close the file
    for row in metaStim: #for each row the directory file
        iwriter.writerow([row]) #print the row
    ifile.close() #close the file