#!/bin/bash


# branch=5.0.0-early-access-2
branch=5.0
# branch=ue5-main
# branch=release

build_date=$(date +"%Y%m%d_%H%M%S")

 

dir_build="/home/$LOGNAME/UE5/$branch/$build_date/"

if [[ ! -d "$dir_build" ]]
    then
        mkdir -p $dir_build
fi

free_space=$(df $dir_build | tail -n +2 | awk '{print $4}')

  


if [[ $free_space -lt 220000000 ]]
then 
    rm -rf $dir_build
    
    echo "not enough space on primary disk"
    
    dir_build="/surv2/UE5/$branch/$build_date/"
    
    if [[ ! -d "$dir_build" ]]
    then
        mkdir -p $dir_build
        
        free_space=$(df $dir_build | tail -n +2 | awk '{print $4}')
        
                
        if [[ $free_space -lt 22000000 ]]
        then 
        
        rm -rf $dir_build
        
        echo "not enough space on secondary disk"
        exit
        
        fi

    fi


fi    
  


cd $dir_build
# 
# git clone git@github.com:EpicGames/UnrealEngine.git
# 
# git checkout $branch
echo "##### Getting git work done...#####"

git clone --depth 1 git@github.com:EpicGames/UnrealEngine.git -b $branch

echo "##### git work done, starting Setup.sh #####"

yes | $dir_build/UnrealEngine/Setup.sh  

echo "##### GENERATING PROJECT FILES #####"

yes | $dir_build/UnrealEngine/GenerateProjectFiles.sh

cd ${dir_build}/UnrealEngine/
echo "##### DOING MAKE 1 #####"
make 

echo "##### DOING MAKE 2 #####"

make CrashReportClient ShaderCompileWorker UnrealLightmass UnrealPak UnrealEditor


echo "##### DONE DONE #####"


echo "##### creating link #####"

ln -s $dir_build/UnrealEngine/Engine/Binaries/Linux/UnrealEditor /home/$LOGNAME/unreal_editors/UE5_${branch}_$build_date
