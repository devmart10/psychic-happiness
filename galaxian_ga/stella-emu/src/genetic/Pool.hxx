#pragma once

class Genome;
class Species;

#include <vector>

class Pool {

public:
	Pool();
	~Pool();

	void initializeRun();
	void createNewGeneration();

	void cullSpecies(bool cutToOne);
	void addToSpecies(Genome *genome);
	void removeStaleSpecies();
	void removeWeakSpecies();

	int newInnovaation();
	void rankGlobally();
	double totalAverageFitness();
	void nextGenome();
	bool fitnessAlreadyMeasured();

	std::vector<Species *> species;
	int generation;
	int innovation;
	int currentSpecies;
	int currentGenome;
	double maxFitness;

private:

};