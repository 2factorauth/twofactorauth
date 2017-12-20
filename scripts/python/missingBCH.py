import os
import datetime
import codecs

totalSites = 0
totalBCH = 0

missingList = ["File, Tag"]
failedPaths = 0
missingEntries = 0

index = 1

dirPath = os.path.join("..","..","_data")
filename = os.listdir(dirPath)

def countFile(dir, filename):
    path = os.path.join(dir, filename)
    #print("Testing site: " + path)
    if ".yml" in path:
        file = codecs.open(path, 'r', "utf-8")
        processed = True
        prevName = ''

        pathFail = False
        global index

        global missingList
        missingList.append(filename + ": \n")
        for line in file:
            #print(line)

            if "- name:" in line:
                global totalSites
                totalSites+= 1
                #check if the previous file has been processed, this accounts for if the BTC support tag does not exist
                if processed == False:

                    nameLine = line.replace("- name:", "")
                    nameLine = nameLine.replace("\n", "")
                    nameLine = nameLine.replace("\r", "")
                    nameLine = nameLine.replace(" ", "")
                    nameLine = nameLine.replace("&amp", "&")
                    missingList[index] = missingList[index] + " " + nameLine + ","
                    global missingEntries
                    missingEntries += 1
                    if pathFail == False:
                        pathFail = True
                        global failedPaths
                        failedPaths += 1
                processed = False

            if "bch: " in line:
                if "Yes" in line:
                    global totalBCH
                    totalBCH += 1
                processed = True
        index += 1

for file in filename:
    #print("Testing path: " + path)
    countFile(dirPath, file)

#create log
timestamp = datetime.datetime.utcnow()

outputPath = os.path.join(".", "output")
try:
	os.mkdir(outputPath)
except Exception as e:
	pass

output = codecs.open(os.path.join(outputPath, "missingBCH_log.csv"), "a", "utf-8")

output.write(str(timestamp) + ", " + str(failedPaths) + ", " + str(missingEntries) + "\n")

output.close()

output = codecs.open(os.path.join(".","output","missingBCH.txt"), "w+", "utf-8")

for string in missingList:
    #print(string + "\n")
    output.write(string + "\n")

#print()
output.write("\n")

#print("Total websites found: " + str(totalSites))
#output.write("Total websites found: " + str(totalSites) + ". \n")

#print("Total BCH supported sites " + str(totalBCH))
#output.write("Total BCH supported sites " + str(totalBCH) + ". \n")

print(str(failedPaths) + " files have entries missing the bch tag")
output.write(str(failedPaths) + " files have entries missing the bch tag \n")

print(str(missingEntries) + " entries are missing the bch tag")
output.write(str(missingEntries) + " entries are missing the bch tag \n")

output.close()
