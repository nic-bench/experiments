#!/bin/bash
#NPF_CLUSTER="client=nslrack11-100G,nic=0 dut=nslrack12-100G,nic=1"

NPF_RUNS=3

T1=1

if [ ${NICABR} = "cx5" ] ; then
    NPF_CLUSTER="client=nslrack12-100G,nic=1 dut=nslrack11-100G,nic=0"
    NPF_FLAGS="$NPF_FLAGS --use-last --variables M=11 --build-folder ./npf_build/"
    NICNAME="Mellanox Connect-X 5"
fi

#CX6
if [ ${NICABR} = "cx6" ] ; then
    NPF_CLUSTER="client=nslrack12-100G,nic=2 dut=nslrack11-100G,nic=2"
    NPF_FLAGS="$NPF_FLAGS --variables MODEL=CX6 DUTSOCKET=1"
    NICNAME="Mellanox Connect-X 6"
fi

#CX4
if [ ${NICABR} = "cx4" ] ; then
    NPF_CLUSTER="client=nslrack12-100G,nic=0 dut=nslrack11-100G,nic=4"
    NPF_FLAGS="$NPF_FLAGS --variables MODEL=CX4 DUTSOCKET=1"
    NICNAME="Mellanox Connect-X 4"
    T1=0
fi

#CX6
if [ ${NICABR} = "bf1" ] ; then
    NPF_CLUSTER="client=nslrack11-100G,nic=1 dut=nslrack14-100G,nic=4"
    NPF_FLAGS="$NPF_FLAGS --variables MODEL=CBF DUTSOCKET=1 NICBENCH_PATH=/home/tom/workspace-cascade/nicbench/"
    NICNAME="Mellanox BlueField"
    T1=0
else
    NPF_FLAGS="$NPF_FLAGS --variables  NICBENCH_PATH=/home/tom/workspace/nicbench/"
fi
