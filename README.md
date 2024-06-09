# RangeIt

## Download

* ### [Linux](https://github.com/heshanthenura/rangeit/releases/tag/linux-v1.0)

* ### [MacOS](https://github.com/heshanthenura/rangeit/releases/tag/macos-v1.0)

* ### [Windows](https://github.com/heshanthenura/rangeit/releases/tag/v1.0)

## Overview
`rangeit` is a utility tool designed for professionals working in networking to calculate and display various details about a given IP range. It supports operations like calculating the network address, broadcast address, and more. Our goal is to provide an easy-to-use tool for network administrators and IT professionals to manage and understand their networks better.

## Features
*  **Network Address Calculation:** Determines the network address based on the provided IP and CIDR.

* **Broadcast Address Calculation:** Determines the broadcast address for the given IP range.

* **Subnet Mask Calculation:** Calculates the subnet mask for the provided CIDR.

* **IP Class Determination:** Identifies the class (A, B, C, D, E) of the provided IP address.

* **Net Bits Calculation:** Calculates the number of bits used for the network portion of the IP address.

* **Host Bits Calculation:** Calculates the number of bits used for the host portion of the IP address.

## Planned Features
We are actively working on adding the following features:

* **Usable IP Address Calculation:** List all usable IP addresses within a given network range.

## Usage
```bash 
rangeit -calc [range/cidr] 
```

#### Example
```bash 
rangeit -calc 192.168.1.1/24
```
Output
```bash
INFO
  |-IP Address: 192.1.0.1
  |-IP Class: C
  |-CIDR Value: 24
  |-Subnet Mask: 255.255.255.0
  |-Network Address: 192.1.0.0
  |-Broadcast Address: 192.1.0.255
  |-Net Bits: 24
  |-Host Bits: 8
```

