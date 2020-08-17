declare -a CURRENT_FILE
declare -a INCOMING_FILE

# Read the local file
readfile="./$BASENAME"
while IFS= read -r line
do
# display $line or do somthing with $line
CURRENT_FILE+=( "$line" )
# printf '%s\n' "$line"
done < "$readfile"

# Read the incoming file
readfile="$CLI/$BASENAME"
while IFS= read -r line
do
# display $line or do somthing with $line
INCOMING_FILE+=( "$line" )
# printf '%s\n' "$line"
done < "$file"

# Get max file length
LEN_INCOMING_FILE=${#INCOMING_FILE[@]}
LEN_CURRENT_FILE=${#CURRENT_FILE[@]}
MAX_LEN=$LEN_INCOMING_FILE
if [ $MAX_LEN -lt $LEN_CURRENT_FILE ]
then 
MAX_LEN=$LEN_CURRENT_FILE
fi

# Compare both file line by line
for ((i=0;i<$MAX_LEN;i++)) do
if [ $i -gt $LEN_INCOMING_FILE ]
then
    echo "  ${i}|${GREEN}+${RESET} ${INCOMING_FILE[$i]}"
elif [ $i -gt $LEN_CURRENT_FILE ]
then
    echo "${i}  |${RED}-${RESET} ${CURRENT_FILE[$i]}"
elif [ "${CURRENT_FILE[$i]}" != "${INCOMING_FILE[$i]}" ]
then
    echo "${i}  |${RED}-${RESET} ${CURRENT_FILE[$i]}"
    echo "  ${i}|${GREEN}+${RESET} ${INCOMING_FILE[$i]}"
fi
done
git diff --no-index "./$BASENAME" "$file"
