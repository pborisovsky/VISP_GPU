#include <cuda.h>
#include <stdio.h>
#include "Binary_operations.h"


__global__ void kernelEnumerate(int n, int *matr, int *sols, int start_sol)
{
    int blockId = blockIdx.x * gridDim.y + blockIdx.y;
    int idx = blockId * blockDim.x  +  threadIdx.x;
	int sol = idx + start_sol;
	
	int c = 0;
	for(int i=0; i<n; i++)
	{
		if(GetBit(sol,i))
		{	c++;
			for(int j=0; j<i; j++)
			{
				if(GetBit(sol,j))
				{
					if(matr[i*n + j])
					{
					    sols[idx] = -1;
						return ;
					}
				}			
			}
		}		
	}	
	sols[idx] = c;
}



// find maximal element in a small part of the array
__global__ void kernelFindMax(int part, int* sols, int* devMaxArray, int* devMaxindArray)
{
    int blockId = blockIdx.x;
    int id = blockId * blockDim.x  +  threadIdx.x;
	
	int max=0, imax;
	
	for(int i=0; i<part; i++)
	{
	   if(sols[i + part*id] > max)
	   {
	      max = sols[i + part*id];
	      imax = i + part*id;
	   }
	}
	devMaxArray[id] = max;
	devMaxindArray[id] = imax;
}



void findMax(int n, int *maxArray, int *maxIndArray, int &max, int &maxind)
{
   int i;
   max=0;
   for(int i=0;i<n;i++)
   {
      if(maxArray[i] > max)
      {
         max = maxArray[i];
         maxind = maxIndArray[i];
      }
   }
}



int solve(int n, int **matr)
{

    int N = 1<<n;
    int i,j,k;
   
    int *matr1 = new int [n*n];
    k=0;
    for(i = 0; i < n; i++) {
        for(j = 0; j < n; j++) {
            matr1[k] = matr[i][j];
            k++;
        }
    }
    int *devMatr;
    cudaMalloc((void**)&devMatr, n * n * sizeof(int) );
    cudaMemcpy(devMatr,    matr1,   n * n * sizeof(int), cudaMemcpyHostToDevice);

    int blocksX=128;
    int blocksY=128;
    int threadsX=32;
    int partSize = blocksX*blocksY*threadsX;

    int *devSols;
    cudaMalloc((void**)&devSols, partSize * sizeof(int) );

    int *sols = new int[partSize];
    for(i=0; i<partSize; i++)
       sols[i]=0;


    // define parts for the REDUCTION step for finding the maximal value in array
    int numSmallParts = 8*128;  //=1024
    int smallPartSize = partSize / numSmallParts; 

    int *devMaxArray, *devMaxIndArray;
    cudaMalloc((void**)&devMaxArray, numSmallParts * sizeof(int) );
    cudaMalloc((void**)&devMaxIndArray, numSmallParts * sizeof(int) );

    int *maxArray = new int[numSmallParts],
        *maxIndArray = new int[numSmallParts];


    int start_sol = 0, part = 0;
    int global_max = 0;
    do
    {
      dim3 blocks  = dim3(blocksX, blocksY);
      dim3 threads = dim3(threadsX);

      //enumerate all the solutions in the current part
      kernelEnumerate<<<blocks,threads>>>(n, devMatr, devSols, start_sol);
      start_sol += partSize;

      // reductio step: fird maximums in small portions of the array and store them in a new array
      blocks  = dim3(8);
      threads = dim3(128);
      kernelFindMax<<<blocks,threads>>>(smallPartSize, devSols, devMaxArray, devMaxIndArray);
      cudaMemcpy(maxArray, devMaxArray,  numSmallParts * sizeof(int), cudaMemcpyDeviceToHost);
      cudaMemcpy(maxIndArray, devMaxIndArray,  numSmallParts * sizeof(int), cudaMemcpyDeviceToHost);

      int max, maxind;
      // find maximal independent set in the curent part
      findMax(numSmallParts, maxArray, maxIndArray, max, maxind);
      printf("part = %i,  max=%i \n", part, max);
      part ++;
      if (global_max < max)
          global_max = max;

    } while(start_sol < N);

return global_max;
}

