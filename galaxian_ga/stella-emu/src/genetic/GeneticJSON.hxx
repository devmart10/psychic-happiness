#pragma once

#include <map>
#include "Neuron.hxx"
#include <nlohmann\json.hpp>
#include <vector>

class Gene;
class Genome;
class Species;
class Pool;

class GeneticJSON {
public:
	GeneticJSON(Pool *);

	void exportGenome(int generationId, int speciesId, int genomeId, Genome *genome);
	Genome *importGenome();
	std::map<int, Neuron *> neuronsFromJson(nlohmann::json myJson, std::vector<Gene *> genes);
	Gene *geneFromJson(nlohmann::json myJson);


private:
	std::string runId;
	bool exportPossible;
	Pool *pool;

};