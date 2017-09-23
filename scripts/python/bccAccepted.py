import os
import datetime
import pathlib
import codecs

totalSites = 0
totalBCC = 0

index = 1

dirPath = os.path.join("..","..","_data")
filename = os.listdir(dirPath)

def countFile(dir, filename):
    path = os.path.join(dir, filename)
    #print("Testing site: " + path)
    if ".yml" in path:
        file = codecs.open(path, 'r', "utf-8")
        processed = True

        global index
        for line in file:
            #print(line)

            if "- name:" in line:
                global totalSites
                totalSites+= 1

            #check for bcc tag
            if "bcc: " in line:
                if "Yes" in line:
                    global totalBCC
                    totalBCC += 1
                processed = True
        index += 1


for file in filename:
    #print("Testing path: " + path)

    countFile(dirPath, file)


print("Total websites found: " + str(totalSites))

print("Total BCC supported sites " + str(totalBCC))

#create log
timestamp = datetime.datetime.utcnow()

outputPath = os.path.join(".", "output")
try:
	os.mkdir(outputPath)
except Exception as e:
	pass

output = codecs.open(os.path.join(outputPath,"bccAccepted_log.csv"), "a", "utf-8")

output.write(str(timestamp) + ", " + str(totalBCC) + ", " + str(totalSites) + "\n")

output.close()

#create html file
output = codecs.open(os.path.join("..","..","_includes","count_support.html"), "w+", "utf-8")

output.write("<p><span class=\"bcc-yes-count\">" + str(totalBCC) + "</span> out of <span class=\"bcc-total-site-count\">"+ str(totalSites) +"</span> sites listed support Bitcoin Cash.</p>")

output.close()
