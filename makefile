ind_set: main.o solver.o
	g++ -O3 -o ind_set main.o solver.o -L/usr/local/cuda/lib64 -lcudart

main.o: main.cpp
	g++ -c -o main.o main.cpp

solver.o: solver.cu
	nvcc -c -I. solver.cu -o solver.o
