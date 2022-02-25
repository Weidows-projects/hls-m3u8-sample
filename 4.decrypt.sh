###
 # @?: *********************************************************************
 # @Author: Weidows
 # @Date: 2022-02-25 14:32:18
 # @LastEditors: Weidows
 # @LastEditTime: 2022-02-25 15:34:10
 # @FilePath: \hls-m3u8-sample\4.decrypt.sh
 # @Description: 解密
 # @!: *********************************************************************
###

# workPath="encrypted-without-iv"
# ivKey=""

workPath="encrypted-with-iv"
ivKey="0d5cce6d9fbfae9dcc86cb3f12d4eb4b"

encryptionKey=$(hexdump -e '16/1 "%02x"' $workPath/enc.key)

numberOfTsFiles=`ls $workPath/enc_*.ts | wc -l`

for ((i=0; i<$numberOfTsFiles; i ++)) do
    if [[ $ivKey == "" ]]; then
        ivKey=$(printf '%032x' $i)
    fi

    openssl aes-128-cbc -d -in $workPath/enc_$i.ts -out $workPath/dec_$i.ts -nosalt -iv $ivKey -K $encryptionKey
done
