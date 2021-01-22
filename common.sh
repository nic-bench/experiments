#!/bin/bash
#NPF_CLUSTER="client=nslrack11-100G,nic=0 dut=nslrack12-100G,nic=1"
NPF_CLUSTER="client=nslrack12-100G,nic=1 dut=nslrack11-100G,nic=0"
NPF_FLAGS="$NPF_FLAGS --use-last --variables M=11 --build-folder ./npf_build/"
NPF_RUNS=5
NICABR=cx5
NICNAME="Mellanox Connect-X 5"


#CX6
#NPF_CLUSTER="client=nslrack12-100G,nic=2 dut=nslrack11-100G,nic=2"
#NPF_FLAGS="$NPF_FLAGS --variables MODEL=CX6 DUTSOCKET=1"
#NICABR=cx6
#NICNAME="Mellanox Connect-X 6"

#CX4
#NPF_CLUSTER="client=nslrack12-100G,nic=0 dut=nslrack11-100G,nic=4"
#NPF_FLAGS="$NPF_FLAGS --variables MODEL=CX4 DUTSOCKET=1"
#NICABR=cx4
#NICNAME="Mellanox Connect-X 4"
