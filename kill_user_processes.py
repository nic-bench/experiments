#!/usr/bin/python3

# Kill  a process which parent was a given process of a given user
# e.g. kill all the click processes of user bob

import psutil
import argparse


parser = argparse.ArgumentParser(description = "Killall but filtering for a user anchestor")
parser.add_argument("--process", dest="process", default="click")
parser.add_argument("--user", dest="user", required=True)
parser.add_argument("--max_depth", dest="max_depth", default=10)
parser.add_argument("--signal", dest="signal", default=9)

args = parser.parse_args()

tokill = args.process
user = args.user
max_depth = args.max_depth
signal = args.signal
depth = 0

for proc in psutil.process_iter():
    try:
        if proc.name() == tokill:
            parent = proc
            # Check the processes three until we reach a limit or we found a process of the giveb user
            while depth < max_depth and parent.username() != user:
                parent = psutil.Process(parent.ppid())
                depth+=1
                print("-"*depth, parent.name(), parent.pid, parent.username())
            if depth == max_depth:
                print("Process not found!")
            else:
                print("Found a target process:", parent.name(), "(", parent.pid,")")
                print("Sending signal", signal, "to process", proc.name(), "(", proc.pid, ")")
                proc.send_signal(signal)
    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        print("Not found?")
        pass
