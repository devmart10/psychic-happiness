#include <iostream>
#include <Windows.h>
#include <memory>

#include "Individual.hxx"

using namespace std;

Individual::Individual()
	: fitness(0)
{
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

void Individual::calculateFitness(GalaxianGameState *gs)
{
	fitness = gs->getPlayerScore();
}

double Individual::getFitness()
{
	return fitness;
}

void Individual::tick(GalaxianGameState* gs)
{
	calculateFitness(gs);
}