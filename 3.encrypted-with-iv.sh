###
 # @?: *********************************************************************
 # @Author: Weidows
 # @Date: 2022-02-24 18:25:21
 # @LastEditors: Weidows
 # @LastEditTime: 2022-02-25 14:56:54
 # @FilePath: \hls-m3u8-sample\3.encrypted-with-iv.sh
 # @Description: 分片+加密+偏移
 # @!: *********************************************************************
###

workPath="encrypted-with-iv"

rm -rf $workPath/*

ffmpeg -i demo.mp4 -codec copy -f segment -segment_list $workPath/index.m3u8 -segment_time 30 $workPath/%d.ts

encryptionKey=`openssl rand 16 | tee -a $workPath/enc.key | hexdump -e '16/1 "%02x"'`

# ivKey 偏移量,32位16进制数据,如: f86b5decdb6359cb1023e308651dccfb
# 不需要另存文件, 只需要写在 m3u8 文件里
ivKey=`openssl rand -hex 16`

numberOfTsFiles=`ls $workPath/*.ts | wc -l`

for ((i=0; i<$numberOfTsFiles; i ++)) do
    openssl aes-128-cbc -e -in $workPath/$i.ts -out $workPath/enc_$i.ts -nosalt -iv $ivKey -K $encryptionKey
done

# 下面 ${ivKey} 需要获取变量,所以字符串要用""而不能是''
sed "/#EXT-X-TARGETDURATION:/a #EXT-X-KEY:METHOD=AES-128,URI=\"enc.key\",IV=0x${ivKey}" $workPath/index.m3u8 > $workPath/index_new.m3u8

mv $workPath/index_new.m3u8 $workPath/index.m3u8
