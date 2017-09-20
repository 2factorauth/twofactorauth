import os
import datetime
import pathlib

totalSites = 0
totalBCC = 0

index = 1

dirPath = "../../_data"
filename = os.listdir(dirPath)

def countFile(dir, filename):
    path = dir + "/" + filename
    #print("Testing site: " + path)
    if ".yml" in path:
        file = open(path, 'r')
        processed = True

        global index
        for line in file:
            #print(line)

            if "- name:" in line:

                #check if the previous file has been processed, this accounts for if the BTC support tag does not exist
                if processed == False:
                    global totalSites
                    totalSites+= 1
                processed = False

            #check for bcc tag
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


print("Total websites found: " + str(totalSites))

print("Total BCC supported sites " + str(totalBCC))

#create log
timestamp = datetime.datetime.utcnow()

output = open("./output/bccAccepted_log.csv", "a")

output.write(str(timestamp) + ", " + str(totalBCC) + ", " + str(totalSites) + "\n")

output.close()

#create html file
output = open("../../_includes/count_support.html", "w+")

output.write("<p><span class=\"bcc-yes-count\">" + str(totalBCC) + "</span> out of <span class=\"bcc-total-site-count\">"+ str(totalSites) +"</span> sites listed support Bitcoin Cash.</p>")

output.close()
