find /path/to/samples -type f -iname "*.wav" | while read f; do
  ch=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels \
       -of default=nk=1:nw=1 "$f")
  if [ "$ch" -eq 1 ]; then
    ffmpeg -y -i "$f" -ac 2 -map_channel 0.0.0 -map_channel 0.0.0 "${f%.wav}_st.wav"
  fi
done

