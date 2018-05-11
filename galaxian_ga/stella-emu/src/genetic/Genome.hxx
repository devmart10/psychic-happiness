#ifndef GENOME_HXX
#define GENOME_HXX

#include <memory>
#include <vector>
#include <map>

#include "GalaxianGameState.hxx"

class GalaxianGameState;
class Gene;
class Neuron;

class Genome {
public:
	Genome();
	Genome(const Genome &oldObj);
	~Genome();

	void initBasicGenome();
	void generateNetwork();

	std::map<int, bool> evaluateNetwork(std::vector<double> inputs);

	void mutate();
	void pointMutate();
	void linkMutate(bool);
	void nodeMutate();
	void enableDisableMutate(bool);

	std::vector<Gene *> genes;
	double fitness;
	double adjustedFitness;
	int innovation;
	std::map<int, Neuron *> network;
	int maxNeuron;
	int globalRank;
	std::map<std::string, double> mutationRates;

private:
};

#endif