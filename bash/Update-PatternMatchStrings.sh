#!/bin/bash

# Functionality:
# Replace #{BP_XXXXX} placeholders with variables from bitbucket pipeline env variables value
# File Pattern : *.feature

fileExtensionToSearch="*.feature"

rootRepoPath=$(git rev-parse --show-toplevel) &&
echo "Git Repo root path: $rootRepoPath"

repoTestsPath="$rootRepoPath/tests"
echo "Tests path: $repoTestsPath"

cd $repoTestsPath

#Look for all files
files_array=($(find "$repoTestsPath" -type f -name "$fileExtensionToSearch"))
echo "Feature files detected: ${#files_array[@]}"

#Look for placeholders and Replace variables
for i in "${files_array[@]}";
    do
        #Replace placeholders: #{BP_XXXXX}
        featureFile=${i}
        echo "--------------------------------------------------------------------------------------------------------------"
        echo "Update in progress for file : $featureFile"
        echo "--------------------------------------------------------------------------------------------------------------"
        varToReplace=($(grep -o "#{BP_.*}" $featureFile))
        
        for i in "${varToReplace[@]}";
            do
                toReplace=${i}

                #This is to handle scenario when multiple placeholders are in same line of feature file
                if [[ "$toReplace" =~ BP_.* ]]
                then
                    trimmedVarToReplace=($(echo "$toReplace" | sed 's/"//g'))
                    echo "Variable : $trimmedVarToReplace will be updated from env variables"

                    trimmed=($(echo "$trimmedVarToReplace" | sed 's/#{//g; s/}//g'))
                    valueToUpdate="${!trimmed}"
                    if [ -z "${valueToUpdate}" ]
                    then
                        echo "Variable not found in env variables !"
                        exit 1
                    else
                        sed -i "s|$trimmedVarToReplace|$valueToUpdate|g" "$featureFile"
                    fi
                fi
            done
    done

echo "------------------------Script execution finished----------------------------------"
