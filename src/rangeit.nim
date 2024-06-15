import os, strutils, parseutils, math

const
  reset = "\x1b[0m"
  red = "\x1b[31m"
  bgRed = "\x1b[41m"
  green = "\x1b[32m"
  yellow = "\x1b[33m"
  blue = "\x1b[34m"
  magenta = "\x1b[35m"
  cyan = "\x1b[36m"
  white = "\x1b[37m"

var IP: string
var CIDR: int

proc printUsage() = 
  echo """
  Usage:
    rangeit -calc [range/cidr]        Calculate and print details.
      ex: rangeit -calc 192.168.1.1/24
    rangeit -au [range/cidr]          Print all usable IP addresses (optional).
      ex: rangeit -au 192.168.1.1/24
  """

proc getIndex(args: seq[string], target: string): int =
  for i, arg in args:
    if arg == target:
      return i
  return -1

proc calculateClass(ip: string): char =
  let firstOctet = ip.split('.')[0].parseInt()

  if firstOctet <= 127:
    return 'A'
  elif firstOctet <= 191:
    return 'B'
  elif firstOctet <= 223:
    return 'C'
  elif firstOctet <= 239:
    return 'D'
  else:
    return 'E'

proc customSplitEvery(s: string, n: int): seq[string] =
  var parts: seq[string]
  var i = 0
  while i < s.len:
    parts.add(s[i .. min(i + n - 1, s.len - 1)])
    i += n
  return parts

proc calculateSubnetMask(CIDR: int): string =
  var mask = ""
  for i in 0..<32:
    if i < CIDR:
      mask.add('1')
    else:
      mask.add('0')
  let octets = customSplitEvery(mask, 8)
  var resultOctets: seq[string]
  for octet in octets:
    var num: int
    discard parseBin(octet, num)
    resultOctets.add($num)
  return resultOctets.join(".")

proc ipToBinary(ip: string): string =
  var binary = ""
  for part in ip.split('.'):
    binary.add part.parseInt().toBin(8)
  return binary

proc binaryToIp(binary: string): string =
  var ip = ""
  let octets = customSplitEvery(binary, 8)
  for octet in octets:
    var num: int
    discard parseBin(octet, num)
    if ip.len > 0:
      ip.add(".")
    ip.add($num)
  return ip

proc calculateBroadcastAddress(ip: string, cidr: int): string =
  let ipBin = ipToBinary(ip)
  var broadcastBin = ipBin[0..cidr-1]
  for i in cidr..<32:
    broadcastBin.add('1')
  return binaryToIp(broadcastBin)

proc calculateNetworkAddress(ip: string, cidr: int): string =
  let ipBin = ipToBinary(ip)
  var networkBin = ipBin[0..cidr-1]
  for i in cidr..<32:
    networkBin.add('0')
  return binaryToIp(networkBin)

proc calculateNetBits(cidr: int): int =
  return cidr

proc calculateHostBits(cidr: int): int =
  return 32 - cidr

proc calculateTotalIPAddresses(cidr: int): int =
  return pow(2.0, float64(32 - cidr)).int  # Convert the exponent to float before passing to pow

proc printAllUsableIPs(ip: string, cidr: int) =
  var ipBlocks = ip.split('.')
  var ipBlock0 = ipBlocks[0].parseInt()
  var ipBlock1 = ipBlocks[1].parseInt()
  var ipBlock2 = ipBlocks[2].parseInt()
  var ipBlock3 = ipBlocks[3].parseInt()
  
  let totalIpAddrs = calculateTotalIPAddresses(cidr)
  let usableIpAddrs = totalIpAddrs - 2  # Subtract network and broadcast addresses

  # Determine network and broadcast IPs
  let networkAddr = calculateNetworkAddress(ip, cidr)
  let broadcastAddr = calculateBroadcastAddress(ip, cidr)

  # Start from the first usable IP address
  ipBlock3 += 1

  # Loop through usable IP addresses
  for i in 1..usableIpAddrs:
    # Skip network and broadcast addresses
    if ipBlock3 == 0 or ipBlock3 == 255:
      ipBlock3 += 1
      
      if ipBlock3 > 255:
        ipBlock3 = 0
        ipBlock2 += 1

        if ipBlock2 > 255:
          ipBlock2 = 0
          ipBlock1 += 1

          if ipBlock1 > 255:
            ipBlock1 = 0
            ipBlock0 += 1

            if ipBlock0 > 255:
              echo "Reached the end of IPv4 space."
              quit(1)
      
      continue  # Skip to the next iteration if it's a network or broadcast address

    echo "  -" & $ipBlock0 & "." & $ipBlock1 & "." & $ipBlock2 & "." & $ipBlock3

    ipBlock3 += 1

    if ipBlock3 > 255:
      ipBlock3 = 0
      ipBlock2 += 1

      if ipBlock2 > 255:
        ipBlock2 = 0
        ipBlock1 += 1

        if ipBlock1 > 255:
          ipBlock1 = 0
          ipBlock0 += 1

          if ipBlock0 > 255:
            echo "Reached the end of IPv4 space."
            quit(1)

when isMainModule:
  let args = commandLineParams()

  if args.len == 0:
    printUsage()
    quit(1)

  var calcIndex = getIndex(args, "-calc")
  if calcIndex != -1 and calcIndex + 1 < args.len:
    var ipNcidr = split(args[calcIndex + 1], "/")
    if ipNcidr.len >= 2:
      IP = ipNcidr[0]
      try:
        CIDR = ipNcidr[1].parseInt()
        let NAddr = calculateNetworkAddress(IP, CIDR)
        let BAddr = calculateBroadcastAddress(IP, CIDR)
        echo "INFO:"
        echo "  -IP Address: ", IP
        echo "  -IP Class: ", calculateClass(IP)
        echo "  -CIDR Value: ", CIDR
        echo "  -Total IP Addresses: ", calculateTotalIPAddresses(CIDR)
        echo "  -Total Usable IP Addresses: ", calculateTotalIPAddresses(CIDR) - 2
        echo "  -Subnet Mask: ", calculateSubnetMask(CIDR)
        echo "  -Network Address: ", NAddr
        echo "  -Broadcast Address: ", BAddr
        echo "  -Net Bits: ", calculateNetBits(CIDR)
        echo "  -Host Bits: ", calculateHostBits(CIDR)

        # Check if -au flag is present
        if getIndex(args, "-au") != -1:
          echo "\nALL USABLE IP ADRESSES:"
          printAllUsableIPs(NAddr,CIDR)
          

      except ValueError:
        echo bgRed & "Error: CIDR value is not a valid integer." & reset
        quit(1)
    else:
      echo bgRed & "Error: Invalid format for range/cidr." & reset
      quit(1)
  else:
    printUsage()
    quit(1)
