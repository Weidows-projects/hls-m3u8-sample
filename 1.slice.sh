###
 # @?: *********************************************************************
 # @Author: Weidows
 # @Date: 2022-02-24 18:25:21
 # @LastEditors: Weidows
 # @LastEditTime: 2022-02-25 22:46:28
 # @FilePath: \hls-m3u8-sample\1.slice.sh
 # @Description: 仅分片
 # @!: *********************************************************************
###

workPath="1.slice"

rm -rf $workPath/*

ffmpeg -i demo.mp4 -codec copy -f segment -segment_list $workPath/index.m3u8 -segment_time 30 $workPath/%d.ts
