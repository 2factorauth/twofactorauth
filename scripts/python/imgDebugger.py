import os
import datetime
import shutil
import codecs

totalSites = 0
totalImg = 0

missingList = []
brokenPathList = []
movedImages = []
createdDir = []
errorMessages = []
imgList = []
failedPaths = 0
missingEntries = 0

index = 0

#dirPath = "../../_data"
dirPath = os.path.join("..","..","_data")
#imgBaseDir = "../../img"
imgBaseDir = os.path.join("..","..","img")

filename = os.listdir(dirPath)
imgBase = os.listdir(imgBaseDir)

imgSubDirList = []
imgFileList = []

#scans directories for updates (in case a directory has been removed)
def scanDir():
    global imgBase
    imgBase = os.listdir(imgBaseDir)
    global imgFileList
    imgFileList = []
    global imgList
    imgList = []
    for dir in imgBase:
        if "." in dir:
            imgFileList.append(dir)
        else:
            imgList.append(dir)      

scanDir()

def removeDir(srcImg, rmDir):
    try:
        os.remove(srcImg)
        os.rmdir(rmDir)
    except:
        pass

#scan for image and move
def findImg(image, fileTitle, index, logMessage):
    foundFile = False

    #find image
    for dir in imgList:
        
        srcPath = os.path.join(imgBaseDir, dir)
        tmpList = os.listdir(srcPath)
        if image in tmpList:
            #location to move to
            destPath = os.path.join(imgBaseDir, fileTitle, image)
            #create a copy of the file
            srcImg = os.path.join(srcPath, image)
            shutil.copyfile(srcImg, destPath)

            #check copied file should also belong in the old folder
            ymlName = dir + ".yml"
            ymlPath = os.path.join(dirPath, ymlName)
            
            try:
                file = codecs.open(ymlPath, "r", "utf-8")
                fileFound = False
                for line in file:
                    if image in line:
                        fileFound = True
                #check if file belongs in current directory
                if fileFound == False:
                    os.remove(srcImg)
            except Exception as e:
                global errorMessages
                errorMessages.append("yml file " + dir + " does not exist")
                rmDir = os.path.join(imgBaseDir, dir)
                removeDir(srcImg, rmDir)
                scanDir()
                

            global movedImages
            movedImages.append(image + ", " + fileTitle + " | Moved: " + srcImg + " to " + destPath)
            break

    if foundFile == False:
        global totalImg
        totalImg += 1
        brokenPathList[index] = logMessage

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
        missingList.append("\n======================================================================================= \n" + filename + ": \n======================================================================================= \n")
        brokenPathList.append("\n======================================================================================= \n" + filename + ": \n======================================================================================= \n")
        for line in file:
            #print(line)

            if "- name:" in line:
                global totalSites
                totalSites+= 1
                    
                nameLine = line.replace("- name:", "")
                nameLine = nameLine.replace("\n", "")
                nameLine = nameLine.replace("\r", "")
                nameLine = nameLine.replace(" ", "")
                nameLine = nameLine.replace("&amp", "&")
                #check if the previous file has been processed, this accounts for if the BTC support tag does not exist
                if processed == False:
                    
                    missingList[index] = missingList[index] + " " + nameLine + ","
                    global missingEntries
                    missingEntries += 1
                    if pathFail == False:
                        pathFail = True
                        global failedPaths
                        failedPaths += 1
                processed = False

            if "img: " in line:
                if "png" in line or "jpg" in line or "bmp" in line or "gif" in line:
                    imgLine = line.replace("img:", "")
                    imgLine = imgLine.replace("\n", "")
                    imgLine = imgLine.replace("\r", "")
                    imgLine = imgLine.replace(" ", "")
                    #print(imgLine)
                    logMessage = brokenPathList[index] + " " + nameLine + ", " + imgLine + " | "
                    #build path
                    fileTitle = filename.replace(".yml", "")
                    subPath = os.path.join(imgBaseDir, fileTitle)
                    if fileTitle in imgBase:
                        subImgList = os.listdir(subPath)
                        if imgLine in subImgList:
                            pass
                        else:
                            #look for file location here
                            if fileTitle in imgList:
                                #move file to appropriate directory here
                                #location to move to
                                destPath = os.path.join(imgBaseDir, fileTitle)
                                srcImg = os.path.join(imgBaseDir, imgLine)
                                if os.path.isfile(srcImg):
                                    #move
                                    try:
                                        shutil.move(srcImg, destPath)
                                        #print("moved " + srcImg + " to " + destPath)
                                        movedImages.append(imgLine + ", " + fileTitle + " | Moved: " + srcImg + " to " + destPath)
                                    except Exception as e:
                                        brokenPathList[index] + " " + nameLine + ", " + imgLine + " | "
                                else:
                                    #scan other directories for the file, just to make sure it's not in the wrong directory
                                    findImg(imgLine, fileTitle, index, logMessage)
                            else:
                                #create directory
                                destPath = os.path.join(imgBaseDir, fileTitle)
                                os.mkdir(destPath)
                                #scan other directories for the file, just to make sure it's not in the wrong directory and move
                                findImg(imgLine, fileTitle, index, logMessage)
                        
                    else:
                        try:
                            os.mkdir(subPath)
                        except Exception as e:
                            pass
                    dirList = os.listdir(subPath)
                processed = True
        index += 1

for file in filename:
    fileTitle = file.replace(".yml", "")
    path = os.path.join(imgBaseDir, fileTitle)
    try:
        os.mkdir(path)
        createdDir.append(path)
        scanDir()
    except Exception as e:
        pass
    #print("Testing path: " + path)
    
    countFile(dirPath, file)

#create log
timestamp = datetime.datetime.utcnow()

outputPath = os.path.join(".", "output")
try:
	os.mkdir(outputPath)
except Exception as e:
	pass

output = codecs.open(os.path.join(outputPath,"missingImg_log.csv"), "a", "utf-8")

output.write(str(timestamp) + ", " + str(failedPaths) + ", " + str(missingEntries) + "\n")

output.close()

output = codecs.open(os.path.join(outputPath,"missingImg.txt"), "w+", "utf-8")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
output.write("Missing tags \n")
output.write("File, Tag \n")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
for string in missingList:
    #print(string + "\n")
    output.write(string + "\n")

#print()
output.write("\n")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
output.write("Broken paths \n")
output.write("File, Name, Path | \n")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
for string in brokenPathList:
    #print(string + "\n")
    output.write(string + "\n")

#print()
output.write("\n")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
output.write("Moved images \n")
output.write("File, Directory \n")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
for string in movedImages:
    #print(string + "\n")
    output.write(string + "\n")

#print()
output.write("\n")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
output.write("Created directories \n")
output.write("Directory \n")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
for string in createdDir:
    #print(string + "\n")
    output.write(string + "\n")

#print()
output.write("\n")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
output.write("Error messages \n")
output.write("Errors \n")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
for string in errorMessages:
    #print(string + "\n")
    output.write(string + "\n")

#print()

output.write("\n")

output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
output.write("Summary \n")
output.write("////////////////////////////////////////////////////////////////////////////////////////////// \n")
print(str(totalSites) + " total sites scanned")
output.write(str(totalSites) + "  total sites scanned \n")

print(str(failedPaths) + " files have entries missing the img tag")
output.write(str(failedPaths) + " files have entries missing the img tag \n")

print(str(missingEntries) + " entries are missing the img tag")
output.write(str(missingEntries) + " entries are missing the img tag \n")

print(str(totalImg) + " entries have broken img links")
output.write(str(totalImg) + " entries have broken img links \n")
output.close()
