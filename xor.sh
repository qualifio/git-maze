#/!bin/bash
{
  echo "${1}" | # start pipeline with first parameter
    fold -w 16 | # break into 16 char lines (note: 4-bit hex char * 16 = 64 bits)
    sed 's/^/0x/' | # prepend '0x' to lines to tell shell their hex numbers
    nl # number the lines (we do this to match corresponding ones)
  echo "${2}" | # do all the same to the second parameter
    fold -w 16 |
    sed 's/^/0x/' |
    nl
} | # coming into this pipe we have lines: 1,...,n,1,...,n
sort -n | # now sort so lines are: 1,1,...,n,n
cut -f 2 | # cut to keep only second field (blocks), ditching the line numbers
paste - - | # paste to join every-other line with tabs (now two-field lines)
while read -r a b; do # read lines, assign 'a' and 'b' to the two fields
  printf "%#0${#a}x" "$(( a ^ b ))" # do the xor and left-pad the result
done |
sed 's/0x//g' | # strip the leading '0x' (here for clarity instead of in the loop)
paste -s -d '\0' - # join all the blocks back into to a big hex string
