import os
import datetime

totalSites = 0
totalBCC = 0

missingList = ["File, Tag"]
failedPaths = 0
missingEntries = 0

index = 1

dirPath = "../../_data"
filename = os.listdir(dirPath)

def countFile(dir, filename):
    path = dir + "/" + filename
    #print("Testing site: " + path)
    if ".yml" in path:
        file = open(path, 'r')
        processed = True
        prevName = ''

        pathFail=False
        global index

        global missingList
        missingList.append(filename + ": \n")
        for line in file:
            #print(line)

            if "- name:" in line:

                #check if the previous file has been processed, this accounts for if the BTC support tag does not exist
                if processed == False:
                    global totalSites
                    totalSites+= 1
                    nameLine = line.replace("- name:", "")
                    nameLine = nameLine.replace("\n", "")
                    nameLine = nameLine.replace(" ", "")
                    nameLine = nameLine.replace("&amp", "&")
                    missingList[index] = missingList[index] + " " + nameLine + ","
                    global missingEntries
                    missingEntries += 1
                processed = False

            if "bcc: " in line:
                if "Yes" in line:
                    global totalBCC
                    totalBCC += 1
                    totalSites += 1
                processed = True
        index += 1

counter = 0
while counter < len(filename):
    path = dirPath + "/" + filename[counter]
    #print("Testing path: " + path)

    countFile(dirPath, filename[counter])
    counter += 1


#create log
timestamp = datetime.datetime.utcnow()

output = open("./output/missingBCC_log.csv", "a")

output.write(str(timestamp) + ", " + str(failedPaths) + ", " + str(missingEntries) + "\n")

output.close()

output = open("./output/missingBCC.txt", "w+")

for string in missingList:
    #print(string + "\n")
    output.write(string + "\n")

#print()
output.write("\n")

#print("Total websites found: " + str(totalSites))
#output.write("Total websites found: " + str(totalSites) + ". \n")

#print("Total BCC supported sites " + str(totalBCC))
#output.write("Total BCC supported sites " + str(totalBCC) + ". \n")

failedPaths = len(missingList) - 1

print(str(failedPaths) + " files have entries missing the bcc tag")
output.write(str(failedPaths) + " files have entries missing the bcc tag \n")

print(str(missingEntries) + " entries are missing the bcc tag")
output.write(str(missingEntries) + " entries are missing the bcc tag \n")

output.close()
