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
	generationCount = 0;
	currentGeneration = new Generation(generationCount);

	startSession();
}

void GalaxianGeneticAlgorithm::startSession()
{
	cout << "starting: gen " << generationCount << ", " << currentGeneration->populationIndex << endl;
	currentPlayer = currentGeneration->getCurrentPlayer();
}

void GalaxianGeneticAlgorithm::finishSession()
{
	printf("Individual %d fitness: %d\n", currentPlayer->id, currentPlayer->fitness);
	currentPlayer = currentGeneration->getNextPlayer();
	if (currentPlayer == nullptr) {
		int temp = currentGeneration->id;
		currentGeneration = currentGeneration->spawnNextGeneration();
		printf("Ending generation %d. Created generation %d.\n", temp, currentGeneration->id);
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

int GalaxianGeneticAlgorithm::getDirection() {
	return currentPlayer->getDirection();
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

void GalaxianGeneticAlgorithm::tick() {
	currentPlayer->tick(myGalaxianGameState);
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