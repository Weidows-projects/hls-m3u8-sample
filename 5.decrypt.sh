###
 # @?: *********************************************************************
 # @Author: Weidows
 # @Date: 2022-02-25 14:32:18
 # @LastEditors: Weidows
 # @LastEditTime: 2022-02-26 00:12:35
 # @FilePath: \hls-m3u8-sample\5.decrypt.sh
 # @Description: 解密-合并
 # @!: *********************************************************************
###

# inputPath="2.encrypted-without-iv"
# ivKey=""

# inputPath="3.encrypted-with-iv"
# ivKey="0d5cce6d9fbfae9dcc86cb3f12d4eb4b"

# 加密 enc_*.ts 输入路径
inputPath="4.encrypt-with-FFmpeg"
ivKey="36bb7a1e43e1d3d88b779243817a67bc"

# 解密 dec_*.ts 和合并后 mp4 输出路径
outputPath="5.decrypt"

rm -rf $outputPath/*

encryptionKey=$(hexdump -e '16/1 "%02x"' $inputPath/enc.key)

numberOfTsFiles=`ls $inputPath/enc_*.ts | wc -l`

for ((i=0; i<$numberOfTsFiles; i ++)) do
    if [[ $ivKey == "" ]]; then
        ivKey=$(printf '%032x' $i)
    fi

    openssl aes-128-cbc -d -in $inputPath/enc_$i.ts -out $outputPath/dec_$i.ts -nosalt -iv $ivKey -K $encryptionKey
done

# 合并
ffmpeg -allowed_extensions ALL -i $inputPath/index.m3u8 -acodec copy -vcodec copy -f mp4 $outputPath/combine.mp4
