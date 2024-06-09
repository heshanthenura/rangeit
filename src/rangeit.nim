import os, strutils, parseutils

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
    rangeit network [range/cidr]      Calculate network address.
    rangeit broadcast [range/cidr]    Determine broadcast address.
    rangeit usable [range/cidr]       List all usable IP addresses.
    rangeit details [range/cidr]      Get network, broadcast, and all usable addresses.
    rangeit -calc [range/cidr]        Calculate and print details.
    rangeit -au [range/cidr]          Print all usable hosts.
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

when isMainModule:
  let args = commandLineParams()

  if args.len == 0:
    printUsage()
    quit(1)

  let calcIndex = getIndex(args, "-calc")
  if calcIndex != -1 and calcIndex + 1 < args.len:
    var ipNcidr = split(args[calcIndex + 1], "/")
    if ipNcidr.len == 2:
      IP = ipNcidr[0]
      try:
        CIDR = ipNcidr[1].parseInt()
        echo "INFO"
        echo "  |-IP Address: ",IP
        echo "  |-IP Class: ", calculateClass(IP)
        echo "  |-CIDR Value: ", CIDR
        echo "  |-Subnet Mask: ", calculateSubnetMask(CIDR)
        let networkAddress = calculateNetworkAddress(IP, CIDR)
        let broadcastAddress = calculateBroadcastAddress(IP, CIDR)
        echo "  |-Network Address: ", networkAddress
        echo "  |-Broadcast Address: ", broadcastAddress
        echo "  |-Net Bits: ", calculateNetBits(CIDR)
        echo "  |-Host Bits: ", calculateHostBits(CIDR)
      except ValueError:
        echo bgRed & "Error: CIDR value is not a valid integer." & reset
        printUsage()
        quit(1)
    else:
      echo bgRed & "Error: Invalid format for range/cidr." & reset
      printUsage()
      quit(1)
  else:
    printUsage()
    quit(1)
