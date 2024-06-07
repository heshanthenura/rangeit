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

proc calculateSubnetMask(cidr: int): string =
  var mask = ""
  for i in 0 ..< 32:
    if i < cidr:
      mask.add('1')
    else:
      mask.add('0')
  
  # Convert binary mask to decimal integer
  var decimalMask: int
  discard parseBin(mask, decimalMask)

  # Split the decimal mask into octets
  var octets: seq[string] = @[]
  for i in 0 ..< 4:
    let octet = (decimalMask shr (24 - i*8)) and 255
    octets.add($octet)

  result = octets.join(".")

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
        echo "IP Class: ", calculateClass(IP)
        echo "Subnet Mask: ", calculateSubnetMask(CIDR)
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
