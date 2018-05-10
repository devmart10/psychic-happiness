#include <iostream>
#include <Windows.h>
#include <memory>

#include "Individual.hxx"

using namespace std;

Individual::Individual(int id)
	: myFitness(0),
	fitness(myFitness),
	myIndividualId(id),
	id(myIndividualId)
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

void Individual::tick(GalaxianGameState* gs)
{
	myFitness = gs->getPlayerScore();
}