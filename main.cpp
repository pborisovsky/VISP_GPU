#include <stdio.h>
#include "Binary_operations.h"
#include <stdlib.h>
#include <fstream>
#include <iomanip>
using namespace std;


int solve(int n, int **matr);

int rand_num(int n)	// returns a random value 0..n-1
{
	if(n == 0) 
		return 0;
		
	return (int)((float)rand()/((float)RAND_MAX+0.1)*(float)n);
}

double rand_double()	// returns a random value 0..n-1
{
	return (double)rand()/((double)RAND_MAX+0.1);
}


double cost(int n, int **matr, double *w, int sol)
{
	int c = 0;
	for(int i=0; i<n; i++)
	{
		if(GetBit(sol,i))
		{
			c++;
			for(int j=0; j<i; j++)
			{
				if(GetBit(sol,j))
				{
					if(matr[i][j])
						return -1;
				}
			
			}
		}		
	}
	return c;
}

void rand_matr(int n, int **matr)
{
	int i,j;
	for(i=0; i<n; i++)
	{
		for(j=0; j<i; j++)
		{
			matr[i][j] = 0;
			if(rand_num(10)==0)
			   matr[i][j] = 1;
			matr[j][i] = matr[i][j];
		}
		
	}
}


void save_matr(int n, int **matr, double *w)
{
	ofstream of("matr.txt");
	of << n << endl;
	
	int i,j;
	for(i=0; i<n; i++)
	{
		for(j=0; j<n; j++)
		{
			of<<matr[i][j]<<" ";
		}
		of<<endl;
	}
	of<<endl;
	for(i=0; i<n; i++)
	{
		of<<std::fixed << std::setprecision(8)<<w[i]<<" ";
	}
	of<<endl;
	of.close();
}



void rand_w(int n, double *w)
{
	int i,j;
	for(i=0; i<n; i++)
	{		
		w[i] = rand_double() * 1000.0;
	}
}




int main(int argc, char **argv)
{
	
	int n = 25;
	int i,j;
	int **matr = new int*[n];
	for(i=0; i<n; i++)
	{
		matr[i] = new int[n];
	}
	double *w=new double[n];
	rand_w(n,w);
	
	rand_matr(n, matr);
	save_matr(n, matr, w);
	
	int N = 1<<n;
	printf("Number of all binary vectors is %i\n", N);
	
	/* // CPU code
	int sol;
	int max_cost=0;
	for(sol=0; sol<N; sol++)
	{
		if(sol%10000000 == 0)
			printf("%i\n", sol);
		int c = cost(n,matr,0,sol);
		if(c > max_cost)
			max_cost = c;
	}
	
	printf("Opt = %i", max_cost);
	 */
	 
	int opt = solve(n, matr);
	printf("opt = %i\n", opt);
	
	return 0;
}
