#pragma once

class Gene;
class Genome;
class Species;
class Pool;

class GeneticJSON {
public:
	GeneticJSON(Pool *);

	void exportGenome(int generationId, int speciesId, int genomeId, Genome *genome);
	Genome *importGenome(std::string path);

private:
	std::string runId;
	bool exportPossible;
	Pool *pool;

};