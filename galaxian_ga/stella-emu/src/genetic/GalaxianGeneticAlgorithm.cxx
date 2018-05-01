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

#include "GalaxianGeneticAlgorithm.hxx"

using namespace std;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GalaxianGeneticAlgorithm::GalaxianGeneticAlgorithm()
{

}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GalaxianGeneticAlgorithm::~GalaxianGeneticAlgorithm() {
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGeneticAlgorithm::initializeAlgorithm() {

}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGeneticAlgorithm::printTickMessage() {
	cout << "Tick message." << endl;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool GalaxianGeneticAlgorithm::isMemDumpKeyDown() {
	static bool pressedLastFrame = false;

	if (GetKeyState('A') & 0x8000) {
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