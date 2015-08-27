#!/bin/sh

# 追従するコミュニティID
community_id="coxxxxxxxx"

# コメントサーバに接続するためのアカウント等の設定
mail="xxxxxxxxxxxxx"
password="xxxxxxxxxxxx"
nicomment_jar_path="./nicomment.jar"
out_charset="utf-8"

# ループごとの待機時間(秒)
sleep_time="45"

# その他の設定
last_file="/tmp/last_autocommloader.txt"
latest_file="/tmp/latest_autocommloader.txt"
community_url="http://com.nicovideo.jp/community/${community_id}"
community_livecast_regex="http://live\.nicovideo\.jp/watch/(lv[0-9]+)\?ref=community.*?class=\"community\""

rm -f "${last_file}" "${latest_file}"
touch $last_file
touch $latest_file

# ループ開始
while true; do
curl -s "${community_url}" | grep -oP "${community_livecast_regex}" | grep -oP "lv[0-9]+" | awk '!lv[$0]++' > ${latest_file}
last_liveid=`cat ${last_file}`
latest_liveid=`cat ${latest_file}`
if [ "${last_liveid}" != "${latest_liveid}" ]; then
echo "${latest_liveid}"
# 放送IDが見つかった
cat ${latest_file} > ${last_file}

# コメントサーバにつなぐ
echo "Connecting Nico Comment Server: ${latest_liveid}"
java -jar "${nicomment_jar_path}" "${mail}" "${password}" "${latest_liveid}" 1984 "${out_charset}" true -100000
echo "Disconnect Nico Comment Server: ${latest_liveid}"

fi

# ちょっと待機
sleep $sleep_time
done


