import os
import re

modules = []

with os.scandir(".") as files:
#    if not ".terraform" in files:
#        print("Wrong directory.")
#        exit()

    for entry in files:
        if not entry.name.startswith('.') and entry.is_dir():
            modules.append(entry)
#            print(entry.path, entry.name)

mainfiles = []
for module in modules:
    #print(module.path)
    mainfiles.append(module.path + "\\main.tf")

try:
    file = open("main.tf", "r")
except:
    print("main.tf doesn't exist")

    exit()


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

    if "var." in lines:
        match2 = re.search("\\((.*?)\\)", lines)
        if match2 != None:
            r2 = match2.group(1)
            r2 = r2.replace("(", "")
            r2 = r2.replace(")", "")
        else:
            match4 = re.search("= (.*)", lines)
            r2 = match4.group(1)
            #r2 = lines+"else"

        match3 = re.search("(var.*)\\[.*", lines)
        if match3 != None:
            r2 = match3.group(1)
        variablesList[0].append(resourceIndex)
        variablesList[1].append(r2)
        
file.close()
for i in range(len(variablesList[0])):
    print(variablesList[0][i], variablesList[1][i])
