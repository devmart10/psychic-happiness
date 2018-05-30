#ifndef GENOME_HXX
#define GENOME_HXX

#include <vector>
#include <map>

#ifndef JSON_INCLUDE
#define JSON_INCLUDE
#include <nlohmann\json.hpp>
#endif

class GalaxianGameState;
class Gene;
class Neuron;
class Pool;
class json;

class Genome {
public:
	Genome(Pool *);
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
	int innovation;
	std::map<int, Neuron *> network;
	int maxNeuron;
	int globalRank;
	std::map<std::string, double> mutationRates;

private:
	Pool *pool;
};

#endif