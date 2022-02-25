###
 # @?: *********************************************************************
 # @Author: Weidows
 # @Date: 2022-02-24 18:25:21
 # @LastEditors: Weidows
 # @LastEditTime: 2022-02-25 22:46:52
 # @FilePath: \hls-m3u8-sample\2.encrypted-without-iv.sh
 # @Description: 分片+加密
 # @!: *********************************************************************
###

workPath="2.encrypted-without-iv"

# 清除原先的
rm -rf $workPath/*

# 分片
ffmpeg -i demo.mp4 -codec copy -f segment -segment_list $workPath/index.m3u8 -segment_time 30 $workPath/%d.ts

# 获取加密秘钥
# openssl rand 16
#   随机生成 16B 二进制数据 (16*8=128 位, 对应AES-128-CBC名称)
#
# tee -a $workPath/enc.key
#   将生成的数据输出到秘钥文件 enc.key, 同时把数据交给 hexdump 处理
#
# hexdump -e '16/1 "%02x"'
#   hexdump -e 'a/b format1 format2'
#     a个字节/8位 -> format2 (a可省,默认为1)
#     b个字节/8位 -> format1
#     详见: https://blog.csdn.net/bytxl/article/details/43738103
#
#   每1字节/8位 -> %02x -> 2位16进制
#     也就是二进制转16进制,每4位合1位, 128/4=32位16进制
#   每16字节的结果为1行, 那去掉这个16可以吗?
#     应该是不行的,结果会出错,例如:
#     4a6afd460c84c498b8a817ad66392ef2 √
#     46fd6a4a98c4840cad17a8b8f22e3966 ×
encryptionKey=`openssl rand 16 | tee -a $workPath/enc.key | hexdump -e '16/1 "%02x"'`

# ts 文件数
numberOfTsFiles=`ls $workPath/*.ts | wc -l`

for ((i=0; i<$numberOfTsFiles; i ++)) do
    # without-iv也就是默认iv为32位文件序列号
    #   如 5.ts -> 00000000000000000000000000000005
    initializationVector=`printf '%032x' $i`

    # 对每个分片加密
    openssl aes-128-cbc -e -in $workPath/$i.ts -out $workPath/enc_$i.ts -nosalt -iv $initializationVector -K $encryptionKey
done

# 寻找并添加加密方法和秘钥URL
#   找 "#EXT-X-TARGETDURATION:" 这一段,并在下一行添加
#   #EXT-X-KEY:METHOD=AES-128,URI="enc.key"
sed '/#EXT-X-TARGETDURATION:/a #EXT-X-KEY:METHOD=AES-128,URI="enc.key"' $workPath/index.m3u8 > $workPath/index_new.m3u8

# 覆盖
mv $workPath/index_new.m3u8 $workPath/index.m3u8
