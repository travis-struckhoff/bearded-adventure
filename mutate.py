import sys, getopt

labels = set()

class Instruction:
	def __init__(self, dest, first, second):
		self.dest = dest
		self.first = first
		self.second = second

	def __repr__(self):
		return '{}: {}, {}, {}'.format(self.__class__.__name__,self.dest,self.first,self.second)

class Add_Inst(Instruction):
	def __repr__(self):
		return '\tadd\t{},\t{},\t{}'.format(self.dest,self.first,self.second)

	def value(self):
		return self.first + self.second

class Sub_Inst(Instruction):
	def __repr__(self):
		return '\tadd\t{},\t{},\t{}'.format(self.dest,self.first,self.second)

	def value(self):
		return self.first - self.second

def parse_line(line):
	items = line.split()
	if items[0][-1] == ':':
		labels.add(items[0][:-1])

def mutate_line(line):
	return '{}\n{}\n'.format(line,line)

def main(argv):
	if len(argv) == 2:
		filename = argv[0]
		output = argv[1]
	else:
		print("mutate.py <inputfile> <output>")
		sys.exit(1)

	with open(filename, 'r') as f:
		with open(output, 'w') as out:
			for line in f:
				if line not in '\n':
					parse_line(mutate_line(line.strip()))
				out.write(mutate_line(line.strip()))

	print(labels)

if __name__ == '__main__':
	main(sys.argv[1:])