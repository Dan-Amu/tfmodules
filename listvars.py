import os
import re

    
def ReadMainfile(file):
    resourceList = []
    variablesList = [[], []]
    
    resourceIndex = 0
    for lines in file:
        if "resource" in lines:
            # regex "(.*?)" captures anything between two quotes
            match = re.search("\"(.*?)\"", lines)
            if match == None:
                continue
            r = match.group()
            r = r.replace("\"", "")
            resourceList.append(r)
            resourceIndex = resourceIndex + 1 
    
        if "var." in lines or "module." in lines:
            match2 = re.search("\\((.*?)\\)", lines)
            if match2 != None:
                r2 = match2.group(1)
                r2 = r2.replace("(", "")
                r2 = r2.replace(")", "")
            else:
                #print(lines+" TEST")
                if "=" in lines:
                    match4 = re.search("= (.*)", lines)
                    r2 = match4.group(1)
                else:
                    r2 = lines
    
            #match3 = re.search("(var.*)\\[.*", lines)       --old regex
            match3 = re.search("(var.*)\\[.*|(module.*)\\[.*", lines)
            if match3 != None:
                if match3.group(1) is None:
                    r2 = match3.group(2)
                else:
                    r2 = match3.group(1)
    
            variablesList[0].append(resourceIndex)
            variablesList[1].append(r2)
            
    lastPrintedTitle = 0
    isTitlePrinted = False
    for i in range(len(variablesList[1])):
        titleIndex = variablesList[0][i]-1
    
        if lastPrintedTitle != titleIndex:
            isTitlePrinted = False
    
        if not isTitlePrinted: 
            lastPrintedTitle = titleIndex
            isTitlePrinted = True
            print("    \n"+resourceList[titleIndex])
    
        print("       -"+str(variablesList[1][i]))
    print("\n")


modules = []

with os.scandir(".") as files:
#    if not ".terraform" in files:
#        print("Wrong directory.")
#        exit()

    for entry in files:
        if not entry.name.startswith('.') and entry.is_dir():
            modules.append(entry)
#            print(entry.path, entry.name)

mainfiles = ["main.tf"]
for module in modules:
    #print(module.path)
    mainfiles.append(module.path + "\\main.tf")

#try:
#    currentFile = open("main.tf", "r")
#except:
#    print("main.tf doesn't exist")
#
#    exit()
#try:
for mf in mainfiles:
    cFile = open(mf, "r")
    print(f"In file {mf}:\n")
    ReadMainfile(cFile)
    cFile.close()
#except:
#    print("I've encountered a problem. Not sure what to do. Exiting.")
#    exit()
