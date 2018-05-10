#include <iostream>
#include <Windows.h>
#include <memory>

#include "Individual.hxx"

using namespace std;

Individual::Individual()
{
	// dna = double[10];
	calcFitness();
}

Individual::~Individual()
{
}

int Individual::getDirection()
{
	int dir = 0 + (rand() % 4);
	cout << dir << endl;
	return dir;
}

void Individual::calcFitness()
{
	fitness = 0.0;
}

double Individual::getFitness()
{
	return fitness;
}

void Individual::tick(GalaxianGameState* gs)
{
	//cout << "ticking" << endl;
}