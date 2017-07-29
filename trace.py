import sys

class l_trace:
	def __init__(self, depth = 0):
		self.depth = depth

	def __call__(self, frame, event, arg):
		print("l_trace", self.depth, frame.f_lineno, event, arg)
		return l_trace(self.depth + 1)

def g_trace(frame, event, arg):
	print("g_trace", frame.f_lineno, event, arg)
	return l_trace()

sys.settrace(g_trace)

def fib(n):
	print("func call:", n)
	if n <= 1:
		return 1
	return fib(n - 1) + fib(n - 2)

fib(3)
