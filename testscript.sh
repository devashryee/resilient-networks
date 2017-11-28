for n in "a1" "b1" "a2" "b2" "a3" "b3"; do
  ping -c 1 $n  | grep "bytes from"
done
