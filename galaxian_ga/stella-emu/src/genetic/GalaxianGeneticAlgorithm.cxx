//============================================================================
//
//   SSSS                        PPPPP
//  SS  SS                       PP  PP                        jj
//  SS       eeee  nn nn         PP   PP rr rrr    oooo
//   SSSS   ee  ee nnn  nn       PPPPPP  rrrr rr  oo  oo       jj
//      SS  eeeeee nn   nn       PP      rr      oo    oo      jj
//  SS  SS  ee     nn   nn ...   PP      rr       oo  oo       jj
//   SSSS    eeeee nn   nn ...   PP      rr        oooo   jj   jj
//                                                        jjjjj
//
// Senior Project Genetic Algorithm of Cole Twitchell and Devon Martin
// Cal Poly, San Luis Obispo 2018
//
// For more information, questions, or inqueries, contact colemtwitchell@gmail.com.
//============================================================================

#include <iostream>
#include <Windows.h>
#include <memory>

#include "bspf.hxx"
#include "Pool.hxx"
#include "Species.hxx"
#include "Genome.hxx"
#include "Console.hxx"

#include "EventHandler.hxx"
#include "OSystem.hxx"
#include "genetic_settings.hxx"
#include "GalaxianGameState.hxx"

#include "GalaxianGeneticAlgorithm.hxx"

using namespace std;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GalaxianGeneticAlgorithm::GalaxianGeneticAlgorithm(GalaxianGameState* gs)
	: myGalaxianGameState(gs)
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GalaxianGeneticAlgorithm::~GalaxianGeneticAlgorithm() {
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGeneticAlgorithm::initializeAlgorithm() {
	myPool = new Pool();

	myPool->initializeRun();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

map<int, bool> GalaxianGeneticAlgorithm::evaluate() {
	Species *currentSpecies = myPool->species[myPool->currentSpecies];
	Genome *currentGenome = currentSpecies->genomes[myPool->currentGenome];

	vector<double> inputs = myGalaxianGameState->getInputs();
	map<int, bool> outputs = currentGenome->evaluateNetwork(inputs);

	sessionTimeFitness += 0.5;
	int currentScore = myGalaxianGameState->getPlayerScore();
	if (currentScore != scoreHolder) {
		scoreHolder = currentScore;
		framesSinceLastKill = 0;
	}

	if (framesSinceLastKill++ > 60) {
		if (!(GetKeyState(VK_CAPITAL) & 0x1) && currentScore < 500)
			myGalaxianGameState->killPlayer();
	}

	if (outputs[BUTTON_LEFT] && outputs[BUTTON_RIGHT]) {
		outputs[BUTTON_LEFT] = outputs[BUTTON_RIGHT] = false;
	}

	return outputs;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGeneticAlgorithm::startSession()
{
	myPool->initializeRun();

	sessionTimeFitness = 0;
	scoreHolder = 0;
	framesSinceLastKill = 0;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGeneticAlgorithm::finishSession()
{
	Species *curSpecies = myPool->species[myPool->currentSpecies];
	Genome *curGenome = curSpecies->genomes[myPool->currentGenome];
	curGenome->fitness = myGalaxianGameState->getPlayerScore() + sessionTimeFitness;
	printf("  Species %d, Genome %d fitness: %d\n", 
		myPool->currentSpecies, myPool->currentGenome, (int)curGenome->fitness);

	myPool->nextGenome();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGeneticAlgorithm::loadSession() {
	myPool->loadRun();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool GalaxianGeneticAlgorithm::isRShiftKeyDown() {
	static bool pressedLastFrame = false;

	if (GetKeyState(VK_RSHIFT) & 0x8000) {
		if (pressedLastFrame) {
			return false;
		}
		else {
			pressedLastFrame = true;

			return true;
		}
	}
	else {
		pressedLastFrame = false;
	}

	return false;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool GalaxianGeneticAlgorithm::isResetKeyDown() {
	static bool pressedLastFrame = false;

	if (GetKeyState('R') & 0x8000) {
		if (pressedLastFrame) {
			return false;
		}
		else {
			pressedLastFrame = true;

			return true;
		}
	}
	else {
		pressedLastFrame = false;
	}

	return false;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool GalaxianGeneticAlgorithm::isLoadKeyDown() {
	static bool pressedLastFrame = false;

	if (GetKeyState('P') & 0x8000) {
		if (pressedLastFrame) {
			return false;
		}
		else {
			pressedLastFrame = true;

			return true;
		}
	}
	else {
		pressedLastFrame = false;
	}

	return false;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -