#include <iostream>
#include <Windows.h>

#include "Generation.hxx"

using namespace std;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Generation::Generation(int genId) :
	myGenerationId(genId),
	id(myGenerationId)
{
	for (int i = 0; i < POPULATION_SIZE; i++) {
		population.push_back(new Individual(i));
	}

	popItr = population.begin();
	currentPlayer = *popItr;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Generation::~Generation()
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Generation *Generation::spawnNextGeneration()
{
	// perform crossover and mutations here

	return new Generation(myGenerationId + 1);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Individual *Generation::getNextPlayer()
{
	popItr = next(popItr);

	currentPlayer = (popItr == population.end() ? nullptr : *popItr);

	return currentPlayer;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -