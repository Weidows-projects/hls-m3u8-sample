###
 # @?: *********************************************************************
 # @Author: Weidows
 # @Date: 2022-02-25 22:37:50
 # @LastEditors: Weidows
 # @LastEditTime: 2022-02-26 00:10:44
 # @FilePath: \hls-m3u8-sample\4.encrypt-with-FFmpeg.sh
 # @Description:
 # @!: *********************************************************************
###

workPath="4.encrypt-with-FFmpeg"
urlPrefix="."

rm -rf $workPath/*

# enc.keyinfo
#   写到 m3u8 里的 keyURL | https://hlsbook.net/enc.key
#   加密用的 key 文件地址  | enc.key
#   IV值 (可选)          | ecd0d06eaf884d8226c33928e87efa33
#   详见: https://hlsbook.net/how-to-encrypt-hls-video-with-ffmpeg/

openssl rand 16 > $workPath/enc.key

tmpfile=`mktemp`
echo $urlPrefix/enc.key > $tmpfile
echo $workPath/enc.key >> $tmpfile
echo `openssl rand -hex 16` >> $tmpfile
mv $tmpfile $workPath/enc.keyinfo

ffmpeg -y -i demo.mp4 -c copy -hls_time 30 -hls_key_info_file $workPath/enc.keyinfo -hls_playlist_type vod -hls_segment_filename $workPath/enc_%d.ts $workPath/index.m3u8
