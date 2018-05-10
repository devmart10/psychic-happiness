#include <iostream>
#include <Windows.h>

#include "Generation.hxx"

using namespace std;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Generation::Generation(int genId) :
	myGenerationId(genId),
	id(myGenerationId)
{
	populationIndex = 0;
	for (int i = 0; i < POPULATION_SIZE; i++) {
		population.push_back(new Individual(i));
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Generation::~Generation()
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Generation *Generation::spawnNextGeneration()
{
	populationIndex = 0;
	return new Generation(myGenerationId + 1);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Individual *Generation::getCurrentPlayer()
{
	return population.at(populationIndex);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Individual *Generation::getNextPlayer()
{
	if (++populationIndex == population.size()) {
		return nullptr;
	}
	return population.at(populationIndex);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -