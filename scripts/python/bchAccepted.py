import os
import datetime
import pathlib
import codecs

totalSites = 0
totalBCH = 0

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

            #check for bch tag
            if "bch: " in line:
                if "Yes" in line:
                    global totalBCH
                    totalBCH += 1
                processed = True
        index += 1

print("\n acceptBitcoin.Cash Site Analyser")
print("-================================-")

for file in filename:
    #print("Testing path: " + path)
	if "examples.yml" not in file:
		countFile(dirPath, file)


print("- Total websites listed: " + str(totalSites))
print("- Total websites supporting BCH: " + str(totalBCH))

#create log
timestamp = datetime.datetime.utcnow()

outputPath = os.path.join(".", "output")
try:
	os.mkdir(outputPath)
except Exception as e:
	pass

output = codecs.open(os.path.join(outputPath,"bchAccepted_log.csv"), "a", "utf-8")

output.write(str(timestamp) + ", " + str(totalBCH) + ", " + str(totalSites) + "\n")

output.close()

#create html file
output = codecs.open(os.path.join("..","..","_includes","count_support.html"), "w+", "utf-8")

print("- Generating HTML snippet for website progress bar...")

output.write(' \
<div class="ui container progress bch-progress" data-value="' + str(totalBCH) + '" data-total="' + str(totalSites) + '" id="bch-count"> \
  <div class="bar"> \
    <div class="progress"></div> \
  </div> \
  <div class="label" data-tooltip="Please help to improve this ratio by sending tweets to, or writing on the wall of the merchants/websites that you hope to see support Bitcoin Cash." data-position="bottom center" data-inverted=""><b>' + str(totalBCH) + '</b> out of <b>' + str(totalSites) + '</b> websites listed support Bitcoin Cash.</div> \
</div>')

output.close()

print("\nDone!")
