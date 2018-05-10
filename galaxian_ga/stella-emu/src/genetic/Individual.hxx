#ifndef INDIVIDUAL_HXX
#define INDIVIDUAL_HXX

#include <memory>

#include "GalaxianGameState.hxx"

class GalaxianGameState;

class Individual {
public:
	Individual(int id);
	~Individual();

	int getDirection();
	void tick(GalaxianGameState *gs);

	const int &id;
	const int &fitness;

private:
	int myIndividualId;
	int myFitness;
	double* dna;
};

#endif