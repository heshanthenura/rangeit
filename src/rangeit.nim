import os

proc printUsage() = 
  echo"""
  Usage:
    rangeit network [range/cidr]      Calculate network address.
    rangeit broadcast [range/cidr]    Determine broadcast address.
    rangeit usable [range/cidr]       List all usable IP addresses.
    rangeit details [range/cidr]      Get network, broadcast, and all usable addresses.
  """

when isMainModule:
  let args = commandLineParams()
  
  if args.len == 0:
    printUsage()
    quit(1)