#!/usr/bin/env python3
import random
import socket
import struct
import sys
import argparse
import time
import math

parser = argparse.ArgumentParser()
parser.add_argument("n", type=int)
parser.add_argument("pc", type=float)
parser.add_argument("--seed", default=None, type=int)
parser.add_argument("--no-ports", dest="ports", action="store_false", default=True,
                            help="Do not do ports")
parser.add_argument("--no-priority", dest="priority", action="store_false", default=True,
                            help="Do not use priority")
parser.add_argument("--flows", dest="nflows", type=int, nargs=1, default=None,
                            help="Number of flows")
parser.add_argument("--burst", dest="burst", type=int, default=1,
                            help="Number of packets per burst")
parser.add_argument("--output", dest="output", default="ip.dump",
                            help="Output file")
parser.add_argument("--rules-output", dest="rulesoutput", default="ip.flows",
                            help="Output file for the rules")
parser.add_argument("--format", dest="format", type=str,
                            help="Select from [text,binary,mindump]")
parser.add_argument("--length", dest="length", default=1486, type=int,
                            help="Packet length")
parser.add_argument("--table", dest="table", default=1, type=int,
                            help="Table")
parser.add_argument("--no-rules", dest="norules", action="store_true",
                            help="Disable rules generation")
parser.add_argument("--min-packets", dest="minpackets", type=int,
                            default=65535)
args = parser.parse_args()
def ip2int(addr):
        return struct.unpack("!I", socket.inet_aton(addr))[0]
do_ports=args.ports
priority = args.priority
output = args.output
format = args.format
length = args.length
burst = args.burst
norules = args.norules
rulesoutput = args.rulesoutput
table = args.table
minpackets=args.minpackets

n = int(args.n)

nflows = args.nflows
if nflows is None or len(nflows) == 0:
    nflows = [n]
nflows = nflows[0]
pc = float(args.pc) * float(nflows)
flows = set()
tot = max(n,nflows) * 2
sport = True
sprefix = 0
smask = 0
dprefix = ip2int("192.168.0.0")
dmask = ip2int("255.255.0.0")
random.seed(args.seed if args.seed else time.time())

fdump = open(output, "wb")
if format == "mindump":
    fdump.write("!MINDUMP0.1\n".encode("latin1"))
    fdump.write("!data\n".encode("latin1"))
else:
    fdump.write("!IPSummaryDump 1.3\n".encode("latin1"))
    fdump.write("!data len ip_src ip_dst sport dport ip_proto\n".encode("latin1"))
    if format == "binary":
        fdump.write("!binary\n".encode("latin1"))

while tot > 0:
    src = (random.randint(1, 0xfffffffe) & ~smask) | sprefix
    dst = (random.randint(1, 0xfffffffe) & ~dmask) | dprefix
    sport = random.randint(1,65535)
    dport = random.randint(1,65535)
    tup = tuple([src,dst,sport,dport])
    if tup in flows:
        continue
    else:
        flows.add(tup)
        tot = tot - 1
flows= list(flows)
def sip(n):
    return str(socket.inet_ntoa(struct.pack('>I', n)))

if not norules:
    fflows = open( rulesoutput, "w")
    if table > 0:
        fflows.write("flow create 0 group 0 ingress pattern eth / end actions jump group 1 / end\n")
        tables = range(1,table +1)
    else:
        tables = [0]

    nft = int(n / len(tables))
    for it,t in enumerate(tables):

        fflows.write("flow create 0 group " +str(t)+ " " + ("priority 2 " if priority else "" )+ " ingress pattern eth / ipv4 dst spec "+sip(dprefix)+" dst mask "+sip(dmask)+" / end actions "+ ("queue index 0" if it == len(tables) - 1 else ("jump group "+str(t+1))  ) + " / end\n")
        for i in range(it*nft,(it+1)*nft):
            tup = flows[i]
            src = socket.inet_ntoa(struct.pack('>I', tup[0]))
            dst = socket.inet_ntoa(struct.pack('>I', tup[1]))
            if do_ports:
                sport = tup[2]
                dport = tup[3]
                fflows.write("flow create 0 group "+str(t)+" " + ("priority 1" if priority else "") + " ingress pattern ipv4 src is %s dst is %s / tcp src is %d dst is %d / end actions queue index 1 / end\n" % (src,dst,sport,dport))
            else:
                fflows.write("flow create 0 group "+str(t)+" " + ("priority 1" if priority else "") + " ingress pattern ipv4 src is %s dst is %s / end actions queue index 1 / end\n" % (src,dst))
    fflows.close()

nmatch = 0
count = 0
flows = list(flows)
nrepeat = max(1,math.ceil( minpackets / nflows / burst))
for j in range(nrepeat):
    for i in range(nflows):
        if i < pc:
            tup = flows[i]
            nmatch+=1
        else:
            tup = flows[n+i]

        for b in range(burst):
            if format == "mindump":
                fdump.write(struct.pack(">IIHH",*tup))
                fdump.write(struct.pack("<HB",length, 6))
            else:
                if format == "binary":
                    if do_ports:
                        fdump.write(struct.pack(">IIIIHHB",21,length,*tup,6))
                    else:
                        fdump.write(struct.pack(">IIIIB",17,length,*(tup[0:2]),6))
                else:
                    src = socket.inet_ntoa(struct.pack('>I', tup[0]))
                    dst = socket.inet_ntoa(struct.pack('>I', tup[1]))
                    if do_ports:
                        tupa=[length,tup[0],src,dst,*tup[2:2],6]
                    else:
                        tupa=[length,tup[0],src,dst,6]
                    fdump.write((" ".join([str(a) for a in tupa]) + "\n").encode("latin1"))
            count+=1

fdump.close()

print("Generated %d flows (repeated %d times). Total %i packets" %(nflows, nrepeat, count))
if not norules:
    print("Generated %d rules, %d flows matching" % (n, nmatch / nrepeat))
