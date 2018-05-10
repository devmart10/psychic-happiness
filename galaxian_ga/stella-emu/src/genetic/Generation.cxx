#include <iostream>
#include <Windows.h>

#include "Generation.hxx"

using namespace std;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Generation::Generation()
{

	populationIndex = 0;
	for (int i = 0; i < POPULATION_SIZE; i++) {
		population.push_back(new Individual());
	}
}

Generation::~Generation()
{
}

Generation * Generation::createNewGeneration()
{
	populationIndex = 0;
	return new Generation();
}

Individual * Generation::getCurrentPlayer()
{
	return population.at(populationIndex);
}

Individual * Generation::getNextPlayer()
{
	if (++populationIndex == population.size()) {
		return nullptr;
	}
	return population.at(populationIndex);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -