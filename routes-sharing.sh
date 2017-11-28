# High level task: remove all routes to 10.* subnets
echo "$(route -n)" | while read -r line; 
do 
  OLDSUBNET=$(echo $line | awk '{print $1;}')
  OLDNETMASK=$(echo $line | awk '{print $3;}')
  if [[ $OLDSUBNET == 10* ]]
  then
    sudo route del -net $OLDSUBNET netmask $OLDNETMASK
  fi
done
 
 
# High level task: Get list of experiment interfaces and IPs
# parse ifconfig output to get dictionary of interfaces and IP addresses
# eth0 => 10.1.2.1, eth1 => 10.2.1.1
# remove any that don't start with 10
declare -A arr
declare -A brr


for i in $(ifconfig | grep "eth" | awk '{print $1;}')
do 
  IP=$(ifconfig $i | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
  if [[ $IP == 10* ]]
  then
    arr["$i"]=$IP
    brr["$IP"]=$i
  fi
done
 
# This is how to get the list:
for key in ${!arr[@]}
do 
  echo ${key} ${arr[${key}]} 
done
 
# High level task: set up a route without gateway for each subnet we are connected to
# for each interface in dictionary,
for key in ${!arr[@]}
do 
  echo "Setting up route for ${key} ${arr[${key}]}" 
  # set DEST and IFACE variables
  IFACE=${key}
  DEST=$(echo ${arr[${key}]} | cut -d"." -f1-3) 
  DEST=$DEST".0"
 
  # route command
  sudo route add -net $DEST netmask 255.255.255.0 $IFACE
done
 
 
# High level task: Find out what node this is
HOST=$(hostname -s)
 
# High level task: If node is a1, b1, a2, b2, a3, b3
 
# Get first three parts of IP address
# set GW variable to first three parts of IP with a ".1" at the end
if [[ $HOST == a* ]] || [[ $HOST == b* ]]
then
  for key in ${!arr[@]}
  do 
    echo "Setting up route for ${key} ${arr[${key}]}" 
    # set DEST and IFACE variables
    IFACE=${key}
    GW=$(echo ${arr[${key}]} | cut -d"." -f1-3) 
    GW=$GW".1"
    # route command
    sudo route add -net 10.0.0.0/8 gw $GW dev $IFACE
  done
fi  
 
 
# High level task: 4 routes with gateways, one for each subnet 
# it's NOT directly connected to. Each of these routes should 
# give as gateway the IP address of the "next hop" 
# (address of the next P node) to get to that subnet.
if [[ $HOST == p1 ]]
then
  # need to set up routes to a2, b2, a3, b3
  sudo route add -net 10.1.2.0 netmask 255.255.255.0 gw 10.1.12.2 dev ${brr["10.1.12.1"]}
  sudo route add -net 10.2.2.0 netmask 255.255.255.0 gw 10.2.12.2 dev ${brr["10.2.12.1"]}
  sudo route add -net 10.1.3.0 netmask 255.255.255.0 gw 10.1.13.3 dev ${brr["10.1.13.1"]}
  sudo route add -net 10.2.3.0 netmask 255.255.255.0 gw 10.2.13.3 dev ${brr["10.2.13.1"]}
  
  # sharing routes to a2, b2, a3, b3
  sudo route add -net 10.1.2.0 netmask 255.255.255.0 gw 10.2.12.2 dev ${brr["10.2.12.1"]} metric 2
  sudo route add -net 10.2.2.0 netmask 255.255.255.0 gw 10.1.12.2 dev ${brr["10.1.12.1"]} metric 2
  sudo route add -net 10.1.3.0 netmask 255.255.255.0 gw 10.2.13.3 dev ${brr["10.2.13.1"]} metric 2
  sudo route add -net 10.2.3.0 netmask 255.255.255.0 gw 10.1.13.3 dev ${brr["10.1.13.1"]} metric 2
  
  
 
  # add backup routes ; thank you for this :D
  sudo route add -net 10.1.2.0 netmask 255.255.255.0 gw 10.1.13.3 dev ${brr["10.1.13.1"]} metric 5
  sudo route add -net 10.2.2.0 netmask 255.255.255.0 gw 10.2.13.3 dev ${brr["10.2.13.1"]} metric 5
  sudo route add -net 10.1.3.0 netmask 255.255.255.0 gw 10.1.12.2 dev ${brr["10.1.12.1"]} metric 5
  sudo route add -net 10.2.3.0 netmask 255.255.255.0 gw 10.2.12.2 dev ${brr["10.2.12.1"]} metric 5
  
  sudo route add -net 10.1.2.0 netmask 255.255.255.0 gw 10.2.13.3 dev ${brr["10.2.13.1"]} metric 7
  sudo route add -net 10.2.2.0 netmask 255.255.255.0 gw 10.1.13.3 dev ${brr["10.1.13.1"]} metric 7
  sudo route add -net 10.1.3.0 netmask 255.255.255.0 gw 10.2.12.2 dev ${brr["10.2.12.1"]} metric 7
  sudo route add -net 10.2.3.0 netmask 255.255.255.0 gw 10.1.12.2 dev ${brr["10.1.12.1"]} metric 7
 
fi
if [[ $HOST == p2 ]]  
then
  # need to set up routes to a1, b1, a3, b3
  sudo route add -net 10.1.1.0 netmask 255.255.255.0 gw 10.1.12.1 dev ${brr["10.1.12.2"]}
  sudo route add -net 10.2.1.0 netmask 255.255.255.0 gw 10.2.12.1 dev ${brr["10.2.12.2"]}
  sudo route add -net 10.1.3.0 netmask 255.255.255.0 gw 10.1.23.3 dev ${brr["10.1.23.2"]}
  sudo route add -net 10.2.3.0 netmask 255.255.255.0 gw 10.2.23.3 dev ${brr["10.2.23.2"]}
  
  # sharing routes to a1, b1, a3, b3
  sudo route add -net 10.1.1.0 netmask 255.255.255.0 gw 10.2.12.1 dev ${brr["10.2.12.2"]} metric 2
  sudo route add -net 10.2.1.0 netmask 255.255.255.0 gw 10.1.12.1 dev ${brr["10.1.12.2"]} metric 2
  sudo route add -net 10.1.3.0 netmask 255.255.255.0 gw 10.2.23.3 dev ${brr["10.2.23.2"]} metric 2
  sudo route add -net 10.2.3.0 netmask 255.255.255.0 gw 10.1.23.3 dev ${brr["10.1.23.2"]} metric 2
  
  #add backup routes
  sudo route add -net 10.1.1.0 netmask 255.255.255.0 gw 10.1.23.3 dev ${brr["10.1.23.2"]} metric 5
  sudo route add -net 10.2.1.0 netmask 255.255.255.0 gw 10.2.23.3 dev ${brr["10.2.23.2"]} metric 5
  sudo route add -net 10.1.3.0 netmask 255.255.255.0 gw 10.1.12.1 dev ${brr["10.1.12.2"]} metric 5
  sudo route add -net 10.2.3.0 netmask 255.255.255.0 gw 10.2.12.1 dev ${brr["10.2.12.2"]} metric 5
  
  sudo route add -net 10.1.1.0 netmask 255.255.255.0 gw 10.2.23.3 dev ${brr["10.2.23.2"]} metric 7
  sudo route add -net 10.2.1.0 netmask 255.255.255.0 gw 10.1.23.3 dev ${brr["10.1.23.2"]} metric 7
  sudo route add -net 10.1.3.0 netmask 255.255.255.0 gw 10.2.12.1 dev ${brr["10.2.12.2"]} metric 7
  sudo route add -net 10.2.3.0 netmask 255.255.255.0 gw 10.1.12.1 dev ${brr["10.1.12.2"]} metric 7

fi
if [[ $HOST == p3 ]]  
then
  # need to set up routes to a2, b2, a1, b1
  sudo route add -net 10.1.2.0 netmask 255.255.255.0 gw 10.1.23.2 dev ${brr["10.1.23.3"]}
  sudo route add -net 10.2.2.0 netmask 255.255.255.0 gw 10.2.23.2 dev ${brr["10.2.23.3"]}
  sudo route add -net 10.1.1.0 netmask 255.255.255.0 gw 10.1.13.1 dev ${brr["10.1.13.3"]}
  sudo route add -net 10.2.1.0 netmask 255.255.255.0 gw 10.2.13.1 dev ${brr["10.2.13.3"]}
  
  # sharing routes to a2, b2, a1, b1
  sudo route add -net 10.1.2.0 netmask 255.255.255.0 gw 10.2.23.2 dev ${brr["10.2.23.3"]} metric 2
  sudo route add -net 10.2.2.0 netmask 255.255.255.0 gw 10.1.23.2 dev ${brr["10.1.23.3"]} metric 2
  sudo route add -net 10.1.1.0 netmask 255.255.255.0 gw 10.2.13.1 dev ${brr["10.2.13.3"]} metric 2
  sudo route add -net 10.2.1.0 netmask 255.255.255.0 gw 10.1.13.1 dev ${brr["10.1.13.3"]} metric 2
  
  # backups :)
  sudo route add -net 10.1.2.0 netmask 255.255.255.0 gw 10.1.13.1 dev ${brr["10.1.13.3"]} metric 5
  sudo route add -net 10.2.2.0 netmask 255.255.255.0 gw 10.2.13.1 dev ${brr["10.2.13.3"]} metric 5
  sudo route add -net 10.1.1.0 netmask 255.255.255.0 gw 10.1.23.2 dev ${brr["10.1.23.3"]} metric 5
  sudo route add -net 10.2.1.0 netmask 255.255.255.0 gw 10.2.23.2 dev ${brr["10.2.23.3"]} metric 5
  
  sudo route add -net 10.1.2.0 netmask 255.255.255.0 gw 10.2.13.1 dev ${brr["10.2.13.3"]} metric 7
  sudo route add -net 10.2.2.0 netmask 255.255.255.0 gw 10.1.13.1 dev ${brr["10.1.13.3"]} metric 7
  sudo route add -net 10.1.1.0 netmask 255.255.255.0 gw 10.2.23.2 dev ${brr["10.2.23.3"]} metric 7
  sudo route add -net 10.2.1.0 netmask 255.255.255.0 gw 10.1.23.2 dev ${brr["10.1.23.3"]} metric 7
fi
