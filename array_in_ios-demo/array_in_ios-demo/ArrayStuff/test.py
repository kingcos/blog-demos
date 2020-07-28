#!/usr/bin/python
from __future__ import division
import commands
import re

def run(cmd):
	return commands.getoutput(cmd)

run("./build.sh")

results = {} # command -> task -> list of times
order = {}
sizes = range(100000, 1100000, 100000)
for cmd in ["naivearray", "vectorarray", "cfarray"]:
	results[cmd] = {}
	for size in sizes:
		result = run("./" + cmd + " " + str(size))
		command_number = 0
		for line in result.split("\n"):
			items = line.strip().split(": ", 2)
			if len(items) == 2:
				key, val = items
				val = float(val.split(" ")[0])
				if not results[cmd].has_key(key):
					results[cmd][key] = []
				else:
					val = val / results[cmd][key][0]
				results[cmd][key].append(val)
				order[key] = command_number
				command_number = command_number + 1

def order_compare(x, y):
	return order[x] - order[y]

for command in ["naivearray", "vectorarray", "cfarray"]:
	print "\n" + command + "\n"
	print ",".join([""] + [str(x) for x in sizes])
	tasks = order.keys()
	tasks.sort(order_compare)
	for task in tasks:
		print ",".join([task] + [str(x) for x in results[command][task]])

