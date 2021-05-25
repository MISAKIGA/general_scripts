#!/bin/bash

unzipDir="/usr/local/docker/"
#初始化
init(){
        echo "init"
        if [ ! `ls | grep docker-in.tar`];then
                echo "请检查当前路径是否存在docker-in.tar"
                exit 2
        fi

        echo "解压到$unzipDir"
        tar -zxvf ./docker-in.tar -C $unzipDir
        if [ ! $? -eq 0 ];then
                echo "解压失败!"
                exit 2
        fi
        echo "解压成功!"       
}

scanning(){
        cd $unzipDir

        tbDir=()
        echo ${tbDir[*]}
        for i in `ls -1`
        do
                if [ -d "$i" ];then
                        echo "即将在docker上安装以下软件$i"
                        tbDir[$j]=$i
                        j=`expr $j + 1`
                fi
        done

        tempDir=${tbDir[*]}
        if [ ! -n tempDir ];
        then
                echo "安装目录为空!"
                exit 2
        fi

        echo "待安装:${tbDir[*]}"
        for i in ${tbDir[*]}
        do
                echo "aaa$i"
                tbInstall $i
                if [ ! $? -eq 0 ];then
                        echo "$i安装失败!"
                        continue
                fi
        done
}

tbInstall(){
        echo "准备安装 $1 !"

        tbIn=$1/docker-compose.yml

        if [ ! `ls $1 |grep docker-compose.yml` ];then
                echo "$tbIn 没有找到docker-compose.yml"
                return
        fi

        docker-compose -f $1/docker-compose.yml up -d

        if [ ! $? -eq 0 ];then
                exit 3
        fi
        echo "安装完成!"
}


main()
{
        init
        scanning
}
main
#main > ./run.log 2>&1