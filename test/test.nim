import strutils, parseutils, math

# Custom implementation of splitEvery
proc splitEvery(s: string, n: int): seq[string] =
  var parts: seq[string]
  var i = 0
  while i < s.len:
    parts.add(s[i .. min(i + n - 1, s.len - 1)])
    i += n
  return parts

# Function to calculate the total number of IP addresses in a subnet
proc calculateTotalIPAddresses(cidr: int): int =
  return pow(2.0, float64(32 - cidr)).int  # Convert the exponent to float before passing to pow

# Function to convert IP address to binary format
proc ipToBinary(ip: string): string =
  var binary = ""
  for part in ip.split('.'):
    binary.add part.parseInt().toBin(8)
  return binary

# Function to convert binary format to IP address
proc binaryToIp(binary: string): string =
  var ip = ""
  let octets = splitEvery(binary, 8)
  for octet in octets:
    var num: int
    discard parseBin(octet, num)
    if ip.len > 0:
      ip.add(".")
    ip.add($num)
  return ip

# Function to calculate network address from IP and CIDR
proc calculateNetworkAddress(ip: string, cidr: int): string =
  let ipBin = ipToBinary(ip)
  var networkBin = ipBin[0..cidr-1]
  for i in cidr..<32:
    networkBin.add('0')
  return binaryToIp(networkBin)

# Function to calculate broadcast address from IP and CIDR
proc calculateBroadcastAddress(ip: string, cidr: int): string =
  let ipBin = ipToBinary(ip)
  var broadcastBin = ipBin[0..cidr-1]
  for i in cidr..<32:
    broadcastBin.add('1')
  return binaryToIp(broadcastBin)

# Function to calculate all usable IPs between network and broadcast addresses
proc calculateAllUsableIPs(naddr: string, baddr: string, cidr: int): seq[string] =
  var usableIpAddrs = pow(2.0, float64(32 - cidr)).int - 2
  var ipBlocks = naddr.split('.')
  var ipBlock0 = ipBlocks[0].parseInt()
  var ipBlock1 = ipBlocks[1].parseInt()
  var ipBlock2 = ipBlocks[2].parseInt()
  var ipBlock3 = ipBlocks[3].parseInt()
  
  var usableIPs: seq[string] = @[]

  for i in 0..<usableIpAddrs:
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
            break
    usableIPs.add($ipBlock0 & "." & $ipBlock1 & "." & $ipBlock2 & "." & $ipBlock3)

  return usableIPs

# Function to get usable IPs in the specified range
proc getUsableIPsInRange(ip: string, cidr: int, startRange, endRange: int): seq[string] =
  let networkAddr = calculateNetworkAddress(ip, cidr)
  let broadcastAddr = calculateBroadcastAddress(ip, cidr)
  let allUsableIPs = calculateAllUsableIPs(networkAddr, broadcastAddr, cidr)

  # Filter and return the IPs within the specified range
  return allUsableIPs[startRange-1..min(endRange-1, allUsableIPs.high)]

# Test the function
let ip = "192.168.1.1"
let cidr = 24
let startRange = 1
let endRange = 23
let usableIPs = getUsableIPsInRange(ip, cidr, startRange, endRange)
for ip in usableIPs:
  echo ip
