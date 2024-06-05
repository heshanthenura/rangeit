import os

proc printUsage() = 
  echo"""
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

when isMainModule:
  let args = commandLineParams()
  echo "Number of arguments:",args.len
  echo "Calc flag is in ", getIndex(args, "-calc")
  echo args[getIndex(args, "-calc")+1]
  if args.len == 0:
    printUsage()
    quit(1)