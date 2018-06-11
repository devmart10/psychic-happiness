#include <string>
#include <chrono>
#include <Windows.h>
#include <iostream>
#include <fstream>
#include <nlohmann\json.hpp>

#include "genetic_settings.hxx"
#include "Genome.hxx"
#include "Neuron.hxx"
#include "Gene.hxx"
#include "Pool.hxx"

#include "GeneticJSON.hxx"

using namespace std;

void neuronToJson(nlohmann::json &myJson, int id, Neuron *neuron, vector<Gene *> genes);
void geneToJson(nlohmann::json &myJson, Gene *gene, int id);

GeneticJSON::GeneticJSON(Pool *_pool) :
	pool(_pool)
{
	auto curDate = chrono::system_clock::to_time_t(chrono::system_clock::now());
	auto timeInfo = localtime(&curDate);
	char buffer[100];

	snprintf(buffer, sizeof(buffer), "%d_%d_%02d-%02d-%d_%02d-%02d-%02d",
		GENETIC_MAJOR_VERSION,
		GENETIC_MINOR_VERSION,
		timeInfo->tm_mon,
		timeInfo->tm_mday,
		timeInfo->tm_year + 1900,
		timeInfo->tm_hour,
		timeInfo->tm_min,
		timeInfo->tm_sec
	);

	runId = string(buffer);

	if (CreateDirectory("../../../runs", NULL) || ERROR_ALREADY_EXISTS == GetLastError())
	{
		if (CreateDirectory(("../../../runs/" + runId).c_str(), NULL) || ERROR_ALREADY_EXISTS == GetLastError())
		{
			exportPossible = true;
			printf("Run %s\n", runId);
		}
		else
		{
			exportPossible = false;
			printf("Creating directory failed... Ignoring future JSON calls...\n");
		}
	}
	else
	{
		exportPossible = false;
		printf("Creating directory failed... Ignoring future JSON calls...\n");
	}
}

void GeneticJSON::exportGenome(int generationId, int speciesId, int genomeId, Genome *genome) {
	if (exportPossible) {
		string generationDirectory = "../../../runs/" + runId + "/Generation_" + to_string(generationId);
		string speciesDirectory = generationDirectory + "/Species_" + to_string(speciesId);

		CreateDirectory(generationDirectory.c_str(), NULL);
		CreateDirectory(speciesDirectory.c_str(), NULL);

		ofstream outfile(speciesDirectory + "/Genome_" + to_string(genomeId));
		nlohmann::json myJson;

		myJson["fitness"] = genome->fitness;
		myJson["maxNeuron"] = genome->maxNeuron;
		myJson["globalRank"] = genome->globalRank;
		myJson["innovation"] = genome->innovation;

		int i = 0;
		for (Gene *gene : genome->genes) {
			geneToJson(myJson, gene, i++);
		}

		for (pair<int, Neuron *> p : genome->network) {
			neuronToJson(myJson, p.first, p.second, genome->genes);
		}

		for (pair<string, double> p : genome->mutationRates) {
			myJson["mutationRates"][p.first] = p.second;
		}

		myJson >> outfile;

		outfile.close();
	}
}

void geneToJson(nlohmann::json &myJson, Gene *gene, int id) {
	myJson["genes"][id]["into"] = gene->into;
	myJson["genes"][id]["out"] = gene->out;
	myJson["genes"][id]["weight"] = gene->weight;
	myJson["genes"][id]["enabled"] = gene->enabled;
	myJson["genes"][id]["innovation"] = gene->innovation;
}

void neuronToJson(nlohmann::json &myJson, int id, Neuron *neuron, vector<Gene *> genes) {
	myJson["network"][to_string(id)]["value"] = neuron->value;

	int i = 0;
	for (Gene *gene : neuron->incoming) {
		ptrdiff_t idx = find(genes.begin(), genes.end(), gene) - genes.begin();

		if (idx >= genes.size()) {
			printf("Couldn't find gene...\n");
		}
		else {
			myJson["network"][to_string(id)]["incoming"] += idx;
		}
	}
}

/*
Genome *GeneticJSON::importGenome(string path) {
	Genome *genome = new Genome(pool);
	std::ifstream infile(path);
	nlohmann::json myJson;

	infile >> myJson;

	genome->fitness = myJson["fitness"];
	genome->maxNeuron = myJson["maxNeuron"];
	genome->globalRank = myJson["globalRank"];
	genome->innovation = myJson["innovation"];

	for (nlohmann::json::iterator it = myJson["genes"].begin(); it != myJson["genes"].end(); ++it) {
		genome->genes.push_back(geneFromJson(*it));
	}

	return genome;
}

Gene *geneFromJson(nlohmann::json myJson) {
	Gene *gene = new Gene();

	gene->into = myJson["into"];
	gene->out = myJson["out"];
	gene->weight = myJson["weight"];
	gene->enabled = myJson["enabled"];
	gene->innovation = myJson["innovation"];

	return gene;
}

Neuron *neuronFromJson(nlohmann::json myJson) {
	Neuron *neuron = new Neuron();

	neuron->value = myJson["value"];

	for (nlohmann::json::iterator it = myJson["incoming"].begin(); it != myJson["incoming"].end(); ++it) {

	}

	return neuron;
}
*/