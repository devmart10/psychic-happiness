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

#include "Console.hxx"
#include "bspf.hxx"
#include "GalaxianGeneticAlgorithm.hxx"

using namespace std;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

<<<<<<< HEAD
GalaxianGeneticAlgorithm::GalaxianGeneticAlgorithm() { }
=======
GalaxianGeneticAlgorithm::GalaxianGeneticAlgorithm(OSystem& sys, GalaxianGameState* gs)
	: osys(sys), myState(gs)
{
}
>>>>>>> 2ecff67b40f262560b4e45a5844f8c13924840e6

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GalaxianGeneticAlgorithm::~GalaxianGeneticAlgorithm() {
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGeneticAlgorithm::initializeAlgorithm() {
<<<<<<< HEAD
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGeneticAlgorithm::setConsole(Console *console) {
	myConsole = console;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

int GalaxianGeneticAlgorithm::getPlayerScore() {
	int tens = myConsole->retreivePartialByte(0xAE, 4, 0);
	int hundreds = myConsole->retreivePartialByte(0xAD, 4, 4);
	int thousands = myConsole->retreivePartialByte(0xAD, 4, 0);
	int ten_thousands = myConsole->retreivePartialByte(0xAC, 4, 4);
	int hun_thousands = myConsole->retreivePartialByte(0xAC, 4, 0);

	return tens * 10 + hundreds * 100 + thousands * 1000 + 
		   ten_thousands * 10000 + hun_thousands * 100000;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool GalaxianGeneticAlgorithm::isPlayerDead() {
	return myConsole->retreiveByte(0xB2) != 0;
=======
	cout << "initializing genetic algorithm" << endl;

	generationCount = 0;
	currentGeneration = new Generation();
}

void GalaxianGeneticAlgorithm::startSession()
{
	cout << "starting: gen " << generationCount << ", " << currentGeneration->populationIndex << endl;
	currentPlayer = currentGeneration->getCurrentPlayer();
}

void GalaxianGeneticAlgorithm::finishSession()
{
	cout << "final fitness: " << currentPlayer->getFitness() << endl;
	currentPlayer = currentGeneration->getNextPlayer();
	if (currentPlayer == nullptr) {
		cout << "ending generation " << generationCount++ << endl;
		currentGeneration = currentGeneration->createNewGeneration();
		cout << "created generation " << generationCount << endl;
	}
>>>>>>> 2ecff67b40f262560b4e45a5844f8c13924840e6
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

<<<<<<< HEAD
int GalaxianGeneticAlgorithm::getPlayerPosition() {
	return myConsole->retreiveByte(0xE4);
=======
int GalaxianGeneticAlgorithm::getDirection() {
	return currentPlayer->getDirection();
>>>>>>> 2ecff67b40f262560b4e45a5844f8c13924840e6
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

void GalaxianGeneticAlgorithm::tick()
{
	currentPlayer->tick(myState);
}
