#ifndef INDIVIDUAL_HXX
#define INDIVIDUAL_HXX

#include <memory>

#include "GalaxianGameState.hxx"

class GalaxianGameState;

class Individual {
public:
	Individual();
	~Individual();
	int getDirection();
	void calcFitness();
	double getFitness();
	void tick(GalaxianGameState* gs);
private:
	double fitness;
	double* dna;
};

#endif